import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/ai_controller.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});
  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _inputCtrl = TextEditingController();
  @override
  void dispose() { _inputCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AiController>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('AI Coach', style: Theme.of(context).textTheme.headlineLarge),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.messages.length,
                itemBuilder: (context, i) {
                  final msg = controller.messages[i];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg['content'] ?? ''),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: CustomTextField(hint: 'Ask your AI coach...', controller: _inputCtrl)),
                  const SizedBox(width: 8),
                  CustomButton(
                    label: 'Send',
                    isLoading: controller.isLoading,
                    onPressed: () { controller.sendMessage(_inputCtrl.text); _inputCtrl.clear(); },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
