import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static const String _useCurrentLocationKey = 'use_current_location';
  static const String _customLocationKey = 'custom_location';
  static const String _lastKnownLatKey = 'last_known_lat';
  static const String _lastKnownLngKey = 'last_known_lng';

  bool _useCurrentLocation = true;
  String _customLocation = '';
  Position? _lastKnownPosition;
  
  // Callback for location changes
  Function()? _onLocationChanged;

  bool get useCurrentLocation => _useCurrentLocation;
  String get customLocation => _customLocation;
  Position? get lastKnownPosition => _lastKnownPosition;

  void setLocationChangeCallback(Function()? callback) {
    _onLocationChanged = callback;
  }

  Future<void> init() async {
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _useCurrentLocation = prefs.getBool(_useCurrentLocationKey) ?? true;
    _customLocation = prefs.getString(_customLocationKey) ?? '';
    
    final lat = prefs.getDouble(_lastKnownLatKey);
    final lng = prefs.getDouble(_lastKnownLngKey);
    if (lat != null && lng != null) {
      _lastKnownPosition = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  Future<void> updateLocationPreference({
    required bool useCurrentLocation,
    String? customLocation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    _useCurrentLocation = useCurrentLocation;
    _customLocation = customLocation ?? '';
    
    await prefs.setBool(_useCurrentLocationKey, _useCurrentLocation);
    await prefs.setString(_customLocationKey, _customLocation);
    
    print('Location preference updated: useCurrentLocation=$_useCurrentLocation, customLocation=$_customLocation');
    
    // Notify listeners of location change
    if (_onLocationChanged != null) {
      _onLocationChanged!();
    }
  }

  Future<String> getLocationName() async {
    if (_useCurrentLocation) {
      try {
        final position = await getCurrentPosition();
        if (position != null) {
          return await _getLocationNameFromCoordinates(position.latitude, position.longitude);
        }
      } catch (e) {
        print('Error getting current location: $e');
      }
      return 'Location unavailable';
    } else {
      return _customLocation.isNotEmpty ? _customLocation : 'Custom location not set';
    }
  }

  Future<Position?> getCurrentPosition() async {
    if (!_useCurrentLocation) {
      // If using custom location, try to geocode it to get coordinates
      if (_customLocation.isNotEmpty) {
        try {
          final locations = await geocoding.locationFromAddress(_customLocation);
          if (locations.isNotEmpty) {
            final location = locations.first;
            final position = Position(
              latitude: location.latitude,
              longitude: location.longitude,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );
            await _saveLastKnownPosition(position);
            return position;
          }
        } catch (e) {
          print('Error geocoding custom location: $e');
        }
      }
      return _lastKnownPosition;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition();
      await _saveLastKnownPosition(position);
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return _lastKnownPosition;
    }
  }

  Future<void> _saveLastKnownPosition(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    _lastKnownPosition = position;
    await prefs.setDouble(_lastKnownLatKey, position.latitude);
    await prefs.setDouble(_lastKnownLngKey, position.longitude);
  }

  Future<String> _getLocationNameFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return placemark.locality ?? placemark.administrativeArea ?? 'Unknown location';
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
    return 'Unknown location';
  }

  String getDisplayLocation() {
    if (_useCurrentLocation) {
      return 'Using current location';
    } else {
      return _customLocation.isNotEmpty ? _customLocation : 'Custom location not set';
    }
  }
}
