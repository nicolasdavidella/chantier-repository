import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

// --- Chat Provider ---
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class IAChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _geminiService;

  IAChatNotifier(this._geminiService) : super([
    ChatMessage(
      text: "Bonjour ! Je suis l'Assistant IA de ChantierTrack propulsé par Gemini. Posez-moi vos questions !",
      isUser: false,
      timestamp: DateTime.now(),
    )
  ]);

  Future<void> sendMessage(String text) async {
    // Add user message
    state = [...state, ChatMessage(text: text, isUser: true, timestamp: DateTime.now())];

    try {
      final aiResponse = await _geminiService.chat(text, state);
      state = [...state, ChatMessage(text: aiResponse, isUser: false, timestamp: DateTime.now())];
    } catch (e) {
      state = [...state, ChatMessage(text: "Erreur de connexion à l'IA.", isUser: false, timestamp: DateTime.now())];
    }
  }
}

final iaChatProvider = StateNotifierProvider<IAChatNotifier, List<ChatMessage>>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  return IAChatNotifier(geminiService);
});

// --- Insights Provider ---
class IAInsightData {
  final double predictionRetard; // 0.0 (en avance) to 1.0 (très en retard)
  final double confiancePrediction;
  final List<Map<String, dynamic>> anomalies;
  final List<String> recommandations;

  IAInsightData({
    required this.predictionRetard,
    required this.confiancePrediction,
    required this.anomalies,
    required this.recommandations,
  });
}

final iaInsightsProvider = FutureProvider.family<IAInsightData, String>((ref, projectId) async {
  final geminiService = ref.watch(geminiServiceProvider);
  
  try {
    final jsonStr = await geminiService.generateInsights(projectId);
    final data = jsonDecode(jsonStr);
    
    return IAInsightData(
      predictionRetard: (data['predictionRetard'] as num).toDouble(),
      confiancePrediction: (data['confiancePrediction'] as num).toDouble(),
      anomalies: List<Map<String, dynamic>>.from(data['anomalies']),
      recommandations: List<String>.from(data['recommandations']),
    );
  } catch (e) {
    print("Erreur parsing insights: $e");
    // Fallback on error
    return IAInsightData(
      predictionRetard: 0.0,
      confiancePrediction: 0.0,
      anomalies: [{'titre': 'Erreur IA', 'description': 'Impossible de générer l\'analyse', 'severite': 'moyenne'}],
      recommandations: ["Veuillez réessayer plus tard"],
    );
  }
});
