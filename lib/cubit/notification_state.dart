part of 'notification_cubit.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    this.notifications = const [],
    this.status = NotificationStatus.initial,
    this.errorMessage,
  });

  final List<NotificationModel> notifications;
  final NotificationStatus status;
  final String? errorMessage;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    NotificationStatus? status,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [notifications, status, errorMessage];
}
