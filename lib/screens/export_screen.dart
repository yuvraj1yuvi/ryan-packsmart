import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../models/trip.dart';
import '../services/pdf_service.dart';

class ExportScreen extends StatelessWidget {
  final Trip trip;

  const ExportScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Share Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share PDF File',
            onPressed: () => PdfService.sharePdf(trip),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy as Text',
            onPressed: () {
              final text = PdfService.getShareableText(trip);
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checklist copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick actions toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.message_outlined, size: 16),
                    label: const Text('Share Text'),
                    onPressed: () => PdfService.shareAsText(trip),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: const Text('Share PDF'),
                    onPressed: () => PdfService.sharePdf(trip),
                  ),
                ),
              ],
            ),
          ),
          // Live PDF viewer
          Expanded(
            child: PdfPreview(
              build: (format) => PdfService.generatePdf(trip),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
            ),
          ),
        ],
      ),
    );
  }
}
