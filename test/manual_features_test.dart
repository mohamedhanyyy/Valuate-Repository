import 'package:flutter_test/flutter_test.dart';
import 'package:valuate_app/models/feasibility_study.dart';
import 'package:valuate_app/models/project_product.dart';

void main() {
  group('Valuate User Manual Feature Alignment Tests', () {
    test('Slide 3: Project Status and Timing Fields', () {
      final study = FeasibilityStudy(
        id: 'p-75',
        projectNumber: 75,
        title: 'Compound Palm Hills',
        developerName: 'Palm Hills Developments',
        status: ProjectStatus.initialized,
        startYear: 2026,
        endYear: 2030,
        salesStartYear: 2026,
        assetType: 'Residential',
        location: 'West Cairo',
        landArea: 40000,
        landCost: 30000000,
        constructionCostPerSqm: 3500,
        expectedRevenuePerSqm: 8000,
      );

      expect(study.projectNumber, 75);
      expect(study.status, ProjectStatus.initialized);
      expect(study.startYear, 2026);
      expect(study.salesStartYear, 2026);
      expect(study.endYear, 2030);
      expect(study.projectYears, [2026, 2027, 2028, 2029, 2030]);
    });

    test('Slide 6: Product Catalog and Configuration', () {
      final residentialProducts = ProjectProduct.defaultCatalogForSectors(['Residential', 'سكني']);
      expect(residentialProducts.isNotEmpty, true);

      final villa = residentialProducts.firstWhere((p) => p.name.contains('Villa') || p.name.contains('فيلا'));
      expect(villa.avgArea > 0, true);
      expect(villa.utilityCapRatePct > 0, true);
      expect(villa.propertyFinishing.isNotEmpty, true);

      final configured = villa.copyWith(
        productMixPct: 30.0,
        plotArea: 400.0,
        avgArea: 280.0,
        propertyFinishing: 'Fully finished',
        priceRate: 45000.0,
      );

      expect(configured.productMixPct, 30.0);
      expect(configured.plotArea, 400.0);
      expect(configured.avgArea, 280.0);
      expect(configured.propertyFinishing, 'Fully finished');
    });

    test('Slide 8: Phased Run-Offs and Consolidated Cash Flow', () {
      final study = FeasibilityStudy(
        id: 'p-76',
        projectNumber: 76,
        title: 'East Cairo Gate',
        developerName: 'Gateway Real Estate',
        status: ProjectStatus.evaluated,
        startYear: 2026,
        endYear: 2028,
        salesStartYear: 2026,
        landArea: 10000,
        far: 2.0,
        landCost: 20000000,
        constructionCostPerSqm: 4000,
        expectedRevenuePerSqm: 9000,
        developmentMonths: 36,
        assumptions: const ProjectAssumptions(
          salesTrend: {2026: 30.0, 2027: 40.0, 2028: 30.0},
          priceGrowthRate: 10.0,
        ),
      );

      final constRunOff = study.getConstructionRunOff();
      expect(constRunOff.isNotEmpty, true);
      expect(constRunOff.containsKey('Grading & Mobilization'), true);

      final salesRunOff = study.getSalesRunOff();
      expect(salesRunOff.containsKey(2026), true);
      expect(salesRunOff.containsKey(2027), true);
      expect(salesRunOff.containsKey(2028), true);

      final consolidated = study.getConsolidatedCashFlow();
      expect(consolidated.length, 3);
      expect(consolidated.first.year, 2026);
      expect(consolidated.last.year, 2028);

      // Verify net cash flow = cash in - cash out
      for (final cf in consolidated) {
        expect((cf.netCashFlow - (cf.totalCashIn - cf.totalCashOut)).abs() < 0.01, true);
      }
    });

    test('Slide 9: MVP Working Rule (GO vs NO-GO)', () {
      // High profit study -> GO
      final profitableStudy = FeasibilityStudy(
        id: 'p-go',
        projectNumber: 80,
        title: 'High Yield Tower',
        startYear: 2026,
        endYear: 2028,
        salesStartYear: 2026,
        landArea: 5000,
        far: 3.0,
        landCost: 10000000,
        constructionCostPerSqm: 3000,
        expectedRevenuePerSqm: 12000,
        hurdleRate: 15.0,
      );

      expect(profitableStudy.annualizedIrrPct >= profitableStudy.hurdleRate, true);
      expect(profitableStudy.equityNpv() >= 0, true);
      expect(profitableStudy.isGoDecision, true);

      // Loss-making study -> NO-GO
      final lossStudy = FeasibilityStudy(
        id: 'p-nogo',
        projectNumber: 81,
        title: 'Unfeasible Tower',
        startYear: 2026,
        endYear: 2028,
        salesStartYear: 2026,
        landArea: 5000,
        far: 1.0,
        landCost: 50000000,
        constructionCostPerSqm: 8000,
        expectedRevenuePerSqm: 4000,
        hurdleRate: 20.0,
      );

      expect(lossStudy.isGoDecision, false);
    });
  });
}
