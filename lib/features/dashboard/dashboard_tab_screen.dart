import 'package:flutter/material.dart';

class DashboardTabScreen extends StatelessWidget {
  final String title;

  const DashboardTabScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}