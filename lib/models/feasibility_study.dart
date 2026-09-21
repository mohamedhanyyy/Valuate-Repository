import 'dart:math';
import 'project_product.dart';

enum VerdictType { go, caution, noGo }

enum ProjectStatus {
  initialized, // Setup is incomplete (e.g. Products/Metrics or Assumptions missing)
  evaluated,   // Complete, outputs and cash flows are available
}

class SectorTimeline {
  final String sector;
  final int salesStartYear;
  final int salesEndYear;
  final int constructionStartYear;
  final int constructionEndYear;

  const SectorTimeline({
    required this.sector,
    this.salesStartYear = 2026,
    this.salesEndYear = 2029,
    this.constructionStartYear = 2026,
    this.constructionEndYear = 2028,
  });

  Map<String, dynamic> toJson() => {
    'sector': sector,
    'sales_start_year': salesStartYear,
    'sales_end_year': salesEndYear,
    'construction_start_year': constructionStartYear,
    'construction_end_year': constructionEndYear,
  };

  factory SectorTimeline.fromJson(Map<String, dynamic> json) => SectorTimeline(
    sector: json['sector'] ?? 'سكني',
    salesStartYear: json['sales_start_year'] ?? json['salesStartYear'] ?? 2026,
    salesEndYear: json['sales_end_year'] ?? json['salesEndYear'] ?? 2029,
    constructionStartYear: json['construction_start_year'] ?? json['constructionStartYear'] ?? 2026,
    constructionEndYear: json['construction_end_year'] ?? json['constructionEndYear'] ?? 2028,
  );
}

/// Project Assumptions corresponding to User Manual Slide 7
class ProjectAssumptions {
  // Sales Trend: Year -> Sales % allocation (must sum to 100%)
  final Map<int, double> salesTrend;

  // Price Growth: annual % increase per product/year (e.g. 12%)
  final double priceGrowthRate;

  // Hard Cost breakdown by cost centre (BUA and total cost)
  final Map<String, double> hardCostUnitRates;

  // Construction S-curve: Cost Centre -> (Year -> % phasing, each row sums to 100%)
  final Map<String, Map<int, double>> constructionSCurve;

  // Override Rule audit log / notes (source, date, reason)
  final String overrideNotes;

  const ProjectAssumptions({
    this.salesTrend = const {2026: 15.0, 2027: 50.0, 2028: 35.0},
    this.priceGrowthRate = 12.0,
    this.hardCostUnitRates = const {
      'Grading & Mobilization': 4000.0,
      'Villas Building structure & block work': 11000.0,
      'Landscape': 1500.0,
      'Infrastructure': 2000.0,
      'Finishing Cost': 4000.0,
    },
    this.constructionSCurve = const {
      'Grading & Mobilization': {2026: 0.0, 2027: 100.0, 2028: 0.0},
      'Villas Building structure & block work': {2026: 0.0, 2027: 25.0, 2028: 75.0},
      'Landscape': {2026: 0.0, 2027: 0.0, 2028: 100.0},
      'Infrastructure': {2026: 0.0, 2027: 0.0, 2028: 100.0},
      'Finishing Cost': {2026: 0.0, 2027: 0.0, 2028: 100.0},
    },
    this.overrideNotes = 'Market benchmark base case baseline',
  });

  Map<int, double> get priceGrowth => {for (var y in salesTrend.keys) y: priceGrowthRate};

