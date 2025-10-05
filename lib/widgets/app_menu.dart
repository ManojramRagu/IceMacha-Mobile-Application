import 'package:flutter/material.dart';
import 'package:icemacha/screens/about.dart';
import 'package:icemacha/screens/contact.dart';

Future<void> showAppMenu(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.info_outline, color: cs.primary),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.mail_outline, color: cs.primary),
            title: const Text('Contact'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ContactScreen()));
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
