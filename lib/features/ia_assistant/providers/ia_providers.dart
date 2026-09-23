import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/anthropic_service.dart';
final anthropicServiceProvider = Provider<AnthropicService>((ref) {
  return AnthropicService();
});

// --- Chat Provider ---
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class IAChatNotifier extends StateNotifier<List<ChatMessage>> {
  final AnthropicService _anthropicService;

  IAChatNotifier(this._anthropicService) : super([
    ChatMessage(
      text: "Bonjour ! Je suis l'Assistant IA de ChantierTrack propulsé par Claude (Anthropic). Posez-moi vos questions !",
      isUser: false,
      timestamp: DateTime.now(),
    )
  ]);

  Future<void> sendMessage(String text) async {
    // Add user message
    state = [...state, ChatMessage(text: text, isUser: true, timestamp: DateTime.now())];

    try {
      final aiResponse = await _anthropicService.chat(text, state);
      state = [...state, ChatMessage(text: aiResponse, isUser: false, timestamp: DateTime.now())];
    } catch (e) {
      state = [...state, ChatMessage(text: "Erreur de connexion à l'IA.", isUser: false, timestamp: DateTime.now())];
    }
  }
}

final iaChatProvider = StateNotifierProvider<IAChatNotifier, List<ChatMessage>>((ref) {
  final anthropicService = ref.watch(anthropicServiceProvider);
  return IAChatNotifier(anthropicService);
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
  final anthropicService = ref.watch(anthropicServiceProvider);
  
  try {
    final jsonStr = await anthropicService.generateInsights(projectId);
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
