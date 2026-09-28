import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/chat_providers.dart';
import '../widgets/chat_bubble.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(widget.otherUserName[0].toUpperCase()),
            ),
            AppSpacing.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (isTyping)
                    const Text(
                          'En train d\'écrire...',
                          style: TextStyle(fontSize: 12, color: Colors.green),
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
                        if (!snapshot.hasData || !snapshot.data!.exists)
                          return const SizedBox.shrink();
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
                            if (!pSnapshot.hasData || !pSnapshot.data!.exists)
                              return const SizedBox.shrink();
                            final pData =
                                pSnapshot.data!.data() as Map<String, dynamic>;
                            return Text(
                              'Projet: ${pData['titre']} • ${pData['budgetPrevisionnel']} FCFA',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
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
                icon: const Icon(Icons.request_quote),
                tooltip: 'Proposer un devis',
                onPressed: _showQuoteDialog,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    if (message.expediteurId == 'system') {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.contenu,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),
          if (_uploadProgress != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(value: _uploadProgress),
                  ),
                  const SizedBox(width: 16),
                  Text('${(_uploadProgress! * 100).toInt()}%'),
                ],
              ),
            ),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.attach_file),
              onSelected: (val) {
                _simulateUpload(val);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'image',
                  child: ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Image'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text('Document PDF'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Taper un message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            AppSpacing.hSm,
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
