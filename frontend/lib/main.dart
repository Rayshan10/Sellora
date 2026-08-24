import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/add_sales_page.dart';
import 'screens/update_sales_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String initialRoute =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;

    return MaterialApp(
      title: 'Sellora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute.isEmpty ? '/' : initialRoute,
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/add-sales': (context) => const AddSalesPage(),
        '/update-sales': (context) => const UpdateSalesPage(),
      },
    );
  }
}
