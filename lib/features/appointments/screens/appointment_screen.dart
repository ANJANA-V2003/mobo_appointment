import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: HugeIcon(icon: HugeIcons.strokeRoundedChevronLeft),
        ),
        title: Text(
          "Appointments",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(child: Text("Appointments")),
    );
  }
}
