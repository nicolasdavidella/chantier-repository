import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../data/models/project_model.dart';
import '../../../data/models/rapport_avancement_model.dart';
import '../../../data/models/depense_model.dart';
import '../../../data/models/devis_model.dart';
import '../../../data/models/entreprise_model.dart';

class PdfExportService {
  // Styles communs
  static const _primaryColor = PdfColor.fromInt(0xFF1E88E5); // Blue 600
  static const _secondaryColor = PdfColor.fromInt(0xFF424242);

  static Future<Uint8List> generateProgressReport({
    required ProjectModel project,
    required List<RapportAvancementModel> rapports,
  }) async {
    final pdf = pw.Document();
    
    // On pourrait charger une image logo depuis les assets, pour l'exemple on utilise un placeholder textuel
    // final logoImage = await imageFromAssetBundle('assets/images/logo.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader('Rapport d\'Avancement', project.titre),
        footer: _buildFooter,
        build: (context) => [
          _buildProjectInfo(project),
          pw.SizedBox(height: 20),
          pw.Text('Historique de progression', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
          pw.Divider(),
          pw.SizedBox(height: 10),
          ...rapports.map((r) => _buildRapportItem(r)).toList(),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateFinancialReport({
    required ProjectModel project,
    required List<DepenseModel> depenses,
  }) async {
    final pdf = pw.Document();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');
    
    // Calculs
    final double totalDepenses = depenses.fold(0, (sum, item) => sum + item.montant);
    final double budget = project.budgetPrevisionnel;
    final double ecart = budget - totalDepenses;

    // Grouper par catégorie
    final Map<String, double> byCategory = {};
    for (var d in depenses) {
      byCategory[d.categorie] = (byCategory[d.categorie] ?? 0) + d.montant;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader('Rapport Financier Détaillé', project.titre),
        footer: _buildFooter,
        build: (context) => [
          _buildProjectInfo(project),
          pw.SizedBox(height: 20),
          
          // Résumé
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryBox('Budget Prévu', currencyFormat.format(budget), PdfColors.blue800),
                _buildSummaryBox('Total Dépenses', currencyFormat.format(totalDepenses), PdfColors.orange800),
                _buildSummaryBox('Reste / Écart', currencyFormat.format(ecart), ecart >= 0 ? PdfColors.green800 : PdfColors.red800),
              ],
            ),
          ),
          
          pw.SizedBox(height: 30),
          pw.Text('Dépenses par catégorie', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
          pw.SizedBox(height: 10),
          _buildCategoryTable(byCategory, currencyFormat),

          pw.SizedBox(height: 30),
          pw.Text('Détail des dépenses', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
          pw.SizedBox(height: 10),
          _buildExpensesTable(depenses, currencyFormat),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateQuote({
    required DevisModel devis,
    required EntrepriseModel entreprise,
  }) async {
    final pdf = pw.Document();
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // En-tête du devis (Entreprise -> Client)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(entreprise.raisonSociale, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
                  pw.Text('Contact: via ChantierTrack'),
                  pw.Text('Tél: sur le profil'),
                  pw.Text('Localisation: ${entreprise.zoneIntervention.isNotEmpty ? entreprise.zoneIntervention.first : "N/A"}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('DEVIS', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: _secondaryColor)),
                  pw.Text('Réf: ${devis.id.substring(0, 8).toUpperCase()}'),
                  pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(devis.dateEnvoi)}'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 40),
          
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            color: PdfColors.grey200,
            width: double.infinity,
            child: pw.Text('PROJET: ${devis.projectId}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), // Idéalement le nom du projet
          ),
          
          pw.SizedBox(height: 20),
          pw.Text('Détails de la proposition :', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text(devis.description),
          
          pw.SizedBox(height: 30),
          
          // Total Box
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _primaryColor, width: 2),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('MONTANT TOTAL (TTC):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(currencyFormat.format(devis.montant), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          
          pw.SizedBox(height: 50),
          pw.Text('Conditions de validité :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
          pw.Text('Ce devis est valable pour une durée de 30 jours à compter de la date d\'émission.'),
        ],
        footer: _buildFooter,
      ),
    );

    return pdf.save();
  }

  // --- Helper Widgets --- //

  static pw.Widget _buildHeader(String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('ChantierTrack', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _primaryColor)),
            pw.Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(DateTime.now()), style: const pw.TextStyle(color: PdfColors.grey)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text(title, style: pw.TextStyle(fontSize: 20, color: _secondaryColor, fontWeight: pw.FontWeight.bold)),
        pw.Text(subtitle, style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
        pw.SizedBox(height: 20),
        pw.Divider(color: _primaryColor, thickness: 2),
        pw.SizedBox(height: 20),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Page ${context.pageNumber} sur ${context.pagesCount}',
        style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
      ),
    );
  }

  static pw.Widget _buildProjectInfo(ProjectModel project) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Informations', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Client ID: ${project.clientId}'), // En prod: Nom du client
              pw.Text('Localisation: ${project.localisation}'),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Calendrier', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Début prévu: ${DateFormat('dd/MM/yyyy').format(project.dateDebut)}'),
              pw.Text('Fin prévue: ${DateFormat('dd/MM/yyyy').format(project.dateFinPrevue)}'),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRapportItem(RapportAvancementModel rapport) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(DateFormat('dd/MM/yyyy à HH:mm').format(rapport.date), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('${rapport.pourcentageAvancement}%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primaryColor)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(rapport.description, style: const pw.TextStyle(color: PdfColors.grey800)),
          if (rapport.photos.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('[${rapport.photos.length} photo(s) attachée(s)]', style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10, fontStyle: pw.FontStyle.italic)),
            // Note: En prod, il faut télécharger les images et les convertir en MemoryImage pour les afficher dans le PDF.
          ]
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryBox(String title, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 12)),
        pw.Text(value, style: pw.TextStyle(color: color, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildCategoryTable(Map<String, double> byCategory, NumberFormat format) {
    return pw.TableHelper.fromTextArray(
      context: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _secondaryColor),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
      cellAlignment: pw.Alignment.centerLeft,
      headers: ['Catégorie', 'Total'],
      data: byCategory.entries.map((e) => [e.key.toUpperCase(), format.format(e.value)]).toList(),
    );
  }

  static pw.Widget _buildExpensesTable(List<DepenseModel> depenses, NumberFormat format) {
    return pw.TableHelper.fromTextArray(
      context: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _primaryColor),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
      cellAlignment: pw.Alignment.centerLeft,
      headers: ['Date', 'Catégorie', 'Description', 'Montant', 'Statut'],
      data: depenses.map((d) => [
        DateFormat('dd/MM/yy').format(d.dateDeclaration),
        d.categorie,
        d.description,
        format.format(d.montant),
        d.statut
      ]).toList(),
    );
  }
}
