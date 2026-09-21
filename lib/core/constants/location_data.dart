class GovernorateOption {
  final String key;
  final String nameAr;
  final String nameEn;
  final String countryCode; // 'SA' or 'EG'
  final double defaultLat;
  final double defaultLng;

  const GovernorateOption({
    required this.key,
    required this.nameAr,
    required this.nameEn,
    required this.countryCode,
    required this.defaultLat,
    required this.defaultLng,
  });
}

class LocationData {
  static const List<GovernorateOption> egyptGovernorates = [
    GovernorateOption(
      key: 'cairo',
      nameAr: 'القاهرة',
      nameEn: 'Cairo',
      countryCode: 'EG',
      defaultLat: 30.0444,
      defaultLng: 31.2357,
    ),
    GovernorateOption(
      key: 'giza',
      nameAr: 'الجيزة',
      nameEn: 'Giza',
      countryCode: 'EG',
      defaultLat: 30.0131,
      defaultLng: 31.2089,
    ),
    GovernorateOption(
      key: 'alexandria',
      nameAr: 'الإسكندرية',
      nameEn: 'Alexandria',
      countryCode: 'EG',
      defaultLat: 31.2001,
      defaultLng: 29.9187,
    ),
    GovernorateOption(
      key: 'qalyubia',
      nameAr: 'القليوبية',
      nameEn: 'Qalyubia',
      countryCode: 'EG',
      defaultLat: 30.3292,
      defaultLng: 31.2168,
    ),
    GovernorateOption(
      key: 'dakahlia',
      nameAr: 'الدقهلية',
      nameEn: 'Dakahlia',
      countryCode: 'EG',
      defaultLat: 31.0409,
      defaultLng: 31.3785,
    ),
    GovernorateOption(
      key: 'sharqia',
      nameAr: 'الشرقية',
      nameEn: 'Sharqia',
      countryCode: 'EG',
      defaultLat: 30.5877,
      defaultLng: 31.5020,
    ),
    GovernorateOption(
      key: 'monufia',
      nameAr: 'المنوفية',
      nameEn: 'Monufia',
      countryCode: 'EG',
      defaultLat: 30.5972,
      defaultLng: 30.9876,
    ),
    GovernorateOption(
      key: 'gharbia',
      nameAr: 'الغربية',
      nameEn: 'Gharbia',
      countryCode: 'EG',
      defaultLat: 30.7865,
      defaultLng: 31.0004,
    ),
    GovernorateOption(
      key: 'beheira',
      nameAr: 'البحيرة',
      nameEn: 'Beheira',
      countryCode: 'EG',
      defaultLat: 31.0364,
      defaultLng: 30.4699,
    ),
    GovernorateOption(
      key: 'kafr_el_sheikh',
      nameAr: 'كفر الشيخ',
      nameEn: 'Kafr El Sheikh',
      countryCode: 'EG',
      defaultLat: 31.1107,
      defaultLng: 30.9388,
    ),
    GovernorateOption(
      key: 'damietta',
      nameAr: 'دمياط',
      nameEn: 'Damietta',
      countryCode: 'EG',
      defaultLat: 31.4175,
      defaultLng: 31.8144,
    ),
    GovernorateOption(
      key: 'port_said',
      nameAr: 'بورسعيد',
      nameEn: 'Port Said',
      countryCode: 'EG',
      defaultLat: 31.2653,
      defaultLng: 32.3019,
    ),
    GovernorateOption(
      key: 'ismailia',
      nameAr: 'الإسماعيلية',
      nameEn: 'Ismailia',
      countryCode: 'EG',
      defaultLat: 30.5965,
      defaultLng: 32.2715,
    ),
    GovernorateOption(
      key: 'suez',
      nameAr: 'السويس',
      nameEn: 'Suez',
      countryCode: 'EG',
      defaultLat: 29.9668,
      defaultLng: 32.5498,
    ),
    GovernorateOption(
      key: 'red_sea',
      nameAr: 'البحر الأحمر (الغردقة)',
      nameEn: 'Red Sea (Hurghada)',
      countryCode: 'EG',
      defaultLat: 27.2579,
      defaultLng: 33.8116,
    ),
    GovernorateOption(
      key: 'south_sinai',
      nameAr: 'جنوب سيناء (شرم الشيخ)',
      nameEn: 'South Sinai (Sharm El Sheikh)',
      countryCode: 'EG',
      defaultLat: 27.9158,
      defaultLng: 34.3299,
    ),
    GovernorateOption(
      key: 'north_sinai',
      nameAr: 'شمال سيناء',
      nameEn: 'North Sinai',
      countryCode: 'EG',
      defaultLat: 31.1325,
      defaultLng: 33.8033,
    ),
    GovernorateOption(
      key: 'matrouh',
      nameAr: 'مطروح والساحل الشمالي',
      nameEn: 'Matrouh & North Coast',
      countryCode: 'EG',
      defaultLat: 31.3543,
      defaultLng: 27.2373,
    ),
    GovernorateOption(
      key: 'beni_suef',
      nameAr: 'بني سويف',
      nameEn: 'Beni Suef',
      countryCode: 'EG',
      defaultLat: 29.0661,
      defaultLng: 31.0994,
    ),
    GovernorateOption(
      key: 'fayoum',
      nameAr: 'الفيوم',
      nameEn: 'Fayoum',
      countryCode: 'EG',
      defaultLat: 29.3084,
      defaultLng: 30.8428,
    ),
    GovernorateOption(
      key: 'minya',
      nameAr: 'المنيا',
      nameEn: 'Minya',
      countryCode: 'EG',
      defaultLat: 28.0871,
      defaultLng: 30.7618,
    ),
    GovernorateOption(
      key: 'asyut',
      nameAr: 'أسيوط',
      nameEn: 'Asyut',
      countryCode: 'EG',
      defaultLat: 27.1783,
      defaultLng: 31.1859,
    ),
    GovernorateOption(
      key: 'sohag',
      nameAr: 'سوهاج',
      nameEn: 'Sohag',
      countryCode: 'EG',
      defaultLat: 26.5569,
      defaultLng: 31.6948,
    ),
    GovernorateOption(
      key: 'qena',
      nameAr: 'قنا',
      nameEn: 'Qena',
      countryCode: 'EG',
      defaultLat: 26.1551,
      defaultLng: 32.7160,
    ),
    GovernorateOption(
      key: 'luxor',
      nameAr: 'الأقصر',
      nameEn: 'Luxor',
      countryCode: 'EG',
      defaultLat: 25.6872,
      defaultLng: 32.6396,
    ),
    GovernorateOption(
      key: 'aswan',
      nameAr: 'أسوان',
      nameEn: 'Aswan',
      countryCode: 'EG',
      defaultLat: 24.0889,
      defaultLng: 32.8998,
    ),
    GovernorateOption(
      key: 'new_valley',
      nameAr: 'الوادي الجديد',
      nameEn: 'New Valley',
      countryCode: 'EG',
      defaultLat: 25.4514,
      defaultLng: 30.5472,
    ),
  ];

