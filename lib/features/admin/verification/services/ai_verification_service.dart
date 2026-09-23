import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final aiVerificationServiceProvider = Provider<AiVerificationService>((ref) {
  final apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
  return AiVerificationService(apiKey: apiKey);
});

class AiVerificationService {
  final String _apiKey;
  final String _baseUrl = 'https://api.anthropic.com/v1/messages';
  final String _model = 'claude-3-5-sonnet-20240620';

  AiVerificationService({required String apiKey}) : _apiKey = apiKey;

  Future<String> analyzeDocument(File file, String documentType, String entrepriseName) async {
    if (_apiKey.isEmpty) return 'Erreur: Clé API manquante.';

    try {
      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
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

      final bool isPdf = mimeType == 'application/pdf';
      final fileBlock = {
        "type": isPdf ? "document" : "image",
        "source": {
          "type": "base64",
          "media_type": mimeType,
          "data": base64Data
        }
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
          if (isPdf) 'anthropic-beta': 'pdfs-2024-09-25', // PDF support requires beta header
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {
              'role': 'user',
              'content': [
                fileBlock,
                {"type": "text", "text": prompt}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] ?? 'Aucune analyse générée.';
      } else {
        return 'Erreur lors de l\'analyse IA (Code \${response.statusCode}): \${response.body}';
      }
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
