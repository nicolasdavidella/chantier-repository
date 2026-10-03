import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../features/ia_assistant/providers/ia_providers.dart';

class AnthropicService {
  final String _apiKey;
  final String _baseUrl = 'https://api.anthropic.com/v1/messages';
  final String _model = 'claude-3-5-sonnet-20240620'; // Claude 3.5 Sonnet

  AnthropicService() : _apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception("La clé ANTHROPIC_API_KEY n'est pas configurée dans le fichier .env");
    }
  }

  /// Handles conversational chat
  Future<String> chat(String message, List<ChatMessage> history) async {
    try {
      final systemPrompt = "Tu es l'Assistant de Conception ChantierTrack, une application de gestion de chantiers de construction au Cameroun et en Afrique.\nTu dois répondre de manière concise, professionnelle, et aidante.";
      
      final messages = history.map((m) {
        return {
          "role": m.isUser ? "user" : "assistant",
          "content": m.text
        };
      }).toList();
      
      messages.add({
        "role": "user",
        "content": message
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'anthropic-dangerously-allow-browser': 'true',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'system': systemPrompt,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] ?? "Désolé, je n'ai pas pu générer une réponse.";
      } else {
        print("Erreur Anthropic API: \${response.statusCode} - \${response.body}");
        return "Une erreur de connexion s'est produite (Erreur \${response.statusCode}).";
      }
    } catch (e) {
      print("Erreur Anthropic chat: \$e");
      return "Une erreur de connexion s'est produite. Veuillez vérifier votre réseau.";
    }
  }

  /// Generates a JSON string containing project insights
  Future<String> generateInsights(String projectId) async {
    try {
      final prompt = """
Analyse ce faux projet de construction et retourne UNIQUEMENT un objet JSON valide (sans markdown ni backticks).
Le JSON doit correspondre exactement à cette structure :
{
  "predictionRetard": 0.65, // entre 0.0 et 1.0
  "confiancePrediction": 0.85, // entre 0.0 et 1.0
  "anomalies": [
    {
      "titre": "Titre court",
      "description": "Description de l'anomalie",
      "severite": "haute" // haute, moyenne, basse
    }
  ],
  "recommandations": [
    "Recommandation 1",
    "Recommandation 2"
  ]
}

Invente des anomalies réalistes pour un chantier de construction (ex: retard livraison, météo, dépenses excessives).
Génère entre 1 et 3 anomalies et 2 recommandations.
""";

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['content'][0]['text'] ?? "{}";
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        return text;
      } else {
        throw Exception("API Error: \${response.statusCode}");
      }
    } catch (e) {
      print("Erreur Anthropic insights: \$e");
      throw Exception("Impossible de générer les insights");
    }
  }

  /// Simulates a cost and duration estimation
  Future<String> simulateDevis(String type, String surface, String gamme) async {
    try {
      final prompt = """
Tu es un expert en chiffrage de travaux de construction en Afrique francophone (utilise le FCFA).
Estime le coût et la durée pour le projet suivant :
Type de travaux : \$type
Surface : \$surface m²
Gamme de matériaux : \$gamme

Retourne UNIQUEMENT un objet JSON valide (sans markdown) avec cette structure :
{
  "budgetMin": 1500000,
  "budgetMax": 2300000,
  "dureeTexte": "2 à 3 semaines"
}
""";

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['content'][0]['text'] ?? "{}";
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        return text;
      } else {
        throw Exception("API Error: \${response.statusCode}");
      }
    } catch (e) {
      print("Erreur Anthropic devis: \$e");
      throw Exception("Impossible de simuler le devis");
    }
  }

  /// Generates an AI report text
  Future<String> generateReport() async {
    try {
      final prompt = """
Rédige un court rapport d'avancement professionnel pour un chantier de construction (1 ou 2 paragraphes maximum).
Le rapport doit sembler naturel, comme écrit par un chef de chantier. 
Mentionne que certaines tâches (invente-les) ont été complétées aujourd'hui et précise si tout va bien.
Ne renvoie que le texte du rapport.
""";

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] ?? "Rapport non généré.";
      } else {
        return "Le service est indisponible (\${response.statusCode}).";
      }
    } catch (e) {
      print("Erreur Anthropic report: \$e");
      return "Le service est indisponible.";
    }
  }

  /// Recommends best matching enterprises for a given project description
  Future<List<String>> matchEntreprises(String projectDescription, List<Map<String, dynamic>> availableEntreprises) async {
    try {
      final prompt = """
Tu es un expert en mise en relation pour la construction.
Voici la description d'un projet : "\$projectDescription"

Voici la liste des entreprises disponibles avec leurs ID, spécialités et notes :
\${availableEntreprises.map((e) => "- ID: \${e['id']}, Spécialités: \${e['specialites']}, Note: \${e['note']}").join('\n')}

Renvoie UNIQUEMENT un tableau JSON (sans markdown ni backticks) contenant les ID des entreprises les plus pertinentes pour ce projet, triées par pertinence. 
Exemple: ["ent1", "ent3"]
""";

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'anthropic-dangerously-allow-browser': 'true',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String text = responseData['content'][0]['text'] ?? "[]";
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        
        final List<dynamic> data = jsonDecode(text);
        return data.map((e) => e.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Erreur Anthropic matching: $e");
      return [];
    }
  }

  /// AI Assistant for Project Creation
  Future<String> chatForProjectCreation(String message, List<ChatMessage> history) async {
    try {
      final systemPrompt = """
Tu es un Assistant de Conception pour ChantierTrack. Ton but est d'aider le client à concevoir son projet de construction.
Pose des questions pour affiner le besoin si nécessaire (type de maison, nombre de pièces, style).
Tu DOIS obligatoirement demander au client son budget prévisionnel (en FCFA).

Si tu estimes avoir toutes les informations nécessaires (description détaillée + budget), tu dois finaliser l'échange en proposant 3 plans de maison sous ce format EXACT JSON (rien d'autre, pas de texte avant ou après, pas de markdown) :
{
  "isFinal": true,
  "budget": 15000000,
  "descriptionComplete": "Résumé du projet...",
  "plans": [
    {
      "nom": "Plan Moderne F4",
      "description": "Maison moderne avec 4 pièces, toit plat.",
      "imageRef": "plan_moderne_1"
    }
  ]
}

Tant que tu n'as pas toutes les infos, réponds normalement (texte naturel). Dès que tu as les infos, réponds avec le JSON.
""";
      
      final messages = history.map((m) {
        return {
          "role": m.isUser ? "user" : "assistant",
          "content": m.text
        };
      }).toList();
      
      messages.add({
        "role": "user",
        "content": message
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
          'anthropic-dangerously-allow-browser': 'true',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'system': systemPrompt,
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] ?? "Désolé, je n'ai pas pu générer une réponse.";
      } else {
        return "Une erreur de connexion s'est produite (Erreur ${response.statusCode}).";
      }
    } catch (e) {
      print("Erreur Anthropic project creation chat: $e");
      return "Une erreur de connexion s'est produite.";
    }
  }
}
