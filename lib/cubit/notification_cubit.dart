import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../models/notification.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationState()) {
    _subscription = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final notifications = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();
      emit(state.copyWith(
        notifications: notifications,
        status: NotificationStatus.success,
      ));
    });
  }

  late final StreamSubscription _subscription;

  Future<void> addNotification(NotificationModel notification) async {
    try {
      emit(state.copyWith(status: NotificationStatus.loading));
      await FirebaseFirestore.instance
          .collection('professor_notifications')
          .add(notification.toMap());
      // no need to emit, stream listener will handle it
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
