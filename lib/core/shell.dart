import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/widgets/app_nav.dart';
import 'package:icemacha/screens/home.dart';
import 'package:icemacha/screens/menu.dart';
import 'package:icemacha/screens/cart.dart';
import 'package:icemacha/screens/profile.dart';
import 'package:icemacha/screens/about.dart';
import 'package:icemacha/screens/contact.dart';

import 'package:icemacha/utils/auth_provider.dart';

class AppShell extends StatefulWidget {
  final int initialTabIndex;
  const AppShell({super.key, this.initialTabIndex = 3});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _tabIndex;
  late int _pageIndex;

  AuthProvider? _auth;

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
        _tabIndex = 0;
        _pageIndex = 0;
      } else {
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

  void _goTab(int i) {
    final authed = context.read<AuthProvider>().isAuthenticated;
    if (!authed && i != 3) {
      setState(() {
        _tabIndex = 3;
        _pageIndex = 3;
      });
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

  List<Widget> _buildPages() => [
    HomeScreen(onBuyNow: () => _goTab(1)),
    const MenuScreen(),
    CartScreen(onBrowseMenu: () => _goTab(1)),
    const ProfileScreen(),
    const AboutScreen(),
    const ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authed = context.watch<AuthProvider>().isAuthenticated;
    final pages = _buildPages();

    final onAuthScreens = _pageIndex == 3 && !authed;
    final hideBottomSelection = _pageIndex >= 4 || onAuthScreens;

    return Scaffold(
      key: _scaffoldKey,
      appBar: onAuthScreens
          ? null
          : AppTopBar(onMenuTap: _openDrawer, onLogoTap: _goHome),
      body: IndexedStack(index: _pageIndex, children: pages),
      bottomNavigationBar: onAuthScreens
          ? null
          : AppBottomNav(
              currentIndex: hideBottomSelection ? -1 : _tabIndex,
              onChanged: _goTab,
            ),
    );
  }
}
