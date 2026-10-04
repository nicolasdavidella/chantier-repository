import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class MeshyService {
  final String _apiKey;
  final String _textTo3dUrl = 'https://api.meshy.ai/openapi/v2/text-to-3d';
  final String _imageTo3dUrl = 'https://api.meshy.ai/openapi/v1/image-to-3d';

  MeshyService() : _apiKey = dotenv.env['MESHY_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      print("Attention: MESHY_API_KEY n'est pas définie dans le fichier .env");
    }
  }

  /// Étape 1 : Demande à Meshy de générer un modèle 3D basé sur le texte (Preview)
  Future<String> create3DTask(String prompt) async {
    if (_apiKey.isEmpty) throw Exception("Clé API Meshy manquante");

    final response = await http.post(
      Uri.parse(_textTo3dUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mode': 'preview',
        'prompt': '$prompt, vibrant colors, realistic materials, wood, metal, glass, fully textured, highly detailed, photorealistic',
        'art_style': 'realistic',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      final data = jsonDecode(response.body);
      return data['result']; // Retourne le Task ID du Preview
    } else {
      throw Exception('Erreur Meshy API (Preview): ${response.statusCode} - ${response.body}');
    }
  }

  /// Étape 1.5 : Demande le raffinement (Haute Qualité) d'un modèle Preview
  Future<String> refine3DTask(String previewTaskId) async {
    final response = await http.post(
      Uri.parse(_textTo3dUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mode': 'refine',
        'preview_task_id': previewTaskId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      final data = jsonDecode(response.body);
      return data['result']; // Retourne le Task ID du Refine
    } else {
      throw Exception('Erreur Meshy API (Refine): ${response.statusCode} - ${response.body}');
    }
  }

  /// Étape 1 b : Demande à Meshy de générer un modèle 3D basé sur une image URL
  Future<String> create3DTaskFromImage(String imageUrl) async {
    if (_apiKey.isEmpty) throw Exception("Clé API Meshy manquante");

    final response = await http.post(
      Uri.parse(_imageTo3dUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'image_url': imageUrl,
        'enable_pbr': true, // Pour un rendu plus réaliste
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      final data = jsonDecode(response.body);
      return data['result']; // Retourne le Task ID
    } else {
      throw Exception('Erreur Meshy API (Image-to-3D): ${response.statusCode} - ${response.body}');
    }
  }

  /// Étape 2 : Vérifie l'état de la tâche et récupère le lien .glb quand c'est prêt
  Future<String?> getTaskResult(String taskId, {bool isImage = false}) async {
    final url = isImage ? '$_imageTo3dUrl/$taskId' : '$_textTo3dUrl/$taskId';
    final response = await http.get(
      Uri.parse(url),
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

  /// Fonction globale qui gère l'attente (Polling) et le raffinement automatiquement
  Future<String> generate3DModel({String? prompt, String? imageUrl}) async {
    final isImage = imageUrl != null;
    
    if (isImage) {
      // Pour l'image-to-3d, on fait direct la boucle
      final taskId = await create3DTaskFromImage(imageUrl);
      while (true) {
        await Future.delayed(const Duration(seconds: 5));
        final glbUrl = await getTaskResult(taskId, isImage: true);
        if (glbUrl != null) return glbUrl;
      }
    } else {
      // 1. Démarrer le mode Preview
      final previewTaskId = await create3DTask(prompt ?? 'Une belle maison 3D');
      
      // 2. Attendre que le Preview soit terminé
      while (true) {
        await Future.delayed(const Duration(seconds: 5));
        final glbUrl = await getTaskResult(previewTaskId, isImage: false);
        if (glbUrl != null) {
          break; // Le preview est fini, on passe au Refine
        }
      }
      
      // 3. Démarrer le mode Refine (Haute Définition + Textures)
      final refineTaskId = await refine3DTask(previewTaskId);
      
      // 4. Attendre que le Refine soit terminé
      while (true) {
        await Future.delayed(const Duration(seconds: 5));
        final finalGlbUrl = await getTaskResult(refineTaskId, isImage: false);
        if (finalGlbUrl != null) {
          return finalGlbUrl; // Le fichier 3D HD est prêt !
        }
      }
    }
  }
}
