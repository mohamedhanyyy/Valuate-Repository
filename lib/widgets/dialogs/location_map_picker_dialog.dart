import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/reverse_geocoding_service.dart';

class LocationOption {
  final String nameAr;
  final String nameEn;
  final String cityAr;
  final String cityEn;
  final String countryAr;
  final String countryEn;
  final double lat;
  final double lng;

  const LocationOption({
    required this.nameAr,
    required this.nameEn,
    required this.cityAr,
    required this.cityEn,
    required this.countryAr,
    required this.countryEn,
    required this.lat,
    required this.lng,
  });
}

class LocationMapPickerDialog extends StatefulWidget {
  final String currentCountry;
  final String currentLocation;
  final bool isDark;
  final String locale;

  const LocationMapPickerDialog({
    super.key,
    required this.currentCountry,
    required this.currentLocation,
    required this.isDark,
    required this.locale,
  });

  static Future<LocationOption?> show(
    BuildContext context, {
    required String currentCountry,
    required String currentLocation,
    required bool isDark,
    required String locale,
  }) {
    return showDialog<LocationOption>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: LocationMapPickerDialog(
          currentCountry: currentCountry,
          currentLocation: currentLocation,
          isDark: isDark,
          locale: locale,
        ),
      ),
    );
  }

  @override
  State<LocationMapPickerDialog> createState() => _LocationMapPickerDialogState();
}