  ProjectAssumptions copyWith({
    Map<int, double>? salesTrend,
    double? priceGrowthRate,
    Map<String, double>? hardCostUnitRates,
    Map<String, Map<int, double>>? constructionSCurve,
    String? overrideNotes,
  }) {
    return ProjectAssumptions(
      salesTrend: salesTrend ?? this.salesTrend,
      priceGrowthRate: priceGrowthRate ?? this.priceGrowthRate,
      hardCostUnitRates: hardCostUnitRates ?? this.hardCostUnitRates,
      constructionSCurve: constructionSCurve ?? this.constructionSCurve,
      overrideNotes: overrideNotes ?? this.overrideNotes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sales_trend': salesTrend.map((k, v) => MapEntry(k.toString(), v)),
      'price_growth_rate': priceGrowthRate,
      'hard_cost_unit_rates': hardCostUnitRates,
      'construction_s_curve': constructionSCurve.map(
        (k, v) => MapEntry(k, v.map((yk, yv) => MapEntry(yk.toString(), yv))),
      ),
      'override_notes': overrideNotes,
    };
  }

  factory ProjectAssumptions.fromJson(Map<String, dynamic> json) {
    Map<int, double> sales = {};
    if (json['sales_trend'] != null) {
      (json['sales_trend'] as Map).forEach((k, v) {
        sales[int.tryParse(k.toString()) ?? 2026] = (v as num).toDouble();
      });
    } else {
      sales = {2026: 15.0, 2027: 50.0, 2028: 35.0};
    }

    Map<String, double> rates = {};
    if (json['hard_cost_unit_rates'] != null) {
      (json['hard_cost_unit_rates'] as Map).forEach((k, v) {
        rates[k.toString()] = (v as num).toDouble();
      });
    } else {
      rates = {
        'Grading & Mobilization': 4000.0,
        'Villas Building structure & block work': 11000.0,
        'Landscape': 1500.0,
        'Infrastructure': 2000.0,
        'Finishing Cost': 4000.0,
      };
    }

    Map<String, Map<int, double>> scurve = {};
    if (json['construction_s_curve'] != null) {
      (json['construction_s_curve'] as Map).forEach((k, v) {
        if (v is Map) {
          final yearMap = <int, double>{};
          v.forEach((yk, yv) {
            yearMap[int.tryParse(yk.toString()) ?? 2026] = (yv as num).toDouble();
          });
          scurve[k.toString()] = yearMap;
        }
      });
    }

    return ProjectAssumptions(
      salesTrend: sales,
      priceGrowthRate: (json['price_growth_rate'] ?? 12.0).toDouble(),
      hardCostUnitRates: rates.isNotEmpty ? rates : const {
        'Grading & Mobilization': 4000.0,
        'Villas Building structure & block work': 11000.0,
        'Landscape': 1500.0,
        'Infrastructure': 2000.0,
        'Finishing Cost': 4000.0,
      },
      constructionSCurve: scurve.isNotEmpty ? scurve : const {
        'Grading & Mobilization': {2026: 0.0, 2027: 100.0, 2028: 0.0},
        'Villas Building structure & block work': {2026: 0.0, 2027: 25.0, 2028: 75.0},
        'Landscape': {2026: 0.0, 2027: 0.0, 2028: 100.0},
        'Infrastructure': {2026: 0.0, 2027: 0.0, 2028: 100.0},
        'Finishing Cost': {2026: 0.0, 2027: 0.0, 2028: 100.0},
      },
      overrideNotes: json['override_notes'] ?? 'Market benchmark base case baseline',
    );
  }
}

