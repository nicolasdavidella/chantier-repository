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
            horizontal: 12,
            vertical: 4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF143D2B) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isMe
                    ? const Color(0xFF143D2B).withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
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
                  title: Text(
                    'Fichier PDF',
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimaryLight,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () async {
                    final uri = Uri.parse(message.contenu);
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                )
              else if (message.type == 'quote')
                _buildQuoteBubble(context, theme)
              else
                SelectableText(
                  message.contenu,
                  style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),

              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    timeFormatter.format(message.dateEnvoi),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.75)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.status == 'sent' ? Icons.check_rounded : Icons.done_all_rounded,
                      size: 14,
                      color: const Color(0xFF86EFAC),
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
    final numberFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF1E523A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? const Color(0xFF2E7D56) : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF143D2B) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.request_quote_rounded, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Proposition de Devis',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isMe ? Colors.white : const Color(0xFF143D2B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: isMe ? Colors.white24 : const Color(0xFFE2E8F0)),
          const SizedBox(height: 4),
          if (amount != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF143D2B) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Text(
                numberFormat.format(amount),
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            message.contenu,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: isMe ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 12),

          if (status == 'pending') ...[
            if (isMe)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '⏳ Devis envoyé, en attente de réponse du client',
                  style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11.5, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
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

      final targetStatut = newStatus == 'accepted' ? 'accepte' : (newStatus == 'rejected' ? 'refuse' : 'en_attente');
      final devisId = metadata['devisId']?.toString();
      if (devisId != null && devisId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance.collection('devis').doc(devisId).update({'statut': targetStatut});
        } catch (_) {}
      }

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
          if (devisId != null && devisId.isNotEmpty) {
            try {
              await FirebaseFirestore.instance
                  .collection('projects')
                  .doc(projectId)
                  .collection('devis')
                  .doc(devisId)
                  .update({'statut': 'accepte'});
            } catch (_) {}
          }

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
