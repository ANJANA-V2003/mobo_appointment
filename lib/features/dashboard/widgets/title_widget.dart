import 'package:flutter/widgets.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class title_widget extends StatelessWidget {
  const title_widget({
    super.key,
    required this.text,
  });


  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}