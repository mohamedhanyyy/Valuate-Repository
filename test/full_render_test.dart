import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

String fixArabic(String text) {
  final isolatedYehRegex = RegExp(
    r'(^|[\s\p{P}\d]|[اأإآدذرزوؤىةء])ي(?=[\s\p{P}\d]|$)',
    unicode: true,
  );
  return text.replaceAllMapped(isolatedYehRegex, (m) => '${m.group(1)}ى');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Render full Arabic text with fixArabic and RTL', () async {
    final cairoReg = await PdfGoogleFonts.cairoRegular();
    final cairoBold = await PdfGoogleFonts.cairoBold();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: cairoReg, bold: cairoBold),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(fixArabic('مشروع سكني تجاري بالرياض'), style: pw.TextStyle(font: cairoBold, fontSize: 22)),
                pw.SizedBox(height: 10),
                pw.Text(fixArabic('مجمع سكني تجاري'), style: pw.TextStyle(font: cairoReg, fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Text(fixArabic('الموقع: الرياض، المملكة العربية السعودية | المدة: 24 شهر | العملة: SAR'), style: pw.TextStyle(font: cairoReg, fontSize: 13)),
                pw.SizedBox(height: 10),
                pw.Text(fixArabic('قرار مجدٍ استثمارياً (GO)'), style: pw.TextStyle(font: cairoBold, fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Text(fixArabic('1. مؤشرات الأداء المالي الرئيسية'), style: pw.TextStyle(font: cairoBold, fontSize: 15)),
                pw.SizedBox(height: 10),
                pw.Text(fixArabic('العائد على الاستثمار (ROI): 15.2%'), style: pw.TextStyle(font: cairoReg, fontSize: 13)),
                pw.SizedBox(height: 10),
                pw.Text(fixArabic('معدل العائد الداخلي السنوي (IRR): 7.3%'), style: pw.TextStyle(font: cairoReg, fontSize: 13)),
                pw.SizedBox(height: 10),
                pw.Text(fixArabic('مضاعف حقوق الملكية (MOIC): 1.15x'), style: pw.TextStyle(font: cairoReg, fontSize: 13)),
                pw.SizedBox(height: 10),
                pw.Text(fixArabic('صافي الأرباح: 9,122,500 ريال سعودي'), style: pw.TextStyle(font: cairoReg, fontSize: 13)),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    expect(bytes.isNotEmpty, true);
  });
}
