import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final aiVerificationServiceProvider = Provider<AiVerificationService>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  // Utilisation de gemini-1.5-flash pour sa rapidité sur l'analyse de documents
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  return AiVerificationService(model: model);
});

class AiVerificationService {
  final GenerativeModel _model;

  AiVerificationService({required GenerativeModel model}) : _model = model;

  Future<String> analyzeDocument(File file, String documentType, String entrepriseName) async {
    try {
      final bytes = await file.readAsBytes();
      final mimeType = _getMimeType(file.path);
      
      final prompt = '''
      Tu es un assistant administratif expert pour une plateforme de construction au Cameroun.
      Examine ce document de type "$documentType" fourni par l'entreprise "$entrepriseName".
      
      Tâches :
      1. Confirme s'il s'agit bien du bon type de document.
      2. Vérifie la lisibilité du document. S'il est flou ou tronqué, signale-le.
      3. Extrait les informations clés (nom de l'entreprise, dates d'émission/expiration, numéros d'identification).
      4. Indique s'il y a des incohérences évidentes (par exemple, le nom sur le document ne correspond pas à "$entrepriseName").
      5. Fournis un bref résumé pour aider l'administrateur à prendre une décision.
      
      IMPORTANT: Ne prends pas de décision finale. Présente cela comme une aide à l'administrateur.
      Sois concis et structure ta réponse avec des puces.
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(mimeType, bytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text ?? 'Aucune analyse générée.';
    } catch (e) {
      return 'Erreur lors de l\'analyse IA: \$e';
    }
  }

  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'image/jpeg';
    }
  }
}