class FeasibilityStudy {
  final String id;
  final int projectNumber; // e.g. 75, 76, 81, 82 (Slide 3)
  final String title;
  final String developerName; // e.g. 'Gateway'
  final ProjectStatus status; // 'Initialized' vs 'Evaluated' (Slide 3)
  final int startYear; // e.g. 2026
  final int endYear; // e.g. 2030
  final int salesStartYear; // e.g. 2026
  final String assetType; // Residential, Commercial, MixedUse, Hospitality
  final List<String> selectedSectors; // e.g. ['Residential', 'Commercial']
  final Map<String, double> sectorPercentages; // e.g. {'Residential': 80.0, 'Commercial': 20.0}
  final List<SectorTimeline> sectorTimelines;
  final List<ProjectProduct> products; // Product Mix (Slide 6)
  final ProjectAssumptions assumptions; // Assumptions (Slide 7)
  final String projectType; // 'Off Plan Sales', 'On Plan Sales', 'Percentage of Completion'
  final String country; // 'Egypt', 'Saudi Arabia', etc.
  final String location; // 'New Giza', 'Riyadh', etc.
  final String? mapLocation; // Coordinates
  final String landPaymentMode; // In Kind Share, Revenue Share, Land Payment
  final List<String> landPaymentModes;
  final double revenueSharePct; // e.g. 25.0 (%)
  final double inKindSharePct; // e.g. 20.0 (%)
  final double landArea; // in sqm
  final double far; // Floor Area Ratio e.g. 2.4
  final double efficiencyPct; // e.g. 85%
  final double landCost; // Total acquisition cost
  final double? landPricePerSqm;
  final int landPaymentYears;
  final double constructionCostPerSqm;
  final double softCostPct; // e.g. 7%
  final double contingencyPct; // e.g. 5%
  final double expectedRevenuePerSqm;
  final int developmentMonths; // e.g. 24
  final double hurdleRate; // Hurdle rate e.g. 15.0% (Slide 9)
  final DateTime createdAt;
  final String currency;

  FeasibilityStudy({
    required this.id,
    int? projectNumber,
    required this.title,
    this.developerName = 'Gateway',
    ProjectStatus? status,
    this.startYear = 2026,
    this.endYear = 2030,
    this.salesStartYear = 2026,
    this.assetType = 'Residential',
    List<String>? selectedSectors,
    Map<String, double>? sectorPercentages,
    List<SectorTimeline>? sectorTimelines,
    this.products = const [],
    ProjectAssumptions? assumptions,
    this.projectType = 'Off Plan Sales',
    this.country = 'Egypt',
    this.location = 'West Cairo - Base Case',
    this.mapLocation,
    this.landPaymentMode = 'Revenue Share',
    List<String>? landPaymentModes,
    this.revenueSharePct = 25.0,
    this.inKindSharePct = 0.0,
    required this.landArea,
    this.far = 2.4,
    this.efficiencyPct = 85.0,
    required this.landCost,
    this.landPricePerSqm,
    this.landPaymentYears = 0,
    required this.constructionCostPerSqm,
    this.softCostPct = 7.0,
    this.contingencyPct = 5.0,
    required this.expectedRevenuePerSqm,
    this.developmentMonths = 36,
    this.hurdleRate = 15.0,
    DateTime? createdAt,
    this.currency = 'SAR',
  })  : projectNumber = projectNumber ?? (75 + (DateTime.now().millisecondsSinceEpoch % 25)),
        status = status ?? (products.isNotEmpty ? ProjectStatus.evaluated : ProjectStatus.initialized),
        selectedSectors = selectedSectors ?? [assetType],
        sectorPercentages = sectorPercentages ?? {assetType: 100.0},
        sectorTimelines = sectorTimelines ??
            (selectedSectors != null
                ? selectedSectors.map((s) => SectorTimeline(sector: s)).toList()
                : [SectorTimeline(sector: assetType)]),
        landPaymentModes = landPaymentModes ?? [landPaymentMode],
        assumptions = assumptions ?? const ProjectAssumptions(),
        createdAt = createdAt ?? DateTime.now();

  // Calculated Built-up Area (BUA)
  double get bua => landArea * far;

  // Gross Floor Area / Salable Area (GFA)
  double get gfa => bua * (efficiencyPct / 100.0);

  // Direct Hard Construction Cost
  double get hardConstructionCost {
    if (products.isNotEmpty) {
      // Calculate from detailed products or overall benchmark
      final productBuaTotal = products.fold(0.0, (sum, p) => sum + (p.bua > 0 ? p.bua : (p.avgArea * 10)));
      if (productBuaTotal > 0) {
        return productBuaTotal * constructionCostPerSqm;
      }
    }
    return bua * constructionCostPerSqm;
  }

