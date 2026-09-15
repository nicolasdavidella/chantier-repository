import 'package:flutter/material.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: const Text('Gestion des Tâches'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Vue de Gestion des Tâches',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
