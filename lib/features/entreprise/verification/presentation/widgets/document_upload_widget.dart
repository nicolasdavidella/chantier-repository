import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../data/models/verification_document_model.dart';

class DocumentUploadWidget extends StatefulWidget {
  final String title;
  final String documentType;
  final bool isRequired;
  final VerificationDocumentModel? currentDocument;
  final Function(File) onFileSelected;

  const DocumentUploadWidget({
    super.key,
    required this.title,
    required this.documentType,
    this.isRequired = true,
    this.currentDocument,
    required this.onFileSelected,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result.isNotEmpty && result.first.path != null) {
      final file = File(result.first.path!);
      setState(() {
        _selectedFile = file;
      });
      widget.onFileSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.currentDocument?.status ?? 'PENDING';
    final isRejected = status == 'REJECTED';
    final isApproved = status == 'APPROVED';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (widget.isRequired)
                  const Text('* Requis', style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
            if (widget.currentDocument != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isApproved ? Icons.check_circle : (isRejected ? Icons.error : Icons.access_time),
                    color: isApproved ? Colors.green : (isRejected ? Colors.red : Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isApproved ? 'Validé' : (isRejected ? 'Rejeté' : 'En attente de vérification'),
                    style: TextStyle(
                      color: isApproved ? Colors.green : (isRejected ? Colors.red : Colors.orange),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (isRejected && widget.currentDocument!.rejectionReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Motif : \${widget.currentDocument!.rejectionReason}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            if (!isApproved)
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: Text(_selectedFile != null ? 'Changer le fichier' : 'Téléverser un document'),
              ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Fichier sélectionné : \${_selectedFile!.path.split('/').last}",
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
