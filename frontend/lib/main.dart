import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'screens/dashboard_home_screen.dart';
import 'storage/token_storage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hasToken = await TokenStorage.hasToken();

  runApp(
    MyApp(
      hasToken: hasToken,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.hasToken,
  }) : super(key: key);

  final bool hasToken;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: hasToken ? '/dashboard' : '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardHomeScreen(),
      },
    );
  }
}
