from django.db import transaction
from django.db.models import F, Sum

from payments.models import Transaction, Wallet
from notifications.services import safe_send_notification
from .serializers import *
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Ride

class CreateRideView(APIView):

    def post(self, request):
        user = request.user

        if user.user_type != "driver":
            return Response(
                {"error": "Only drivers can create rides"},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = CreateRideSerializer(
            data=request.data,
            context={"driver": user.driver}
        )

        if serializer.is_valid():

            ride = serializer.save(driver=user.driver)

            return Response(
                CreateRideSerializer(ride).data,
                status=status.HTTP_201_CREATED
            )

        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )


class UpdateRideView(APIView):

    def patch(self, request, ride_id):
        user = request.user
        if user.user_type != "driver":
            return Response(
                {"error": "Only drivers can update rides"}, 
                status=status.HTTP_403_FORBIDDEN
            )
        try:
            ride = Ride.objects.get(id=ride_id, driver= user.driver)
        except Ride.DoesNotExist:
            return Response({"error": "Ride not found"}, status=status.HTTP_404_NOT_FOUND)

        if ride.status != Ride.RideStatus.ACTIVE:
            return Response({"error": "Only active rides can be updated"}, status=status.HTTP_400_BAD_REQUEST)

        if Reservation.objects.filter(ride=ride).exists():
            return Response(
                {"error": "Cannot update a ride that has reservations"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = UpdateRideSerializer(ride, data=request.data, partial=True)  
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CancelRideView(APIView):

    def delete(self, request, ride_id):
        user = request.user
        if user.user_type != "driver":
            return Response(
                {"error": "Only drivers can cancel rides"}, 
                status=status.HTTP_403_FORBIDDEN
            )
        try:
            ride = Ride.objects.get(id=ride_id, driver=request.user.driver)
        except Ride.DoesNotExist:
            return Response({"error": "Ride not found"}, status=status.HTTP_404_NOT_FOUND)

        if ride.status != Ride.RideStatus.ACTIVE:
            return Response({"error": "Only active rides can be cancelled"}, status=status.HTTP_400_BAD_REQUEST)

        ride.status = Ride.RideStatus.CANCELLED
        ride.save(update_fields=["status"])
        reservations= Reservation.objects.filter(
        ride=ride,
        status__in=[
            Reservation.ReservationStatus.PENDING,
            Reservation.ReservationStatus.ACCEPTED
        ]
        )
        for reservation in reservations:

            safe_send_notification(

                user=reservation.rider.user,

                title="Ride Cancelled",

                body=(
                    f"The ride from "
                    f"{reservation.ride.location} to "
                    f"{reservation.ride.destination} "
                    f"has been cancelled."
                ),

                data={
                    "type": "ride_cancelled",
                    "ride_id": str(reservation.ride.id),
                    "reservation_id": str(reservation.id),
                }
            )
        reservations.update(
            status=Reservation.ReservationStatus.CANCELLED
        )

        return Response({"message": "Ride cancelled successfully"}, status=status.HTTP_200_OK)

class CreateReservationView(APIView):

    def post(self, request):
        if not hasattr(request.user, 'rider'):
            return Response(
                {"error": "Only riders can create reservations."}, 
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = CreateReservationSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            reservation = serializer.save(rider=request.user.rider)

            driver_user = reservation.ride.driver.user

            safe_send_notification(
                user=driver_user,
                title="New Reservation",
                body=(
                    f"{reservation.rider.user.name} "
                    f"requested a reservation for your ride "
                    f"from {reservation.ride.location} "
                    f"to {reservation.ride.destination}."
                ),
                data={
                    "type": "new_reservation",
                    "reservation_id": str(reservation.id),
                    "ride_id": str(reservation.ride.id),
                }
)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class CancelReservationView(APIView):
    def post(self, request, reservation_id):
        user= request.user
        if user.user_type != "rider":
            return Response(
                {"error": "Only riders can canceled reservations"}, 
                status=status.HTTP_403_FORBIDDEN
            )
        try:
            reservation= Reservation.objects.get(id= reservation_id)
        except Reservation.DoesNotExist:
            return Response({"error": "Reservation not found"}, status= status.HTTP_404_NOT_FOUND)
        if reservation.rider.user != user:
            return Response(
                {"error": "You can only canceled your reservations"},
                status=status.HTTP_403_FORBIDDEN
            )
        if reservation.status in [

            Reservation.ReservationStatus.REJECTED,
            Reservation.ReservationStatus.CANCELLED
        ]:
            return Response({"error": "This reservation cannot be canceled"}, status=status.HTTP_400_BAD_REQUEST)
        reservation.status = Reservation.ReservationStatus.CANCELLED
        reservation.save()
        return Response(
            {"message": "Reservation canceled successfully"},
            status=status.HTTP_200_OK
        )

class AcceptReservationView(APIView):

    @transaction.atomic
    def post(self, request, reservation_id):

        user = request.user

        if user.user_type != "driver":
            return Response(
                {"error": "Only drivers can accept reservations"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        try:
            reservation = Reservation.objects.select_related(
                "ride__driver__user",
                "rider__user"
            ).get(id=reservation_id)

        except Reservation.DoesNotExist:
            return Response(
                {"error": "Reservation not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        if reservation.ride.driver.user != user:
            return Response(
                {"error": "You can only accept reservations for your rides"},
                status=status.HTTP_403_FORBIDDEN
            )

        if reservation.status != Reservation.ReservationStatus.PENDING:
            return Response(
                {"error": "Only pending reservations can be accepted"},
                status=status.HTTP_400_BAD_REQUEST
            )

        wallet = Wallet.objects.select_for_update().get(
            user=reservation.rider.user
        )

        if wallet.balance < reservation.ride.cost:
            return Response(
                {"error": "Insufficient balance."},
                status=status.HTTP_400_BAD_REQUEST
            )

        wallet.balance = F("balance") - reservation.ride.cost
        wallet.save()
        wallet.refresh_from_db()

        payment_transaction = Transaction.objects.create(
            wallet=wallet,
            reservation=reservation,
            amount=reservation.ride.cost,
            transaction_type=Transaction.TransactionType.PAYMENT
        )

        reservation.status = Reservation.ReservationStatus.ACCEPTED
        reservation.payment = Reservation.PaymentStatus.PAID
        reservation.save()

        safe_send_notification(
            user=reservation.rider.user,
            title="Reservation Accepted",
            body=(
                f"Your reservation for "
                f"{reservation.ride.location} to "
                f"{reservation.ride.destination} "
                f"has been accepted."
            ),
            data={
                "type": "reservation_accepted",
                "reservation_id": str(reservation.id),
                "ride_id": str(reservation.ride.id),
            }
        )

        return Response(
            {
                "message": "Reservation accepted and payment completed successfully.",
                "transaction_id": payment_transaction.id,
                "remaining_balance": wallet.balance
            },
            status=status.HTTP_200_OK
        )

class RejectReservationView(APIView):
    @transaction.atomic
    def post(self, request, reservation_id):
        user = request.user

        if user.user_type != "driver":
            return Response(
                {"error": "Only drivers can reject reservations"},
                status=status.HTTP_403_FORBIDDEN
            )

        try:
            reservation = Reservation.objects.select_related(
                "ride",
                "ride__driver",
                "rider__user"
            ).get(id=reservation_id)

        except Reservation.DoesNotExist:
            return Response(
                {"error": "Reservation not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        if reservation.ride.driver.user != user:
            return Response(
                {"error": "You can only reject reservations for your rides"},
                status=status.HTTP_403_FORBIDDEN
            )

        if reservation.status != Reservation.ReservationStatus.PENDING:
            return Response(
                {"error": "Reservation cannot be rejected"},
                status=status.HTTP_400_BAD_REQUEST
            )

        reservation.status = Reservation.ReservationStatus.REJECTED
        reservation.save()
        safe_send_notification(

            user=reservation.rider.user,

            title="Reservation Rejected",

            body=(
                f"Your reservation for "
                f"{reservation.ride.location} to "
                f"{reservation.ride.destination} "
                f"has been rejected."
            ),

            data={
                "type": "reservation_rejected",
                "reservation_id": str(reservation.id),
                "ride_id": str(reservation.ride.id),
            }
        )

        return Response(
            {"message": "Reservation rejected successfully"},
            status=status.HTTP_200_OK
        )

class SearchRides(APIView):

    def get(self, request):
       
        location = request.query_params.get('location')
        destination = request.query_params.get('destination')

        if not location or not destination:
            return Response(
                {"error": "Please provide both location and destination."},
                status=status.HTTP_400_BAD_REQUEST
            )

        rides = Ride.objects.filter(
            location__icontains=location,
            destination__icontains=destination,
            status=Ride.RideStatus.ACTIVE
        )
        rides = [
        ride for ride in rides
        if ride.available_seats > 0
        ]
        serializer = RideSearchSerializer(rides, many=True)
        return Response({"rides":serializer.data}, status=status.HTTP_200_OK)

class MyRidesView(APIView):
    def get(self, request):
        user = request.user
        if user.user_type== 'driver':
            try:
                driver= user.driver
            except AttributeError:
                return Response({"error": "Driver profile not found"}, status= status.HTTP_404_NOT_FOUND)
            rides= Ride.objects.filter(driver= driver, status=Ride.RideStatus.ACTIVE).order_by('-id')
            serializer= MyRidesSerializer(rides, many= True)
            return Response({
                "rides": serializer.data
            }, status=status.HTTP_200_OK)
        return Response({"error": "Only drivers can access this endpoint"},status=status.HTTP_403_FORBIDDEN)
        
class MyReservationView(APIView):
    def get(self, request):
        user = request.user
        if user.user_type== 'rider':
            try:
              rider= user.rider
            except AttributeError:
                return Response({"error": "Rider profile not found"}, status= status.HTTP_404_NOT_FOUND)
            reservations= Reservation.objects.filter(rider= rider).order_by('-id')
            serializer= ReservationDetailSerializer(reservations, many= True)
            return Response({
                "reservations" : serializer.data
            }, status= status.HTTP_200_OK)
        else:
            return Response({"error": "Invalid user type"}, status=status.HTTP_400_BAD_REQUEST)

class ViewRideDetails(APIView):

    def get(self, request, ride_id):

        try:
            ride = Ride.objects.get(id=ride_id)
        except Ride.DoesNotExist:
            return Response(
                {"error": "Ride not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        if request.user.user_type == "driver" and ride.driver.user == request.user:

            serializer = RideDetailsSerializer(ride)

            reservations = ReservationDetailSerializer(
                ride.reservations.all(),
                many=True
            )

            data = serializer.data
            data["reservations"] = reservations.data

            return Response(
                {"ride": data},
                status=status.HTTP_200_OK
            )

        if ride.status != Ride.RideStatus.ACTIVE:
            return Response(
                {"error": "Ride not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = RideDetailsSerializer(ride)

        return Response(
            {"ride": serializer.data},
            status=status.HTTP_200_OK
        )

class CompleteRideView(APIView):
    @transaction.atomic
    def post(self, request, ride_id):

        try:
            ride = Ride.objects.select_related(
                "driver",
                "driver__user"
            ).get(id=ride_id)

        except Ride.DoesNotExist:
            return Response(
                {"error": "Ride not found"},
                status=status.HTTP_404_NOT_FOUND
            )

        if request.user.user_type != "driver":
            return Response(
                {"error": "Only drivers can complete rides"},
                status=status.HTTP_403_FORBIDDEN
            )

        if ride.driver.user != request.user:
            return Response(
                {"error": "You are not the driver of this ride"},
                status=status.HTTP_403_FORBIDDEN
            )

        if ride.status != Ride.RideStatus.ACTIVE:
            return Response(
                {"error": "Only active rides can be completed"},
                status=status.HTTP_400_BAD_REQUEST
            )

        paid_reservations = Reservation.objects.filter(
            ride=ride,
            payment=Reservation.PaymentStatus.PAID
        )

        total_earnings = paid_reservations.aggregate(
            total=Sum("ride__cost")
        )["total"] or 0

        wallet = Wallet.objects.select_for_update().get(
            user=request.user
        )

        wallet.balance = F("balance") + total_earnings
        wallet.save()
        wallet.refresh_from_db()

        if total_earnings > 0:
            Transaction.objects.create(
                wallet=wallet,
                amount=total_earnings,
                transaction_type=Transaction.TransactionType.EARNING
            )

        ride.status = Ride.RideStatus.COMPLETED
        ride.save()
        safe_send_notification(
            user=ride.driver.user,
            title="Payment Received",
            body=(
                f"The payment for your ride from "
                f"{ride.location} to "
                f"{ride.destination} "
                f"has been added to your wallet."
            ),
            data={
                "type": "payment_received",
                "ride_id": str(ride.id),
                "amount": str(total_earnings),
            }
        )
        return Response(
            {
                "message": "Ride completed successfully",
                "total_earnings": total_earnings,
                "driver_balance": wallet.balance
            },
            status=status.HTTP_200_OK
        )
