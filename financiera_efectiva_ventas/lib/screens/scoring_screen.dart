import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../utils/scoring.dart';
import '../widgets/app_shell_widgets.dart';

class ScoringScreen extends StatefulWidget {
  const ScoringScreen({super.key});

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  double savings = 160;
  double income = 130;
  double discipline = 145;
  double relationship = 120;
  double risk = 95;
  double business = 52;
  double payment = 48;
  double informalDebt = 30;
  double assets = 35;
  bool characterVeto = false;

  @override
  Widget build(BuildContext context) {
    final txScore = savings + income + discipline + relationship + risk;
    final fieldScore = characterVeto ? 0.0 : business + payment + informalDebt + assets;
    final finalScore = txScore + fieldScore;
    final segment = classifyFinal(finalScore, characterVeto);

    return AppScrollView(
      children: [
        const SectionTitle(
          title: 'Motor de scoring',
          subtitle: 'Score transaccional + visita de campo para preaprobar microcreditos.',
        ),
        MetricsGrid(
          metrics: [
            Metric('Transaccional', txScore.round().toString(), Icons.account_balance, AppTheme.brandBlue),
            Metric('Campo', fieldScore.round().toString(), Icons.fact_check_outlined, AppTheme.brandNavy),
            Metric('Score final', finalScore.round().toString(), Icons.speed, AppTheme.brandCoral),
            Metric('Segmento', segment, Icons.workspace_premium_outlined, AppTheme.brandGold),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 840 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: width,
                  child: ScorePanel(
                    title: 'Scoring transaccional',
                    maxScore: 800,
                    sliders: [
                      ScoreSlider('Capacidad de ahorro', savings, 200, (value) => setState(() => savings = value)),
                      ScoreSlider('Regularidad ingresos', income, 160, (value) => setState(() => income = value)),
                      ScoreSlider('Disciplina financiera', discipline, 160, (value) => setState(() => discipline = value)),
                      ScoreSlider('Vinculo institucional', relationship, 160, (value) => setState(() => relationship = value)),
                      ScoreSlider('Riesgo', risk, 120, (value) => setState(() => risk = value)),
                    ],
                  ),
                ),
                SizedBox(
                  width: width,
                  child: ScorePanel(
                    title: 'Ficha de visita de campo',
                    maxScore: 200,
                    trailing: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: characterVeto,
                      title: const Text('Veto por caracter del cliente'),
                      onChanged: (value) => setState(() => characterVeto = value),
                    ),
                    sliders: [
                      ScoreSlider('Verificacion del negocio', business, 60, (value) => setState(() => business = value)),
                      ScoreSlider('Capacidad real de pago', payment, 60, (value) => setState(() => payment = value)),
                      ScoreSlider('Deuda informal', informalDebt, 40, (value) => setState(() => informalDebt = value)),
                      ScoreSlider('Activos y respaldo', assets, 40, (value) => setState(() => assets = value)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        IntegrationPanel(finalScore: finalScore, segment: segment),
      ],
    );
  }
}

class ScorePanel extends StatelessWidget {
  const ScorePanel({
    super.key,
    required this.title,
    required this.maxScore,
    required this.sliders,
    this.trailing,
  });

  final String title;
  final int maxScore;
  final List<ScoreSlider> sliders;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final total = sliders.fold<double>(0, (sum, slider) => sum + slider.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: PanelHeader(title, Icons.tune)),
                Text(
                  '${total.round()}/$maxScore',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            ?trailing,
            for (final slider in sliders) slider,
          ],
        ),
      ),
    );
  }
}

class ScoreSlider extends StatelessWidget {
  const ScoreSlider(this.label, this.value, this.max, this.onChanged, {super.key});

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(
                '${value.round()}/${max.round()}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: max,
            divisions: max.round(),
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class IntegrationPanel extends StatelessWidget {
  const IntegrationPanel({
    super.key,
    required this.finalScore,
    required this.segment,
  });

  final double finalScore;
  final String segment;

  @override
  Widget build(BuildContext context) {
    final amount = finalScore >= 750
        ? 'S/ 24,000'
        : finalScore >= 550
            ? 'S/ 14,000'
            : finalScore >= 350
                ? 'S/ 6,000'
                : 'No aplica';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PanelHeader('Credito preaprobado e integracion', Icons.hub_outlined),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatusPill(label: 'Monto $amount', color: segmentColor(segment)),
                const StatusPill(label: 'Plazo 12 meses', color: AppTheme.brandBlue),
                const StatusPill(label: 'TEA 38%', color: AppTheme.brandNavy),
                const StatusPill(label: 'Control de acceso', color: AppTheme.brandCoral),
                const StatusPill(label: 'Reportes', color: AppTheme.brandGold),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
