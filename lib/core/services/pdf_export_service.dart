import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/feasibility_study.dart';
import '../../widgets/common/app_snack_bar.dart';

class PdfExportService {
  /// Fixes Arabic isolated Yeh characters so they render correctly in Cairo font
  /// without disappearing or failing to display.
  static String _fixArabic(String text, bool isAr) {
    if (!isAr || text.isEmpty) return text;
    final isolatedYehRegex = RegExp(
      r'(^|[\s\p{P}\d]|[اأإآدذرزوؤىةء])ي(?=[\s\p{P}\d]|$)',
      unicode: true,
    );
    return text.replaceAllMapped(isolatedYehRegex, (m) => '${m.group(1)}ى');
  }

  /// Builds a TableRow respecting RTL reading order by reversing cells when [isAr] is true.
  static pw.TableRow _buildTableRow(
    List<pw.Widget> cells, {
    required bool isAr,
    pw.BoxDecoration? decoration,
  }) {
    return pw.TableRow(
      decoration: decoration,
      children: isAr ? cells.reversed.toList() : cells,
    );
  }

  /// Formats a single table cell with appropriate alignment and font weights.
  static pw.Widget _tableCell(
    String text, {
    required bool isAr,
    required pw.Font regularFont,
    required pw.Font boldFont,
    bool bold = false,
    pw.TextAlign? align,
    PdfColor? color,
  }) {
    final defaultAlign = isAr ? pw.TextAlign.right : pw.TextAlign.left;
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: pw.Text(
        _fixArabic(text, isAr),
        textAlign: align ?? defaultAlign,
        style: pw.TextStyle(
          font: bold ? boldFont : regularFont,
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (bold ? PdfColor.fromHex('#1E2547') : PdfColors.blueGrey800),
        ),
      ),
    );
  }

  static Future<Uint8List> generateFeasibilityPdf({
    required FeasibilityStudy study,
    required String locale,
  }) async {
    final pdf = pw.Document();

    // Prefer local Cairo fonts bundled in assets for offline fidelity, fallback to Google Fonts
    pw.Font fontRegular;
    pw.Font fontBold;
    try {
      final regData = await rootBundle.load('google_fonts/Cairo-Regular.ttf');
      final boldData = await rootBundle.load('google_fonts/Cairo-Bold.ttf');
      fontRegular = pw.Font.ttf(regData);
      fontBold = pw.Font.ttf(boldData);
    } catch (_) {
      try {
        fontRegular = await PdfGoogleFonts.cairoRegular();
        fontBold = await PdfGoogleFonts.cairoBold();
      } catch (_) {
        fontRegular = pw.Font.helvetica();
        fontBold = pw.Font.helveticaBold();
      }
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

    final verdictTitle = isAr ? 'قرار دراسة الجدوى' : 'FEASIBILITY VERDICT';
    final scoreLabel = isAr ? 'الدرجة: ${study.feasibilityScore}/100' : 'Score: ${study.feasibilityScore}/100';
    final dossierTitle = isAr ? 'ملف دراسة الجدوى التنفيذية' : 'EXECUTIVE FEASIBILITY DOSSIER';
    final footerText = isAr
        ? 'منصة فاليوت للذكاء العقاري | سري ومملوك'
        : 'Valuate Real Estate Intelligence Platform | Confidential & Proprietary';
    final metaLine = isAr
        ? 'الموقع: ${study.location} | مدة التنفيذ: ${study.developmentMonths} شهراً | العملة: ${study.currency}'
        : 'Location: ${study.location} | Timeline: ${study.developmentMonths} Months | Currency: ${study.currency}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        header: (pw.Context context) {
          return pw.Directionality(
            textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 8),
              margin: const pw.EdgeInsets.only(bottom: 6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.blueGrey200, width: 0.8),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 22,
                        height: 22,
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#1E2547'),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'V',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 7),
                      pw.Text(
                        'VALUATE',
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('#1E2547'),
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    _fixArabic(dossierTitle, isAr),
                    style: pw.TextStyle(
                      color: PdfColors.blueGrey600,
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: isAr ? 0 : 0.8,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        footer: (pw.Context context) {
          final pageText = isAr
              ? 'صفحة ${context.pageNumber} من ${context.pagesCount}'
              : 'Page ${context.pageNumber} of ${context.pagesCount}';
          return pw.Directionality(
            textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Container(
              padding: const pw.EdgeInsets.only(top: 8),
              margin: const pw.EdgeInsets.only(top: 6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.blueGrey100, width: 0.8),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    _fixArabic(footerText, isAr),
                    style: const pw.TextStyle(color: PdfColors.blueGrey400, fontSize: 7.5),
                  ),
                  pw.Text(
                    _fixArabic(pageText, isAr),
                    style: const pw.TextStyle(color: PdfColors.blueGrey400, fontSize: 7.5),
                  ),
                ],
              ),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Directionality(
              textDirection: isAr ? pw.TextDirection.rtl : pw.TextDirection.ltr,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Title & Meta Box
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#1E2547'),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              _fixArabic(study.title, isAr),
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#2B3969'),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                _fixArabic(study.assetType, isAr),
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          _fixArabic(metaLine, isAr),
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#E8E8E8'),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // Executive Verdict Badge
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: verdictColor, width: 1.2),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              _fixArabic(verdictTitle, isAr),
                              style: const pw.TextStyle(
                                color: PdfColors.blueGrey700,
                                fontSize: 8,
                                letterSpacing: 0.6,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              _fixArabic(verdictText, isAr),
                              style: pw.TextStyle(
                                color: verdictColor,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: verdictColor,
                            borderRadius: pw.BorderRadius.circular(5),
                          ),
                          child: pw.Text(
                            _fixArabic(scoreLabel, isAr),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 12),

                  // Section 1: KPI Table
                  pw.Text(
                    _fixArabic(
                      isAr ? '1. مؤشرات الأداء المالي الرئيسية' : '1. KEY FINANCIAL PERFORMANCE INDICATORS',
                      isAr,
                    ),
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1E2547'),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    children: [
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'المؤشر المالي' : 'Financial Metric', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true),
                          _tableCell(isAr ? 'القيمة' : 'Value', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                          _tableCell(isAr ? 'المعيار المستهدف' : 'Benchmark Target', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                          _tableCell(isAr ? 'الحالة' : 'Status', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'العائد على الاستثمار (ROI)' : 'Return on Investment (ROI)', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell('${study.roiPct.toStringAsFixed(1)}%', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell('>= 20.0%', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(isAr ? (study.roiPct >= 20 ? 'ممتاز' : 'متوسط') : (study.roiPct >= 20 ? 'Optimal' : 'Moderate'), isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'معدل العائد الداخلي السنوي (IRR)' : 'Annualized Project IRR', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell('${study.annualizedIrrPct.toStringAsFixed(1)}%', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell('>= 15.0%', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(isAr ? (study.annualizedIrrPct >= 15 ? 'ممتاز' : 'قياسي') : (study.annualizedIrrPct >= 15 ? 'Optimal' : 'Standard'), isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'مضاعف حقوق الملكية (MOIC)' : 'Equity Multiple (MOIC)', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell('${study.equityMultiple.toStringAsFixed(2)}x', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell('>= 1.25x', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(isAr ? (study.equityMultiple >= 1.25 ? 'قوي' : 'متوسط') : (study.equityMultiple >= 1.25 ? 'Strong' : 'Moderate'), isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'صافي الأرباح (EBIT)' : 'Net Profit (EBIT)', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell('${currencyFmt.format(study.netProfit)} ${study.currency}', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell('> 0', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(isAr ? (study.netProfit > 0 ? 'مربح' : 'عجز') : (study.netProfit > 0 ? 'Profitable' : 'Deficit'), isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'سعر نقطة التعادل (للمتر المربع)' : 'Breakeven Price / m²', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell(isAr ? '${currencyFmt.format(study.breakevenPerSqm)} ${study.currency} / متر مربع' : '${currencyFmt.format(study.breakevenPerSqm)} ${study.currency}/m²', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(isAr ? '< سعر البيع' : '< Sale Price', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(isAr ? (study.breakevenPerSqm < study.expectedRevenuePerSqm ? 'هامش آمن' : 'هامش ضيق') : (study.breakevenPerSqm < study.expectedRevenuePerSqm ? 'Safe Cushion' : 'Tight Margin'), isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),

                  // Section 2: TDC Breakdown Table
                  pw.Text(
                    _fixArabic(
                      isAr ? '2. تفاصيل إجمالي تكاليف التطوير (TDC)' : '2. TOTAL DEVELOPMENT COST (TDC) BREAKDOWN',
                      isAr,
                    ),
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1E2547'),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    children: [
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'بند التكلفة' : 'Cost Component', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true),
                          _tableCell(isAr ? 'المعدل / الأساس' : 'Rate / Basis', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                          _tableCell(isAr ? 'الإجمالي (${study.currency})' : 'Total (${study.currency})', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                          _tableCell(isAr ? 'نسبة من التكلفة' : '% of TDC', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'شراء الأرض' : 'Land Acquisition', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell(isAr ? '${currencyFmt.format(study.landArea)} متر مربع' : '${currencyFmt.format(study.landArea)} m²', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(currencyFmt.format(study.landCost), isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell('${study.totalDevelopmentCost > 0 ? ((study.landCost / study.totalDevelopmentCost) * 100).toStringAsFixed(1) : 0}%', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'تكاليف البناء المباشرة' : 'Hard Construction Costs', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell(isAr ? '${currencyFmt.format(study.constructionCostPerSqm)} ${study.currency} / متر مربع' : '${currencyFmt.format(study.constructionCostPerSqm)} ${study.currency}/m²', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(currencyFmt.format(study.hardConstructionCost), isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell('${study.totalDevelopmentCost > 0 ? ((study.hardConstructionCost / study.totalDevelopmentCost) * 100).toStringAsFixed(1) : 0}%', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'التكاليف غير المباشرة (استشارات ورخص)' : 'Soft Costs (Permits/Consultants)', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell(isAr ? '${study.softCostPct.toStringAsFixed(1)}% من تكلفة البناء' : '${study.softCostPct.toStringAsFixed(1)}% of Hard Cost', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(currencyFmt.format(study.softCosts), isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell('${study.totalDevelopmentCost > 0 ? ((study.softCosts / study.totalDevelopmentCost) * 100).toStringAsFixed(1) : 0}%', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'احتياطي الطوارئ' : 'Contingency Reserve', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell(isAr ? '${study.contingencyPct.toStringAsFixed(1)}% احتياطي' : '${study.contingencyPct.toStringAsFixed(1)}% Reserve', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell(currencyFmt.format(study.contingencyCost), isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                          _tableCell('${study.totalDevelopmentCost > 0 ? ((study.contingencyCost / study.totalDevelopmentCost) * 100).toStringAsFixed(1) : 0}%', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'إجمالي تكاليف التطوير (TDC)' : 'TOTAL DEVELOPMENT COST (TDC)', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true),
                          _tableCell('-', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                          _tableCell('${currencyFmt.format(study.totalDevelopmentCost)} ${study.currency}', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                          _tableCell('100.0%', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                        decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),

                  // Section 3: Revenue & Zoning Program Table
                  pw.Text(
                    _fixArabic(
                      isAr ? '3. برنامج الإيرادات ومحددات البناء' : '3. REVENUE & ZONING PROGRAM',
                      isAr,
                    ),
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1E2547'),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    children: [
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'المحدد / البيان' : 'Parameter', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true),
                          _tableCell(isAr ? 'القيمة المحسوبة' : 'Calculated Metric', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'مساحة الأرض' : 'Plot Area', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell(isAr ? '${currencyFmt.format(study.landArea)} متر مربع' : '${currencyFmt.format(study.landArea)} m²', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'معامل مسطحات البناء (FAR)' : 'Floor Area Ratio (FAR)', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell('${study.far.toStringAsFixed(2)}x', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'إجمالي مسطحات البناء (BUA)' : 'Built-Up Area (BUA)', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell(isAr ? '${currencyFmt.format(study.bua)} متر مربع' : '${currencyFmt.format(study.bua)} m²', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'المساحة البيعية / التأجيرية (GFA)' : 'Salable / Gross Floor Area (GFA)', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell(isAr ? '${currencyFmt.format(study.gfa)} متر مربع (${study.efficiencyPct.toStringAsFixed(0)}% كفاءة)' : '${currencyFmt.format(study.gfa)} m² (${study.efficiencyPct.toStringAsFixed(0)}% Efficiency)', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'سعر البيع المستهدف (للمتر المربع)' : 'Target Sale Price / m²', isAr: isAr, regularFont: fontRegular, boldFont: fontBold),
                          _tableCell(isAr ? '${currencyFmt.format(study.expectedRevenuePerSqm)} ${study.currency} / متر مربع' : '${currencyFmt.format(study.expectedRevenuePerSqm)} ${study.currency}/m²', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                      ),
                      _buildTableRow(
                        [
                          _tableCell(isAr ? 'إجمالي الإيرادات المتوقعة' : 'GROSS PROJECTED REVENUE', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true),
                          _tableCell('${currencyFmt.format(study.grossRevenue)} ${study.currency}', isAr: isAr, regularFont: fontRegular, boldFont: fontBold, bold: true, align: pw.TextAlign.center),
                        ],
                        isAr: isAr,
                        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),

                  // Disclaimer Box
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      borderRadius: pw.BorderRadius.circular(5),
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                    ),
                    child: pw.Text(
                      _fixArabic(
                        isAr
                            ? 'إخلاء مسؤولية: تم إعداد هذا التقرير عبر محرك تحليلات فاليوت استناداً إلى المدخلات المقدمة ومؤشرات البناء الإقليمية. هذه التقديرات مخصصة لدعم القرار والتقييم الاستثماري.'
                            : 'DISCLAIMER: This feasibility dossier is generated by the Valuate Intelligence Engine based on supplied inputs and regional construction benchmarks. Projections are intended for investment underwriting and decision support.',
                        isAr,
                      ),
                      style: const pw.TextStyle(
                        color: PdfColors.blueGrey600,
                        fontSize: 7,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
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
        AppSnackBar.showError(
          context,
          message: 'Error generating PDF: $e',
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
        AppSnackBar.showError(
          context,
          message: 'Error opening PDF: $e',
        );
      }
    }
  }
}
