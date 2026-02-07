import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/core/theme.dart';
import 'package:icemacha/core/shell.dart';
import 'package:icemacha/providers/auth_provider.dart';
import 'package:icemacha/providers/product_catalog_provider.dart';
import 'package:icemacha/providers/cart_provider.dart';
import 'package:icemacha/providers/theme_provider.dart';

import 'package:icemacha/screens/order_placed.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductCatalogProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: context.watch<ThemeProvider>().mode,
          home: const AppShell(initialTabIndex: 3),
          routes: {
            '/home': (context) => const AppShell(initialTabIndex: 0),
            '/order-placed': (context) => const OrderPlacedScreen(),
          },
        ),
      ),
    );
  }
}
