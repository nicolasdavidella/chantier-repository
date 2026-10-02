import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/message_model.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:chantier_track/core/theme/app_colors.dart';


class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

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
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 4,
          ),
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
                color: AppColors.textPrimaryLight.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.type == 'image')
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse(message.contenu);
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      },
                      child: Image.network(message.contenu, fit: BoxFit.cover),
                    ),
                  ),
                )
              else if (message.type == 'pdf')
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
                  title: const Text(
                    'Fichier PDF',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  onTap: () async {
                    final uri = Uri.parse(message.contenu);
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                )
              else if (message.type == 'quote')
                _buildQuoteBubble(context, theme)
              else
                Text(
                  message.contenu,
                  style: TextStyle(
                    color: isMe
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
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
                      color: isMe
                          ? theme.colorScheme.primary.withValues(alpha: 0.7)
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (isMe) ...[
                    AppSpacing.hXs,
                    Icon(
                      message.status == 'sent' ? Icons.check : Icons.done_all,
                      size: 14,
                      color: message.status == 'read'
                          ? AppColors.primary
                          : AppColors.textSecondaryLight,
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

  Widget _buildQuoteBubble(BuildContext context, ThemeData theme) {
    final amount = message.metadata?['quoteAmount'];
    final status = message.metadata?['quoteStatus'] ?? 'pending';
    final numberFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.request_quote, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Offre spéciale',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(),
          if (amount != null)
            Text(
              numberFormat.format(amount),
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Text(
            message.contenu,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),

          if (status == 'pending') ...[
            if (isMe)
              const Text(
                'Devis envoyé, en attente de réponse',
                style: TextStyle(color: AppColors.warning, fontSize: 12),
                textAlign: TextAlign.center,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateQuoteStatus(context, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: const Text('Refuser'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateQuoteStatus(context, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      child: const Text('Accepter'),
                    ),
                  ),
                ],
              ),
          ] else if (status == 'accepted')
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'Devis accepté !',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else if (status == 'rejected')
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'Devis refusé',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _updateQuoteStatus(BuildContext context, String newStatus) async {
    try {
      final messageRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc(message.id);

      final metadata = Map<String, dynamic>.from(message.metadata ?? {});
      metadata['quoteStatus'] = newStatus;

      await messageRef.update({'metadata': metadata});

      if (newStatus == 'accepted') {
        // Find projectId from conversation
        final convDoc = await FirebaseFirestore.instance
            .collection('conversations')
            .doc(message.conversationId)
            .get();
        final projectId = convDoc.data()?['projectId'];
        if (projectId != null) {
          await FirebaseFirestore.instance
              .collection('projects')
              .doc(projectId)
              .update({'statut': 'en_cours'});

          // Send system message
          await FirebaseFirestore.instance
              .collection('conversations')
              .doc(message.conversationId)
              .collection('messages')
              .add({
                'conversationId': message.conversationId,
                'expediteurId': 'system',
                'contenu': 'Le client a accepté l\'offre spéciale.',
                'dateEnvoi': FieldValue.serverTimestamp(),
                'type': 'texte',
                'status': 'sent',
                'lu': false,
              });
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}
