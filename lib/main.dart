import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:psyconnect/blocs/auth/auth_bloc.dart';
import 'package:psyconnect/blocs/consultation/consultation_bloc.dart';
import 'package:psyconnect/blocs/psychologist/psychologist_bloc.dart';
import 'package:psyconnect/blocs/schedule/schedule_bloc.dart';
import 'package:psyconnect/firebase_options.dart';
import 'package:psyconnect/repositories/consultation_repository.dart';
import 'package:psyconnect/repositories/psychologist_repository.dart';
import 'package:psyconnect/repositories/schedule_repository.dart';
import 'package:psyconnect/screens/auth-screen/login_screen.dart';
import 'package:psyconnect/screens/chat-screen/chat_screen.dart';
import 'package:psyconnect/screens/homepage.dart';
import 'package:psyconnect/screens/profile_screen.dart';
import 'package:psyconnect/screens/psycholog-screen/consultation_management_screen.dart';
import 'package:psyconnect/screens/psycholog-screen/profile_psycholog_screen.dart';
import 'package:psyconnect/screens/psycholog-screen/schedule_management_screen.dart';
import 'package:psyconnect/screens/splash_screen.dart';
import 'package:psyconnect/utils/firebase_helper.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseHelper.syncUserData();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _checkFirebaseConnection() async {
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('connection_test')
          .set({
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Firebase test connection successful');
    } catch (e) {
      debugPrint('Firebase connection error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkFirebaseConnection();
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => AuthBloc()),
            BlocProvider(
              create: (context) => ScheduleBloc(
                repository: ScheduleRepositoryImpl(client: http.Client()),
                psychologistId: '',
              ),
            ),
            BlocProvider(
              create: (context) => ConsultationBloc(
                repository: ConsultationRepositoryImpl(client: http.Client()),
                psychologistId: '',
              ),
            ),
            BlocProvider(
              create: (context) => PsychologistBloc(
                repository: PsychologistRepositoryImpl(client: http.Client()),
              ),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/home':
                  return MaterialPageRoute(builder: (_) => const Homepage());
                case '/login':
                  return MaterialPageRoute(builder: (_) => const LoginScreen());
                case '/profile':
                  return MaterialPageRoute(
                      builder: (_) => const ProfilePsychologScreen());
                case '/profile-client':
                  return MaterialPageRoute(
                      builder: (_) => const ClientProfileScreen());
                case '/chat':
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      receiverId: args?['receiverId'] ?? '',
                    ),
                  );
                case '/consultation-management':
                  return _buildConsultationManagementRoute();
                case '/schedule':
                  return _buildScheduleManagementRoute();
                default:
                  return MaterialPageRoute(
                      builder: (_) => const SplashScreen());
              }
            },
          ),
        );
      },
    );
  }

  MaterialPageRoute _buildScheduleManagementRoute() {
    return MaterialPageRoute(
        builder: (_) => FutureBuilder<String>(
              future: _getPsychologistId(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final psychologistId = snapshot.data ?? '';
                if (psychologistId.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  });
                  return const Center(
                      child: Text('Silakan login terlebih dahulu'));
                }

                return BlocProvider(
                  create: (context) => ScheduleBloc(
                    repository: ScheduleRepositoryImpl(client: http.Client()),
                    psychologistId: psychologistId,
                  )..add(LoadSchedules()),
                  child: const ScheduleManagementScreen(),
                );
              },
            ));
  }

  MaterialPageRoute _buildConsultationManagementRoute() {
    return MaterialPageRoute(
      builder: (_) => FutureBuilder<String>(
        future: _getPsychologistId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final psychologistId = snapshot.data ?? '';
          if (psychologistId.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            });
            return const Center(child: Text('Silakan login terlebih dahulu'));
          }

          return BlocProvider(
            create: (context) => ConsultationBloc(
              repository: ConsultationRepositoryImpl(client: http.Client()),
              psychologistId: psychologistId,
            )..add(LoadConsultations()),
            child: const ConsultationManagementScreen(),
          );
        },
      ),
    );
  }

  Future<String> _getPsychologistId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('id') ?? '';
      return id;
    } catch (e) {
      throw Exception('Failed to load psychologist ID: $e');
    }
  }
}
