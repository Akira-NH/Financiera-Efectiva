import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/movement.dart';

class MovementList extends StatelessWidget {
  const MovementList({required this.movements, super.key});

  final List<Movement> movements;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: movements.map((movement) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            movement.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: movement.isIncome ? Colors.green : Colors.red,
          ),
          title: Text(movement.title),
          subtitle: Text(movement.date),
          trailing: Text(
            '${movement.isIncome ? '+' : '-'}${Formatters.currency(movement.amount)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      }).toList(),
    );
  }
}
