import 'package:flutter/material.dart';

Future<int?> showIntSettingDialog({
  required BuildContext context,
  required String title,
  required int currentValue,
  required int minValue,
  required int maxValue,
  String suffix = '',
}) async {
  final controller = TextEditingController(text: currentValue.toString());
  int? newValue;
  String? errorText;

  final result = await showDialog<int>(
    context: context, 
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        void validate(String value) {
          final parsed = int.tryParse(value);
          if (parsed == null) {
            setDialogState(() => errorText = 'Please enter a valid number');
          } else if (parsed < minValue || parsed > maxValue) {
            setDialogState(() => errorText = 'Value must be between $minValue and $maxValue');
          } else {
            setDialogState(() {errorText = null; newValue = parsed;});
          }
        }
      
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: suffix,
                helperText: 'Range: $minValue-$maxValue', 
                errorText: errorText, 
              ),
              onChanged: validate,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel')
            ),
            TextButton(
              onPressed: 
                errorText == null
                ? () => Navigator.pop(context, newValue)
                : null,
              child: const Text('Save'),
            ),
          ],
        );
      }
    ),
  );
  return result;
}

Future<void> showBoolSettingDialog({
  required BuildContext context,
  required String title,
  required bool currentValue,
  required Function(bool) onSave,
}) async {
  bool newValue = currentValue;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SwitchListTile(
        title: const Text('Enable'),
        value: newValue,
        onChanged: (v) => newValue = v,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onSave(newValue);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    )
  );
}