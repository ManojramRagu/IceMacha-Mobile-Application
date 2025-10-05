import 'package:flutter/material.dart';
import 'package:icemacha/widgets/app_nav.dart';
import 'package:icemacha/widgets/app_menu.dart';
import 'package:icemacha/screens/home.dart';
import 'package:icemacha/screens/menu.dart';
import 'package:icemacha/screens/cart.dart';
import 'package:icemacha/screens/profile.dart';
import 'package:icemacha/screens/about.dart';
import 'package:icemacha/screens/contact.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _tabIndex = 0;
  int _pageIndex = 0;

  final _pages = const [
    HomeScreen(), // 0
    MenuScreen(), // 1
    CartScreen(), // 2
    ProfileScreen(), // 3
    AboutScreen(), // 4
    ContactScreen(), // 5
  ];

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _goHome() => setState(() {
    _tabIndex = 0;
    _pageIndex = 0;
    _scaffoldKey.currentState?.closeDrawer();
  });

  void _openAbout() => setState(() {
    _pageIndex = 4; // About
    _scaffoldKey.currentState?.closeDrawer();
  });

  void _openContact() => setState(() {
    _pageIndex = 5; // Contact
    _scaffoldKey.currentState?.closeDrawer();
  });

  @override
  Widget build(BuildContext context) {
    final hideBottomSelection = _pageIndex >= 4;

    return Scaffold(
      key: _scaffoldKey,

      appBar: AppTopBar(onMenuTap: _openDrawer, onLogoTap: _goHome),

      drawer: AppDrawer(onAbout: _openAbout, onContact: _openContact),

      body: IndexedStack(index: _pageIndex, children: _pages),

      bottomNavigationBar: AppBottomNav(
        currentIndex: hideBottomSelection ? -1 : _tabIndex,
        onChanged: (i) => setState(() {
          _tabIndex = i;
          _pageIndex = i;
        }),
      ),
    );
  }
}
