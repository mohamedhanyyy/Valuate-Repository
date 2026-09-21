import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/location_data.dart';
import 'reverse_geocoding_service.dart';

class UserLocationResult {
  final double lat;
  final double lng;
  final String countryCode; // 'SA' or 'EG'
  final GovernorateOption governorate;
  final String addressAr;
  final String addressEn;
  final bool isGpsSource;

  const UserLocationResult({
    required this.lat,
    required this.lng,
    required this.countryCode,
    required this.governorate,
    required this.addressAr,
    required this.addressEn,
    required this.isGpsSource,
  });
}

class UserLocationService {
  /// Attempts to fetch the user's current GPS location.
  /// Falls back gracefully to Riyadh or Cairo if permissions are denied or GPS is unavailable.
  static Future<UserLocationResult> determineUserLocation({String preferredCountry = 'SA'}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _buildDefaultFallback(preferredCountry);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _buildDefaultFallback(preferredCountry);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _buildDefaultFallback(preferredCountry);
      }

      // Fetch position with 4-second timeout to never block UI
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      );

      final lat = position.latitude;
      final lng = position.longitude;

      // Reverse geocode via reverse geocoding service
      final address = await ReverseGeocodingService.reverseGeocode(lat, lng);

      // Determine whether user is in Egypt or Saudi Arabia
      final countryLower = address.countryEn.toLowerCase();
      final countryArLower = address.countryAr.toLowerCase();
      String countryCode = preferredCountry;

      if (countryLower.contains('egypt') || countryArLower.contains('مصر') || (lat >= 21.5 && lat <= 32.0 && lng >= 24.5 && lng <= 36.5)) {
        countryCode = 'EG';
      } else if (countryLower.contains('saudi') || countryArLower.contains('سعود') || (lat >= 16.0 && lat <= 32.5 && lng >= 36.5 && lng <= 55.5)) {
        countryCode = 'SA';
      }

      final governorate = LocationData.matchGovernorate(
        countryCode,
        '${address.cityAr} ${address.districtAr} ${address.cityEn} ${address.districtEn}',
      );

      return UserLocationResult(
        lat: lat,
        lng: lng,
        countryCode: countryCode,
        governorate: governorate,
        addressAr: address.displayNameAr,
        addressEn: address.displayNameEn,
        isGpsSource: true,
      );
    } catch (e) {
      debugPrint('UserLocationService error: $e');
      return _buildDefaultFallback(preferredCountry);
    }
  }

  static UserLocationResult _buildDefaultFallback(String countryCode) {
    final gov = LocationData.getDefaultGovernorate(countryCode);
    final isEg = countryCode == 'EG';
    return UserLocationResult(
      lat: gov.defaultLat,
      lng: gov.defaultLng,
      countryCode: countryCode,
      governorate: gov,
      addressAr: isEg ? 'القاهرة - التجمع الخامس' : 'الرياض - حي النرجس',
      addressEn: isEg ? 'Cairo - New Cairo' : 'Riyadh - Al Narjis',
      isGpsSource: false,
    );
  }
}
