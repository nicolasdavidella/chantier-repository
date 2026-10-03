import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MeshyService {
  final String _apiKey;
  final String _baseUrl = 'https://api.meshy.ai/openapi/v2/text-to-3d';

  MeshyService() : _apiKey = dotenv.env['MESHY_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      print("Attention: MESHY_API_KEY n'est pas définie dans le fichier .env");
    }
  }

  /// Étape 1 : Demande à Meshy de générer un modèle 3D basé sur le texte
  Future<String> create3DTask(String prompt) async {
    if (_apiKey.isEmpty) throw Exception("Clé API Meshy manquante");

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mode': 'preview', // 'preview' est plus rapide et moins cher pour tester
        'prompt': prompt,
        'art_style': 'realistic',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      final data = jsonDecode(response.body);
      return data['result']; // Retourne le Task ID
    } else {
      throw Exception('Erreur Meshy API: ${response.statusCode} - ${response.body}');
    }
  }

  /// Étape 2 : Vérifie l'état de la tâche et récupère le lien .glb quand c'est prêt
  Future<String?> getTaskResult(String taskId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$taskId'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final status = data['status'];
      
      if (status == 'SUCCEEDED') {
        // Retourne le lien vers le fichier 3D
        return data['model_urls']['glb']; 
      } else if (status == 'FAILED' || status == 'EXPIRED') {
        throw Exception('La génération 3D a échoué');
      }
      
      // Si status est 'PENDING' ou 'IN_PROGRESS', on retourne null
      return null;
    } else {
      throw Exception('Erreur vérification Meshy: ${response.statusCode}');
    }
  }

  /// Fonction globale qui gère l'attente (Polling) automatiquement
  Future<String> generate3DModel(String prompt) async {
    final taskId = await create3DTask(prompt);
    
    // On boucle jusqu'à ce que ce soit terminé (avec une pause entre chaque essai)
    while (true) {
      await Future.delayed(const Duration(seconds: 5)); // Attend 5 secondes
      final glbUrl = await getTaskResult(taskId);
      if (glbUrl != null) {
        return glbUrl; // Le fichier 3D est prêt !
      }
    }
  }
}
