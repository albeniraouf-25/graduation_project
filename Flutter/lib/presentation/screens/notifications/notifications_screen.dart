import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:a_tareqaak/core/extension/localization_extension.dart';
import 'package:a_tareqaak/core/extension/theme_color_extension.dart';
import 'package:a_tareqaak/core/resources/app_fonts.dart';
import 'package:a_tareqaak/core/resources/app_values.dart';
import 'package:a_tareqaak/data/models/notifications/notification_model.dart';
import 'package:a_tareqaak/presentation/cubit/notifications/notifications_cubit.dart';
import 'package:a_tareqaak/presentation/cubit/notifications/notifications_state.dart';
import 'package:a_tareqaak/presentation/widgets/text/body_title.dart';
import 'package:a_tareqaak/presentation/widgets/text/section_title.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit()..loadNotifications(),
      child: const _NotificationsContent(),
    );
  }
}

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent();

  @override
  Widget build(BuildContext context) {
    final tr = context.loc;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: context.appColors.backGround,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPaddingWidth.p20,
                vertical: AppPaddingHeight.p15,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: FaIcon(
                      isRtl
                          ? FontAwesomeIcons.chevronRight
                          : FontAwesomeIcons.chevronLeft,
                      color: context.appColors.blackText,
                      size: AppSize.s20,
                    ),
                  ),
                  SectionTitle(
                    text: tr.notifications,
                    fontSize: AppFontSize.s18,
                    fontWeight: AppFontWeight.bold,
                  ),
                  SizedBox(width: AppWidth.w40),
                ],
              ),
            ),

            // التبويب العلوي (الكل / غير المقروءة)
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                final cubit = context.read<NotificationsCubit>();
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPaddingWidth.p20),
                  child: Container(
                    padding: EdgeInsets.all(AppPaddingWidth.p4),
                    decoration: BoxDecoration(
                      color: context.appColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                    ),
                    child: Row(
                      children: [
                        _TabButton(
                          label: tr.all,
                          selected: cubit.currentTab == 0,
                          onTap: () => cubit.changeTab(0),
                        ),
                        _TabButton(
                          label: cubit.unreadCount > 0
                              ? '${tr.unread} (${cubit.unreadCount})'
                              : tr.unread,
                          selected: cubit.currentTab == 1,
                          onTap: () => cubit.changeTab(1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // قائمة الإشعارات الحقيقية من الخادم
            Expanded(
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoadingState ||
                      state is NotificationsInitialState) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is NotificationsErrorState) {
                    return Center(child: BodyTitle(text: state.message));
                  }

                  final cubit = context.read<NotificationsCubit>();
                  final items = cubit.visibleNotifications;

                  if (items.isEmpty) {
                    return Center(child: BodyTitle(text: tr.no_data));
                  }

                  return RefreshIndicator(
                    onRefresh: () => cubit.loadNotifications(),
                    child: ListView.separated(
                      padding: EdgeInsets.all(AppPaddingWidth.p20),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: AppHeight.h10),
                      itemBuilder: (context, index) => _NotificationItem(
                        notification: items[index],
                        onTap: () => cubit.markAsRead(items[index].id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppPaddingHeight.p8),
          decoration: BoxDecoration(
            color: selected ? context.appColors.primary : context.appColors.none,
            borderRadius: BorderRadius.circular(AppRadius.r10),
          ),
          child: BodyTitle(
            text: label,
            textAlign: TextAlign.center,
            color: selected
                ? context.appColors.white
                : context.appColors.greyText,
            fontWeight: AppFontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationItem({required this.notification, required this.onTap});

  String _formatTime(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return DateFormat('d MMM yyyy · hh:mm a').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isRead != true;
    final iconColor = context.appColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r14),
      child: Container(
        padding: EdgeInsets.all(AppPaddingWidth.p14),
        decoration: BoxDecoration(
          color: isUnread
              ? context.appColors.primary.withOpacity(0.06)
              : context.appColors.white,
          borderRadius: BorderRadius.circular(AppRadius.r14),
          boxShadow: [
            BoxShadow(
              color: context.appColors.primary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          spacing: AppWidth.w12,
          children: [
            CircleAvatar(
              radius: AppRadius.r18,
              backgroundColor: iconColor.withOpacity(0.1),
              child: FaIcon(
                FontAwesomeIcons.bell,
                color: iconColor,
                size: AppSize.s16,
              ),
            ),
            Expanded(
              child: Column(
                spacing: AppHeight.h4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyTitle(
                    text: notification.title ?? '',
                    fontSize: AppFontSize.s14,
                    fontWeight: AppFontWeight.bold,
                  ),
                  if ((notification.body ?? '').isNotEmpty)
                    BodyTitle(
                      text: notification.body!,
                      fontSize: AppFontSize.s13,
                      color: context.appColors.greyText,
                    ),
                  BodyTitle(
                    text: _formatTime(notification.createdAt),
                    fontSize: AppFontSize.s12,
                    color: context.appColors.greyText,
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: AppWidth.w10,
                height: AppHeight.h10,
                decoration: BoxDecoration(
                  color: context.appColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
