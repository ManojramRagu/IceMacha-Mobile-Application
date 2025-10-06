import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/core/theme.dart';
import 'package:icemacha/screens/auth/auth_gate.dart';
import 'package:icemacha/utils/auth_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const AuthGate(),
      ),
    );
  }
}
