import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool showBorder;
  final bool isObscure;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  const AppTextField({
    required this.controller,
    this.hintText,
    this.validator,
    this.showBorder = false,
    this.isObscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    super.key,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // going below a height will cause the field to shrink.
      height: 65,
      child: TextFormField(
        cursorColor: Colors.black,
        cursorErrorColor: Colors.black,
        style: TextStyle(
          fontFamily: GoogleFonts.manrope(
            fontWeight: FontWeight.w400,
          ).fontFamily,
          color: Color(0xff000000),
        ),
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: keyboardType,
        obscureText: isObscure,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: TextStyle(color: Colors.white),
          hintText: hintText,
          fillColor: Color(0xffF2F4F6), // check condition afterwards
          filled: true,
          hintStyle: TextStyle(
            fontFamily: GoogleFonts.manrope(
              fontWeight: FontWeight.w400,
            ).fontFamily,
            fontSize: 14,
            color: Colors.grey[500],
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: showBorder
                ? BorderSide(color: Color(0xff9E9E9E), width: 2)
                : BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: showBorder
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 1,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
