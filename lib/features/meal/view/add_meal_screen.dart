import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_assistant/features/meal/viewmodel/meal_viewmodel.dart';

class AddMealScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MealViewModel(),
      child: Scaffold(
        appBar: AppBar(title: Text("Add Meal")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<MealViewModel>(
            builder: (context, vm, child) {
              return Column(
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Enter meal (e.g. chicken rice)",
                    ),
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      vm.analyzeMeal(controller.text);
                    },
                    child: Text("Analyze"),
                  ),

                  SizedBox(height: 20),

                  if (vm.isLoading) CircularProgressIndicator(),

                  if (vm.meal != null)
                    Text("Calories: ${vm.meal!.calories}"),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}