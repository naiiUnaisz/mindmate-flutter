import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:application_belajar/main.dart';
import 'package:application_belajar/screens/onboarding/splash_screen.dart';
import 'package:application_belajar/networks/api_client.dart';

void main() {
  testWidgets('App renders SplashScreen when not logged in', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await Hive.initFlutter();
    await ApiClient().init();

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
