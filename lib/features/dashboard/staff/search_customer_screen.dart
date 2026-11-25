import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class SearchCustomerScreen extends StatelessWidget {
  const SearchCustomerScreen({super.key});

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
        title: Text("Search"),
      ),
      body: Center(child: Text("Search screen")),
    );
  }
}
