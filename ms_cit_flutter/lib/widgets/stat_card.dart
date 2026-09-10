import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../models/dashboard_stats_model.dart';

/// Small reusable presentational widget — not a screen. It holds no
/// state and talks to no ViewModel/Service; it just renders whatever
/// values it's given. Shared across screens the way a "Card" or
/// "Button" component would be in any UI kit.
class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final DeskSplit? split;
  final Color accent;
  final Color accentSoft;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    required this.accentSoft,
    required this.icon,
    this.split,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.accentCard(accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 15,
                backgroundColor: accentSoft,
                child: Icon(icon, size: 15, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              height: 1.1,
            ),
          ),
          if (split != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _DeskChip(label: 'DESK-I', value: split!.deskOne, color: accent, bg: accentSoft)),
                const SizedBox(width: 8),
                Expanded(child: _DeskChip(label: 'DESK-II', value: split!.deskTwo, color: accent, bg: accentSoft)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DeskChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color bg;

  const _DeskChip({required this.label, required this.value, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 1),
          Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: color.withOpacity(0.85))),
        ],
      ),
    );
  }
}
