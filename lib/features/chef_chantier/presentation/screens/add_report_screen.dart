import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/connectivity/sync_queue_provider.dart';
import '../../providers/chef_chantier_providers.dart';

class AddReportScreen extends ConsumerStatefulWidget {
  final String projectId;

  const AddReportScreen({super.key, required this.projectId});

  @override
  ConsumerState<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends ConsumerState<AddReportScreen> {
  double _progress = 0;
  bool _photoTaken = false;
  bool _isRecording = false;
  final TextEditingController _descController = TextEditingController();
  final Set<String> _selectedTasks = {};

  void _takePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ouverture de l\'appareil photo...')));
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _photoTaken = true);
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Écoute en cours (simulation)...')));
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isRecording) {
          setState(() {
            _descController.text += ' Les fondations avancent bien, nous avons coulé 4 semelles aujourd\'hui.';
            _isRecording = false;
          });
        }
      });
    }
  }

  void _saveReport() {
    if (!_photoTaken) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez prendre une photo du chantier !')));
      return;
    }

    final reportData = {
      'projectId': widget.projectId,
      'progress': _progress,
      'description': _descController.text,
      'tasks': _selectedTasks.toList(),
      'timestamp': DateTime.now().toIso8601String(),
      'location': 'Lat: 4.0511, Lng: 9.7085', // Simulated GPS
    };

    final item = SyncAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'report',
      data: reportData,
    );

    ref.read(syncQueueProvider.notifier).addAction(item);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapport enregistré en mode hors-ligne. Synchronisation dès que le réseau sera disponible.')),
    );
    context.pop();
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = ref.watch(chefTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Rapport')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 1. Photo Capture (Big Button)
          InkWell(
            onTap: _takePhoto,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: _photoTaken ? Colors.green.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: _photoTaken ? Colors.green : theme.colorScheme.outline, width: 2),
                image: _photoTaken 
                    ? const DecorationImage(
                        image: NetworkImage('https://picsum.photos/seed/rapport-photo/500/350'), 
                        fit: BoxFit.cover,
                      ) 
                    : null,
              ),
              child: _photoTaken
                  ? Center(child: Container(padding: const EdgeInsets.all(8), color: Colors.black54, child: const Icon(Icons.check_circle, color: Colors.white, size: 48)))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 64, color: theme.colorScheme.primary),
                        AppSpacing.vSm,
                        const Text('Prendre une photo (Requis)', style: TextStyle(fontWeight: FontWeight.bold)),
                        AppSpacing.vXs,
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                            Text(' Position GPS activée', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          AppSpacing.vXxl,

          // 2. Progress Slider
          Text('Avancement Global: ${_progress.toInt()}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Slider(
            value: _progress,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_progress.toInt()}%',
            onChanged: (val) => setState(() => _progress = val),
          ).animate().slideX(begin: 0.1).fadeIn(delay: 100.ms),

          AppSpacing.vXxl,

          // 3. Description with Voice Input
          Text('Commentaires', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Décrivez l\'avancement...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              AppSpacing.hSm,
              InkWell(
                onTap: _toggleRecording,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ).animate(target: _isRecording ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2)),
            ],
          ).animate().slideX(begin: 0.1).fadeIn(delay: 200.ms),

          AppSpacing.vXxl,

          // 4. Tasks Checkboxes
          Text('Tâches concernées', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          AppSpacing.vSm,
          ...tasks.map((t) => CheckboxListTile(
                title: Text(t.titre),
                value: _selectedTasks.contains(t.id),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedTasks.add(t.id);
                    } else {
                      _selectedTasks.remove(t.id);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              )).toList().animate().fadeIn(delay: 300.ms),

          AppSpacing.vXxl,
          AppSpacing.vXxl,

          SizedBox(
            width: double.infinity,
            height: 60,
            child: AppButton(
              onPressed: _saveReport,
              text: 'ENREGISTRER',
              icon: Icons.save,
            ),
          ).animate().scale(delay: 400.ms),
          
          AppSpacing.vXxl,
        ],
      ),
    );
  }
}
