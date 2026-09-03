import 'package:flutter/material.dart';

class DocumentsReportsScreen extends StatelessWidget {
  const DocumentsReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: const Text('Documents & Reports'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Vue des Documents et Rapports',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
