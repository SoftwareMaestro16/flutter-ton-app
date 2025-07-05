import 'package:flutter/material.dart';
import 'package:testapp/core/ui/theme.dart';
import 'package:testapp/features/menu/view/main_navigation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mintory App',
      theme: theme,
      home: const MainNavigationScreen(),
    );
  }
}