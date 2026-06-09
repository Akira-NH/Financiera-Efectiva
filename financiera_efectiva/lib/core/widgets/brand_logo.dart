import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({this.compact = false, this.light = false, super.key});

  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final mainColor = light ? Colors.white : AppColors.primary;
    final detailColor = light ? AppColors.accent : AppColors.navy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 36 : 46,
          height: compact ? 36 : 46,
          decoration: BoxDecoration(
            color: mainColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.bolt_rounded,
            color: light ? AppColors.primary : Colors.white,
            size: compact ? 24 : 30,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Financiera',
                style: TextStyle(
                  color: mainColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              Text(
                'Efectiva',
                style: TextStyle(
                  color: detailColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 0.95,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
