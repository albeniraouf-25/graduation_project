import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';

class CurrentLocationMapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const CurrentLocationMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<CurrentLocationMapWidget> createState() =>
      _CurrentLocationMapWidgetState();
}

class _CurrentLocationMapWidgetState
    extends State<CurrentLocationMapWidget> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(
    covariant CurrentLocationMapWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.latitude != null &&
        widget.longitude != null &&
        (widget.latitude != oldWidget.latitude ||
            widget.longitude != oldWidget.longitude)) {
      _moveCamera();
    }
  }

  Future<void> _moveCamera() async {
    if (_mapController == null ||
        widget.latitude == null ||
        widget.longitude == null) {
      return;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            widget.latitude!,
            widget.longitude!,
          ),
          zoom: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLocation =
        widget.latitude != null &&
        widget.longitude != null;

    if (!hasLocation) {
      return Container(
        height: AppHeight.h250,
        decoration: BoxDecoration(
          color: context.appColors.lightGreySec,
          borderRadius:
              BorderRadius.circular(AppRadius.r16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final LatLng currentPosition = LatLng(
      widget.latitude!,
      widget.longitude!,
    );

    return SizedBox(
      height: AppHeight.h250,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AppRadius.r16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentPosition,
            zoom: 16,
          ),

          onMapCreated: (controller) {
            _mapController = controller;
          },

          myLocationEnabled: true,
          myLocationButtonEnabled: true,

          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,

          buildingsEnabled: false,
          rotateGesturesEnabled: true,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: false,

          markers: {
            Marker(
              markerId: const MarkerId(
                'current_driver_location',
              ),
              position: currentPosition,
              infoWindow: const InfoWindow(
                title: 'Current Location',
              ),
            ),
          },
        ),
      ),
    );
  }
}