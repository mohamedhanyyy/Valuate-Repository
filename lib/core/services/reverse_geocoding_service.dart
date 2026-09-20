import 'package:dio/dio.dart';

class GeocodedAddress {
  final String displayNameAr;
  final String displayNameEn;
  final String districtAr;
  final String districtEn;
  final String cityAr;
  final String cityEn;
  final String countryAr;
  final String countryEn;
  final double lat;
  final double lng;

  const GeocodedAddress({
    required this.displayNameAr,
    required this.displayNameEn,
    required this.districtAr,
    required this.districtEn,
    required this.cityAr,
    required this.cityEn,
    required this.countryAr,
    required this.countryEn,
    required this.lat,
    required this.lng,
  });
}

class ReverseGeocodingService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      headers: {
        'User-Agent': 'ValuateApp/1.0 (com.gateways.valuate)',
        'Accept-Language': 'ar,en',
      },
    ),
  );

  static const List<_PresetDistrict> _knownDistricts = [
    // Riyadh
    _PresetDistrict('الرياض', 'Riyadh', 'حي النرجس', 'Al Narjis', 'المملكة العربية السعودية', 'Saudi Arabia', 24.8412, 46.6562),
    _PresetDistrict('الرياض', 'Riyadh', 'حي الملقا', 'Al Malqa', 'المملكة العربية السعودية', 'Saudi Arabia', 24.8021, 46.6025),
    _PresetDistrict('الرياض', 'Riyadh', 'حي الياسمين', 'Al Yasmin', 'المملكة العربية السعودية', 'Saudi Arabia', 24.8214, 46.6480),
    _PresetDistrict('الرياض', 'Riyadh', 'حي حطين', 'Hittin', 'المملكة العربية السعودية', 'Saudi Arabia', 24.7680, 46.5980),
    _PresetDistrict('الرياض', 'Riyadh', 'مركز الملك عبدالله المالي (KAFD)', 'KAFD Financial District', 'المملكة العربية السعودية', 'Saudi Arabia', 24.7645, 46.6432),
    _PresetDistrict('الرياض', 'Riyadh', 'حي الصحافة', 'Al Sahafah', 'المملكة العربية السعودية', 'Saudi Arabia', 24.7990, 46.6410),
    _PresetDistrict('الرياض', 'Riyadh', 'حي العقيق', 'Al Aqiq', 'المملكة العربية السعودية', 'Saudi Arabia', 24.7780, 46.6320),
    _PresetDistrict('الرياض', 'Riyadh', 'حي قرطبة', 'Qurtubah', 'المملكة العربية السعودية', 'Saudi Arabia', 24.8050, 46.7280),
    _PresetDistrict('الرياض', 'Riyadh', 'حي الرمال', 'Al Rimal', 'المملكة العربية السعودية', 'Saudi Arabia', 24.8620, 46.8150),
    _PresetDistrict('الرياض', 'Riyadh', 'حي السليمانية', 'Al Sulaymaniyah', 'المملكة العربية السعودية', 'Saudi Arabia', 24.7080, 46.6970),
    _PresetDistrict('الرياض', 'Riyadh', 'حي العليا', 'Al Olaya', 'المملكة العربية السعودية', 'Saudi Arabia', 24.6980, 46.6850),

    // Jeddah & Khobar
    _PresetDistrict('جدة', 'Jeddah', 'الكورنيش الشمالي', 'North Corniche', 'المملكة العربية السعودية', 'Saudi Arabia', 21.5833, 39.1098),
    _PresetDistrict('جدة', 'Jeddah', 'أبحر الشمالية', 'North Obhur', 'المملكة العربية السعودية', 'Saudi Arabia', 21.7456, 39.1124),
    _PresetDistrict('جدة', 'Jeddah', 'حي الشاطئ', 'Al Shati', 'المملكة العربية السعودية', 'Saudi Arabia', 21.6020, 39.1180),
    _PresetDistrict('الخبر', 'Khobar', 'الواجهة البحرية', 'Waterfront', 'المملكة العربية السعودية', 'Saudi Arabia', 26.2845, 50.2178),
    _PresetDistrict('الدمام', 'Dammam', 'حي الشاطئ الشرقي', 'East Shati', 'المملكة العربية السعودية', 'Saudi Arabia', 26.4620, 50.1250),

    // Egypt - Giza & Cairo
    _PresetDistrict('الجيزة', 'Giza', 'مدينة 6 أكتوبر (طريق الواحات)', '6th of October City', 'جمهورية مصر العربية', 'Egypt', 29.8978, 30.9059),
    _PresetDistrict('الجيزة', 'Giza', 'مدينة الشيخ زايد', 'Sheikh Zayed City', 'جمهورية مصر العربية', 'Egypt', 30.0561, 30.9857),
    _PresetDistrict('القاهرة', 'Cairo', 'التجمع الخامس (القاهرة الجديدة)', 'New Cairo (5th Settlement)', 'جمهورية مصر العربية', 'Egypt', 30.0131, 31.4913),
    _PresetDistrict('القاهرة', 'Cairo', 'مدينة نصر', 'Nasr City', 'جمهورية مصر العربية', 'Egypt', 30.0560, 31.3350),
    _PresetDistrict('القاهرة', 'Cairo', 'حي المعادي', 'Maadi', 'جمهورية مصر العربية', 'Egypt', 29.9600, 31.2580),
    _PresetDistrict('القاهرة', 'Cairo', 'مصر الجديدة', 'Heliopolis', 'جمهورية مصر العربية', 'Egypt', 30.0900, 31.3250),
    _PresetDistrict('العاصمة الإدارية', 'New Capital', 'الحي المالي والإداري', 'Financial District', 'جمهورية مصر العربية', 'Egypt', 30.0074, 31.7487),

    // UAE - Dubai & Abu Dhabi
    _PresetDistrict('دبي', 'Dubai', 'وسط مدينة دبي (Downtown)', 'Downtown Dubai', 'الإمارات العربية المتحدة', 'United Arab Emirates', 25.1972, 55.2744),
    _PresetDistrict('دبي', 'Dubai', 'الخليج التجاري (Business Bay)', 'Business Bay', 'الإمارات العربية المتحدة', 'United Arab Emirates', 25.1867, 55.2744),
    _PresetDistrict('دبي', 'Dubai', 'مرسى دبي (Dubai Marina)', 'Dubai Marina', 'الإمارات العربية المتحدة', 'United Arab Emirates', 25.0805, 55.1403),
    _PresetDistrict('دبي', 'Dubai', 'نخلة جميرا (Palm Jumeirah)', 'Palm Jumeirah', 'الإمارات العربية المتحدة', 'United Arab Emirates', 25.1124, 55.1390),
    _PresetDistrict('دبي', 'Dubai', 'جميرا بيتش ريزيدنس (JBR)', 'Jumeirah Beach Residence', 'الإمارات العربية المتحدة', 'United Arab Emirates', 25.0780, 55.1320),
    _PresetDistrict('أبوظبي', 'Abu Dhabi', 'جزيرة الريم (Al Reem)', 'Al Reem Island', 'الإمارات العربية المتحدة', 'United Arab Emirates', 24.4988, 54.4074),
    _PresetDistrict('أبوظبي', 'Abu Dhabi', 'جزيرة ياس (Yas Island)', 'Yas Island', 'الإمارات العربية المتحدة', 'United Arab Emirates', 24.4980, 54.6050),

    // Qatar
    _PresetDistrict('الدوحة', 'Doha', 'مدينة لوسيل (Lusail Marina)', 'Lusail Marina', 'دولة قطر', 'Qatar', 25.4167, 51.5333),
    _PresetDistrict('الدوحة', 'Doha', 'جزيرة اللؤلؤة (The Pearl)', 'The Pearl Qatar', 'دولة قطر', 'Qatar', 25.3713, 51.5518),
    _PresetDistrict('الدوحة', 'Doha', 'الخليج الغربي (West Bay)', 'West Bay', 'دولة قطر', 'Qatar', 25.3210, 51.5280),

    // Kuwait
    _PresetDistrict('الكويت', 'Kuwait City', 'شرق ومدينة الكويت', 'Sharq District', 'دولة الكويت', 'Kuwait', 29.3842, 47.9944),
    _PresetDistrict('الكويت', 'Kuwait City', 'السالمية', 'Salmiya', 'دولة الكويت', 'Kuwait', 29.3350, 48.0750),

    // Bahrain
    _PresetDistrict('المنامة', 'Manama', 'ضاحية السيف', 'Seef District', 'مملكة البحرين', 'Bahrain', 26.2415, 50.5344),
    _PresetDistrict('المنامة', 'Manama', 'خليج البحرين', 'Bahrain Bay', 'مملكة البحرين', 'Bahrain', 26.2480, 50.5750),

    // Oman
    _PresetDistrict('مسقط', 'Muscat', 'الموج مسقط (Al Mouj)', 'Al Mouj Waterfront', 'سلطنة عمان', 'Oman', 23.6264, 58.2618),
    _PresetDistrict('مسقط', 'Muscat', 'شاطئ القرم', 'Shatti Al Qurum', 'سلطنة عمان', 'Oman', 23.6080, 58.4550),
  ];

  /// Immediate local offline reverse geocode lookup
  static GeocodedAddress getLocalNearest(double lat, double lng) {
    _PresetDistrict nearest = _knownDistricts.first;
    double minDistanceSq = double.infinity;

    for (final d in _knownDistricts) {
      final dLat = d.lat - lat;
      final dLng = d.lng - lng;
      final distSq = dLat * dLat + dLng * dLng;
      if (distSq < minDistanceSq) {
        minDistanceSq = distSq;
        nearest = d;
      }
    }

    // Distance ~0.35 deg (~35km radius)
    if (minDistanceSq < 0.25) {
      return GeocodedAddress(
        displayNameAr: '${nearest.cityAr} - ${nearest.districtAr}',
        displayNameEn: '${nearest.cityEn} - ${nearest.districtEn}',
        districtAr: nearest.districtAr,
        districtEn: nearest.districtEn,
        cityAr: nearest.cityAr,
        cityEn: nearest.cityEn,
        countryAr: nearest.countryAr,
        countryEn: nearest.countryEn,
        lat: lat,
        lng: lng,
      );
    }

    // Fallback if far from known presets
    return GeocodedAddress(
      displayNameAr: 'موقع جغرافي (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
      displayNameEn: 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
      districtAr: '',
      districtEn: '',
      cityAr: nearest.cityAr,
      cityEn: nearest.cityEn,
      countryAr: nearest.countryAr,
      countryEn: nearest.countryEn,
      lat: lat,
      lng: lng,
    );
  }

  /// Live Reverse Geocoding with OpenStreetMap Nominatim API
  static Future<GeocodedAddress> reverseGeocode(double lat, double lng) async {
    final localFallback = getLocalNearest(lat, lng);

    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=ar,en&zoom=18';
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final road = address['road'] ?? address['pedestrian'] ?? address['street'];
          final suburb = address['suburb'] ??
              address['neighbourhood'] ??
              address['residential'] ??
              address['district'] ??
              address['quarter'] ??
              address['commercial'];
          final city = address['city'] ??
              address['town'] ??
              address['municipality'] ??
              address['state_district'] ??
              address['state'] ??
              localFallback.cityAr;
          final country = address['country'] ?? localFallback.countryAr;

          String finalAr = '';
          if (city != null && city.toString().isNotEmpty) {
            finalAr = city.toString();
          }
          if (suburb != null && suburb.toString().isNotEmpty) {
            finalAr = finalAr.isNotEmpty ? '$finalAr - $suburb' : suburb.toString();
          } else if (road != null && road.toString().isNotEmpty) {
            finalAr = finalAr.isNotEmpty ? '$finalAr - $road' : road.toString();
          }

          if (finalAr.trim().isEmpty) {
            finalAr = data['name'] ?? localFallback.displayNameAr;
          }

          return GeocodedAddress(
            displayNameAr: finalAr,
            displayNameEn: finalAr,
            districtAr: (suburb ?? road ?? localFallback.districtAr).toString(),
            districtEn: (suburb ?? road ?? localFallback.districtEn).toString(),
            cityAr: (city ?? localFallback.cityAr).toString(),
            cityEn: (city ?? localFallback.cityEn).toString(),
            countryAr: country.toString(),
            countryEn: localFallback.countryEn,
            lat: lat,
            lng: lng,
          );
        }
      }
    } catch (_) {
      // Return offline calculated local nearest address
    }

    return localFallback;
  }
}

class _PresetDistrict {
  final String cityAr;
  final String cityEn;
  final String districtAr;
  final String districtEn;
  final String countryAr;
  final String countryEn;
  final double lat;
  final double lng;

  const _PresetDistrict(
    this.cityAr,
    this.cityEn,
    this.districtAr,
    this.districtEn,
    this.countryAr,
    this.countryEn,
    this.lat,
    this.lng,
  );
}
