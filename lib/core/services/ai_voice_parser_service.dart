import 'dart:math';
import '../../models/feasibility_study.dart';

class VoiceParseResult {
  final FeasibilityStudy study;
  final Map<String, String> extractedSummary;
  final List<String> detectedFields;
  final double confidenceScore;
  final String rawTranscript;

  const VoiceParseResult({
    required this.study,
    required this.extractedSummary,
    required this.detectedFields,
    required this.confidenceScore,
    required this.rawTranscript,
  });
}

class AiVoiceFeasibilityParserService {
  /// Pre-defined ready-to-test voice prompt examples in Arabic & English
  static final List<Map<String, String>> voiceSamples = [
    {
      'title': 'أبراج السحاب السكنية — الرياض',
      'category': 'سكني فاخر',
      'transcript':
          'مشروع أبراج السحاب السكني في مدينة الرياض، مساحة الأرض 6000 متر مربع ومعامل البناء 3.2 ونسبة الكفاءة 85%، تكلفة شراء الأرض 24 مليون ريال، تكلفة البناء 4200 ريال للمتر، وسعر البيع المتوقع 18500 ريال للمتر، ومدة التطوير سنتين.',
    },
    {
      'title': 'مركز النخيل التجاري — دبي',
      'category': 'تجاري ومكاتب',
      'transcript':
          'برج النخيل التجاري والمكتبي في دبي، مساحة الأرض 4500 متر مربع، والـ FAR 4.0، تكلفة الأرض 35 مليون درهم، تكلفة البناء 5500 درهم للمتر المربع، سعر البيع المتوقع 26000 درهم للمتر، ومدة التنفيذ 36 شهر.',
    },
    {
      'title': 'فندق مارينا ويفز — جدة',
      'category': 'ضيافة وفندقي',
      'transcript':
          'مشروع فندق مارينا ويفز السياحي في جدة، مساحة الأرض 3500 متر مربع، معامل البناء 2.8، تكلفة الأرض 16 مليون ريال، وتكلفة إنشاء الفندق 4800 للمتر، والإيراد المتوقع 21000 للمتر، بمدة إنجاز 24 شهر.',
    },
    {
      'title': 'Skyline Commercial Tower — Riyadh',
      'category': 'Commercial / English',
      'transcript':
          'Project Skyline Commercial Towers in Riyadh, plot area 5000 sqm, FAR 3.5, efficiency 85 percent, land acquisition cost 28 million SAR, construction cost 4500 SAR per sqm, expected revenue 19500 SAR per sqm, development duration 30 months.',
    },
  ];

