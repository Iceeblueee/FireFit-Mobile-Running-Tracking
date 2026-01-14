// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/navigation_model.dart';
import 'models/tracking_model.dart';
import 'screens/splash_screen.dart';
import 'screens/activity_screen.dart';

final trackingModel = TrackingModel();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationModel()),
        ChangeNotifierProvider.value(value: trackingModel),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireFit',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Poppins'),
      home: const SplashScreen(),
      routes: {'/activity': (context) => const ActivityScreen()},
      debugShowCheckedModeBanner: false,
    );
  }
}
