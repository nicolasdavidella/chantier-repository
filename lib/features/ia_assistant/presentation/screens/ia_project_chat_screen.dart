import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../providers/ia_project_provider.dart';
import '../../../../core/providers/settings_provider.dart';
import '../widgets/lix_iridescent_orb.dart';
import '../widgets/ai_generation_matrix_card.dart';

class IaProjectChatScreen extends ConsumerStatefulWidget {
  const IaProjectChatScreen({super.key});

  @override
  ConsumerState<IaProjectChatScreen> createState() => _IaProjectChatScreenState();
}

class _IaProjectChatScreenState extends ConsumerState<IaProjectChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  XFile? _attachedImage;

  // Paramètres par défaut de modélisation 3D
  final String _selectedType = 'Villa';

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _attachedImage = picked);
    }
  }

  void _submitPrompt([String? customPrompt]) {
    final text = customPrompt ?? _textController.text.trim();
    if (text.isEmpty && _attachedImage == null) return;

    _textController.clear();
    final imagePath = _attachedImage?.path;
    setState(() => _attachedImage = null);

    ref.read(iaProjectProvider.notifier).answerQuestion(text, imagePath: imagePath);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider);
    final isFrench = language == 'fr';
    final state = ref.watch(iaProjectProvider);

    // Auto-scroll sur nouveaux messages
    ref.listen(iaProjectProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    final visibleMessages = state.messages.where((m) => !m.isForm && m.text.isNotEmpty).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Fond beige doux élégant / blanc cassé
      body: Stack(
        children: [
          // ── Éclairages d'ambiance et dégradés subtils vert sage / menthe ──
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8F5E9).withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -60,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDCFCE7).withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 280,
            right: -30,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF0FDF4).withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu principal (Top bar + Fil de discussion + Barre de saisie) ──
          SafeArea(
            child: Column(
              children: [
                // Top Bar épurée : Retour, Titre NICO IA, Réinitialiser
                _buildAuraTopBar(context, isFrench),

                // Fil de messages ou écran d'accueil avec suggestions
                Expanded(
                  child: visibleMessages.isEmpty
                      ? _buildEmptyState(context, isFrench)
                      : _buildMessagesList(context, state, visibleMessages, isFrench),
                ),

                // Barre de saisie et d'édition de messages
                _buildAuraInputBar(context, isFrench),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Top Bar épurée (NICO IA)
  // ─────────────────────────────────────────────
  Widget _buildAuraTopBar(BuildContext context, bool isFrench) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Retour vers le Dashboard
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4D3E).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1B4D3E), size: 18),
              tooltip: isFrench ? 'Retour au tableau de bord' : 'Back to dashboard',
              onPressed: () => context.pop(),
            ),
          ),

          // Badge central NICO IA
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF81C784).withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B4D3E).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.architecture_rounded, color: Color(0xFF2E7D32), size: 16),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Studio 3D',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF1B4D3E),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF81C784).withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      '3D ARCHI',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton Nouvelle Session / Recommencer
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4D3E).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1B4D3E), size: 22),
              tooltip: isFrench ? 'Nouvelle session' : 'New session',
              onPressed: () {
                ref.read(iaProjectProvider.notifier).resetSession();
                setState(() => _attachedImage = null);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Écran d'accueil quand la conversation commence
  // ─────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context, bool isFrench) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // L'Orbe holographique Aura aux reflets vert émeraude & or
          const AuraOrb(size: 130)
              .animate()
              .fadeIn(duration: 700.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

          const SizedBox(height: 22),

          Text(
            isFrench ? 'Studio de Conception 3D' : '3D Design Studio',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4D3E),
              letterSpacing: -0.3,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 8),

          Text(
            isFrench
                ? 'Concevez vos plans de maison en 3D, simulez vos devis et estimez vos matériaux en quelques échanges.'
                : 'Design 3D floor plans, simulate estimates and calculate construction materials.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 28),

          // Suggestions rapides éditables en 1 clic
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              isFrench ? 'Idées de projets :' : 'Suggested projects:',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 12),

          _suggestionCard(
            icon: Icons.architecture_rounded,
            title: isFrench ? 'Villa contemporaine 4 chambres' : 'Modern 4-bedroom villa',
            subtitle: isFrench
                ? 'Maquette 3D avec salon spacieux, cuisine ouverte et terrasse'
                : '3D model with open living and terrace',
            onTap: () {
              _textController.text = isFrench
                  ? 'Génère une villa contemporaine de plain-pied avec 4 chambres, salon spacieux et terrasse'
                  : 'Generate a single-story contemporary villa with 4 bedrooms, spacious living room, and terrace';
            },
          ),
          const SizedBox(height: 10),

          _suggestionCard(
            icon: Icons.calculate_outlined,
            title: isFrench ? 'Estimation des matériaux gros œuvre' : 'Core structure estimation',
            subtitle: isFrench
                ? 'Calculer les briques, sacs de ciment et ferraillage pour 200m²'
                : 'Calculate bricks, cement bags and rebar for 200sqm',
            onTap: () {
              _textController.text = isFrench
                  ? 'Estime le coût et la quantité de matériaux (ciment, briques, ferraillage) pour un bâtiment de 200m²'
                  : 'Estimate cost and materials (cement, bricks, rebar) for a 200sqm building';
            },
          ),
          const SizedBox(height: 10),

          _suggestionCard(
            icon: Icons.domain_rounded,
            title: isFrench ? 'Duplex moderne avec garage' : 'Modern duplex with garage',
            subtitle: isFrench
                ? 'Plan d\'étage avec balcon et suite parentale à Yaoundé'
                : 'Floor plan with balcony and master suite',
            onTap: () {
              _textController.text = isFrench
                  ? 'Conçois un plan 3D pour un duplex avec garage et balcon à Yaoundé'
                  : 'Design a 3D floor plan for a duplex with garage and balcony in Yaoundé';
            },
          ),
        ],
      ),
    );
  }

  Widget _suggestionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC8E6C9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4D3E).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1B4D3E),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF81C784), size: 14),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Liste des messages (Questions / Réponses)
  // ─────────────────────────────────────────────
  Widget _buildMessagesList(
    BuildContext context,
    IaProjectState state,
    List<IaMessage> messages,
    bool isFrench,
  ) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + (state.isTyping && !state.isGenerating3D ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && state.isTyping && !state.isGenerating3D) {
          return _buildAuraTypingIndicator(isFrench);
        }
        final msg = messages[index];

        if (msg.isUser) {
          // Bulle de message utilisateur (Nuance Vert Forêt)
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1B4D3E),
                    Color(0xFF14382C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: const Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1B4D3E).withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              child: Text(
                msg.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          );
        } else {
          // Réponse de NICO IA avec mini-orbe Aura
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: AuraOrb(size: 28),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18).copyWith(
                            topLeft: const Radius.circular(4),
                          ),
                          border: Border.all(
                            color: const Color(0xFFC8E6C9),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B4D3E).withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Studio 3D',
                                  style: TextStyle(
                                    color: Color(0xFF1B4D3E),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.5,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              msg.text,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Animation de matrice ondulante (style ChatGPT DALL-E) pendant la modélisation 3D
                      if (state.isGenerating3D && index == messages.length - 1)
                        AiGenerationMatrixCard(
                          title: isFrench ? 'Votre idée prend forme...' : 'Your idea is taking shape...',
                        ),

                      // Modèle 3D Meshy interactif
                      if (!state.isGenerating3D &&
                          (msg.isPlans ||
                              (state.generatedPlans != null &&
                                  state.generatedPlans!.isNotEmpty &&
                                  index == messages.length - 1)))
                        _buildAura3DCard(state, isFrench),

                      // Choix et options envoyés par NICO IA (chips interactifs en nuances vertes)
                      if (msg.options != null &&
                          msg.options!.isNotEmpty &&
                          index == messages.length - 1 &&
                          !state.isTyping &&
                          !state.isGenerating3D)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: msg.options!.map((opt) {
                              return InkWell(
                                onTap: () {
                                  ref.read(iaProjectProvider.notifier).answerQuestion(opt);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF81C784),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        opt,
                                        style: const TextStyle(
                                          color: Color(0xFF1B4D3E),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2E7D32), size: 14),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // ─────────────────────────────────────────────
  // Carte du Modèle 3D Meshy & Validation
  // ─────────────────────────────────────────────
  Widget _buildAura3DCard(IaProjectState state, bool isFrench) {
    if (state.generatedPlans == null || state.generatedPlans!.isEmpty) {
      return const SizedBox.shrink();
    }
    final glbUrl = state.generatedPlans!.first as String;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF81C784),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4D3E).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête de la maquette 3D
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.view_in_ar_rounded, color: Color(0xFF2E7D32), size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '$_selectedType 3D - ChantierTrack',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1B4D3E),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF86EFAC),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    isFrench ? 'Modèle 3D Prêt' : '3D Ready',
                    style: const TextStyle(
                      color: Color(0xFF15803D),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Visionneuse 3D interactive
          SizedBox(
            height: 290,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ModelViewer(
                src: glbUrl,
                alt: 'Modèle 3D ChantierTrack',
                ar: true,
                autoRotate: true,
                cameraControls: true,
                backgroundColor: const Color(0xFFF8FAF7),
              ),
            ),
          ),

          // Bouton de validation du projet
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                label: Text(
                  isFrench ? 'Valider et Trouver des Entreprises' : 'Validate & Find Contractors',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4D3E),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ref.read(iaProjectProvider.notifier).validerPlan({});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1B4D3E),
                      content: Text(isFrench
                          ? 'Projet validé ! Recherche d\'entreprises partenaires en cours...'
                          : 'Project validated! Finding partner contractors...'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Barre de saisie et d'édition de messages
  // ─────────────────────────────────────────────
  Widget _buildAuraInputBar(BuildContext context, bool isFrench) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Fichier / Plan sélectionné
          if (_attachedImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Chip(
                avatar: const Icon(Icons.image, size: 16, color: Color(0xFF1B4D3E)),
                label: Text(
                  _attachedImage!.name,
                  style: const TextStyle(color: Color(0xFF1B4D3E), fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                backgroundColor: const Color(0xFFE8F5E9),
                deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF2E7D32)),
                onDeleted: () => setState(() => _attachedImage = null),
              ),
            ),

          Row(
            children: [
              // Champ de texte en pilule blanche avec nuances vertes
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF81C784).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4D3E).withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          cursorColor: const Color(0xFF1B4D3E),
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: isFrench
                                ? 'Écrivez votre réponse (ex: 35 000 000 FCFA)...'
                                : 'Type your answer (e.g. 35,000,000 FCFA)...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13.5,
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              _submitPrompt(val.trim());
                            }
                          },
                        ),
                      ),
                      // Bouton "+" pour importer un plan / document
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF2E7D32), size: 22),
                        tooltip: isFrench ? 'Importer plan ou image' : 'Attach floor plan or image',
                        onPressed: _pickImage,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Bouton d'envoi du message
              GestureDetector(
                onTap: () => _submitPrompt(),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2E7D32),
                        Color(0xFF1B4D3E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4D3E).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuraTypingIndicator(bool isFrench) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuraOrb(size: 26),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC8E6C9),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4D3E).withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isFrench ? 'Modélisation 3D et calcul du devis en cours...' : 'Generating 3D model & estimate...',
                  style: const TextStyle(color: Color(0xFF1B4D3E), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
