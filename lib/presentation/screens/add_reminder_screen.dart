import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_pet_care_and_veterinary_app/application/provider/pet_provider.dart';
import 'package:flutter_pet_care_and_veterinary_app/application/provider/reminder_provider.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/emergency_contact.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/reminder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddReminderScreen extends HookConsumerWidget {
  const AddReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final pets = ref.watch(petsProvider);
    final selectedPet = useState<String?>(null);
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final selectedType = useState(ReminderType.medication);
    final selectedDate = useState<DateTime?>(null);
    final selectedTime = useState<TimeOfDay?>(null);
    final isLoading = useState(false);
    final isRecurring = useState(false);
    final selectedFrequency = useState('Daily');
    final selectedPriority = useState('Medium');

    // Animation controllers
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    final slideAnimation = useMemoized(
      () =>
          Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(
              parent: animationController,
              curve: Curves.easeOutCubic,
            ),
          ),
      [animationController],
    );

    final fadeAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      ),
      [animationController],
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    // Color scheme
    const primaryColor = Color(0xFF090040);
    const secondaryColor = Color(0xFF471396);
    const accentColor = Color(0xFFB13BFF);
    const highlightColor = Color(0xFFFFCC00);

    Future<void> selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: accentColor,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        selectedDate.value = picked;
      }
    }

    Future<void> selectTime() async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: accentColor,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        selectedTime.value = picked;
      }
    }

    Future<void> saveReminder() async {
      if (!formKey.currentState!.validate()) return;

      if (selectedPet.value == null) {
        _showErrorSnackBar(context, 'Please select a pet');
        return;
      }

      if (selectedDate.value == null || selectedTime.value == null) {
        _showErrorSnackBar(context, 'Please select date and time');
        return;
      }

      isLoading.value = true;

      try {
        final pet = pets.firstWhere((p) => p.id == selectedPet.value);
        final reminderDateTime = DateTime(
          selectedDate.value!.year,
          selectedDate.value!.month,
          selectedDate.value!.day,
          selectedTime.value!.hour,
          selectedTime.value!.minute,
        );

        final reminder = Reminder(
          id: const Uuid().v4(),
          petId: pet.id,
          petName: pet.name,
          title: titleController.text.trim(),
          type: selectedType.value,
          dateTime: reminderDateTime,
          isCompleted: false,
          description: descriptionController.text.trim(),
        );

        ref.read(remindersProvider.notifier).addReminder(reminder);

        if (context.mounted) {
          _showSuccessSnackBar(context, 'Reminder created successfully!');
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(
            context,
            'Error creating reminder: ${e.toString()}',
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Add Reminder',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          if (isLoading.value)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(),
                  const SizedBox(height: 24),

                  // Pet Selection Card
                  _buildPetSelectionCard(pets, selectedPet),
                  const SizedBox(height: 20),

                  // Reminder Details Card
                  _buildReminderDetailsCard(
                    titleController,
                    descriptionController,
                    selectedType,
                    selectedPriority,
                  ),
                  const SizedBox(height: 20),

                  // Date & Time Card
                  _buildDateTimeCard(
                    selectedDate,
                    selectedTime,
                    selectDate,
                    selectTime,
                    context,
                  ),
                  const SizedBox(height: 20),

                  // Advanced Options Card
                  _buildAdvancedOptionsCard(isRecurring, selectedFrequency),
                  const SizedBox(height: 32),

                  // Save Button
                  _buildSaveButton(isLoading, saveReminder),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF471396), Color(0xFFB13BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB13BFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.add_alert, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'Create New Reminder',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Never miss important pet care activities',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelectionCard(List pets, ValueNotifier<String?> selectedPet) {
    return _buildCard(
      title: 'Select Pet',
      icon: Icons.pets,
      child: DropdownButtonFormField<String>(
        value: selectedPet.value,
        hint: const Text('Choose a pet'),
        decoration: _buildInputDecoration('Select your pet'),
        items:
            pets.map((pet) {
              return DropdownMenuItem<String>(
                value: pet.id,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFB13BFF).withOpacity(0.1),
                      child: const Icon(
                        Icons.pets,
                        size: 16,
                        color: Color(0xFFB13BFF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(pet.name),
                  ],
                ),
              );
            }).toList(),
        onChanged: (value) {
          selectedPet.value = value;
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a pet';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildReminderDetailsCard(
    TextEditingController titleController,
    TextEditingController descriptionController,
    ValueNotifier<ReminderType> selectedType,
    ValueNotifier<String> selectedPriority,
  ) {
    return _buildCard(
      title: 'Reminder Details',
      icon: Icons.edit_note,
      child: Column(
        children: [
          TextFormField(
            style: TextStyle(color: Colors.black),
            controller: titleController,
            decoration: _buildInputDecoration('Enter reminder title'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            style: TextStyle(color: Colors.black),
            controller: descriptionController,
            decoration: _buildInputDecoration('Add description (optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ReminderType>(
                  value: selectedType.value,
                  decoration: _buildInputDecoration('Type'),
                  items:
                      ReminderType.values.map((type) {
                        return DropdownMenuItem<ReminderType>(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _getTypeIcon(type),
                                size: 16,
                                color: const Color(0xFFB13BFF),
                              ),
                              const SizedBox(width: 8),
                              Text(type.name.toUpperCase()),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedType.value = value;
                    }
                  },
                ),
              ),
              // const SizedBox(width: 16),
              // Expanded(
              //   child: DropdownButtonFormField<String>(
              //     value: selectedPriority.value,
              //     decoration: _buildInputDecoration('Priority'),
              //     items:
              //         ['High', 'Medium', 'Low'].map((priority) {
              //           return DropdownMenuItem<String>(
              //             value: priority,
              //             child: Row(
              //               children: [
              //                 Container(
              //                   width: 8,
              //                   height: 8,
              //                   decoration: BoxDecoration(
              //                     color: _getPriorityColor(priority),
              //                     shape: BoxShape.circle,
              //                   ),
              //                 ),
              //                 const SizedBox(width: 8),
              //                 Text(priority),
              //               ],
              //             ),
              //           );
              //         }).toList(),
              //     onChanged: (value) {
              //       if (value != null) {
              //         selectedPriority.value = value;
              //       }
              //     },
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(
    ValueNotifier<DateTime?> selectedDate,
    ValueNotifier<TimeOfDay?> selectedTime,
    VoidCallback selectDate,
    VoidCallback selectTime,
    BuildContext context,
  ) {
    return _buildCard(
      title: 'Date & Time',
      icon: Icons.schedule,
      child: Row(
        children: [
          Expanded(
            child: _buildDateTimeSelector(
              label: 'Date',
              value:
                  selectedDate.value == null
                      ? 'Select date'
                      : DateFormat('MMM dd, yyyy').format(selectedDate.value!),
              icon: Icons.calendar_today,
              onTap: selectDate,
              isSelected: selectedDate.value != null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDateTimeSelector(
              label: 'Time',
              value:
                  selectedTime.value == null
                      ? 'Select time'
                      : selectedTime.value!.format(context),
              icon: Icons.access_time,
              onTap: selectTime,
              isSelected: selectedTime.value != null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsCard(
    ValueNotifier<bool> isRecurring,
    ValueNotifier<String> selectedFrequency,
  ) {
    return _buildCard(
      title: 'Advanced Options',
      icon: Icons.tune,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recurring Reminder',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Switch(
                value: isRecurring.value,
                onChanged: (value) {
                  isRecurring.value = value;
                },
                activeColor: const Color(0xFFB13BFF),
              ),
            ],
          ),
          if (isRecurring.value) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedFrequency.value,
              decoration: _buildInputDecoration('Frequency'),
              items:
                  ['Daily', 'Weekly', 'Monthly'].map((frequency) {
                    return DropdownMenuItem<String>(
                      value: frequency,
                      child: Text(frequency),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedFrequency.value = value;
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    ValueNotifier<bool> isLoading,
    VoidCallback saveReminder,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF471396), Color(0xFFB13BFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB13BFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading.value ? null : saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            isLoading.value
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Save Reminder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB13BFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFFB13BFF)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF090040),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFFB13BFF) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color:
                  isSelected
                      ? const Color(0xFFB13BFF).withOpacity(0.05)
                      : Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF090040) : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                Icon(
                  icon,
                  color:
                      isSelected ? const Color(0xFFB13BFF) : Colors.grey[600],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB13BFF), width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.feeding:
        return Icons.restaurant;
      case ReminderType.grooming:
        return Icons.content_cut;
      case ReminderType.exercise:
        return Icons.directions_run;
      case ReminderType.veterinary:
        return Icons.local_hospital;
      default:
        return Icons.notifications;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return const Color(0xFFFFCC00);
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
