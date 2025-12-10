import 'package:flutter/material.dart';
import 'package:flutter_live_shopping/config/theme_config.dart';
import 'package:flutter_live_shopping/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType != DeviceScreenType.mobile) {
          return const Drawer(child: SizedBox.shrink());
        }

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Live Shopping',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return Text(
                          auth.currentUser?.name ?? 'Invité',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Mon Profil'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/profile');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
