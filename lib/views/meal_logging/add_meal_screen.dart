import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/meal_controller.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});
  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _descCtrl = TextEditingController();

  @override
  void dispose() { _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MealController>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Meal', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 24),
              CustomTextField(hint: 'Describe your meal...', controller: _descCtrl),
              if (controller.error != null) ...[
                const SizedBox(height: 12),
                Text(controller.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 16),
              CustomButton(
                label: 'Analyze Meal',
                isLoading: controller.isLoading,
                onPressed: () => controller.analyzeMeal(_descCtrl.text),
              ),
              // TODO: show analysis result, barcode/photo/voice options
            ],
          ),
        ),
      ),
    );
  }
}
