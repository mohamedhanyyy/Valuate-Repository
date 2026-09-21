import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
  bool _isLocatingGps = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initCoordinates();
  }

  void _initCoordinates() {
    final country = widget.currentCountry.toLowerCase();
    final location = widget.currentLocation;

    // Check if location string has coordinates like "29.8978, 30.9059"
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
      _selectedPoint = const LatLng(30.0444, 31.2357); // Cairo
      _countryAr = 'جمهورية مصر العربية';
      _countryEn = 'Egypt';
      _cityAr = 'القاهرة';
      _cityEn = 'Cairo';
    } else {
      // Default: Saudi Arabia (Riyadh)
      _selectedPoint = const LatLng(24.7136, 46.6753);
      _countryAr = 'المملكة العربية السعودية';
      _countryEn = 'Saudi Arabia';
      _cityAr = 'الرياض';
      _cityEn = 'Riyadh';
    }

    _updateSelectedPoint(_selectedPoint, initial: true);

    // If no explicit coordinates were passed, attempt to obtain user's current GPS position
    _locateUserCurrent(animate: true);
  }

  Future<void> _locateUserCurrent({bool animate = true}) async {
    if (_isLocatingGps) return;
    setState(() => _isLocatingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLocatingGps = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
          ),
        );
        if (!mounted) return;
        final userPoint = LatLng(pos.latitude, pos.longitude);
        _updateSelectedPoint(userPoint);
        if (animate) {
          _mapController.move(userPoint, 15.0);
        }
      }
    } catch (e) {
      debugPrint('Locate user error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLocatingGps = false);
      }
    }
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
                  isAr ? 'تحديد الموقع على الخريطة' : 'Select Location On Map',
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
                          Container(height: 1, width: 24, color: Colors.black12),
                          InkWell(
                            onTap: () => _locateUserCurrent(animate: true),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: _isLocatingGps
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                                    )
                                  : const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFF2563EB)),
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
              crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                        isAr
                            ? 'العنوان المحدد: ${_resolvedAddressAr.isNotEmpty ? _resolvedAddressAr : 'الموقع عند ${_selectedPoint.latitude.toStringAsFixed(4)}, ${_selectedPoint.longitude.toStringAsFixed(4)}'}'
                            : 'Selected Address: ${_resolvedAddressEn.isNotEmpty ? _resolvedAddressEn : 'Location at ${_selectedPoint.latitude.toStringAsFixed(4)}, ${_selectedPoint.longitude.toStringAsFixed(4)}'}',
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.brandNavy,
                        ),
                      ),
                    ),
                  ],
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