  // Soft Costs (Engineering, Legal, Permits, PM)
  double get softCosts => hardConstructionCost * (softCostPct / 100.0);

  // Contingency Reserve
  double get contingencyCost =>
      (hardConstructionCost + softCosts) * (contingencyPct / 100.0);

  // Total Development Cost (TDC)
  double get totalDevelopmentCost =>
      landCost + hardConstructionCost + softCosts + contingencyCost;

  // Gross Projected Revenue
  double get grossRevenue {
    if (products.isNotEmpty) {
      double total = 0.0;
      for (final p in products) {
        final area = p.bua > 0 ? p.bua : (p.avgArea * 10);
        final rate = p.priceRate > 0 ? p.priceRate : expectedRevenuePerSqm;
        total += (area * rate);
      }
      if (total > 0) return total;
    }
    return gfa * expectedRevenuePerSqm;
  }

  // Net Profit (EBIT)
  double get netProfit => grossRevenue - totalDevelopmentCost;

  // Profit Margin (% of total revenue) - Slide 9
  double get profitMarginPct =>
      grossRevenue > 0 ? (netProfit / grossRevenue) * 100.0 : 0.0;

  // Return on Development (ROD %) - Slide 9
  double get rodPct =>
      totalDevelopmentCost > 0 ? (netProfit / totalDevelopmentCost) * 100.0 : 0.0;

  // Return on Investment (ROI %)
  double get roiPct => rodPct;

  // Margin on Cost (%)
  double get marginOnCostPct => roiPct;

  // Direct Construction Cost (alias for hardConstructionCost)
  double get constructionCost => hardConstructionCost;

  // Sensitivity Scenarios (Base, Bull, Bear)
  Map<String, FeasibilityStudy> getScenarios() {
    return {
      'Base': this,
      'Bull': copyWith(
        title: '$title (Bull Case)',
        expectedRevenuePerSqm: expectedRevenuePerSqm * 1.10,
        constructionCostPerSqm: constructionCostPerSqm * 0.95,
      ),
      'Bear': copyWith(
        title: '$title (Bear Case)',
        expectedRevenuePerSqm: expectedRevenuePerSqm * 0.90,
        constructionCostPerSqm: constructionCostPerSqm * 1.10,
      ),
    };
  }

  // Equity Multiple (MOIC)
  double get equityMultiple =>
      totalDevelopmentCost > 0 ? (grossRevenue / totalDevelopmentCost) : 0.0;

  // Breakeven price per salable sqm
  double get breakevenPerSqm => gfa > 0 ? (totalDevelopmentCost / gfa) : 0.0;

  // Annualized Project IRR (%) - Slide 9
  double get annualizedIrrPct {
    if (totalDevelopmentCost <= 0 || grossRevenue <= 0) return 0.0;
    final years = max(0.5, (endYear - startYear + 1).toDouble());
    final multiple = grossRevenue / totalDevelopmentCost;
    if (multiple <= 0) return 0.0;
    final irr = (pow(multiple, 1.0 / years) - 1.0) * 100.0;
    if (!irr.isFinite || irr.isNaN) return 0.0;
    return irr.clamp(-50.0, 150.0).toDouble();
  }

  // Equity NPV (at hurdle rate or 25%) - Slide 9
  double equityNpv({double? discountRate}) {
    final rate = (discountRate ?? hurdleRate) / 100.0;
    final cfList = getConsolidatedCashFlow();
    double npv = 0.0;
    int index = 0;
    for (final cf in cfList) {
      npv += cf.netCashFlow / pow(1.0 + rate, index);
      index++;
    }
    return npv;
  }