  static const List<GovernorateOption> saudiProvinces = [
    GovernorateOption(
      key: 'riyadh',
      nameAr: 'منطقة الرياض',
      nameEn: 'Riyadh Region',
      countryCode: 'SA',
      defaultLat: 24.7136,
      defaultLng: 46.6753,
    ),
    GovernorateOption(
      key: 'makkah',
      nameAr: 'منطقة مكة المكرمة (جدة / مكة)',
      nameEn: 'Makkah Region (Jeddah / Makkah)',
      countryCode: 'SA',
      defaultLat: 21.5433,
      defaultLng: 39.1728,
    ),
    GovernorateOption(
      key: 'eastern',
      nameAr: 'المنطقة الشرقية (الدمام / الخبر)',
      nameEn: 'Eastern Province (Dammam / Khobar)',
      countryCode: 'SA',
      defaultLat: 26.4207,
      defaultLng: 50.0888,
    ),
    GovernorateOption(
      key: 'madinah',
      nameAr: 'منطقة المدينة المنورة',
      nameEn: 'Madinah Region',
      countryCode: 'SA',
      defaultLat: 24.5247,
      defaultLng: 39.5692,
    ),
    GovernorateOption(
      key: 'qassim',
      nameAr: 'منطقة القصيم',
      nameEn: 'Qassim Region',
      countryCode: 'SA',
      defaultLat: 26.3260,
      defaultLng: 43.9750,
    ),
    GovernorateOption(
      key: 'asir',
      nameAr: 'منطقة عسير (أبها)',
      nameEn: 'Asir Region (Abha)',
      countryCode: 'SA',
      defaultLat: 18.2164,
      defaultLng: 42.5053,
    ),
    GovernorateOption(
      key: 'tabuk',
      nameAr: 'منطقة تبوك (نيوم)',
      nameEn: 'Tabuk Region (NEOM)',
      countryCode: 'SA',
      defaultLat: 28.3835,
      defaultLng: 36.5662,
    ),
    GovernorateOption(
      key: 'hail',
      nameAr: 'منطقة حائل',
      nameEn: 'Hail Region',
      countryCode: 'SA',
      defaultLat: 27.5114,
      defaultLng: 41.7208,
    ),
    GovernorateOption(
      key: 'northern_borders',
      nameAr: 'منطقة الحدود الشمالية',
      nameEn: 'Northern Borders Region',
      countryCode: 'SA',
      defaultLat: 30.9753,
      defaultLng: 41.0381,
    ),
    GovernorateOption(
      key: 'jazan',
      nameAr: 'منطقة جازان',
      nameEn: 'Jazan Region',
      countryCode: 'SA',
      defaultLat: 16.8892,
      defaultLng: 42.5511,
    ),
    GovernorateOption(
      key: 'najran',
      nameAr: 'منطقة نجران',
      nameEn: 'Najran Region',
      countryCode: 'SA',
      defaultLat: 17.4924,
      defaultLng: 44.1277,
    ),
    GovernorateOption(
      key: 'baha',
      nameAr: 'منطقة الباحة',
      nameEn: 'Al Baha Region',
      countryCode: 'SA',
      defaultLat: 20.0129,
      defaultLng: 41.4677,
    ),
    GovernorateOption(
      key: 'jawf',
      nameAr: 'منطقة الجوف',
      nameEn: 'Al Jawf Region',
      countryCode: 'SA',
      defaultLat: 29.9697,
      defaultLng: 40.2064,
    ),
  ];

  static List<GovernorateOption> getGovernoratesForCountry(String countryCode) {
    if (countryCode == 'EG') {
      return egyptGovernorates;
    }
    return saudiProvinces;
  }

  static GovernorateOption getDefaultGovernorate(String countryCode) {
    if (countryCode == 'EG') {
      return egyptGovernorates.first; // Cairo
    }
    return saudiProvinces.first; // Riyadh
  }

  static GovernorateOption matchGovernorate(String countryCode, String query) {
    final list = getGovernoratesForCountry(countryCode);
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list.first;

    for (final item in list) {
      if (item.key == q ||
          item.nameAr.toLowerCase().contains(q) ||
          q.contains(item.nameAr.toLowerCase()) ||
          item.nameEn.toLowerCase().contains(q) ||
          q.contains(item.nameEn.toLowerCase())) {
        return item;
      }
    }
    return list.first;
  }
}
