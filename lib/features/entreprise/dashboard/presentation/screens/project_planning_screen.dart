import 'package:flutter/material.dart';

class ProjectPlanningScreen extends StatelessWidget {
  const ProjectPlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: const Text('Project Planning'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Vue de Planification (Calendrier)',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
