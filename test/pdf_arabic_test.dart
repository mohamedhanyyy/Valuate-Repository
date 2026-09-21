import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:valuate_app/core/services/pdf_export_service.dart';
import 'package:valuate_app/models/feasibility_study.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Generate Arabic PDF through PdfExportService', () async {
    final study = FeasibilityStudy(
      id: 'test-study-ar',
      title: 'مشروع سكني تجاري بالرياض',
      assetType: 'مجمع سكني تجاري',
      location: 'الرياض، المملكة العربية السعودية',
      landArea: 5000,
      far: 2.5,
      landCost: 15000000,
      constructionCostPerSqm: 3200,
      expectedRevenuePerSqm: 6500,
      developmentMonths: 24,
      currency: 'SAR',
      createdAt: DateTime.now(),
    );

    final pdfBytes = await PdfExportService.generateFeasibilityPdf(
      study: study,
      locale: 'ar',
    );

    expect(pdfBytes.isNotEmpty, true);
    final file = File('final_arabic_pdf_output.pdf');
    await file.writeAsBytes(pdfBytes);
  });

  test('Generate English PDF through PdfExportService', () async {
    final study = FeasibilityStudy(
      id: 'test-study-en',
      title: 'Riyadh Mixed-Use Development',
      assetType: 'Mixed-Use Residential',
      location: 'Riyadh, Saudi Arabia',
      landArea: 5000,
      far: 2.5,
      landCost: 15000000,
      constructionCostPerSqm: 3200,
      expectedRevenuePerSqm: 6500,
      developmentMonths: 24,
      currency: 'SAR',
      createdAt: DateTime.now(),
    );

    final pdfBytes = await PdfExportService.generateFeasibilityPdf(
      study: study,
      locale: 'en',
    );

    expect(pdfBytes.isNotEmpty, true);
    final file = File('final_english_pdf_output.pdf');
    await file.writeAsBytes(pdfBytes);
  });

}
