import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_pet_care_and_veterinary_app/application/provider/pet_provider.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/pet.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddPetScreen extends HookConsumerWidget {
  final Pet? editingPet;

  const AddPetScreen({super.key, this.editingPet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController();
    final ageController = useTextEditingController();
    final breedController = useTextEditingController();
    final selectedGender = useState<String>('Male');
    final selectedImage = useState<File?>(null);
    final isLoading = useState(false);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    final fadeController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );
    final slideAnimation = useMemoized(
      () => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
      ),
      [animationController],
    );
    final fadeAnimation = useMemoized(
      () => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: fadeController, curve: Curves.easeInOut),
      ),
      [fadeController],
    );
    final fadeAnimationOpacity = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: fadeController, curve: Curves.easeInOut),
      ),
    );

    final ImagePicker picker = ImagePicker();
    final isEditing = editingPet != null;

    // Color scheme
    const Color primaryDark = Color(0xFF090040);
    const Color primaryPurple = Color(0xFF471396);
    const Color accent = Color(0xFFB13BFF);
    const Color warning = Color(0xFFFFCC00);

    useEffect(() {
      animationController.forward();
      fadeController.forward();
      return null;
    }, []);

    // Pre-populate form fields if editing
    useEffect(() {
      if (editingPet != null) {
        nameController.text = editingPet!.name;
        ageController.text = editingPet!.age.toString();
        breedController.text = editingPet!.breed;
        selectedGender.value = editingPet!.gender;
        if (editingPet!.photoPath != null) {
          selectedImage.value = File(editingPet!.photoPath!);
        }
      }
      return null;
    }, [editingPet]);

    Future<void> pickImage() async {
      try {
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 600,
          imageQuality: 85,
        );

        if (image != null) {
          selectedImage.value = File(image.path);
        }
      } catch (e) {
        if (context.mounted) {
          _showCustomSnackBar(
            context,
            'Error picking image: $e',
            isError: true,
          );
        }
      }
    }

    Future<void> savePet() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        final pet = Pet(
          id: isEditing ? editingPet!.id : const Uuid().v4(),
          name: nameController.text.trim(),
          age: int.parse(ageController.text.trim()),
          breed: breedController.text.trim(),
          gender: selectedGender.value,
          photoPath: selectedImage.value?.path,
          medicalHistory: isEditing ? editingPet!.medicalHistory : [],
        );

        if (isEditing) {
          ref.read(petsProvider.notifier).updatePet(pet);
        } else {
          ref.read(petsProvider.notifier).addPet(pet);
        }

        if (context.mounted) {
          _showCustomSnackBar(
            context,
            isEditing ? 'Pet updated successfully!' : 'Pet added successfully!',
            isError: false,
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          _showCustomSnackBar(
            context,
            isEditing ? 'Error updating pet: $e' : 'Error adding pet: $e',
            isError: true,
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedBuilder(
                animation: fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: fadeAnimationOpacity,
                    child: Text(
                      isEditing ? 'Edit Pet' : 'Add New Pet',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  );
                },
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryDark, primaryPurple],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: warning.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: SlideTransition(
              position: slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Section with Animation
                      Center(
                        child: AnimatedBuilder(
                          animation: fadeAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: fadeAnimation.value,
                              child: _buildPhotoSection(
                                selectedImage.value,
                                pickImage,
                                isEditing,
                                accent,
                                warning,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Form Fields
                      _buildAnimatedFormField(
                        controller: nameController,
                        label: 'Pet Name',
                        hint: 'Enter your pet\'s name',
                        icon: Icons.pets,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter pet name';
                          }
                          return null;
                        },
                        primaryColor: primaryPurple,
                        accentColor: accent,
                        delay: 200,
                      ),
                      const SizedBox(height: 20),

                      _buildAnimatedFormField(
                        controller: ageController,
                        label: 'Age (years)',
                        hint: 'Enter pet\'s age',
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter pet age';
                          }
                          final age = int.tryParse(value.trim());
                          if (age == null || age < 0 || age > 50) {
                            return 'Please enter a valid age (0-50)';
                          }
                          return null;
                        },
                        primaryColor: primaryPurple,
                        accentColor: accent,
                        delay: 400,
                      ),
                      const SizedBox(height: 20),

                      _buildAnimatedFormField(
                        controller: breedController,
                        label: 'Breed',
                        hint: 'Enter pet\'s breed',
                        icon: Icons.category,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter pet breed';
                          }
                          return null;
                        },
                        primaryColor: primaryPurple,
                        accentColor: accent,
                        delay: 600,
                      ),
                      const SizedBox(height: 30),

                      // Gender Selection with Animation
                      _buildAnimatedGenderSection(
                        selectedGender,
                        primaryPurple,
                        accent,
                        warning,
                      ),
                      const SizedBox(height: 40),

                      // Save Button with Animation
                      _buildAnimatedSaveButton(
                        isLoading.value,
                        savePet,
                        isEditing,
                        primaryDark,
                        accent,
                        warning,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(
    File? selectedImage,
    VoidCallback onTap,
    bool isEditing,
    Color accent,
    Color warning,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withOpacity(0.1), warning.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(70),
          border: Border.all(color: accent, width: 3),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child:
            selectedImage != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(67),
                  child: Image.file(selectedImage, fit: BoxFit.cover),
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, size: 40, color: accent),
                    const SizedBox(height: 8),
                    Text(
                      isEditing ? 'Change Photo' : 'Add Photo',
                      style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildAnimatedFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required Color primaryColor,
    required Color accentColor,
    required int delay,
    TextInputType? keyboardType,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  prefixIcon: Icon(icon, color: accentColor, size: 24),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  labelStyle: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                validator: validator,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedGenderSection(
    ValueNotifier<String> selectedGender,
    Color primaryColor,
    Color accentColor,
    Color warningColor,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderOption(
                          'Male',
                          Icons.male,
                          selectedGender.value == 'Male',
                          () => selectedGender.value = 'Male',
                          accentColor,
                          warningColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildGenderOption(
                          'Female',
                          Icons.female,
                          selectedGender.value == 'Female',
                          () => selectedGender.value = 'Female',
                          accentColor,
                          warningColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderOption(
    String gender,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    Color accentColor,
    Color warningColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [accentColor, warningColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          color: isSelected ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSaveButton(
    bool isLoading,
    VoidCallback onPressed,
    bool isEditing,
    Color primaryColor,
    Color accentColor,
    Color warningColor,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEditing ? Icons.edit : Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isEditing ? 'Update Pet' : 'Add Pet',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        );
      },
    );
  }

  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isError ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isError ? Icons.error : Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
