import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../../data/models/user_model.dart';
import '../../../../core/theme/app_spacing.dart';

class EditableInfoSection extends StatefulWidget {
  final UserModel user;

  const EditableInfoSection({super.key, required this.user});

  @override
  State<EditableInfoSection> createState() => _EditableInfoSectionState();
}

class _EditableInfoSectionState extends State<EditableInfoSection> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  String? _savingField;
  String? _savedField;
  Timer? _savedTimer;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.nom);
    _phoneCtrl = TextEditingController(text: widget.user.telephone);
    _emailCtrl = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _savedTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveField(String field, String value) async {
    setState(() => _savingField = field);
    
    // Simuler un appel réseau pour sauvegarde
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _savingField = null;
        _savedField = field;
      });
      
      _savedTimer?.cancel();
      _savedTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _savedField = null);
      });
    }
  }

  Widget _buildEditableRow(String label, IconData icon, TextEditingController controller, String fieldKey) {
    final theme = Theme.of(context);
    final isSaving = _savingField == fieldKey;
    final isSaved = _savedField == fieldKey;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            // Sauvegarder automatiquement lors de la perte de focus
            _saveField(fieldKey, controller.text);
          }
        },
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
            suffixIcon: isSaving
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : isSaved
                    ? const Icon(Icons.check_circle, color: Colors.green).animate().scale(curve: Curves.elasticOut)
                    : null,
          ),
          onFieldSubmitted: (val) => _saveField(fieldKey, val),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations Personnelles',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.vLg,
        _buildEditableRow('Nom complet', Icons.person_outline, _nameCtrl, 'name'),
        _buildEditableRow('Numéro de téléphone', Icons.phone_outlined, _phoneCtrl, 'phone'),
        _buildEditableRow('Adresse e-mail', Icons.email_outlined, _emailCtrl, 'email'),
      ],
    );
  }
}
