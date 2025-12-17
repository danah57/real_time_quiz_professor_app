// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../screens/notifications_screen.dart';
// import 'package:real_time_quiz_professor_app/main.dart';
// import 'navigation_service.dart';
// import '../cubit/notification_cubit.dart';
// import '../models/notification.dart';
// import 'dart:convert';
// import 'package:real_time_quiz_professor_app/screens/notifications_screen.dart';

// /// Background message handler (must be a top-level function)
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // You can add logging or minimal processing here if needed.
//   debugPrint(' BG message: ${message.messageId}');
// }

// class ProfNotificationService {

//   ProfNotificationService._();
//   static final ProfNotificationService instance = ProfNotificationService._();

//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   static const AndroidNotificationChannel _androidChannel =
//       AndroidNotificationChannel(
//     'quiz_notifications', // id
//     'Quiz Notifications', // name
//     description: 'Notifications when students finish quizzes',
//     importance: Importance.high,
//   );

//   /// Call once on app startup after Firebase.initializeApp
//   static Future<void> initialize() async {
//     // Create Android notification channel
//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_androidChannel);

//     // Initialize local notifications
//     const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidInit);
//     await _flutterLocalNotificationsPlugin.initialize(initSettings);

//     // Request notification permissions (Android < 13 & iOS)
//     final messaging = FirebaseMessaging.instance;
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // Always refresh/save FCM token on launch
//     await _saveCurrentFcmToken();

//     // Listen for token refreshes
//     FirebaseMessaging.instance.onTokenRefresh.listen((token) {
//       _saveTokenToFirestore(token);
//     });

//     // Subscribe professor app to quiz results topic
//     await messaging.subscribeToTopic('quiz_results');

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

//     // When app opened from terminated/background via notification tap
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       debugPrint('🔔 Notification opened: ${message.messageId}');
//       //_navigateFromData(message.data);

//       // You can navigate to notifications screen here if needed.

//     });

//     // Handle the case where the app was launched by tapping on a notification
//     final initialMessage = await messaging.getInitialMessage();
//     if (initialMessage != null) {

//       debugPrint(
//           '🚀 App launched from notification: ${initialMessage.messageId}');
//           //_navigateFromData(initialMessage.data);
//     }
//   }

//   static Future<void> _saveCurrentFcmToken() async {
//     final token = await FirebaseMessaging.instance.getToken();
//     if (token != null) {
//       await _saveTokenToFirestore(token);
//     }
//   }

//   static Future<void> _saveTokenToFirestore(String token) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('system')
//           .doc('professor_app')
//           .set(
//         {
//           'fcmToken': token,
//           'updatedAt': DateTime.now().toIso8601String(),
//         },
//         SetOptions(merge: true),
//       );
//       debugPrint('✅ Professor FCM token saved');
//     } catch (e) {
//       debugPrint('❌ Error saving professor FCM token: $e');
//     }
//   }

//   static Future<void> _handleForegroundMessage(RemoteMessage message) async {
//     final notification = message.notification;
//     final android = notification?.android;

//     if (notification != null && android != null) {
//       final title = notification.title ?? 'Quiz Result';
//       final body = notification.body ?? 'A student has finished a quiz.';

//       await _flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         title?? 'Quiz Result',
//         body?? 'A student has finished a quiz.',
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             _androidChannel.id,
//             _androidChannel.name,
//             channelDescription: _androidChannel.description,
//             importance: Importance.high,
//             priority: Priority.high,
//             icon: '@mipmap/ic_launcher',
//           ),
//         ),
//         payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
//       );
//     }
//     await _saveNotificationToFirestore(message.data);
//   }
//   static Future<void> _saveNotificationToFirestore(Map<String, dynamic> data) async {
//     if (data.isEmpty) return;