  /// Parses voice/text transcript and generates a structured FeasibilityStudy
  static VoiceParseResult parseTranscript(String rawText, {String locale = 'ar'}) {
    final text = rawText.trim();
    if (text.isEmpty) {
      return VoiceParseResult(
        study: FeasibilityStudy(
          id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
          title: locale == 'ar' ? 'مشروع جديد' : 'New Voice Project',
          landArea: 3500,
          landCost: 14000000,
          constructionCostPerSqm: 4000,
          expectedRevenuePerSqm: 16000,
        ),
        extractedSummary: {},
        detectedFields: [],
        confidenceScore: 0.0,
        rawTranscript: rawText,
      );
    }

    final normalized = _normalizeArabicText(text);

    // 1. Extract Title
    final title = _extractTitle(text, normalized, locale);

    // 2. Extract Asset Type
    final assetType = _extractAssetType(normalized);

    // 3. Extract Location & Currency
    final locationData = _extractLocation(normalized);
    final location = locationData['location'] ?? 'Riyadh, Saudi Arabia';
    final currency = locationData['currency'] ?? 'SAR';

    // 4. Extract Land Area
    final landArea = _extractLandArea(normalized) ?? 3500.0;

    // 5. Extract FAR
    final far = _extractFar(normalized) ?? 2.8;

    // 6. Extract Efficiency
    final efficiency = _extractEfficiency(normalized) ?? 85.0;

    // 7. Extract Land Cost
    final landCost = _extractLandCost(normalized, landArea) ?? (landArea * 4000.0);

    // 8. Extract Construction Cost per sqm
    final constructionCost = _extractConstructionCost(normalized) ?? 4000.0;

    // 9. Extract Expected Revenue per sqm
    final expectedRevenue = _extractExpectedRevenue(normalized) ?? 16500.0;

    // 10. Extract Duration
    final durationMonths = _extractDuration(normalized) ?? 24;

    // 11. Soft Costs & Contingency
    final softCosts = _extractSoftCosts(normalized) ?? 7.0;
    final contingency = _extractContingency(normalized) ?? 5.0;

    final study = FeasibilityStudy(
      id: 'study_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      assetType: assetType,
      location: location,
      landArea: landArea,
      far: far,
      efficiencyPct: efficiency,
      landCost: landCost,
      constructionCostPerSqm: constructionCost,
      softCostPct: softCosts,
      contingencyPct: contingency,
      expectedRevenuePerSqm: expectedRevenue,
      developmentMonths: durationMonths,
      currency: currency,
    );

    final detectedFields = <String>[];
    final summary = <String, String>{};

    if (title.isNotEmpty) {
      detectedFields.add('title');
      summary[locale == 'ar' ? 'اسم المشروع' : 'Project Name'] = title;
    }
    detectedFields.add('assetType');
    summary[locale == 'ar' ? 'نوع الأصل' : 'Asset Type'] = _localizedAssetType(assetType, locale);

    detectedFields.add('location');
    summary[locale == 'ar' ? 'المدينة / السوق' : 'Location'] = location;

    detectedFields.add('landArea');
    summary[locale == 'ar' ? 'مساحة الأرض' : 'Plot Area'] = '${landArea.toStringAsFixed(0)} m²';

    detectedFields.add('far');
    summary[locale == 'ar' ? 'معامل البناء (FAR)' : 'FAR'] = '${far.toStringAsFixed(2)}x';

    detectedFields.add('landCost');
    summary[locale == 'ar' ? 'تكلفة الأرض' : 'Land Cost'] =
        '${(landCost / 1000000).toStringAsFixed(1)}M $currency';

    detectedFields.add('constructionCost');
    summary[locale == 'ar' ? 'تكلفة البناء / م²' : 'Construction Cost/m²'] =
        '${constructionCost.toStringAsFixed(0)} $currency/m²';

    detectedFields.add('expectedRevenue');
    summary[locale == 'ar' ? 'سعر البيع / م²' : 'Target Price/m²'] =
        '${expectedRevenue.toStringAsFixed(0)} $currency/m²';

    detectedFields.add('duration');
    summary[locale == 'ar' ? 'مدة التطوير' : 'Duration'] =
        locale == 'ar' ? '$durationMonths شهر' : '$durationMonths Months';

    final confidence = min(1.0, 0.4 + (detectedFields.length * 0.07));

    return VoiceParseResult(
      study: study,
      extractedSummary: summary,
      detectedFields: detectedFields,
      confidenceScore: confidence,
      rawTranscript: rawText,
    );
  }

