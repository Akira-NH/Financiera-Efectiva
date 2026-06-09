import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'screens/sales_force_home.dart';

class FuerzaVentasApp extends StatelessWidget {
  const FuerzaVentasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fuerza de Ventas',
      theme: AppTheme.light,
      home: const SalesForceHome(),
    );
  }
}
