import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../../../core/theme/theme_provider.dart';

class switch_toggle extends StatelessWidget {
  const switch_toggle({super.key, required this.themeProvider});

  final ThemeProvider themeProvider;

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
      inactiveSwitchBorder: Border.all(color: Color(0xFFC03355), width: 2),
      inactiveColor: const Color(0xFFFCF3F6),
      value: themeProvider.themeMode == ThemeMode.dark,
      onToggle: (value) {
        themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
      },
    );
  }
}
