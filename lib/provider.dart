// provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/navigation_model.dart';
import 'models/tracking_model.dart';

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NavigationModel()),
        ChangeNotifierProvider(create: (context) => TrackingModel()),
      ],
      child: child,
    );
  }
}
