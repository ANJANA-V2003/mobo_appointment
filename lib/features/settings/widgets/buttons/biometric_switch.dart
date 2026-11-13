import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class biometric_switch extends StatelessWidget {
  const biometric_switch({
    super.key,
    required this.isDark,
    required this.onChanged,
    required this.value,
  });

  final bool isDark;

  final ValueChanged<bool> onChanged;

  final bool value;

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      width: 70,
      height: 40,
      toggleSize: 28,
      borderRadius: 20,
      activeColor: const Color(0xFFC03355),
      activeToggleColor: Colors.white,
      inactiveToggleColor: const Color(0xFFC03355),
      activeSwitchBorder: Border.all(color: Color(0xFFC03355), width: 2),
      inactiveSwitchBorder: Border.all(
        color: isDark ? Colors.grey : Color(0xFFC03355),
        width: 2,
      ),
      inactiveColor: isDark ? Colors.grey.shade900 : const Color(0xFFFCF3F6),
      value: value,
      onToggle: onChanged,
    );
  }
}
