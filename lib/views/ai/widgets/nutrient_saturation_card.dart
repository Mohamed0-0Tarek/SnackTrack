import 'package:flutter/material.dart';
import 'custom_card.dart';

class NutrientSaturationCard extends StatelessWidget {
  const NutrientSaturationCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrient Saturation', style: tt.headlineMedium),
          const SizedBox(height: 14),
          NutrientRow(
            icon: Icons.water_drop_outlined,
            iconColor: scheme.primary,
            name: 'Magnesium Glycinate',
            sub: '-12% vs Target',
            trailing: Icon(
              Icons.trending_down,
              color: Colors.red.shade400,
              size: 16,
            ),
          ),
          Divider(color: Theme.of(context).dividerColor, height: 20),
          NutrientRow(
            icon: Icons.wb_sunny_outlined,
            iconColor: scheme.tertiary,
            name: 'Vitamin D3 + K2',
            sub: 'at Primal Levels',
            trailing: Icon(
              Icons.check_circle_outline,
              color: scheme.primary,
              size: 16,
            ),
          ),
          Divider(color: Theme.of(context).dividerColor, height: 20),
          NutrientRow(
            icon: Icons.waves_rounded,
            iconColor: scheme.secondary,
            name: 'Omega-3 Index',
            sub: '+5% vs Last Week',
            trailing: Icon(Icons.trending_up, color: scheme.primary, size: 16),
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'VIEW FULL MICRONUTRIENT MAP',
                  style: tt.labelSmall?.copyWith(
                    color: scheme.primary,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NutrientRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String sub;
  final Widget trailing;

  const NutrientRow({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.sub,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(sub, style: tt.bodySmall),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}
