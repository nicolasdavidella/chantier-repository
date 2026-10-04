import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ia_project_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IaProjectForm extends ConsumerStatefulWidget {
  const IaProjectForm({Key? key}) : super(key: key);

  @override
  ConsumerState<IaProjectForm> createState() => _IaProjectFormState();
}

class _IaProjectFormState extends ConsumerState<IaProjectForm> {
  final _formKey = GlobalKey<FormState>();
  
  String? titre;
  String? ville;
  String? quartier;
  String typeConstruction = 'maison individuelle';
  int nombreChambres = 3;
  int nombreSallesDeBain = 2;
  double superficieTerrain = 500;
  double budgetPrevisionnel = 15000000;
  String? delai;
  String? description;
  
  XFile? _selectedImage;
  bool _useImage = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  final List<String> villesCameroun = ['Yaoundé', 'Douala', 'Bafoussam', 'Garoua', 'Maroua', 'Bamenda', 'Kribi', 'Limbé', 'Buéa', 'Ngaoundéré'];
  final List<String> typesConstruction = ['maison individuelle', 'villa', 'duplex/immeuble', 'studio', 'rénovation', 'extension', 'clôture'];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Parlez-nous de votre projet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titre du projet', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                onSaved: (v) => titre = v,
              ),
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Ville', border: OutlineInputBorder()),
                items: villesCameroun.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (v) => setState(() => ville = v),
                validator: (v) => v == null ? 'Requis' : null,
                onSaved: (v) => ville = v,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: const InputDecoration(labelText: 'Quartier', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                onSaved: (v) => quartier = v,
              ),
              const SizedBox(height: 16),
              
              const Text('Type de construction', style: TextStyle(fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8,
                children: typesConstruction.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: typeConstruction == type,
                    onSelected: (selected) {
                      if (selected) setState(() => typeConstruction = type);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Chambres', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: '3',
                      onSaved: (v) => nombreChambres = int.tryParse(v ?? '3') ?? 3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Salles de bain', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: '2',
                      onSaved: (v) => nombreSallesDeBain = int.tryParse(v ?? '2') ?? 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: const InputDecoration(labelText: 'Superficie estimée du terrain (m²)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                initialValue: '500',
                onSaved: (v) => superficieTerrain = double.tryParse(v ?? '500') ?? 500,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                decoration: const InputDecoration(labelText: 'Budget prévisionnel (FCFA)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                initialValue: '15000000',
                onSaved: (v) => budgetPrevisionnel = double.tryParse(v ?? '15000000') ?? 15000000,
              ),
              const SizedBox(height: 12),
              
              const Text('Source d\'inspiration 3D', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Description textuelle'),
                      value: false,
                      groupValue: _useImage,
                      onChanged: (val) => setState(() => _useImage = val!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Image / Croquis'),
                      value: true,
                      groupValue: _useImage,
                      onChanged: (val) => setState(() => _useImage = val!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              if (!_useImage)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description de la maison', border: OutlineInputBorder()),
                  maxLines: 3,
                  maxLength: 800,
                  validator: (v) => !_useImage && (v == null || v.isEmpty) ? 'Requis' : null,
                  onSaved: (v) => description = v,
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Téléverser une image'),
                    ),
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Fichier sélectionné : ${_selectedImage!.name}', style: const TextStyle(color: Colors.green)),
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              
              ElevatedButton.icon(
                onPressed: () {
                  // MOCK: Position
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Position captée (Simulée)')));
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Capter ma position'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Estimation et génération du plan',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_useImage && _selectedImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez téléverser une image.')));
                        return;
                      }
                      
                      _formKey.currentState!.save();
                      
                      final formData = {
                        'titre': titre,
                        'ville': ville,
                        'quartier': quartier,
                        'typeConstruction': typeConstruction,
                        'nombreChambres': nombreChambres,
                        'nombreSallesDeBain': nombreSallesDeBain,
                        'surfaceTerrain': superficieTerrain,
                        'budgetPrevisionnel': budgetPrevisionnel,
                        'delai': delai,
                        'description': _useImage ? null : description,
                        'imagePath': _useImage ? _selectedImage?.path : null,
                        'lat': 3.8480, // Mock Yaounde lat
                        'lng': 11.5021, // Mock Yaounde lng
                      };
                      
                      ref.read(iaProjectProvider.notifier).submitProjectForm(formData);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
