import 'package:flutter/material.dart';

import 'config/institution_config.dart';
import 'routes/app_router.dart';
import 'routes/route_names.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class FinancieraEfectivaApp extends StatelessWidget {
  const FinancieraEfectivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: InstitutionConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          initialRoute: RouteNames.splash,
          routes: AppRouter.routes,
        );
      },
    );
  }
}
