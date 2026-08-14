import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/ia_providers.dart';

class IaChatScreen extends ConsumerStatefulWidget {
  const IaChatScreen({super.key});

  @override
  ConsumerState<IaChatScreen> createState() => _IaChatScreenState();
}

class _IaChatScreenState extends ConsumerState<IaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() => _isTyping = true);

    await ref.read(iaChatProvider.notifier).sendMessage(text);
    
    if (mounted) {
      setState(() => _isTyping = false);
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(iaChatProvider);
    final theme = Theme.of(context);

    // Schedule scroll to bottom after build when new messages appear
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            AppSpacing.hSm,
            const Text('Assistant IA'),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isTyping) {
                  return _buildTypingIndicator(theme);
                }
                
                final msg = messages[index];
                return _buildMessageBubble(msg, theme).animate().fadeIn().slideY(begin: 0.1, end: 0);
              },
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 4, backgroundColor: Colors.grey).animate(onPlay: (c) => c.repeat()).fade(duration: 500.ms),
            AppSpacing.hXs,
            const CircleAvatar(radius: 4, backgroundColor: Colors.grey).animate(delay: 200.ms, onPlay: (c) => c.repeat()).fade(duration: 500.ms),
            AppSpacing.hXs,
            const CircleAvatar(radius: 4, backgroundColor: Colors.grey).animate(delay: 400.ms, onPlay: (c) => c.repeat()).fade(duration: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -1), blurRadius: 10),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Posez votre question...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            AppSpacing.hSm,
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
