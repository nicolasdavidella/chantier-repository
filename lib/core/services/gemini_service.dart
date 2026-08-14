import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/ia_assistant/providers/ia_providers.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("La clé GEMINI_API_KEY n'est pas configurée dans le fichier .env");
    }
    
    // We use gemini-1.5-flash as it's the recommended model for general tasks and text
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Handles conversational chat
  Future<String> chat(String message, List<ChatMessage> history) async {
    try {
      final prompt = """
Tu es l'Assistant IA de ChantierTrack, une application de gestion de chantiers de construction au Cameroun et en Afrique.
Tu dois répondre de manière concise, professionnelle, et aidante. 
Voici l'historique récent de la conversation (pour contexte) :
${history.map((m) => "${m.isUser ? 'Utilisateur' : 'Assistant'} : ${m.text}").join('\n')}

Utilisateur : $message
""";
      
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Désolé, je n'ai pas pu générer une réponse.";
    } catch (e) {
      print("Erreur Gemini chat: $e");
      return "Une erreur de connexion à l'IA s'est produite. Veuillez vérifier votre clé API.";
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

      final response = await _model.generateContent([Content.text(prompt)]);
      
      String text = response.text ?? "{}";
      // Clean up markdown block if the model added it despite instructions
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      return text;
    } catch (e) {
      print("Erreur Gemini insights: $e");
      throw Exception("Impossible de générer les insights");
    }
  }

  /// Simulates a cost and duration estimation
  Future<String> simulateDevis(String type, String surface, String gamme) async {
    try {
      final prompt = """
Tu es un expert en chiffrage de travaux de construction en Afrique francophone (utilise le FCFA).
Estime le coût et la durée pour le projet suivant :
Type de travaux : $type
Surface : $surface m²
Gamme de matériaux : $gamme

Retourne UNIQUEMENT un objet JSON valide (sans markdown) avec cette structure :
{
  "budgetMin": 1500000,
  "budgetMax": 2300000,
  "dureeTexte": "2 à 3 semaines"
}
""";

      final response = await _model.generateContent([Content.text(prompt)]);
      
      String text = response.text ?? "{}";
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      return text;
    } catch (e) {
      print("Erreur Gemini devis: $e");
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

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Rapport non généré.";
    } catch (e) {
      print("Erreur Gemini report: $e");
      return "Le service IA est indisponible.";
    }
  }
}