  static String _normalizeArabicText(String text) {
    var t = text.toLowerCase();
    // Normalize Arabic letters
    t = t.replaceAll(RegExp(r'[إأآا]'), 'ا');
    t = t.replaceAll('ة', 'ه');
    t = t.replaceAll('ى', 'ي');
    // Replace Arabic digits with standard digits
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < 10; i++) {
      t = t.replaceAll(arabicDigits[i], '$i');
    }
    // Remove commas from numbers like 4,000
    t = t.replaceAll(RegExp(r'(\d),(\d)'), r'$1$2');
    return t;
  }

  static String _extractTitle(String original, String normalized, String locale) {
    // Check patterns like "مشروع أبراج النرجس", "برج السحاب", "كمبوند ..."
    final match = RegExp(
      r'(مشروع|برج|ابراج|كمبوند|مجمع|فندق|مركز|مستودعات|project|tower|towers|residence|complex)\s+([^\,\.\n\،]+?)(?=\s+(في|بمدينة|بمساحة|مساحة|سكني|تجاري|in|with|\,|\.|\،|$))',
      caseSensitive: false,
    ).firstMatch(original);

    if (match != null) {
      final prefix = match.group(1)?.trim() ?? '';
      final name = match.group(2)?.trim() ?? '';
      return '$prefix $name'.trim();
    }

    // Default based on asset type or fallback
    return locale == 'ar' ? 'مشروع دراسة جدوى صوتية' : 'Voice Feasibility Study';
  }

  static String _extractAssetType(String text) {
    if (text.contains('سكني') || text.contains('شقق') || text.contains('فلل') || text.contains('residential')) {
      return 'Residential';
    }
    if (text.contains('تجاري') || text.contains('مكاتب') || text.contains('commercial') || text.contains('office')) {
      return 'Commercial';
    }
    if (text.contains('فندق') || text.contains('فندقي') || text.contains('ضيافه') || text.contains('hospitality') || text.contains('hotel')) {
      return 'Hospitality';
    }
    if (text.contains('صناعي') || text.contains('مستودع') || text.contains('لوجستي') || text.contains('industrial') || text.contains('logistics')) {
      return 'Industrial';
    }
    if (text.contains('متعدد') || text.contains('مختلط') || text.contains('mixed')) {
      return 'MixedUse';
    }
    return 'Residential';
  }

  static Map<String, String> _extractLocation(String text) {
    if (text.contains('رياض') || text.contains('riyadh')) {
      return {'location': 'Riyadh, Saudi Arabia', 'currency': 'SAR'};
    }
    if (text.contains('دبي') || text.contains('dubai')) {
      return {'location': 'Dubai, UAE', 'currency': 'AED'};
    }
    if (text.contains('جده') || text.contains('jeddah')) {
      return {'location': 'Jeddah, Saudi Arabia', 'currency': 'SAR'};
    }
    if (text.contains('قاهره') || text.contains('مصر') || text.contains('cairo')) {
      return {'location': 'Cairo, Egypt', 'currency': 'EGP'};
    }
    if (text.contains('ابوظبي') || text.contains('abu dhabi')) {
      return {'location': 'Abu Dhabi, UAE', 'currency': 'AED'};
    }
    if (text.contains('دوحه') || text.contains('قطر') || text.contains('doha')) {
      return {'location': 'Doha, Qatar', 'currency': 'QAR'};
    }
    if (text.contains('كويت') || text.contains('kuwait')) {
      return {'location': 'Kuwait City, Kuwait', 'currency': 'KWD'};
    }
    return {'location': 'Riyadh, Saudi Arabia', 'currency': 'SAR'};
  }

  static double? _extractLandArea(String text) {
    final match = RegExp(
      r'(?:مساحه\s*(?:الارض)?|ارض\s*مساحتها|ارض\s*بمساحه|ارض|plot\s*area|area|land\s*area)\s*(?:تبلغ|هي|:)?\s*(\d+(?:\.\d+)?)',
    ).firstMatch(text);

    if (match != null) {
      return double.tryParse(match.group(1)!);
    }

    // Fallback: look for number followed by sqm or متر
    final match2 = RegExp(r'(\d{3,6})\s*(?:متر|م2|م²|sqm|sq m)').firstMatch(text);
    if (match2 != null) {
      return double.tryParse(match2.group(1)!);
    }
    return null;
  }

  static double? _extractFar(String text) {
    final match = RegExp(
      r'(?:معامل\s*البناء|نسبه\s*البناء|far|f\.a\.r)\s*(?:هو|تبلغ|:)?\s*(\d+(?:\.\d+)?)',
    ).firstMatch(text);

    if (match != null) {
      final val = double.tryParse(match.group(1)!);
      if (val != null && val <= 15.0) return val;
    }
    return null;
  }

  static double? _extractEfficiency(String text) {
    final match = RegExp(
      r'(?:كفاءه|نسبه\s*الكفاءه|efficiency)\s*(?:تبلغ|هي|:)?\s*(\d+(?:\.\d+)?)\s*(?:%|بالمئه|بالمائه|percent)?',
    ).firstMatch(text);

    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  static double? _extractLandCost(String text, double landArea) {
    // Look for "تكلفة الأرض 24 مليون" or "24 million" or "24m"
    final millionMatch = RegExp(
      r'(?:تكلفه\s*الارض|سعر\s*الارض|شراء\s*الارض|قيمه\s*الارض|land\s*cost|land\s*price)\s*(?:تبلغ|هي|:)?\s*(\d+(?:\.\d+)?)\s*(?:مليون|ملايين|million|m)',
    ).firstMatch(text);

    if (millionMatch != null) {
      final val = double.tryParse(millionMatch.group(1)!);
      if (val != null) return val * 1000000.0;
    }

    // General number for land cost
    final generalMatch = RegExp(
      r'(?:تكلفه\s*الارض|سعر\s*الارض|شراء\s*الارض|land\s*cost)\s*(?:تبلغ|هي|:)?\s*(\d+(?:\.\d+)?)',
    ).firstMatch(text);

    if (generalMatch != null) {
      final val = double.tryParse(generalMatch.group(1)!);
      if (val != null) {
        // If small number like 24 or 30, it might mean millions
        if (val < 500) return val * 1000000.0;
        return val;
      }
    }
    return null;
  }

  static double? _extractConstructionCost(String text) {
    final match = RegExp(
      r'(?:تكلفه\s*البناء|تكلفه\s*المتر|سعر\s*المتر\s*للبناء|انشاء|بناء|construction\s*cost|build\s*cost)\s*(?:تبلغ|للمتر|هي|:)?\s*(\d+(?:\.\d+)?)',
    ).firstMatch(text);

    if (match != null) {
      final val = double.tryParse(match.group(1)!);
      if (val != null && val >= 500 && val <= 30000) return val;
    }
    return null;
  }

  static double? _extractExpectedRevenue(String text) {
    // "سعر البيع 18500" or "سعر البيع 18 الف"
    final thousandMatch = RegExp(
      r'(?:سعر\s*البيع|الايراد\s*المتوقع|ايراد\s*المتر|سعر\s*المتر\s*للبيع|expected\s*revenue|sale\s*price)\s*(?:تبلغ|للمتر|هو|:)?\s*(\d+(?:\.\d+)?)\s*(?:الف|الاف|k|thousand)',
    ).firstMatch(text);

    if (thousandMatch != null) {
      final val = double.tryParse(thousandMatch.group(1)!);
      if (val != null) return val * 1000.0;
    }

    final match = RegExp(
      r'(?:سعر\s*البيع|الايراد\s*المتوقع|ايراد\s*المتر|سعر\s*المتر\s*للبيع|expected\s*revenue|sale\s*price)\s*(?:تبلغ|للمتر|هو|:)?\s*(\d+(?:\.\d+)?)',
    ).firstMatch(text);

    if (match != null) {
      final val = double.tryParse(match.group(1)!);
      if (val != null) {
        if (val < 100) return val * 1000.0; // e.g. 18 -> 18000
        return val;
      }
    }
    return null;
  }

  static int? _extractDuration(String text) {
    if (text.contains('سنتين') || text.contains('عامين') || text.contains('2 years')) {
      return 24;
    }
    if (text.contains('سنه ونصف') || text.contains('عام ونصف') || text.contains('1.5 years')) {
      return 18;
    }
    if (text.contains('سنه') || text.contains('عام') || text.contains('1 year')) {
      return 12;
    }
    if (text.contains('ثلاث سنوات') || text.contains('3 سنوات') || text.contains('3 years')) {
      return 36;
    }

    final monthMatch = RegExp(
      r'(?:مده|فتره|duration|timeline|period)\s*(?:التطوير|التنفيذ|المشروع)?\s*(?:تبلغ|هي|:)?\s*(\d+)\s*(?:شهر|شهور|months)',
    ).firstMatch(text);

    if (monthMatch != null) {
      return int.tryParse(monthMatch.group(1)!);
    }
    return null;
  }

  static double? _extractSoftCosts(String text) {
    final match = RegExp(
      r'(?:تكاليف\s*هندسيه|soft\s*costs?)\s*(?:تبلغ|هي|:)?\s*(\d+(?:\.\d+)?)',
    ).firstMatch(text);
    if (match != null) return double.tryParse(match.group(1)!);
    return null;
  }

  static double? _extractContingency(String text) {
    final match = RegExp(
      r'(?:طوارئ|احتياطي|contingency)\s*(?:تبلغ|هي|:)?\s*(\d+(?:\.\d+)?)',
    ).firstMatch(text);
    if (match != null) return double.tryParse(match.group(1)!);
    return null;
  }

  static String _localizedAssetType(String assetType, String locale) {
    if (locale == 'ar') {
      switch (assetType) {
        case 'Residential':
          return 'سكني';
        case 'Commercial':
          return 'تجاري ومكاتب';
        case 'Hospitality':
          return 'فندقي وضيافة';
        case 'Industrial':
          return 'صناعي ولوجستي';
        case 'MixedUse':
          return 'متعدد الاستخدام';
        default:
          return assetType;
      }
    }
    return assetType;
  }
}
