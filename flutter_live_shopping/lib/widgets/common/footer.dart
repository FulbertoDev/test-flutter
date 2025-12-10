import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme_config.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.paddingXL,
        horizontal: AppTheme.paddingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Live Shopping',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _FooterLink(text: 'À propos', onTap: () {}),
              _FooterLink(text: 'Conditions générales', onTap: () {}),
              _FooterLink(text: 'Confidentialité', onTap: () {}),
              _FooterLink(text: 'Contact', onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© ${DateFormat.y().format(DateTime.now())} Live Shopping. Tous droits réservés.',
                style: TextStyle(color: textColor, fontSize: 12),
              ),
              Row(
                children: [
                  _SocialIcon(icon: Icons.camera_alt, onTap: () {}),
                  const SizedBox(width: 16),
                  _SocialIcon(icon: Icons.facebook, onTap: () {}),
                  const SizedBox(width: 16),
                  _SocialIcon(icon: Icons.alternate_email, onTap: () {}),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.grey[700],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Icon(
        icon,
        size: 20,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }
}