  // Payback Period (years) - Slide 9
  double get paybackPeriodYears {
    final cfList = getConsolidatedCashFlow();
    for (int i = 0; i < cfList.length; i++) {
      if (cfList[i].cumulativeCashFlow > 0) {
        if (i == 0) return 1.0;
        final prevCum = cfList[i - 1].cumulativeCashFlow.abs();
        final curNet = cfList[i].netCashFlow;
        final fraction = curNet > 0 ? (prevCum / curNet) : 0.5;
        return (i + fraction).clamp(1.0, 10.0);
      }
    }
    return (endYear - startYear + 1).toDouble();
  }

  // Official MVP Working Rule (Slide 9):
  // GO: NPV >= 0 AND IRR >= hurdle
  // NO-GO: NPV < 0 OR IRR < hurdle
  bool get isGoDecision => (equityNpv() >= 0) && (annualizedIrrPct >= hurdleRate);

  VerdictType get verdict {
    if (isGoDecision && rodPct >= 18.0) {
      return VerdictType.go;
    } else if (equityNpv() >= 0 || annualizedIrrPct >= (hurdleRate - 5)) {
      return VerdictType.caution;
    } else {
      return VerdictType.noGo;
    }
  }

  int get feasibilityScore {
    double score = 50.0;
    if (annualizedIrrPct >= hurdleRate) {
      score += 25;
    } else {
      score -= 20;
    }
    if (equityNpv() >= 0) {
      score += 20;
    } else {
      score -= 20;
    }
    if (profitMarginPct >= 20.0) {
      score += 15;
    } else if (profitMarginPct >= 10.0) {
      score += 5;
    }
    return score.round().clamp(5, 99);
  }

  // List of active project years
  List<int> get projectYears {
    final start = startYear;
    final end = max(start, endYear);
    return [for (int y = start; y <= end; y++) y];
  }

  // Construction Run Off by Category & Year (Slide 8)
  Map<String, Map<int, double>> getConstructionRunOff() {
    final years = projectYears;
    final Map<String, Map<int, double>> runOff = {};

    final categories = assumptions.constructionSCurve.keys.toList();
    final totalHard = hardConstructionCost;

    final weights = {
      'Grading & Mobilization': 0.15,
      'Villas Building structure & block work': 0.45,
      'Landscape': 0.10,
      'Infrastructure': 0.15,
      'Finishing Cost': 0.15,
    };

    for (final cat in categories) {
      runOff[cat] = {};
      final catTotal = totalHard * (weights[cat] ?? 0.20);
      final curve = assumptions.constructionSCurve[cat] ?? {};

      for (final y in years) {
        final pct = (curve[y] ?? 0.0) / 100.0;
        runOff[cat]![y] = catTotal * pct;
      }
    }
    return runOff;
  }

  // Sales Run Off by Year (Slide 8)
  Map<int, double> getSalesRunOff() {
    final years = projectYears;
    final Map<int, double> sales = {};
    final totalRev = grossRevenue;

    for (final y in years) {
      final pct = (assumptions.salesTrend[y] ?? 0.0) / 100.0;
      sales[y] = totalRev * pct;
    }
    return sales;
  }

  // Soft Cost Run Off by Year (Slide 8)
  Map<int, double> getSoftCostRunOff() {
    final years = projectYears;
    final Map<int, double> soft = {};
    final totalSoft = softCosts + contingencyCost;
    final perYear = totalSoft / max(1, years.length);

    for (final y in years) {
      soft[y] = perYear;
    }
    return soft;
  }