class _LocationMapPickerDialogState extends State<LocationMapPickerDialog> {
  late final MapController _mapController;
  late LatLng _selectedPoint;
  String _resolvedAddressAr = '';
  String _resolvedAddressEn = '';
  String _countryAr = 'المملكة العربية السعودية';
  String _countryEn = 'Saudi Arabia';
  String _cityAr = 'الرياض';
  String _cityEn = 'Riyadh';
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initCoordinates();
  }

  void _initCoordinates() {
    // Determine initial coordinates from current country or location
    final country = widget.currentCountry.toLowerCase();
    final location = widget.currentLocation;

    // Check if location string has coordinates like "29.8978, 30.9059" or "Location at 29.8978, 30.9059"
    final coordsMatch = RegExp(r'([0-9]+\.[0-9]+)[\s,]+([0-9]+\.[0-9]+)').firstMatch(location);
    if (coordsMatch != null) {
      final parsedLat = double.tryParse(coordsMatch.group(1)!);
      final parsedLng = double.tryParse(coordsMatch.group(2)!);
      if (parsedLat != null && parsedLng != null) {
        _selectedPoint = LatLng(parsedLat, parsedLng);
        _updateSelectedPoint(_selectedPoint, initial: true);
        return;
      }
    }

    if (country.contains('مصر') || country.contains('egypt')) {
      _selectedPoint = const LatLng(29.897806, 30.905914); // 6th of October / Giza
      _countryAr = 'جمهورية مصر العربية';
      _countryEn = 'Egypt';
      _cityAr = 'الجيزة';
      _cityEn = 'Giza';
    } else if (country.contains('الإمارات') || country.contains('emirates') || country.contains('uae')) {
      _selectedPoint = const LatLng(25.1972, 55.2744); // Dubai Downtown
      _countryAr = 'الإمارات العربية المتحدة';
      _countryEn = 'United Arab Emirates';
      _cityAr = 'دبي';
      _cityEn = 'Dubai';
    } else if (country.contains('قطر') || country.contains('qatar')) {
      _selectedPoint = const LatLng(25.2854, 51.5310);
      _countryAr = 'دولة قطر';
      _countryEn = 'Qatar';
      _cityAr = 'الدوحة';
      _cityEn = 'Doha';
    } else if (country.contains('الكويت') || country.contains('kuwait')) {
      _selectedPoint = const LatLng(29.3759, 47.9774);
      _countryAr = 'دولة الكويت';
      _countryEn = 'Kuwait';
      _cityAr = 'الكويت';
      _cityEn = 'Kuwait City';
    } else if (country.contains('البحرين') || country.contains('bahrain')) {
      _selectedPoint = const LatLng(26.2285, 50.5860);
      _countryAr = 'مملكة البحرين';
      _countryEn = 'Bahrain';
      _cityAr = 'المنامة';
      _cityEn = 'Manama';
    } else if (country.contains('عمان') || country.contains('oman')) {
      _selectedPoint = const LatLng(23.5880, 58.3829);
      _countryAr = 'سلطنة عمان';
      _countryEn = 'Oman';
      _cityAr = 'مسقط';
      _cityEn = 'Muscat';
    } else {
      // Default: Saudi Arabia (Riyadh)
      _selectedPoint = const LatLng(24.8412, 46.6562);
      _countryAr = 'المملكة العربية السعودية';
      _countryEn = 'Saudi Arabia';
      _cityAr = 'الرياض';
      _cityEn = 'Riyadh';
    }

    _updateSelectedPoint(_selectedPoint, initial: true);
  }

  void _updateSelectedPoint(LatLng point, {bool initial = false}) {
    final local = ReverseGeocodingService.getLocalNearest(point.latitude, point.longitude);
    setState(() {
      _selectedPoint = point;
      _resolvedAddressAr = local.displayNameAr;
      _resolvedAddressEn = local.displayNameEn;
      _cityAr = local.cityAr;
      _cityEn = local.cityEn;
      _countryAr = local.countryAr;
      _countryEn = local.countryEn;
      _isResolving = true;
    });

    _fetchRealAddress(point.latitude, point.longitude);
  }

  void _fetchRealAddress(double lat, double lng) async {
    final result = await ReverseGeocodingService.reverseGeocode(lat, lng);
    if (mounted && _selectedPoint.latitude == lat && _selectedPoint.longitude == lng) {
      setState(() {
        _resolvedAddressAr = result.displayNameAr;
        _resolvedAddressEn = result.displayNameEn;
        _cityAr = result.cityAr;
        _cityEn = result.cityEn;
        _countryAr = result.countryAr;
        _countryEn = result.countryEn;
        _isResolving = false;
      });
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_selectedPoint, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_selectedPoint, currentZoom - 1);
  }

  LocationOption _buildResultOption() {
    return LocationOption(
      nameAr: _resolvedAddressAr.isNotEmpty
          ? _resolvedAddressAr
          : 'الموقع (${_selectedPoint.latitude.toStringAsFixed(4)}, ${_selectedPoint.longitude.toStringAsFixed(4)})',
      nameEn: _resolvedAddressEn.isNotEmpty
          ? _resolvedAddressEn
          : 'Location at ${_selectedPoint.latitude.toStringAsFixed(4)}, ${_selectedPoint.longitude.toStringAsFixed(4)}',
      cityAr: _cityAr,
      cityEn: _cityEn,
      countryAr: _countryAr,
      countryEn: _countryEn,
      lat: _selectedPoint.latitude,
      lng: _selectedPoint.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isAr = widget.locale == 'ar';
    final dialogBg = isDark ? const Color(0xFF161F38) : Colors.white;
    final borderColor = isDark ? const Color(0xFF222F54) : const Color(0xFFE2E8F0);

    return Container(
      width: 680,
      constraints: const BoxConstraints(maxHeight: 640),
      decoration: BoxDecoration(
        color: dialogBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Location On Map',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.brandNavy,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Real Interactive Map View Container
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Flutter Map OpenStreetMap Tile Layer
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPoint,
                      initialZoom: 14.0,
                      minZoom: 3.0,
                      maxZoom: 18.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      onTap: (tapPosition, point) {
                        _updateSelectedPoint(point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.gateways.valuate',
                        maxZoom: 19,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedPoint,
                            width: 50,
                            height: 50,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_on,
                              size: 44,
                              color: Color(0xFF2563EB), // Rich Blue Pin as in screenshot
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Zoom Buttons on Top-Left (matching screenshot)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: _zoomIn,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.add, size: 18, color: Colors.black87),
                            ),
                          ),
                          Container(height: 1, width: 24, color: Colors.black12),
                          InkWell(
                            onTap: _zoomOut,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.remove, size: 18, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Map instruction hint
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isAr ? 'انقر على أي نقطة في الخريطة لتحديد الموقع' : 'Tap on map to place pin',
                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Address and Coordinates Information Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_isResolving) ...[
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        'Selected Address: ${_resolvedAddressAr.isNotEmpty ? _resolvedAddressAr : 'Location at ${_selectedPoint.latitude.toStringAsFixed(4)}, ${_selectedPoint.longitude.toStringAsFixed(4)}'}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.brandNavy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'الإحداثيات: ${_selectedPoint.latitude.toStringAsFixed(6)} ,${_selectedPoint.longitude.toStringAsFixed(6)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Buttons (تأكيد الموقع, إلغاء)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Confirm Location Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _buildResultOption());
                  },
                  child: Text(
                    isAr ? 'تأكيد الموقع' : 'Confirm Location',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),

                // Cancel Button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    foregroundColor: isDark ? Colors.white70 : Colors.black87,
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    isAr ? 'إلغاء' : 'Cancel',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
