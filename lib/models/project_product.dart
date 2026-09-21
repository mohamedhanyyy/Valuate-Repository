class ProjectProduct {
  final String id;
  final String name; // e.g. 'Stand Alone Villa', 'Twin House'
  final String sector; // e.g. 'Residential' / 'سكني', 'Commercial' / 'تجاري', 'Hospitality' / 'ضيافة'
  final double productMixPct; // نسبة الوزن % within sector (sums to 100%)
  final double plotArea; // مساحة الأرض للمنتج / للوحدة
  final double plotAreaPct; // % نسبة المساحة
  final double landArea; // مساحة الأرض
  final double footprintPct; // %FP نسبة البصمة البنائية
  final double footprintArea; // FP مساحة البصمة
  final double heightMeters; // الارتفاع (م) / عدد الأدوار
  final double avgArea; // متوسط مساحة الوحدة (م²)
  final double utilityCapRatePct; // نسبة كفاءة الخدمات / المرافق %
  final String propertyFinishing; // نوع التشطيب: Fully Finished, Core & Shell, Semi Finished
  final double bua; // BUA مساحة البناء
  final double priceRate; // Price Rate (سعر البيع / المتر)
  final double rentalRate; // Rental Rate
  final String? marketReference; // مرجع السوق المعياري

  const ProjectProduct({
    required this.id,
    required this.name,
    required this.sector,
    this.productMixPct = 0.0,
    this.plotArea = 0.0,
    this.plotAreaPct = 0.0,
    this.landArea = 0.0,
    this.footprintPct = 0.0,
    this.footprintArea = 0.0,
    this.heightMeters = 2.0,
    this.avgArea = 250.0,
    this.utilityCapRatePct = 25.0,
    this.propertyFinishing = 'Fully finished',
    this.bua = 0.0,
    this.priceRate = 0.0,
    this.rentalRate = 0.0,
    this.marketReference,
  });

  ProjectProduct copyWith({
    String? id,
    String? name,
    String? sector,
    double? productMixPct,
    double? plotArea,
    double? plotAreaPct,
    double? landArea,
    double? footprintPct,
    double? footprintArea,
    double? heightMeters,
    double? avgArea,
    double? utilityCapRatePct,
    String? propertyFinishing,
    double? bua,
    double? priceRate,
    double? rentalRate,
    String? marketReference,
  }) {
    return ProjectProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      sector: sector ?? this.sector,
      productMixPct: productMixPct ?? this.productMixPct,
      plotArea: plotArea ?? this.plotArea,
      plotAreaPct: plotAreaPct ?? this.plotAreaPct,
      landArea: landArea ?? this.landArea,
      footprintPct: footprintPct ?? this.footprintPct,
      footprintArea: footprintArea ?? this.footprintArea,
      heightMeters: heightMeters ?? this.heightMeters,
      avgArea: avgArea ?? this.avgArea,
      utilityCapRatePct: utilityCapRatePct ?? this.utilityCapRatePct,
      propertyFinishing: propertyFinishing ?? this.propertyFinishing,
      bua: bua ?? this.bua,
      priceRate: priceRate ?? this.priceRate,
      rentalRate: rentalRate ?? this.rentalRate,
      marketReference: marketReference ?? this.marketReference,
    );
  }

  factory ProjectProduct.fromJson(Map<String, dynamic> json) {
    return ProjectProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sector: json['sector'] ?? '',
      productMixPct: (json['product_mix_pct'] ?? json['productMixPct'] ?? 0.0).toDouble(),
      plotArea: (json['plot_area'] ?? json['plotArea'] ?? 0.0).toDouble(),
      plotAreaPct: (json['plot_area_pct'] ?? json['plotAreaPct'] ?? 0.0).toDouble(),
      landArea: (json['land_area'] ?? json['landArea'] ?? 0.0).toDouble(),
      footprintPct: (json['footprint_pct'] ?? json['footprintPct'] ?? 0.0).toDouble(),
      footprintArea: (json['footprint_area'] ?? json['footprintArea'] ?? 0.0).toDouble(),
      heightMeters: (json['height_meters'] ?? json['heightMeters'] ?? 2.0).toDouble(),
      avgArea: (json['avg_area'] ?? json['avgArea'] ?? 250.0).toDouble(),
      utilityCapRatePct: (json['utility_cap_rate_pct'] ?? json['utilityCapRatePct'] ?? 25.0).toDouble(),
      propertyFinishing: json['property_finishing'] ?? json['propertyFinishing'] ?? 'Fully finished',
      bua: (json['bua'] ?? 0.0).toDouble(),
      priceRate: (json['price_rate'] ?? json['priceRate'] ?? 0.0).toDouble(),
      rentalRate: (json['rental_rate'] ?? json['rentalRate'] ?? 0.0).toDouble(),
      marketReference: json['market_reference'] ?? json['marketReference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sector': sector,
      'product_mix_pct': productMixPct,
      'plot_area': plotArea,
      'plot_area_pct': plotAreaPct,
      'land_area': landArea,
      'footprint_pct': footprintPct,
      'footprint_area': footprintArea,
      'height_meters': heightMeters,
      'avg_area': avgArea,
      'utility_cap_rate_pct': utilityCapRatePct,
      'property_finishing': propertyFinishing,
      'bua': bua,
      'price_rate': priceRate,
      'rental_rate': rentalRate,
      'market_reference': marketReference,
    };
  }

  /// Default product templates aligned with Valuate User Manual (Slide 6)
  static List<ProjectProduct> defaultCatalogForSectors(List<String> sectors) {
    final List<ProjectProduct> list = [];

    final hasResidential = sectors.any((s) => s.contains('سكني') || s.toLowerCase().contains('res'));
    final hasCommercial = sectors.any((s) => s.contains('تجاري') || s.toLowerCase().contains('comm'));
    final hasHospitality = sectors.any((s) => s.contains('ضيافة') || s.toLowerCase().contains('hosp'));

    // Residential (Slide 6)
    if (hasResidential) {
      list.addAll([
        const ProjectProduct(
          id: 'res_stand_alone_villa',
          name: 'Stand Alone Villa',
          sector: 'Residential',
          plotArea: 3000,
          footprintPct: 40,
          heightMeters: 2,
          avgArea: 350,
          utilityCapRatePct: 25,
          propertyFinishing: 'Fully finished',
          priceRate: 141876,
          marketReference: 'Market reference: 141,876.00/sqm - "Villa" [0.67 FP] 3000m²',
        ),
        const ProjectProduct(
          id: 'res_twin_house',
          name: 'Twin House',
          sector: 'Residential',
          plotArea: 2200,
          footprintPct: 45,
          heightMeters: 2,
          avgArea: 280,
          utilityCapRatePct: 20,
          propertyFinishing: 'Fully finished',
          priceRate: 125000,
          marketReference: 'Market reference: 125,000.00/sqm - "Twin House"',
        ),
        const ProjectProduct(
          id: 'res_duplex',
          name: 'Duplex',
          sector: 'Residential',
          plotArea: 1500,
          footprintPct: 50,
          heightMeters: 3,
          avgArea: 220,
          utilityCapRatePct: 20,
          propertyFinishing: 'Fully finished',
          priceRate: 98000,
          marketReference: 'Market reference: 98,000.00/sqm - "Duplex"',
        ),
        const ProjectProduct(
          id: 'res_apartments',
          name: 'Apartments',
          sector: 'Residential',
          plotArea: 1800,
          footprintPct: 55,
          heightMeters: 5,
          avgArea: 140,
          utilityCapRatePct: 20,
          propertyFinishing: 'Fully finished',
          priceRate: 75000,
          marketReference: 'Market reference: 75,000.00/sqm - "Apartments"',
        ),
        const ProjectProduct(
          id: 'res_town_villas',
          name: 'Town Villas',
          sector: 'Residential',
          plotArea: 1600,
          footprintPct: 50,
          heightMeters: 2,
          avgArea: 230,
          utilityCapRatePct: 20,
          propertyFinishing: 'Fully finished',
          priceRate: 110000,
          marketReference: 'Market reference: 110,000.00/sqm - "Town Villa"',
        ),
        const ProjectProduct(
          id: 'res_cabin',
          name: 'Cabin',
          sector: 'Residential',
          plotArea: 800,
          footprintPct: 35,
          heightMeters: 1,
          avgArea: 90,
          utilityCapRatePct: 15,
          propertyFinishing: 'Fully finished',
          priceRate: 130000,
          marketReference: 'Market reference: 130,000.00/sqm - "Cabin"',
        ),
        const ProjectProduct(
          id: 'res_chalet',
          name: 'Chalet',
          sector: 'Residential',
          plotArea: 1200,
          footprintPct: 40,
          heightMeters: 2,
          avgArea: 130,
          utilityCapRatePct: 18,
          propertyFinishing: 'Fully finished',
          priceRate: 115000,
          marketReference: 'Market reference: 115,000.00/sqm - "Chalet"',
        ),
        const ProjectProduct(
          id: 'res_quarto_villa',
          name: 'Quarto Villa',
          sector: 'Residential',
          plotArea: 1900,
          footprintPct: 45,
          heightMeters: 2,
          avgArea: 200,
          utilityCapRatePct: 20,
          propertyFinishing: 'Fully finished',
          priceRate: 105000,
          marketReference: 'Market reference: 105,000.00/sqm - "Quarto Villa"',
        ),
      ]);
    }

    // Commercial
    if (hasCommercial) {
      list.addAll([
        const ProjectProduct(
          id: 'comm_office',
          name: 'Administrative Offices',
          sector: 'Commercial',
          plotArea: 2500,
          footprintPct: 55,
          heightMeters: 6,
          avgArea: 180,
          utilityCapRatePct: 25,
          propertyFinishing: 'Core & Shell',
          priceRate: 85000,
          rentalRate: 3500,
          marketReference: 'Market reference: 85,000.00/sqm - Grade A Offices',
        ),
        const ProjectProduct(
          id: 'comm_retail',
          name: 'Retail & Strip Mall',
          sector: 'Commercial',
          plotArea: 3500,
          footprintPct: 60,
          heightMeters: 2,
          avgArea: 120,
          utilityCapRatePct: 30,
          propertyFinishing: 'Core & Shell',
          priceRate: 140000,
          rentalRate: 6000,
          marketReference: 'Market reference: 140,000.00/sqm - Prime Retail',
        ),
        const ProjectProduct(
          id: 'comm_restaurant',
          name: 'F&B / Restaurants',
          sector: 'Commercial',
          plotArea: 1500,
          footprintPct: 50,
          heightMeters: 2,
          avgArea: 200,
          utilityCapRatePct: 35,
          propertyFinishing: 'Core & Shell',
          priceRate: 160000,
          rentalRate: 7500,
          marketReference: 'Market reference: 160,000.00/sqm - Prime F&B',
        ),
      ]);
    }

    // Hospitality
    if (hasHospitality) {
      list.addAll([
        const ProjectProduct(
          id: 'hosp_hotel_room',
          name: 'Hotel Rooms & Suites',
          sector: 'Hospitality',
          plotArea: 4000,
          footprintPct: 50,
          heightMeters: 7,
          avgArea: 55,
          utilityCapRatePct: 35,
          propertyFinishing: 'Fully finished',
          priceRate: 150000,
          marketReference: 'Market reference: 150,000.00/sqm - 5-Star Hotel Key',
        ),
        const ProjectProduct(
          id: 'hosp_branded_res',
          name: 'Branded Residences',
          sector: 'Hospitality',
          plotArea: 3000,
          footprintPct: 45,
          heightMeters: 5,
          avgArea: 160,
          utilityCapRatePct: 25,
          propertyFinishing: 'Fully finished',
          priceRate: 190000,
          marketReference: 'Market reference: 190,000.00/sqm - Luxury Serviced',
        ),
      ]);
    }

    // Fallback if none matched
    if (list.isEmpty) {
      list.addAll([
        const ProjectProduct(id: 'gen_villa', name: 'Stand Alone Villa', sector: 'Residential', priceRate: 141876),
        const ProjectProduct(id: 'gen_apt', name: 'Apartments', sector: 'Residential', priceRate: 75000),
        const ProjectProduct(id: 'gen_office', name: 'Offices', sector: 'Commercial', priceRate: 85000),
      ]);
    }

    return list;
  }
}
