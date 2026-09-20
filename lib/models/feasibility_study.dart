import 'dart:math';

enum VerdictType { go, caution, noGo }

class FeasibilityStudy {
  final String id;
  final String title;
  final String assetType; // Residential, Commercial, MixedUse, Hospitality, etc.
  final String location; // Riyadh, Dubai, Cairo, etc.
  final double landArea; // in sqm or sqft
  final double far; // Floor Area Ratio e.g. 2.5
  final double efficiencyPct; // e.g. 85%
  final double landCost; // Total acquisition or per sqm * area
  final double constructionCostPerSqm;
  final double softCostPct; // e.g. 7%
  final double contingencyPct; // e.g. 5%
  final double expectedRevenuePerSqm;
  final int developmentMonths; // e.g. 24
  final DateTime createdAt;
  final String currency;

  FeasibilityStudy({
    required this.id,
    required this.title,
    this.assetType = 'Residential',
    this.location = 'Riyadh, Saudi Arabia',
    required this.landArea,
    this.far = 2.4,
    this.efficiencyPct = 85.0,
    required this.landCost,
    required this.constructionCostPerSqm,
    this.softCostPct = 7.0,
    this.contingencyPct = 5.0,
    required this.expectedRevenuePerSqm,
    this.developmentMonths = 24,
    DateTime? createdAt,
    this.currency = 'SAR',
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculated Built-up Area (BUA)
  double get bua => landArea * far;

  // Gross Floor Area / Salable Area (GFA)
  double get gfa => bua * (efficiencyPct / 100.0);

  // Direct Hard Construction Cost
  double get hardConstructionCost => bua * constructionCostPerSqm;

  // Soft Costs (Engineering, Legal, Permits, PM)
  double get softCosts => hardConstructionCost * (softCostPct / 100.0);

  // Contingency Reserve
  double get contingencyCost =>
      (hardConstructionCost + softCosts) * (contingencyPct / 100.0);

  // Total Development Cost (TDC)
  double get totalDevelopmentCost =>
      landCost + hardConstructionCost + softCosts + contingencyCost;

  // Gross Projected Revenue
  double get grossRevenue => gfa * expectedRevenuePerSqm;

  // Net Profit (EBIT)
  double get netProfit => grossRevenue - totalDevelopmentCost;

  // Return on Investment (ROI %)
  double get roiPct =>
      totalDevelopmentCost > 0 ? (netProfit / totalDevelopmentCost) * 100.0 : 0.0;

  // Margin on Cost (%)
  double get marginOnCostPct => roiPct;

  // Equity Multiple (MOIC)
  double get equityMultiple =>
      totalDevelopmentCost > 0 ? (grossRevenue / totalDevelopmentCost) : 0.0;

  // Breakeven price per salable sqm
  double get breakevenPerSqm => gfa > 0 ? (totalDevelopmentCost / gfa) : 0.0;

  // Project IRR (Annualized estimate based on project timeline)
  double get annualizedIrrPct {
    if (totalDevelopmentCost <= 0 || grossRevenue <= 0) return 0.0;
    final years = max(0.5, developmentMonths / 12.0);
    final multiple = grossRevenue / totalDevelopmentCost;
    if (multiple <= 0) return 0.0;
    final irr = (pow(multiple, 1.0 / years) - 1.0) * 100.0;
    if (!irr.isFinite || irr.isNaN) return 0.0;
    return irr.clamp(-50.0, 150.0).toDouble();
  }

  // Feasibility Score (0 - 100)
  int get feasibilityScore {
    double score = 50.0;
    if (roiPct >= 25) {
      score += 35;
    } else if (roiPct >= 18) {
      score += 25;
    } else if (roiPct >= 12) {
      score += 10;
    } else if (roiPct > 0) {
      score -= 10;
    } else {
      score -= 40;
    }

    if (annualizedIrrPct >= 20) {
      score += 15;
    } else if (annualizedIrrPct >= 14) {
      score += 10;
    } else {
      score -= 10;
    }

    return score.round().clamp(5, 99);
  }

  // Go / Caution / No-Go Decision
  VerdictType get verdict {
    if (roiPct >= 20.0 && feasibilityScore >= 70) {
      return VerdictType.go;
    } else if (roiPct >= 10.0 && feasibilityScore >= 50) {
      return VerdictType.caution;
    } else {
      return VerdictType.noGo;
    }
  }

  // Monthly Phased Cashflows (for charts)
  List<CashflowMonth> getMonthlyCashflows() {
    final months = max(6, developmentMonths);
    final List<CashflowMonth> list = [];
    final landPerMonth = landCost; // Month 1
    final constPerMonth = (hardConstructionCost + softCosts + contingencyCost) / (months - 2);
    final revPhasingMonths = max(4, (months * 0.4).round());
    final revPerMonth = grossRevenue / revPhasingMonths;

    for (int m = 1; m <= months; m++) {
      double outflow = 0.0;
      double inflow = 0.0;

      if (m == 1) {
        outflow = landPerMonth + (constPerMonth * 0.5);
      } else if (m < months) {
        outflow = constPerMonth;
      }

      // Revenue phasing kicks in middle to end of project
      if (m > (months - revPhasingMonths)) {
        inflow = revPerMonth;
      }

      list.add(CashflowMonth(
        month: m,
        outflow: outflow,
        inflow: inflow,
        netCashflow: inflow - outflow,
      ));
    }
    return list;
  }

  // Sensitivity Scenarios (Base, Bull +10% rev & -5% cost, Bear -10% rev & +10% cost)
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

  FeasibilityStudy copyWith({
    String? id,
    String? title,
    String? assetType,
    String? location,
    double? landArea,
    double? far,
    double? efficiencyPct,
    double? landCost,
    double? constructionCostPerSqm,
    double? softCostPct,
    double? contingencyPct,
    double? expectedRevenuePerSqm,
    int? developmentMonths,
    DateTime? createdAt,
    String? currency,
  }) {
    return FeasibilityStudy(
      id: id ?? this.id,
      title: title ?? this.title,
      assetType: assetType ?? this.assetType,
      location: location ?? this.location,
      landArea: landArea ?? this.landArea,
      far: far ?? this.far,
      efficiencyPct: efficiencyPct ?? this.efficiencyPct,
      landCost: landCost ?? this.landCost,
      constructionCostPerSqm:
          constructionCostPerSqm ?? this.constructionCostPerSqm,
      softCostPct: softCostPct ?? this.softCostPct,
      contingencyPct: contingencyPct ?? this.contingencyPct,
      expectedRevenuePerSqm:
          expectedRevenuePerSqm ?? this.expectedRevenuePerSqm,
      developmentMonths: developmentMonths ?? this.developmentMonths,
      createdAt: createdAt ?? this.createdAt,
      currency: currency ?? this.currency,
    );
  }

  factory FeasibilityStudy.fromJson(Map<String, dynamic> json) {
    return FeasibilityStudy(
      id: json['id'] ?? 'std_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? 'Untitled Study',
      assetType: json['asset_type'] ?? json['assetType'] ?? 'Residential',
      location: json['location'] ?? 'Riyadh, Saudi Arabia',
      landArea: (json['land_area'] ?? json['landArea'] ?? 2000.0).toDouble(),
      far: (json['far'] ?? 2.4).toDouble(),
      efficiencyPct: (json['efficiency_pct'] ?? json['efficiencyPct'] ?? 85.0).toDouble(),
      landCost: (json['land_cost'] ?? json['landCost'] ?? 5000000.0).toDouble(),
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
      developmentMonths: json['development_months'] ?? json['developmentMonths'] ?? 24,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      currency: json['currency'] ?? 'SAR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'asset_type': assetType,
      'location': location,
      'land_area': landArea,
      'far': far,
      'efficiency_pct': efficiencyPct,
      'land_cost': landCost,
      'construction_cost_per_sqm': constructionCostPerSqm,
      'soft_cost_pct': softCostPct,
      'contingency_pct': contingencyPct,
      'expected_revenue_per_sqm': expectedRevenuePerSqm,
      'development_months': developmentMonths,
      'created_at': createdAt.toIso8601String(),
      'currency': currency,
    };
  }
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
