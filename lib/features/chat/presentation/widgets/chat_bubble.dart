import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/message_model.dart';
import '../../../../core/theme/app_spacing.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormatter = DateFormat('HH:mm');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isMe ? theme.colorScheme.primaryContainer : theme.cardColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.type == 'image')
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      message.contenu,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Text(
                  message.contenu,
                  style: TextStyle(
                    color: isMe ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                  ),
                ),
              AppSpacing.vXs,
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    timeFormatter.format(message.dateEnvoi),
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? theme.colorScheme.primary.withValues(alpha: 0.7) : Colors.grey,
                    ),
                  ),
                  if (isMe) ...[
                    AppSpacing.hXs,
                    Icon(
                      message.status == 'sent' ? Icons.check : Icons.done_all,
                      size: 14,
                      color: message.status == 'read' ? Colors.blue : Colors.grey,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
