/*
import 'package:flutter/material.dart';
import 'package:carebridge/pages/LoginSignup/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:carebridge/provider/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('en_IN', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => TaskProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthPage(appName: '', appUserModelId: '', guid: ''),
      ),
    );
  }
}
*/
import 'package:carebridge/pages/GrowthMonitor/upload_growth_chart.dart';
import 'package:flutter/material.dart';
import 'package:carebridge/pages/LoginSignup/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:carebridge/provider/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('en_IN', null);

  runApp(const MyApp());
  await uploadGrowthChartData();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => TaskProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthPage(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[900],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[900],
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
