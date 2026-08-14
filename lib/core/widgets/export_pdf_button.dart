import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:printing/printing.dart';
import '../theme/app_spacing.dart';

class ExportPdfButton extends StatefulWidget {
  final Future<Uint8List> Function() onGenerate;
  final String fileName;
  final String label;

  const ExportPdfButton({
    super.key,
    required this.onGenerate,
    this.fileName = 'document.pdf',
    this.label = 'Exporter en PDF',
  });

  @override
  State<ExportPdfButton> createState() => _ExportPdfButtonState();
}

class _ExportPdfButtonState extends State<ExportPdfButton> {
  bool _isGenerating = false;

  Future<void> _handleExport() async {
    setState(() => _isGenerating = true);
    
    try {
      // Génère le document en binaire
      final bytes = await widget.onGenerate();
      
      // Affiche le menu de partage natif (qui inclut WhatsApp, Email, Sauvegarder dans Fichiers...)
      // Sur mobile, l'utilisateur verra WhatsApp en priorité si l'app est très utilisée
      await Printing.sharePdf(
        bytes: bytes,
        filename: widget.fileName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la génération: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton.icon(
      onPressed: _isGenerating ? null : _handleExport,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),
      icon: _isGenerating 
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.picture_as_pdf),
      label: Text(_isGenerating ? 'Génération...' : widget.label),
    ).animate(target: _isGenerating ? 1 : 0)
     .shimmer(duration: 1.seconds);
  }
}
