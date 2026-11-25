import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class NewBookingScreen extends StatelessWidget {
  const NewBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {
                  context.pop();
                }, icon: HugeIcon(icon: HugeIcons.strokeRoundedChevronLeft)),
        title: Text("Booking Form"),
      ),
      body:Center(child: Text("Booking"),)
    );
  }
}