  // Consolidated Cash Flow (Slide 8)
  List<AnnualCashFlow> getConsolidatedCashFlow() {
    final years = projectYears;
    final constRunOff = getConstructionRunOff();
    final salesRunOff = getSalesRunOff();
    final softRunOff = getSoftCostRunOff();

    final List<AnnualCashFlow> result = [];
    double cumulative = 0.0;

    for (int i = 0; i < years.length; i++) {
      final y = years[i];

      // Cash In
      final offPlanSales = salesRunOff[y] ?? 0.0;
      final rent = 0.0;
      final terminalValue = (i == years.length - 1) ? (grossRevenue * 0.05) : 0.0;
      final totalIn = offPlanSales + rent + terminalValue;

      // Cash Out
      double constTotalForYear = 0.0;
      for (final cat in constRunOff.keys) {
        constTotalForYear += (constRunOff[cat]?[y] ?? 0.0);
      }

      final softCostYear = softRunOff[y] ?? 0.0;
      // Land payment schedule
      final landPaymentYear = (i == 0 && landCost > 0)
          ? (landPaymentYears > 0 ? (landCost / landPaymentYears) : landCost)
          : (i < landPaymentYears ? (landCost / landPaymentYears) : 0.0);

      final totalOut = constTotalForYear + softCostYear + landPaymentYear;
      final net = totalIn - totalOut;
      cumulative += net;

      result.add(AnnualCashFlow(
        year: y,
        offPlanSales: offPlanSales,
        rent: rent,
        terminalValue: terminalValue,
        totalCashIn: totalIn,
        constructionCost: constTotalForYear,
        softCost: softCostYear,
        landPayment: landPaymentYear,
        totalCashOut: totalOut,
        netCashFlow: net,
        cumulativeCashFlow: cumulative,
      ));
    }

    return result;
  }

  // Legacy monthly cash flow for charts compatibility
  List<CashflowMonth> getMonthlyCashflows() {
    final annualCF = getConsolidatedCashFlow();
    final List<CashflowMonth> list = [];
    int monthIndex = 1;

    for (final a in annualCF) {
      for (int m = 0; m < 12; m++) {
        final outMonth = a.totalCashOut / 12.0;
        final inMonth = a.totalCashIn / 12.0;
        list.add(CashflowMonth(
          month: monthIndex++,
          outflow: outMonth,
          inflow: inMonth,
          netCashflow: inMonth - outMonth,
        ));
      }
    }
    return list;
  }

  FeasibilityStudy copyWith({
    String? id,
    int? projectNumber,
    String? title,
    String? developerName,
    ProjectStatus? status,
    int? startYear,
    int? endYear,
    int? salesStartYear,
    String? assetType,
    List<String>? selectedSectors,
    Map<String, double>? sectorPercentages,
    List<SectorTimeline>? sectorTimelines,
    List<ProjectProduct>? products,
    ProjectAssumptions? assumptions,
    String? projectType,
    String? country,
    String? location,
    String? mapLocation,
    String? landPaymentMode,
    List<String>? landPaymentModes,
    double? revenueSharePct,
    double? inKindSharePct,
    double? landArea,
    double? far,
    double? efficiencyPct,
    double? landCost,
    double? landPricePerSqm,
    int? landPaymentYears,
    double? constructionCostPerSqm,
    double? softCostPct,
    double? contingencyPct,
    double? expectedRevenuePerSqm,
    int? developmentMonths,
    double? hurdleRate,
    DateTime? createdAt,
    String? currency,
  }) {
    return FeasibilityStudy(
      id: id ?? this.id,
      projectNumber: projectNumber ?? this.projectNumber,
      title: title ?? this.title,
      developerName: developerName ?? this.developerName,
      status: status ?? this.status,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      salesStartYear: salesStartYear ?? this.salesStartYear,
      assetType: assetType ?? this.assetType,
      selectedSectors: selectedSectors ?? this.selectedSectors,
      sectorPercentages: sectorPercentages ?? this.sectorPercentages,
      sectorTimelines: sectorTimelines ?? this.sectorTimelines,
      products: products ?? this.products,
      assumptions: assumptions ?? this.assumptions,
      projectType: projectType ?? this.projectType,
      country: country ?? this.country,
      location: location ?? this.location,
      mapLocation: mapLocation ?? this.mapLocation,
      landPaymentMode: landPaymentMode ?? this.landPaymentMode,
      landPaymentModes: landPaymentModes ?? this.landPaymentModes,
      revenueSharePct: revenueSharePct ?? this.revenueSharePct,
      inKindSharePct: inKindSharePct ?? this.inKindSharePct,
      landArea: landArea ?? this.landArea,
      far: far ?? this.far,
      efficiencyPct: efficiencyPct ?? this.efficiencyPct,
      landCost: landCost ?? this.landCost,
      landPricePerSqm: landPricePerSqm ?? this.landPricePerSqm,
      landPaymentYears: landPaymentYears ?? this.landPaymentYears,
      constructionCostPerSqm: constructionCostPerSqm ?? this.constructionCostPerSqm,
      softCostPct: softCostPct ?? this.softCostPct,
      contingencyPct: contingencyPct ?? this.contingencyPct,
      expectedRevenuePerSqm: expectedRevenuePerSqm ?? this.expectedRevenuePerSqm,
      developmentMonths: developmentMonths ?? this.developmentMonths,
      hurdleRate: hurdleRate ?? this.hurdleRate,
      createdAt: createdAt ?? this.createdAt,
      currency: currency ?? this.currency,
    );
  }

