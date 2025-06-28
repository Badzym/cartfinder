import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/cart_marker_model.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/location_service.dart';

class MapState {
  final List<CartMarker> markers;
  final bool isLoading;
  final String? error;
  final Position? currentLocation;

  MapState({
    this.markers = const [],
    this.isLoading = false,
    this.error,
    this.currentLocation,
  });

  MapState copyWith({
    List<CartMarker>? markers,
    bool? isLoading,
    String? error,
    Position? currentLocation,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  final DatabaseService _databaseService;
  final LocationService _locationService;

  MapNotifier(this._databaseService, this._locationService)
      : super(MapState()) {
    _init();
  }

  Future<void> _init() async {
    await loadMarkers();
    _subscribeToMarkers();
  }

  Future<void> loadMarkers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final markers = await _databaseService.getCartMarkers();
      state = state.copyWith(markers: markers, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load markers: $e',
        isLoading: false,
      );
    }
  }

  void _subscribeToMarkers() {
    _databaseService.cartMarkersStream().listen(
      (markers) {
        state = state.copyWith(markers: markers);
      },
      onError: (error) {
        state = state.copyWith(error: 'Stream error: $error');
      },
    );
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      state = state.copyWith(currentLocation: position);
      return position;
    } catch (e) {
      state = state.copyWith(error: 'Location error: $e');
      return null;
    }
  }

  Future<bool> addMarker(CartMarker marker) async {
    try {
      await _databaseService.addCartMarker(marker);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add marker: $e');
      return false;
    }
  }

  Future<bool> updateMarker(CartMarker marker) async {
    try {
      await _databaseService.updateCartMarker(marker);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update marker: $e');
      return false;
    }
  }

  Future<bool> deleteMarker(String markerId, String userId) async {
    try {
      await _databaseService.deleteCartMarker(markerId, userId);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete marker: $e');
      return false;
    }
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final locationService = ref.watch(locationServiceProvider);
  return MapNotifier(databaseService, locationService);
});
