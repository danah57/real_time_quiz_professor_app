import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'cubit/course_cubit.dart';
import 'cubit/quiz_cubit.dart';
import 'screens/prof_home.dart';
import 'services/firebase_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              CourseCubit(FirebaseDataService.instance)..loadInitialData(),
        ),
        BlocProvider(
          create: (_) =>
              QuizCubit(FirebaseDataService.instance)..loadInitialData(),
        ),
      ],
      child: MaterialApp(
        title: 'Professor Quiz App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const ProfessorHome(),
      ),
    );
  }
}
