import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/chat_providers.dart';
import '../widgets/chat_bubble.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class ChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUserName;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  double? _uploadProgress;
  String _uploadStatus = '';

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage({
    String type = 'texte',
    String? url,
    Map<String, dynamic>? metadata,
    String? text,
  }) {
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty && url == null) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    ref
        .read(chatRepositoryProvider)
        .sendMessage(
          widget.conversationId,
          url ?? messageText,
          user.uid,
          type: type,
          metadata: metadata,
        );

    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _simulateUpload(String type) async {
    // Dans une vraie app, on utiliserait ImagePicker / FilePicker
    setState(() {
      _uploadProgress = 0;
      _uploadStatus = 'Préparation du fichier...';
    });

    final fileName = 'file_${DateTime.now().millisecondsSinceEpoch}.$type';
    final refStorage = FirebaseStorage.instance.ref().child(
      'conversations/${widget.conversationId}/$fileName',
    );

    // Simulate upload progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) setState(() => _uploadProgress = i / 10);
    }

    // Dummy URL for demonstration if we aren't actually putting a file
    // String url = await refStorage.getDownloadURL();
    String url = type == 'pdf'
        ? 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'
        : 'https://picsum.photos/seed/chat-photo/400/300';

    if (mounted) {
      setState(() => _uploadProgress = null);
      _sendMessage(type: type == 'pdf' ? 'pdf' : 'image', url: url);
    }
  }

  void _showQuoteDialog() {
    final amountController = TextEditingController();
    final delayController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Proposer un devis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: delayController,
              decoration: const InputDecoration(
                labelText: 'Délai estimé (ex: 2 semaines)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(amountController.text.trim());
              if (amount != null) {
                Navigator.pop(ctx);
                _sendMessage(
                  type: 'quote',
                  text: 'Délai : ${delayController.text.trim()}',
                  metadata: {'quoteAmount': amount, 'quoteStatus': 'pending'},
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesStreamProvider(widget.conversationId),
    );
    final isTyping = ref.watch(typingStateProvider(widget.conversationId));
    final theme = Theme.of(context);
    final user = ref.read(authStateProvider).value;
    final role = ref.watch(currentUserRoleProvider);
    final isEntreprise = role == 'entreprise';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF143D2B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFF143D2B),
                child: Text(
                  widget.otherUserName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF86EFAC), fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  if (isTyping)
                    const Text(
                          'En train d\'écrire...',
                          style: TextStyle(fontSize: 11, color: Color(0xFF86EFAC), fontWeight: FontWeight.w600),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fade(duration: 1.seconds)
                  else
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('conversations')
                          .doc(widget.conversationId)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const SizedBox.shrink();
                        }
                        final projectId = snapshot.data!.data() != null
                            ? (snapshot.data!.data() as Map)['projectId']
                            : null;
                        if (projectId == null) return const SizedBox.shrink();

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('projects')
                              .doc(projectId)
                              .get(),
                          builder: (context, pSnapshot) {
                            if (!pSnapshot.hasData || !pSnapshot.data!.exists) {
                              return const SizedBox.shrink();
                            }
                            final pData =
                                pSnapshot.data!.data() as Map<String, dynamic>;
                            return Text(
                              'Projet : ${pData['titre']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
            if (isEntreprise)
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.request_quote_rounded, color: Colors.white, size: 18),
                ),
                tooltip: 'Proposer un devis',
                onPressed: _showQuoteDialog,
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background ambient glow
          Positioned(
            top: 20,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE8F5E9).withValues(alpha: 0.8),
                    const Color(0xFFE8F5E9).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToBottom(),
                    );
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        if (message.expediteurId == 'system') {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
                              ),
                              child: Text(
                                message.contenu,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF143D2B),
                                ),
                              ),
                            ),
                          );
                        }
                        return ChatBubble(
                          message: message,
                          isMe: message.expediteurId == user?.uid,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF143D2B))),
                  error: (err, stack) => Center(child: Text('Erreur: $err')),
                ),
              ),
              if (_uploadProgress != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _uploadProgress,
                            backgroundColor: const Color(0xFFE8F5E9),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF10B981)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(_uploadProgress! * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF143D2B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              _buildInputBar(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFC8E6C9), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D2B).withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.attach_file_rounded, color: Color(0xFF143D2B), size: 20),
              ),
              onSelected: (val) {
                _simulateUpload(val);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'image',
                  child: ListTile(
                    leading: Icon(Icons.image_rounded, color: Color(0xFF10B981)),
                    title: Text('Image du chantier'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626)),
                    title: Text('Document / Devis PDF'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
                ),
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Taper votre message...',
                    hintStyle: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF143D2B),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFF86EFAC), size: 18),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
