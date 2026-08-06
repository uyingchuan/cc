import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('小助手')),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _FeatureCard(
            icon: Icons.edit_note_rounded,
            label: '随手记',
            color: const Color(0xFF6366F1),
            onTap: () => context.push('/journal'),
          ),
          _FeatureCard(
            icon: Icons.account_balance_wallet,
            label: '资产',
            color: const Color(0xFF10B981),
            onTap: () => context.push('/assets'),
          ),
          _FeatureCard(
            icon: Icons.receipt_long,
            label: '记账',
            color: const Color(0xFFF59E0B),
            onTap: () => context.push('/bills'),
          ),
          _FeatureCard(
            icon: Icons.access_time,
            label: '时间日志',
            color: const Color(0xFF6366F1),
            onTap: () => context.push('/timelog'),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
