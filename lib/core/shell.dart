// lib/core/shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:icemacha/widgets/app_nav.dart';
import 'package:icemacha/widgets/app_menu.dart';

import 'package:icemacha/screens/home.dart';
import 'package:icemacha/screens/menu.dart'; // MenuScreen
import 'package:icemacha/screens/cart.dart';
import 'package:icemacha/screens/profile.dart'; // ProfileScreen
import 'package:icemacha/screens/about.dart';
import 'package:icemacha/screens/contact.dart';

import 'package:icemacha/utils/auth_provider.dart';

class AppShell extends StatefulWidget {
  /// Tabs: 0=Home, 1=Menu, 2=Cart, 3=Profile
  final int initialTabIndex;
  const AppShell({
    super.key,
    this.initialTabIndex = 3,
  }); // default to Profile(Login)

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late int _tabIndex; // bottom nav highlight (0..3, or -1 for about/contact)
  late int _pageIndex; // IndexedStack index (0..5)

  AuthProvider? _auth; // hold ref to add/remove listener

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex.clamp(0, 3);
    _pageIndex = _tabIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (_auth != auth) {
      _auth?.removeListener(_onAuthChange);
      _auth = auth;
      _auth!.addListener(_onAuthChange);
    }
  }

  void _onAuthChange() {
    if (!mounted) return;
    final authed = _auth!.isAuthenticated;
    setState(() {
      if (authed) {
        // After login -> Home
        _tabIndex = 0;
        _pageIndex = 0;
      } else {
        // After logout -> Profile (login form)
        _tabIndex = 3;
        _pageIndex = 3;
      }
    });
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChange);
    super.dispose();
  }

  // Block switching to other tabs unless authenticated
  void _goTab(int i) {
    final authed = context.read<AuthProvider>().isAuthenticated;
    if (!authed && i != 3) {
      setState(() {
        _tabIndex = 3;
        _pageIndex = 3;
      });
      // Optional hint:
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }
    setState(() {
      _tabIndex = i;
      _pageIndex = i;
    });
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _goHome() {
    final authed = context.read<AuthProvider>().isAuthenticated;
    setState(() {
      if (authed) {
        _tabIndex = 0;
        _pageIndex = 0;
      } else {
        _tabIndex = 3;
        _pageIndex = 3;
      }
      _scaffoldKey.currentState?.closeDrawer();
    });
  }

  void _openAbout() => setState(() {
    _pageIndex = 4; // keep bars; hide bottom highlight via -1 below
    _scaffoldKey.currentState?.closeDrawer();
  });

  void _openContact() => setState(() {
    _pageIndex = 5; // keep bars; hide bottom highlight via -1 below
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
    final hideBottomSelection = _pageIndex >= 4; // About/Contact

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(onMenuTap: _openDrawer, onLogoTap: _goHome),
      drawer: AppDrawer(onAbout: _openAbout, onContact: _openContact),
      body: IndexedStack(index: _pageIndex, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: hideBottomSelection ? -1 : _tabIndex,
        onChanged: _goTab,
      ),
    );
  }
}
