import 'package:flutter/material.dart';
import 'widgets/hero_header.dart';
import 'widgets/grade_card.dart';
import 'widgets/metabolic_health_card.dart';
import 'widgets/energy_flux_card.dart';
import 'widgets/nutrient_saturation_card.dart';
import 'widgets/oracle_verdict_card.dart';
import 'widgets/system_logs_card.dart';


class WeeklySummaryScreen extends StatelessWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HeroHeader(),
              SizedBox(height: 20),
              GradeCard(),
              SizedBox(height: 14),
              MetabolicHealthCard(),
              SizedBox(height: 14),
              EnergyFluxCard(),
              SizedBox(height: 14),
              NutrientSaturationCard(),
              SizedBox(height: 14),
              OracleVerdictCard(),
              SizedBox(height: 14),
              SystemLogsCard(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
