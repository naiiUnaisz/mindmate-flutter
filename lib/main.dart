import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindmate/config/theme.dart';
import 'package:mindmate/bloc/auth/auth_bloc.dart';
import 'package:mindmate/bloc/task/task_bloc.dart';
import 'package:mindmate/bloc/task/task_event.dart';
import 'package:mindmate/bloc/profile/profile_bloc.dart';
import 'package:mindmate/bloc/profile/profile_event.dart';
import 'package:mindmate/bloc/mood/mood_bloc.dart';
import 'package:mindmate/bloc/mood/mood_event.dart';
import 'package:mindmate/bloc/note/note_bloc.dart';
import 'package:mindmate/screens/onboarding/splash_screen.dart';
import 'package:mindmate/screens/onboarding/onboarding_screen.dart';
import 'package:mindmate/screens/auth/login_screen.dart';
import 'package:mindmate/screens/auth/signup_screen.dart';
import 'package:mindmate/screens/auth/forgot_password_screen.dart';
import 'package:mindmate/screens/auth/verification_screen.dart';
import 'package:mindmate/screens/auth/new_password_screen.dart';
import 'package:mindmate/screens/main_screen.dart';
import 'package:mindmate/screens/tasks/add_task_screen.dart';
import 'package:mindmate/screens/tasks/note_screen.dart';
import 'package:mindmate/screens/profile/edit_profile_screen.dart';
import 'package:mindmate/screens/settings/settings_screen.dart';
import 'package:mindmate/screens/profile/change_password_screen.dart';
import 'package:mindmate/screens/profile/change_email_screen.dart';
import 'package:mindmate/screens/settings/app_version_screen.dart';
import 'package:mindmate/screens/settings/privacy_policy_screen.dart';
import 'package:mindmate/screens/profile/puzzle_collection_screen.dart';
import 'package:mindmate/screens/profile/coin_detail_screen.dart';
// import 'package:mindmate/screens/profile/trash_screen.dart'; // File removed
import 'package:mindmate/networks/api_client.dart';
import 'package:mindmate/utils/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient().init();
  await NotificationHelper.init();
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
        BlocProvider(create: (_) => NoteBloc()),
      ],
      child: MaterialApp(
        title: 'Mindmate',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
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
              // '/trash': (_) => const TrashScreen(), // File removed
            },
          ),
    );
  }
}
