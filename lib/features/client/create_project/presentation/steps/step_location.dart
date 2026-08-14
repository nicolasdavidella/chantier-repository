import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../providers/create_project_provider.dart';

class StepLocation extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  
  const StepLocation({super.key, required this.formKey});

  @override
  ConsumerState<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends ConsumerState<StepLocation> {
  late TextEditingController _quartierController;
  String _selectedVille = 'Douala';
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;

  final List<String> _villes = [
    'Douala',
    'Yaoundé',
    'Bafoussam',
    'Bamenda',
    'Garoua',
    'Maroua',
    'Ngaoundéré',
    'Kribi',
    'Limbé',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    final data = ref.read(projectCreationProvider).value;
    _quartierController = TextEditingController(text: data?.quartier);
    if (data != null) {
      if (data.ville.isNotEmpty) {
        _selectedVille = data.ville;
      }
      _latitude = data.latitude;
      _longitude = data.longitude;
    }
  }

  @override
  void dispose() {
    _quartierController.dispose();
    super.dispose();
  }

  void _saveData() {
    ref.read(projectCreationProvider.notifier).updateField(
      ville: _selectedVille,
      quartier: _quartierController.text,
      latitude: _latitude,
      longitude: _longitude,
    );
  }

  Future<void> _getLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Les services de localisation sont désactivés.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Les permissions de localisation sont refusées.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Les permissions de localisation sont définitivement refusées.');
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      _saveData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Position géographique récupérée avec succès !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: widget.formKey,
        onChanged: _saveData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Où se trouve le chantier ?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.vSm,
            Text(
              'La localisation aide les entreprises proches à vous trouver facilement.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            AppSpacing.vXxl,
            DropdownButtonFormField<String>(
              value: _selectedVille,
              decoration: const InputDecoration(
                labelText: 'Ville',
                prefixIcon: Icon(Icons.location_city),
              ),
              items: _villes.map((ville) {
                return DropdownMenuItem(value: ville, child: Text(ville));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedVille = val);
                  _saveData();
                }
              },
            ),
            AppSpacing.vLg,
            TextFormField(
              controller: _quartierController,
              decoration: const InputDecoration(
                labelText: 'Quartier / Lieu-dit',
                hintText: 'Ex: Bonapriso, Akwa, Bastos...',
                prefixIcon: Icon(Icons.map),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Le quartier est requis' : null,
            ),
            AppSpacing.vLg,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLocating ? null : _getLocation,
                icon: _isLocating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
                label: Text(_latitude != null 
                    ? 'Position enregistrée (${_latitude!.toStringAsFixed(3)}, ${_longitude!.toStringAsFixed(3)})' 
                    : 'Me géolocaliser (optionnel)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  side: BorderSide(
                    color: _latitude != null ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                  foregroundColor: _latitude != null ? Colors.green : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
