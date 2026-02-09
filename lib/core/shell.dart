import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/widgets/app_nav.dart';
import 'package:icemacha/screens/home.dart';
import 'package:icemacha/screens/menu.dart';
import 'package:icemacha/screens/cart.dart';
import 'package:icemacha/screens/profile.dart';
import 'package:icemacha/screens/about.dart';
import 'package:icemacha/screens/contact.dart';
import 'package:icemacha/providers/auth_provider.dart';

class AppShell extends StatefulWidget {
  final int initialTabIndex;
  const AppShell({super.key, this.initialTabIndex = 3});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _tabIndex;
  late int _pageIndex;
  bool _isLoading = true;
  bool? _wasAuthed;

  AuthProvider? _auth;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex.clamp(0, 3);
    _pageIndex = _tabIndex;
    _initApp();
  }

  Future<void> _initApp() async {
    // Only try auto-login if we haven't already determined auth state
    // (though initState runs once, safe to just call it)
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = await authProvider.tryAutoLogin();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      // If logged in, go to Home (0). If not, stay on initial tab or go to Login (3).
      // Typically initialTabIndex=3 (Profile/Login) is default.
      if (isLoggedIn) {
        _tabIndex = 0;
        _pageIndex = 0;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (_auth != auth) {
      _auth?.removeListener(_onAuthChange);
      _auth = auth;
      _auth!.addListener(_onAuthChange);
      _wasAuthed = _auth!.isAuthenticated;
    }
  }

  void _onAuthChange() {
    if (!mounted) return;
    final authed = _auth!.isAuthenticated;

    if (_wasAuthed == authed) return;
    _wasAuthed = authed;

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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authed = context.watch<AuthProvider>().isAuthenticated;
    final pages = _buildPages();

    final onAuthScreens = _pageIndex == 3 && !authed;
    final hideBottomSelection = _pageIndex >= 4 || onAuthScreens;

    return Scaffold(
      appBar: onAuthScreens ? null : AppTopBar(onLogoTap: _goHome),
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
