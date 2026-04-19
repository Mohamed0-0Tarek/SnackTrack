import 'package:flutter/material.dart';
import 'package:health_assistant/views/reports/widgets/caloric_flux_card.dart';
import 'package:health_assistant/views/reports/widgets/header.dart';
import 'package:health_assistant/views/reports/widgets/macro_integrity_card.dart';
import 'package:health_assistant/views/reports/widgets/oracle_card.dart';
import 'package:health_assistant/views/reports/widgets/stats_grid.dart';
import 'package:health_assistant/views/reports/widgets/view_summary_button.dart';
import 'package:health_assistant/views/reports/widgets/weight_card.dart';



class WeeklyReportScreen extends StatelessWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: const _BottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // _TopBar(),
              // SizedBox(height: 20),
              Header(),
              SizedBox(height: 20),
              WeightCard(),
              SizedBox(height: 14),
              CaloricFluxCard(),
              SizedBox(height: 14),
              MacroIntegrityCard(),
              SizedBox(height: 14),
              OracleCard(),
              SizedBox(height: 14),
              StatsGrid(),
              SizedBox(height: 20),
              ViewSummaryButton(),
              SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}


