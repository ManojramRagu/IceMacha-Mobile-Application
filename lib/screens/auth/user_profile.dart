import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:icemacha/providers/auth_provider.dart';
import 'package:icemacha/screens/auth/camera_screen.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: cs.surfaceContainerHigh,
                backgroundImage: auth.profileImagePath != null
                    ? FileImage(File(auth.profileImagePath!))
                    : null,
                child: auth.profileImagePath == null
                    ? Icon(
                        Icons.account_circle,
                        size: 100,
                        color: cs.primary.withOpacity(0.8),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 20),
                    color: cs.onPrimary,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CameraScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                      if (result != null && result is String) {
                        if (context.mounted) {
                          context.read<AuthProvider>().setProfileImage(result);
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            auth.name,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            auth.email ?? '',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (r) => false);
            },
          ),
        ],
      ),
    );
  }
}
