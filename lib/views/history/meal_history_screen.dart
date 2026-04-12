import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/meal_controller.dart';
import '../../core/widgets/loading_overlay.dart';

class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});
  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealController>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MealController>();
    if (controller.isLoading) return const LoadingOverlay(isLoading: true , child: SizedBox());
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('History', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: controller.history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final meal = controller.history[i];
                    return ListTile(
                      title: Text(meal.name),
                      subtitle: Text('${meal.calories} kcal'),
                      tileColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
