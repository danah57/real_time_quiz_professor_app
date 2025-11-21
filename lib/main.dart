import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/course_cubit.dart';
import 'screens/prof_home.dart';
import 'services/data_service.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CourseCubit(DataService.instance)..loadInitialData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Professor Quiz App',
        home: const ProfessorHome(),
      ),
    );
  }
}