  factory FeasibilityStudy.fromJson(Map<String, dynamic> json) {
    List<String>? sectors;
    if (json['selected_sectors'] != null) {
      sectors = List<String>.from(json['selected_sectors']);
    }

    Map<String, double>? sectorPercentagesMap;
    if (json['sector_percentages'] != null) {
      sectorPercentagesMap = (json['sector_percentages'] as Map).map(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    }

    List<SectorTimeline>? timelines;
    if (json['sector_timelines'] != null) {
      timelines = (json['sector_timelines'] as List)
          .map((e) => SectorTimeline.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<ProjectProduct>? productList;
    if (json['products'] != null) {
      productList = (json['products'] as List)
          .map((e) => ProjectProduct.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<String>? paymentModes;
    if (json['land_payment_modes'] != null) {
      paymentModes = List<String>.from(json['land_payment_modes']);
    }

    final statusStr = json['status'] ?? 'evaluated';
    final status = statusStr == 'initialized'
        ? ProjectStatus.initialized
        : ProjectStatus.evaluated;

    return FeasibilityStudy(
      id: json['id'] ?? 'std_${DateTime.now().millisecondsSinceEpoch}',
      projectNumber: json['project_number'] ?? json['projectNumber'] ?? 75,
      title: json['title'] ?? 'Untitled Project',
      developerName: json['developer_name'] ?? json['developerName'] ?? 'Gateway',
      status: status,
      startYear: json['start_year'] ?? json['startYear'] ?? 2026,
      endYear: json['end_year'] ?? json['endYear'] ?? 2030,
      salesStartYear: json['sales_start_year'] ?? json['salesStartYear'] ?? 2026,
      assetType: json['asset_type'] ?? json['assetType'] ?? 'Residential',
      selectedSectors: sectors,
      sectorPercentages: sectorPercentagesMap,
      sectorTimelines: timelines,
      products: productList ?? const [],
      assumptions: json['assumptions'] != null
          ? ProjectAssumptions.fromJson(json['assumptions'] as Map<String, dynamic>)
          : const ProjectAssumptions(),
      projectType: json['project_type'] ?? json['projectType'] ?? 'Off Plan Sales',
      country: json['country'] ?? 'Egypt',
      location: json['location'] ?? 'West Cairo - Base Case',
      mapLocation: json['map_location'] ?? json['mapLocation'],
      landPaymentMode: json['land_payment_mode'] ?? json['landPaymentMode'] ?? 'Revenue Share',
      landPaymentModes: paymentModes,
      revenueSharePct: (json['revenue_share_pct'] ?? json['revenueSharePct'] ?? 25.0).toDouble(),
      inKindSharePct: (json['in_kind_share_pct'] ?? json['inKindSharePct'] ?? 0.0).toDouble(),
      landArea: (json['land_area'] ?? json['landArea'] ?? 42000.0).toDouble(),
      far: (json['far'] ?? 2.4).toDouble(),
      efficiencyPct: (json['efficiency_pct'] ?? json['efficiencyPct'] ?? 85.0).toDouble(),
      landCost: (json['land_cost'] ?? json['landCost'] ?? 15000000.0).toDouble(),
      landPricePerSqm: json['land_price_per_sqm'] != null
          ? (json['land_price_per_sqm']).toDouble()
          : (json['landPricePerSqm'] != null ? (json['landPricePerSqm']).toDouble() : null),
      landPaymentYears: json['land_payment_years'] ?? json['landPaymentYears'] ?? 0,
      constructionCostPerSqm: (json['construction_cost_per_sqm'] ??
              json['constructionCostPerSqm'] ??
              3800.0)
          .toDouble(),
      softCostPct: (json['soft_cost_pct'] ?? json['softCostPct'] ?? 7.0).toDouble(),
      contingencyPct:
          (json['contingency_pct'] ?? json['contingencyPct'] ?? 5.0).toDouble(),
      expectedRevenuePerSqm: (json['expected_revenue_per_sqm'] ??
              json['expectedRevenuePerSqm'] ??
              8500.0)
          .toDouble(),
      developmentMonths: json['development_months'] ?? json['developmentMonths'] ?? 36,
      hurdleRate: (json['hurdle_rate'] ?? json['hurdleRate'] ?? 15.0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      currency: json['currency'] ?? 'SAR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_number': projectNumber,
      'title': title,
      'developer_name': developerName,
      'status': status.name,
      'start_year': startYear,
      'end_year': endYear,
      'sales_start_year': salesStartYear,
      'asset_type': assetType,
      'selected_sectors': selectedSectors,
      'sector_percentages': sectorPercentages,
      'sector_timelines': sectorTimelines.map((t) => t.toJson()).toList(),
      'products': products.map((p) => p.toJson()).toList(),
      'assumptions': assumptions.toJson(),
      'project_type': projectType,
      'country': country,
      'location': location,
      'map_location': mapLocation,
      'land_payment_mode': landPaymentMode,
      'land_payment_modes': landPaymentModes,
      'revenue_share_pct': revenueSharePct,
      'in_kind_share_pct': inKindSharePct,
      'land_area': landArea,
      'far': far,
      'efficiency_pct': efficiencyPct,
      'land_cost': landCost,
      'land_price_per_sqm': landPricePerSqm,
      'land_payment_years': landPaymentYears,
      'construction_cost_per_sqm': constructionCostPerSqm,
      'soft_cost_pct': softCostPct,
      'contingency_pct': contingencyPct,
      'expected_revenue_per_sqm': expectedRevenuePerSqm,
      'development_months': developmentMonths,
      'hurdle_rate': hurdleRate,
      'created_at': createdAt.toIso8601String(),
      'currency': currency,
    };
  }
}

class AnnualCashFlow {
  final int year;
  final double offPlanSales;
  final double rent;
  final double terminalValue;
  final double totalCashIn;
  final double constructionCost;
  final double softCost;
  final double landPayment;
  final double totalCashOut;
  final double netCashFlow;
  final double cumulativeCashFlow;

  const AnnualCashFlow({
    required this.year,
    required this.offPlanSales,
    required this.rent,
    required this.terminalValue,
    required this.totalCashIn,
    required this.constructionCost,
    required this.softCost,
    required this.landPayment,
    required this.totalCashOut,
    required this.netCashFlow,
    required this.cumulativeCashFlow,
  });
}

class CashflowMonth {
  final int month;
  final double outflow;
  final double inflow;
  final double netCashflow;

  CashflowMonth({
    required this.month,
    required this.outflow,
    required this.inflow,
    required this.netCashflow,
  });
}
