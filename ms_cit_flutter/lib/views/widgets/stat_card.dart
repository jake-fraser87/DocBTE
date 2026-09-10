import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/dashboard_stats_model.dart';

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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          top: const BorderSide(color: AppColors.line, width: 1.5),
          right: const BorderSide(color: AppColors.line, width: 1.5),
          bottom: const BorderSide(color: AppColors.line, width: 1.5),
          left: BorderSide(color: accent, width: 5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: 0.2,
                ),
              ),
              CircleAvatar(
                radius: 13,
                backgroundColor: accentSoft,
                child: Icon(icon, size: 14, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          if (split != null) ...[
            const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text('$value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: color.withOpacity(0.85))),
        ],
      ),
    );
  }
}
