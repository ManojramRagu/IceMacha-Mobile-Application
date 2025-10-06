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

  void _goTab(int i) => setState(() {
    _tabIndex = i;
    _pageIndex = i;
  });

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _goHome() => setState(() {
    _tabIndex = 0;
    _pageIndex = 0;
    _scaffoldKey.currentState?.closeDrawer();
  });

  void _openAbout() => setState(() {
    _pageIndex = 4;
    _scaffoldKey.currentState?.closeDrawer();
  });

  void _openContact() => setState(() {
    _pageIndex = 5;
    _scaffoldKey.currentState?.closeDrawer();
  });

  List<Widget> _buildPages() => [
    HomeScreen(onBuyNow: () => _goTab(1)),
    const MenuScreen(),
    const CartScreen(),
    const ProfileScreen(),
    const AboutScreen(),
    const ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();
    final hideBottomSelection = _pageIndex >= 4;

    return Scaffold(
      key: _scaffoldKey,

      appBar: AppTopBar(onMenuTap: _openDrawer, onLogoTap: _goHome),

      drawer: AppDrawer(onAbout: _openAbout, onContact: _openContact),

      body: IndexedStack(index: _pageIndex, children: pages),

      bottomNavigationBar: AppBottomNav(
        currentIndex: hideBottomSelection ? -1 : _tabIndex,
        onChanged: (i) => _goTab(i),
      ),
    );
  }
}
