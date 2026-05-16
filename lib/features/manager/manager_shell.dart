import 'package:flutter/material.dart';

class ManagerShell extends StatelessWidget {
  final Widget child;
  const ManagerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager View')),
      body: child,
    );
  }
}
