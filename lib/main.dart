import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/core/theme.dart';
import 'package:icemacha/core/shell.dart';
import 'package:icemacha/utils/auth_provider.dart';
import 'package:icemacha/utils/product_catalog_provider.dart';
import 'package:icemacha/utils/cart_provider.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductCatalogProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const AppShell(initialTabIndex: 3),
      ),
    );
  }
}
