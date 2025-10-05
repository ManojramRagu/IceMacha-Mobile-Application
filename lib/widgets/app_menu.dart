import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onAbout, required this.onContact});

  final VoidCallback onAbout;
  final VoidCallback onContact;

  static const _logo = 'assets/img/logo.webp';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: ClipOval(
                child: Image.asset(
                  _logo,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text('IceMacha', style: tt.titleMedium),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.info_outline, color: cs.primary),
              title: const Text('About'),
              onTap: onAbout,
            ),
            ListTile(
              leading: Icon(Icons.mail_outline, color: cs.primary),
              title: const Text('Contact'),
              onTap: onContact,
            ),
          ],
        ),
      ),
    );
  }
}
