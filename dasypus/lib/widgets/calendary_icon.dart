// widgets/calendar_icon_button.dart
import 'package:flutter/material.dart';

Future<IconButton> calendarIconButton({
  required BuildContext context,
  required TextEditingController controller,
  required void Function() onDatePicked,
}) async {
  return IconButton(
    onPressed: () async {
      final DateTime now = DateTime.now();
      final DateTime initial = DateTime.tryParse(
            controller.text.split('/').reversed.join('-'),
          ) ??
          now.subtract(const Duration(days: 6570));
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(now.year - 120),
        lastDate: now,
        locale: const Locale('pt', 'BR'),
      );
      if (picked != null) {
        final String text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        controller.text = text;
        onDatePicked();
      }
    },
    icon: const Icon(Icons.calendar_today_outlined),
  );
}
