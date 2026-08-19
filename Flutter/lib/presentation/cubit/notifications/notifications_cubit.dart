// lib/presentation/cubit/notifications/notifications_cubit.dart
import 'package:a_tareqaak/core/services/locator/locator.dart';
import 'package:a_tareqaak/data/models/base/base_model.dart';
import 'package:a_tareqaak/data/models/notifications/notification_model.dart';
import 'package:a_tareqaak/domain/entity/rides/id_entity.dart';
import 'package:a_tareqaak/domain/entity/rides/rides_no_params_entity.dart';
import 'package:a_tareqaak/domain/usecase/i_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsInitialState());

  int currentTab = 0;
  List<NotificationModel> _all = [];

  // القائمة الظاهرة حسب التبويب الحالي (الكل / غير المقروءة)
  List<NotificationModel> get visibleNotifications => currentTab == 1
      ? _all.where((n) => n.isRead != true).toList()
      : _all;

  int get unreadCount => _all.where((n) => n.isRead != true).length;

  void _emitLoaded() {
    emit(NotificationsLoadedState(
      notifications: _all,
      selectedTab: currentTab,
      unreadCount: unreadCount,
    ));
  }

  // تحميل الإشعارات من الخادم
  Future<void> loadNotifications() async {
    emit(NotificationsLoadingState());
    try {
      final result = await locator<
          IUseCase<BaseModel<NotificationsListModel>?, RidesNoParamsEntity>>(
        instanceName: 'GetNotificationsUseCase',
      )(const RidesNoParamsEntity());

      result.fold(
        (l) => emit(NotificationsErrorState(l.message)),
        (r) {
          _all = r?.data?.notifications ?? <NotificationModel>[];
          _emitLoaded();
        },
      );
    } catch (e) {
      emit(NotificationsErrorState(e.toString()));
    }
  }

  void changeTab(int tabIndex) {
    currentTab = tabIndex;
    _emitLoaded();
  }

  // تعليم إشعار كمقروء (عند الضغط عليه) وتحديث القائمة محلياً
  Future<void> markAsRead(int? id) async {
    if (id == null) return;
    final index = _all.indexWhere((n) => n.id == id);
    if (index == -1 || _all[index].isRead == true) return;

    // تحديث تفاؤلي محلي
    final n = _all[index];
    _all[index] = NotificationModel(
      id: n.id,
      title: n.title,
      body: n.body,
      notificationType: n.notificationType,
      data: n.data,
      isRead: true,
      createdAt: n.createdAt,
    );
    _emitLoaded();

    try {
      await locator<IUseCase<BaseModel<dynamic>?, IdEntity>>(
        instanceName: 'MarkNotificationReadUseCase',
      )(IdEntity(id));
    } catch (_) {
      // في حال الفشل نتركها كما هي محلياً؛ سيُصحَّح عند إعادة التحميل
    }
  }
}
