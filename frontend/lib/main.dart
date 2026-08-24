import 'package:flutter/material.dart';

import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/add_sales_page.dart';
import 'screens/update_sales_page.dart';
import 'screens/delete_sales_page.dart';
import 'storage/token_storage.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: hasToken ? '/home' : '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/add-sales': (context) => const AddSalesPage(),
        '/update-sales': (context) => const UpdateSalesPage(),
        '/delete-sales': (context) => const DeleteSalesPage(),
      },
    );
  }
}