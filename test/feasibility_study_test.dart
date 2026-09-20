import 'package:flutter_test/flutter_test.dart';
import 'package:valuate_app/models/feasibility_study.dart';

void main() {
  group('FeasibilityStudy & Create Project Tests', () {
    test('Model instantiation with new wizard fields and calculations', () {
      final study = FeasibilityStudy(
        id: 'test_prj_01',
        title: 'برج النرجس ريزيدنس',
        developerName: 'mohamed hany',
        assetType: 'سكني',
        selectedSectors: ['سكني', 'تجاري', 'ضيافة'],
        sectorPercentages: {'سكني': 50.0, 'تجاري': 30.0, 'ضيافة': 20.0},
        projectType: 'بيع',
        country: 'المملكة العربية السعودية',
        location: 'الرياض - حي النرجس',
        mapLocation: '24.8423, 46.6631',
        landPaymentMode: 'دفع نقدي',
        landArea: 5000,
        far: 2.5,
        efficiencyPct: 85,
        landCost: 15000000,
        constructionCostPerSqm: 4200,
        expectedRevenuePerSqm: 9800,
        developmentMonths: 24,
        currency: 'SAR',
      );

      // Verify basic fields
      expect(study.developerName, 'mohamed hany');
      expect(study.assetType, 'سكني');
      expect(study.selectedSectors, ['سكني', 'تجاري', 'ضيافة']);
      expect(study.sectorPercentages['سكني'], 50.0);
      expect(study.sectorPercentages['تجاري'], 30.0);
      expect(study.sectorPercentages['ضيافة'], 20.0);
      expect(study.projectType, 'بيع');
      expect(study.country, 'المملكة العربية السعودية');
      expect(study.location, 'الرياض - حي النرجس');
      expect(study.mapLocation, '24.8423, 46.6631');
      expect(study.landPaymentMode, 'دفع نقدي');

      // Verify financial calculation getters
      expect(study.bua, 5000 * 2.5); // 12,500 m²
      expect(study.gfa, 12500 * 0.85); // 10,625 m²
      expect(study.hardConstructionCost, 12500 * 4200); // 52,500,000 SAR
      expect(study.grossRevenue, 10625 * 9800); // 104,125,000 SAR
      expect(study.netProfit, greaterThan(0));
      expect(study.roiPct, greaterThan(0));
      expect(study.verdict, isNotNull);

      // Verify JSON serialization round-trip
      final json = study.toJson();
      expect(json['developer_name'], 'mohamed hany');
      expect(json['selected_sectors'], ['سكني', 'تجاري', 'ضيافة']);
      expect(json['sector_percentages'], {'سكني': 50.0, 'تجاري': 30.0, 'ضيافة': 20.0});
      expect(json['project_type'], 'بيع');
      expect(json['country'], 'المملكة العربية السعودية');
      expect(json['map_location'], '24.8423, 46.6631');
      expect(json['land_payment_mode'], 'دفع نقدي');

      final deserialized = FeasibilityStudy.fromJson(json);
      expect(deserialized.id, study.id);
      expect(deserialized.developerName, study.developerName);
      expect(deserialized.selectedSectors, ['سكني', 'تجاري', 'ضيافة']);
      expect(deserialized.sectorPercentages['سكني'], 50.0);
      expect(deserialized.sectorPercentages['تجاري'], 30.0);
      expect(deserialized.sectorPercentages['ضيافة'], 20.0);
      expect(deserialized.projectType, study.projectType);
      expect(deserialized.country, study.country);
      expect(deserialized.location, study.location);
      expect(deserialized.landArea, study.landArea);
      expect(deserialized.far, study.far);
    });
  });
}
