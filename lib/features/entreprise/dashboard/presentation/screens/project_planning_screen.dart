import 'package:flutter/material.dart';

class ProjectPlanningScreen extends StatefulWidget {
  const ProjectPlanningScreen({super.key});

  @override
  State<ProjectPlanningScreen> createState() => _ProjectPlanningScreenState();
}

class _ProjectPlanningScreenState extends State<ProjectPlanningScreen> {
  final List<Map<String, dynamic>> _phases = [
    {'titre': 'Développement architectural', 'completed': true},
    {'titre': 'Design d\'intérieur', 'completed': true},
    {'titre': 'Construction', 'completed': true},
    {'titre': 'Améliorations de l\'habitat', 'completed': true},
    {'titre': 'Rénovations', 'completed': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1E16), // Fond sombre aux tons chauds
      appBar: AppBar(
        title: const Text('Planning du Projet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Carte principale avec dégradé marron/doré
              Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC78438), Color(0xFF91571F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40), // Espace pour l'en-tête flottant
                    ...List.generate(_phases.length, (index) {
                      final phase = _phases[index];
                      return _buildChecklistItem(
                        title: phase['titre'],
                        isCompleted: phase['completed'],
                        isLast: index == _phases.length - 1,
                        onTap: () {
                          setState(() {
                            phase['completed'] = !phase['completed'];
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // En-tête flottant "Nos Services" (style ruban)
              Positioned(
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B4D10), Color(0xFF5E3206)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFDCA96F).withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Nos Services',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required String title,
    required bool isCompleted,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isCompleted ? 0.05 : 0.0), // Légère surbrillance si coché
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
        ),
        child: Row(
          children: [
            // Icône étoilée/dentelée pour simuler le badge de validation de l'image
            Icon(
              isCompleted ? Icons.verified : Icons.verified_outlined,
              color: isCompleted ? const Color(0xFFFFB300) : Colors.white54,
              size: 28,
              shadows: isCompleted ? [
                const Shadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(1, 1),
                )
              ] : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
