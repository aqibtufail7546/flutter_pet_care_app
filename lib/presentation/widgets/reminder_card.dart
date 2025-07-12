import 'package:flutter/material.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/reminder.dart';
import 'package:intl/intl.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;

  const ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.notification_important,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${reminder.petName} • ${reminder.type.name.toUpperCase()}',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 196, 195, 195),
                  ),
                ),
                Text(
                  DateFormat(
                    'MMM dd, yyyy • hh:mm a',
                  ).format(reminder.dateTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 200, 195, 195),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
