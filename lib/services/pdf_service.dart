import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/trip.dart';

class PdfService {
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  static Future<Uint8List> generatePdf(Trip trip) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromInt(0xFF028090);
    final darkColor = PdfColor.fromInt(0xFF1B2A32);
    final accentGreen = PdfColor.fromInt(0xFF10B981);
    final accentRed = PdfColor.fromInt(0xFFEF4444);
    final lightGrey = PdfColor.fromInt(0xFFF1F5F9);
    final textMuted = PdfColor.fromInt(0xFF64748B);

    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/logo.jpg');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 20),
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 38,
                        height: 38,
                        margin: const pw.EdgeInsets.only(right: 10),
                        child: pw.ClipRRect(
                          horizontalRadius: 8,
                          verticalRadius: 8,
                          child: pw.Image(logoImage),
                        ),
                      ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PACKSMART',
                          style: pw.TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          trip.title,
                          style: pw.TextStyle(
                            color: darkColor,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (trip.destination.isNotEmpty)
                          pw.Text(
                            'Destination: ${trip.destination}',
                            style: pw.TextStyle(color: textMuted, fontSize: 11),
                          ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Departure: ${_dateFormat.format(trip.departureDate)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                        color: darkColor,
                      ),
                    ),
                    if (trip.returnDate != null)
                      pw.Text(
                        'Return: ${_dateFormat.format(trip.returnDate!)}',
                        style: pw.TextStyle(fontSize: 10, color: textMuted),
                      ),
                    pw.Text(
                      'Type: ${trip.templateType}',
                      style: pw.TextStyle(fontSize: 10, color: textMuted),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 16),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Created with PackSmart • Smart Packing & Luggage Tracker',
                  style: pw.TextStyle(color: textMuted, fontSize: 8),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(color: textMuted, fontSize: 8),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          final categories = trip.categories;

          return [
            // Summary KPI Cards
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightGrey,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildKpiCard(
                    'Packed Items',
                    '${trip.packedItems} / ${trip.totalItems}',
                    '${(trip.packedPercentage * 100).toInt()}% Done',
                    primaryColor,
                  ),
                  _buildKpiCard(
                    'Estimated Weight',
                    '${trip.totalWeightKg.toStringAsFixed(1)} kg',
                    'Limit: ${trip.maxWeightKg.toStringAsFixed(1)} kg',
                    trip.isOverweight ? accentRed : accentGreen,
                  ),
                  _buildKpiCard(
                    'Countdown',
                    trip.daysUntilDeparture <= 0
                        ? 'Today!'
                        : '${trip.daysUntilDeparture} Days',
                    trip.daysUntilDeparture < 0 ? 'Past departure' : 'Until departure',
                    darkColor,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Item lists by category
            ...categories.map((category) {
              final items = trip.getItemsByCategory(category);
              final categoryPacked = items.where((i) => i.isPacked).length;
              final categoryWeight = items.fold(0.0, (s, i) => s + (i.weightKg * i.quantity));

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Category Header
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFE2E8F0),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            category.toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                          pw.Text(
                            '$categoryPacked/${items.length} packed • ${categoryWeight.toStringAsFixed(1)} kg',
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 6),

                    // Items Table
                    pw.Table(
                      border: const pw.TableBorder(
                        horizontalInside: pw.BorderSide(
                          color: PdfColors.grey200,
                          width: 0.5,
                        ),
                      ),
                      columnWidths: {
                        0: const pw.FixedColumnWidth(24),
                        1: const pw.FlexColumnWidth(4),
                        2: const pw.FixedColumnWidth(45),
                        3: const pw.FixedColumnWidth(55),
                      },
                      children: items.map((item) {
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 4),
                              child: pw.Container(
                                width: 12,
                                height: 12,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    color: item.isPacked ? accentGreen : PdfColors.grey400,
                                    width: 1.5,
                                  ),
                                  borderRadius: pw.BorderRadius.circular(2),
                                  color: item.isPacked ? accentGreen : null,
                                ),
                                child: item.isPacked
                                    ? pw.Center(
                                        child: pw.Text(
                                          '✓',
                                          style: const pw.TextStyle(
                                            color: PdfColors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 4),
                              child: pw.Text(
                                item.name,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  color: item.isPacked ? textMuted : darkColor,
                                  decoration: item.isPacked
                                      ? pw.TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 4),
                              child: pw.Text(
                                'x${item.quantity}',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: textMuted,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 4),
                              child: pw.Text(
                                item.weightKg > 0
                                    ? '${(item.weightKg * item.quantity).toStringAsFixed(1)} kg'
                                    : '-',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  color: textMuted,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildKpiCard(
    String label,
    String value,
    String subtext,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: PdfColor.fromInt(0xFF64748B),
            fontSize: 9,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          subtext,
          style: pw.TextStyle(
            color: PdfColor.fromInt(0xFF94A3B8),
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  static Future<void> sharePdf(Trip trip) async {
    final bytes = await generatePdf(trip);
    final filename =
        'PackSmart_${trip.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  static Future<void> printPdf(Trip trip) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) => generatePdf(trip),
      name: 'PackSmart - ${trip.title}',
    );
  }

  static String getShareableText(Trip trip) {
    final buffer = StringBuffer();
    final depDateStr = _dateFormat.format(trip.departureDate);

    buffer.writeln('✈️ PACKSMART: ${trip.title.toUpperCase()}');
    if (trip.destination.isNotEmpty) {
      buffer.writeln('📍 Destination: ${trip.destination}');
    }
    buffer.writeln('📅 Departure: $depDateStr (${trip.daysUntilDeparture} days)');
    buffer.writeln('📊 Progress: ${trip.packedItems}/${trip.totalItems} Packed (${(trip.packedPercentage * 100).toInt()}%)');
    buffer.writeln('⚖️ Weight: ${trip.totalWeightKg.toStringAsFixed(1)} kg / ${trip.maxWeightKg.toStringAsFixed(1)} kg limit');
    if (trip.isOverweight) {
      buffer.writeln('⚠️ CAUTION: Luggage is overweight by +${trip.excessWeightKg.toStringAsFixed(1)} kg!');
    }
    buffer.writeln('\n----------------------------------------');

    for (final category in trip.categories) {
      final items = trip.getItemsByCategory(category);
      buffer.writeln('\n📁 $category');
      for (final item in items) {
        final check = item.isPacked ? '[✓]' : '[ ]';
        final qtyStr = item.quantity > 1 ? ' (x${item.quantity})' : '';
        final weightStr = item.weightKg > 0 ? ' [${(item.weightKg * item.quantity).toStringAsFixed(1)}kg]' : '';
        buffer.writeln('  $check ${item.name}$qtyStr$weightStr');
      }
    }

    buffer.writeln('\n----------------------------------------');
    buffer.writeln('Generated with PackSmart');
    return buffer.toString();
  }

  static Future<void> shareAsText(Trip trip) async {
    final text = getShareableText(trip);
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'Packing Checklist: ${trip.title}',
      ),
    );
  }
}
