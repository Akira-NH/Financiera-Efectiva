import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle title = TextStyle(
    color: AppColors.text,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.text,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.text,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle muted = TextStyle(
    color: AppColors.mutedText,
    fontSize: 13,
  );
}
