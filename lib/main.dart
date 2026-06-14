import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:application_belajar/config/theme.dart';
import 'package:application_belajar/bloc/auth/auth_bloc.dart';
import 'package:application_belajar/bloc/task/task_bloc.dart';
import 'package:application_belajar/bloc/task/task_event.dart';
import 'package:application_belajar/bloc/profile/profile_bloc.dart';
import 'package:application_belajar/bloc/profile/profile_event.dart';
import 'package:application_belajar/bloc/mood/mood_bloc.dart';
import 'package:application_belajar/bloc/mood/mood_event.dart';
import 'package:application_belajar/screens/onboarding/splash_screen.dart';
import 'package:application_belajar/screens/onboarding/onboarding_screen.dart';
import 'package:application_belajar/screens/auth/login_screen.dart';
import 'package:application_belajar/screens/auth/signup_screen.dart';
import 'package:application_belajar/screens/auth/forgot_password_screen.dart';
import 'package:application_belajar/screens/auth/verification_screen.dart';
import 'package:application_belajar/screens/auth/new_password_screen.dart';
import 'package:application_belajar/screens/main_screen.dart';
import 'package:application_belajar/screens/tasks/add_task_screen.dart';
import 'package:application_belajar/screens/tasks/note_screen.dart';
import 'package:application_belajar/screens/profile/edit_profile_screen.dart';
import 'package:application_belajar/screens/settings/settings_screen.dart';
import 'package:application_belajar/screens/profile/change_password_screen.dart';
import 'package:application_belajar/screens/profile/change_email_screen.dart';
import 'package:application_belajar/screens/settings/app_version_screen.dart';
import 'package:application_belajar/screens/settings/privacy_policy_screen.dart';
import 'package:application_belajar/screens/profile/puzzle_collection_screen.dart';
import 'package:application_belajar/screens/profile/coin_detail_screen.dart';
import 'package:application_belajar/screens/profile/trash_screen.dart';
import 'package:application_belajar/networks/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await ApiClient().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ApiClient().isLoggedIn;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => TaskBloc()..add(LoadTasks())),
        BlocProvider(create: (_) => ProfileBloc()..add(LoadProfile())),
        BlocProvider(create: (_) => MoodBloc()..add(LoadMoodHistory())),
      ],
      child: MaterialApp(
        title: 'Mindmate',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: isLoggedIn ? const MainScreen() : const SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/verification': (_) => const VerificationScreen(),
          '/new-password': (_) => const NewPasswordScreen(),
          '/main': (_) => const MainScreen(),
          '/add-task': (_) => const AddTaskScreen(),
          '/note': (_) => const NoteScreen(),
          '/edit-profile': (_) => const EditProfileScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/change-password': (_) => const ChangePasswordScreen(),
          '/change-email': (_) => const ChangeEmailScreen(),
          '/app-version': (_) => const AppVersionScreen(),
          '/privacy-policy': (_) => const PrivacyPolicyScreen(),
          '/puzzle-collection': (_) => const PuzzleCollectionScreen(),
          '/coin-detail': (_) => const CoinDetailScreen(),
          '/trash': (_) => const TrashScreen(),
        },
      ),
    );
  }
}
