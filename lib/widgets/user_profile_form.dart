import 'package:dp/colors.dart';
import 'package:dp/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfileForm extends StatelessWidget {
  const UserProfileForm({
    super.key,
    required this.nameController,
    required this.heightController,
    required this.weightController,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  final TextEditingController nameController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final UserGender? selectedGender;
  final ValueChanged<UserGender> onGenderSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildGenderSelector(),
        const SizedBox(height: 18),
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Имя',
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: heightController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Рост (см)',
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: const InputDecoration(
            hintText: 'Вес (кг)',
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: _GenderOptionButton(
            label: UserGender.male.label,
            isSelected: selectedGender == UserGender.male,
            onTap: () => onGenderSelected(UserGender.male),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderOptionButton(
            label: UserGender.female.label,
            isSelected: selectedGender == UserGender.female,
            onTap: () => onGenderSelected(UserGender.female),
          ),
        ),
      ],
    );
  }
}

class _GenderOptionButton extends StatelessWidget {
  const _GenderOptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? elevatedButtonBackgroundColor : inputInnerColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? elevatedButtonForegroundColor
                  : inputOutlineBorderColor,
              width: isSelected ? 2.5 : 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.barlow(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: elevatedButtonForegroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
