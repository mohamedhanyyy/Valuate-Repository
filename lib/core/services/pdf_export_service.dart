import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/feasibility_study.dart';

class PdfExportService {
  static Future<Uint8List> generateFeasibilityPdf({
    required FeasibilityStudy study,
    required String locale,
  }) async {
    final pdf = pw.Document();

    pw.Font fontRegular;
    pw.Font fontBold;
    try {
      fontRegular = await PdfGoogleFonts.cairoRegular();
      fontBold = await PdfGoogleFonts.cairoBold();
    } catch (_) {
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    final currencyFmt = NumberFormat('#,##0', 'en_US');
    final isAr = locale == 'ar';

    final verdictColor = study.verdict == VerdictType.go
        ? PdfColors.green800
        : study.verdict == VerdictType.caution
            ? PdfColors.amber800
            : PdfColors.red800;

    final verdictText = study.verdict == VerdictType.go
        ? (isAr ? 'قرار مجدٍ استثمارياً (GO)' : 'GO - VIABLE INVESTMENT')
        : study.verdict == VerdictType.caution
            ? (isAr ? 'يتطلب الحذر والمراجعة (CAUTION)' : 'CAUTION - CONDITIONAL')
            : (isAr ? 'غير مجدٍ استثمارياً (NO-GO)' : 'NO-GO - HIGH RISK');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.blueGrey200, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 24,
                      height: 24,
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#D4AF37'),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'V',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'VALUATE',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#0B2545'),
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'EXECUTIVE FEASIBILITY DOSSIER',
                  style: pw.TextStyle(
                    color: PdfColors.blueGrey600,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.blueGrey100, width: 0.8),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Valuate Real Estate Intelligence Platform | Confidential & Proprietary',
                  style: const pw.TextStyle(color: PdfColors.blueGrey400, fontSize: 8),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(color: PdfColors.blueGrey400, fontSize: 8),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 10),

            // Document Title & Meta Box
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0B2545'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        study.title.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#D4AF37'),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          study.assetType.toUpperCase(),
                          style: pw.TextStyle(
                            color: PdfColors.black,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Location: ${study.location} | Timeline: ${study.developmentMonths} Months | Currency: ${study.currency}',
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('#E2E8F0'),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Executive Verdict Badge
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: verdictColor, width: 1.5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'FEASIBILITY VERDICT',
                        style: const pw.TextStyle(
                          color: PdfColors.blueGrey700,
                          fontSize: 9,
                          letterSpacing: 0.8,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        verdictText,
                        style: pw.TextStyle(
                          color: verdictColor,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: verdictColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'Score: ${study.feasibilityScore}/100',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),

            // Key Return Metrics Grid
            pw.Text(
              '1. KEY FINANCIAL PERFORMANCE INDICATORS',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0B2545'),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableHeader('Financial Metric'),
                    _tableHeader('Value'),
                    _tableHeader('Benchmark Target'),
                    _tableHeader('Status'),
                  ],
                ),
                _tableRow('Return on Investment (ROI)', '${study.roiPct.toStringAsFixed(1)}%', '>= 20.0%', study.roiPct >= 20 ? 'Optimal' : 'Moderate'),
                _tableRow('Annualized Project IRR', '${study.annualizedIrrPct.toStringAsFixed(1)}%', '>= 15.0%', study.annualizedIrrPct >= 15 ? 'Optimal' : 'Standard'),
                _tableRow('Equity Multiple (MOIC)', '${study.equityMultiple.toStringAsFixed(2)}x', '>= 1.25x', study.equityMultiple >= 1.25 ? 'Strong' : 'Moderate'),
                _tableRow('Net Profit (EBIT)', '${currencyFmt.format(study.netProfit)} ${study.currency}', '> 0', study.netProfit > 0 ? 'Profitable' : 'Deficit'),
                _tableRow('Breakeven Price / m²', '${currencyFmt.format(study.breakevenPerSqm)} ${study.currency}/m²', '< Sale Price', study.breakevenPerSqm < study.expectedRevenuePerSqm ? 'Safe Cushion' : 'Tight Margin'),
              ],
            ),
            pw.SizedBox(height: 18),

            // Capital Expenditure (TDC) Breakdown
            pw.Text(
              '2. TOTAL DEVELOPMENT COST (TDC) BREAKDOWN',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0B2545'),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableHeader('Cost Component'),
                    _tableHeader('Rate / Basis'),
                    _tableHeader('Total (${study.currency})'),
                    _tableHeader('% of TDC'),
                  ],
                ),
                _tableRow('Land Acquisition', '${currencyFmt.format(study.landArea)} m²', currencyFmt.format(study.landCost), '${study.totalDevelopmentCost > 0 ? ((study.landCost / study.totalDevelopmentCost) * 100).toStringAsFixed(1) : 0}%'),
                _tableRow('Hard Construction Costs', '${currencyFmt.format(study.constructionCostPerSqm)} ${study.currency}/m²', currencyFmt.format(study.hardConstructionCost), '${study.totalDevelopmentCost > 0 ? ((study.hardConstructionCost / study.totalDevelopmentCost) * 100).toStringAsFixed(1) : 0}%'),
                _tableRow('Soft Costs (Permits/Consultants)', '${study.softCostPct.toStringAsFixed(1)}% of Hard Cost', currencyFmt.format(study.softCosts), '${study.totalDevelopmentCost > 0 ? ((study.softCosts / study.totalDevelopmentCost) * 100).toStringAsFixed(1) : 0}%'),
                _tableRow('Contingency Reserve', '${study.contingencyPct.toStringAsFixed(1)}% Reserve', currencyFmt.format(study.contingencyCost), '${study.totalDevelopmentCost > 0 ? ((study.contingencyCost / study.totalDevelopmentCost) * 100).toStringAsFixed(1) : 0}%'),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                  children: [
                    _tableCell('TOTAL DEVELOPMENT COST (TDC)', bold: true),
                    _tableCell('-', bold: true),
                    _tableCell('${currencyFmt.format(study.totalDevelopmentCost)} ${study.currency}', bold: true),
                    _tableCell('100.0%', bold: true),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 18),

            // Revenue & Gross Margin
            pw.Text(
              '3. REVENUE & ZONING PROGRAM',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0B2545'),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableHeader('Parameter'),
                    _tableHeader('Calculated Metric'),
                  ],
                ),
                _tableRow('Plot Area', '${currencyFmt.format(study.landArea)} m²'),
                _tableRow('Floor Area Ratio (FAR)', '${study.far.toStringAsFixed(2)}x'),
                _tableRow('Built-Up Area (BUA)', '${currencyFmt.format(study.bua)} m²'),
                _tableRow('Salable / Gross Floor Area (GFA)', '${currencyFmt.format(study.gfa)} m² (${study.efficiencyPct.toStringAsFixed(0)}% Efficiency)'),
                _tableRow('Target Sale Price / m²', '${currencyFmt.format(study.expectedRevenuePerSqm)} ${study.currency}/m²'),
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.amber50),
                  children: [
                    _tableCell('GROSS PROJECTED REVENUE', bold: true),
                    _tableCell('${currencyFmt.format(study.grossRevenue)} ${study.currency}', bold: true),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Disclaimer Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
              ),
              child: pw.Text(
                'DISCLAIMER: This feasibility dossier is generated by the Valuate Intelligence Engine based on supplied inputs and regional construction benchmarks. Projections are intended for investment underwriting and decision support.',
                style: const pw.TextStyle(
                  color: PdfColors.blueGrey600,
                  fontSize: 7.5,
                  height: 1.3,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
    );
  }

  static pw.TableRow _tableRow(String c1, String c2, [String? c3, String? c4]) {
    return pw.TableRow(
      children: [
        _tableCell(c1),
        _tableCell(c2),
        if (c3 != null) _tableCell(c3),
        if (c4 != null) _tableCell(c4),
      ],
    );
  }

  static pw.Widget _tableCell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: bold ? PdfColor.fromHex('#0B2545') : PdfColors.blueGrey800,
        ),
      ),
    );
  }

  /// Generates the PDF and immediately opens the native share sheet
  static Future<void> sharePdf(
    BuildContext context, {
    required FeasibilityStudy study,
    required String locale,
  }) async {
    try {
      final pdfBytes = await generateFeasibilityPdf(
        study: study,
        locale: locale,
      );

      final cleanName = study.title.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF-]'), '_').trim();
      final filename = '$cleanName-Feasibility-Report.pdf';

      Rect? bounds;
      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          bounds = box.localToGlobal(Offset.zero) & box.size;
        }
      }

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: filename,
        bounds: bounds,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generates the PDF and opens full print / preview dialog
  static Future<void> previewOrPrintPdf(
    BuildContext context, {
    required FeasibilityStudy study,
    required String locale,
  }) async {
    try {
      final cleanName = study.title.replaceAll(RegExp(r'[^\w\s\u0600-\u06FF-]'), '_').trim();
      final filename = '$cleanName-Feasibility-Report.pdf';

      await Printing.layoutPdf(
        name: filename,
        onLayout: (PdfPageFormat format) async {
          return await generateFeasibilityPdf(
            study: study,
            locale: locale,
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
