import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindmate/main.dart';
import 'package:mindmate/screens/onboarding/splash_screen.dart';
import 'package:mindmate/networks/api_client.dart';

void main() {
  testWidgets('App renders SplashScreen when not logged in', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await ApiClient().init();

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