//     final notif = NotificationModel(
//       quizId: data['quizId'] ?? '',
//       studentId: data['studentId'] ?? '',
//       studentName: data['studentName'] ?? '',
//       score: int.tryParse(data['score'] ?? '0') ?? 0,
//       totalQuestions: int.tryParse(data['totalQuestions'] ?? '0') ?? 0,
//       timeTakenSeconds: int.tryParse(data['timeTakenSeconds'] ?? '0') ?? 0,
//     );

//     try {
//       await FirebaseFirestore.instance
//           .collection('professor_notifications')
//           .add(notif.toMap());
//       debugPrint('✅ Notification saved in Firestore');
//     } catch (e) {
//       debugPrint('❌ Error saving notification: $e');
//     }
//   }
//    static void _navigateFromData(Map<String, dynamic> data) {
//     final screen = data['screen'];
//     if (screen == 'notifications_screen') {
//       navigatorKey.currentState?.push(
//         MaterialPageRoute(
//           builder: (_) => NotificationsScreen(
//           ),
//         ),
//       );
//     }
//   }
// }
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../screens/notifications_screen.dart';
import 'navigation_service.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_cubit.dart';
import '../models/notification.dart';
import 'package:real_time_quiz_professor_app/main.dart';
import 'package:real_time_quiz_professor_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for background handler initialization

import 'package:flutter/services.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📩 BG message: ${message.messageId}');
  // Ensure Firebase is initialized for background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  if (message.data.isNotEmpty) {
    await ProfNotificationService.saveNotificationToFirestore(message.data);
  }
}

class ProfNotificationService {
  ProfNotificationService._();
  static final ProfNotificationService instance = ProfNotificationService._();

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'quiz_notifications',
    'Quiz Notifications',
    description: 'Notifications when students finish quizzes',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    // Setup Android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final data = jsonDecode(details.payload!);
          _navigateFromData(Map<String, dynamic>.from(data));
        }
      },
    );

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await _saveCurrentFcmToken();
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToFirestore);
    await messaging.subscribeToTopic('quiz_results');

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      if (msg.data.isNotEmpty) _navigateFromData(msg.data);
    });
    
    // NOTE: Removed immediate getInitialMessage check. 
    // It should be called from the UI when ready.
  }

  // Call this from the first screen (ProfHome)
  static Future<void> checkForInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      debugPrint('🚀 App launched from notification: ${initialMessage.messageId}');
      // Small delay to ensure navigator is mounted
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateFromData(initialMessage.data);
    }
  }

  static Future<void> _saveCurrentFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) _saveTokenToFirestore(token);
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    try {
      await FirebaseFirestore.instance
          .collection('system')
          .doc('professor_app')
          .set({
        'fcmToken': token,
        'updatedAt': DateTime.now().toIso8601String()
      }, SetOptions(merge: true));
      debugPrint('Professor FCM token saved');
    } catch (e) {
      debugPrint('Error saving professor FCM token: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;

    if (notification != null && android != null) {
      final title = notification.title ?? 'Quiz Result';
      final body = notification.body ?? 'A student has finished a quiz.';
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      );
    }

    await saveNotificationToFirestore(message.data);
  }

  // Made public so background handler can use it
  static Future<void> saveNotificationToFirestore(
      Map<String, dynamic> data) async {
    if (data.isEmpty) return;

    final notif = NotificationModel(
      quizId: data['quizId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      score: int.tryParse(data['score']?.toString() ?? '0') ?? 0,
      totalQuestions: int.tryParse(data['totalQuestions']?.toString() ?? '0') ?? 0,
      timeTakenSeconds: int.tryParse(data['timeTakenSeconds']?.toString() ?? '0') ?? 0,
    );

    try {
      await FirebaseFirestore.instance
          .collection('notifications') // FIXED: Collection name
          .add(notif.toMap());
      debugPrint('✅ Notification saved in Firestore (notifications)');
    } catch (e) {
      debugPrint('❌ Error saving notification: $e');
    }
  }

  static void _navigateFromData(Map<String, dynamic> data) {
    final screen = data['screen'];
    if (screen == 'notifications_screen') {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        ),
      );
    }
  }
}
