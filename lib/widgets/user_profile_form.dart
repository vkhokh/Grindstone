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
    this.nameErrorText,
    this.heightErrorText,
    this.weightErrorText,
    this.genderErrorText,
    this.onNameChanged,
    this.onHeightChanged,
    this.onWeightChanged,
  });

  final TextEditingController nameController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final UserGender? selectedGender;
  final ValueChanged<UserGender> onGenderSelected;

  final String? nameErrorText;
  final String? heightErrorText;
  final String? weightErrorText;
  final String? genderErrorText;

  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onHeightChanged;
  final ValueChanged<String>? onWeightChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildGenderSelector(),
        if (genderErrorText != null) ...[
          const SizedBox(height: 6),
          _buildErrorText(genderErrorText!),
        ],
        const SizedBox(height: 18),

        _buildTextField(
          controller: nameController,
          hintText: 'Имя',
          errorText: nameErrorText,
          textCapitalization: TextCapitalization.words,
          onChanged: onNameChanged,
        ),

        const SizedBox(height: 18),

        _buildTextField(
          controller: heightController,
          hintText: 'Рост (см)',
          errorText: heightErrorText,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onHeightChanged,
        ),

        const SizedBox(height: 18),

        _buildTextField(
          controller: weightController,
          hintText: 'Вес (кг)',
          errorText: weightErrorText,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          onChanged: onWeightChanged,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: hintTextForegroundColor,
            ),
            filled: true,
            fillColor: inputInnerColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red : inputOutlineBorderColor,
                width: hasError ? 1.5 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red : inputOutlineBorderColor,
                width: hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.red : inputOutlineBorderColor,
                width: hasError ? 1.8 : 1.4,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          _buildErrorText(errorText),
        ],
      ],
    );
  }

  Widget _buildErrorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
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