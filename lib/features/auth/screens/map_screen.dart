import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../core/constants/api_keys.dart';
import '../../../core/services/auth_service.dart';
import '../providers/map_provider.dart';
import '../widgets/add_marker_dialog.dart';
import '../widgets/marker_info_popup.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CartFinder'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(mapProvider.notifier).loadMarkers(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: const Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: const Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authServiceProvider).signOut();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // MapBox Map
          MapWidget(
            key: const ValueKey("mapWidget"),
            resourceOptions: ResourceOptions(
              accessToken: ApiKeys.mapboxAccessToken,
            ),
            cameraOptions: CameraOptions(
              center: Point(
                  coordinates: Position(-106.3468, 56.1304)), // Canada center
              zoom: 4.0,
            ),
            onMapCreated: _onMapCreated,
            onTapListener: _onMapTap,
          ),

          // Loading indicator
          if (mapState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error message
          if (mapState.error != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    mapState.error!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ),
            ),

          // Floating Action Buttons
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "location",
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.blue.shade600,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "add",
                  onPressed: _showAddMarkerAtCenter,
                  backgroundColor: Colors.green.shade600,
                  child: const Icon(Icons.add_location, color: Colors.white),
                ),
              ],
            ),
          ),

          // Stats card
          Positioned(
            bottom: 16,
            left: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '🛒 ${mapState.markers.length} carts found',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _pointAnnotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    _loadMarkers();
  }

  void _onMapTap(MapContentGestureContext context) {
    final point = context.point;
    _showAddMarkerDialog(point.coordinates.lat, point.coordinates.lng);
  }

  Future<void> _loadMarkers() async {
    if (_pointAnnotationManager == null) return;

    final mapState = ref.read(mapProvider);

    // Clear existing annotations
    await _pointAnnotationManager!.deleteAll();

    // Add markers
    for (final marker in mapState.markers) {
      final options = PointAnnotationOptions(
        geometry:
            Point(coordinates: Position(marker.longitude, marker.latitude)),
        iconImage: 'shopping-cart-icon',
        iconSize: 1.2,
      );

      final annotation = await _pointAnnotationManager!.create(options);

      // Add tap listener for marker info
      _pointAnnotationManager!.addOnPointAnnotationClickListener(
        OnPointAnnotationClickListener(
          onPointAnnotationClick: (PointAnnotation annotation) {
            _showMarkerInfo(marker);
          },
        ),
      );
    }
  }

  void _getCurrentLocation() async {
    final position = await ref.read(mapProvider.notifier).getCurrentLocation();

    if (position != null && _mapboxMap != null) {
      await _mapboxMap!.setCamera(
        CameraOptions(
          center: Point(
              coordinates: Position(position.longitude, position.latitude)),
          zoom: 15.0,
        ),
      );
    }
  }

  void _showAddMarkerAtCenter() async {
    if (_mapboxMap == null) return;

    final cameraState = await _mapboxMap!.getCameraState();
    final center = cameraState.center;

    _showAddMarkerDialog(center.coordinates.lat, center.coordinates.lng);
  }

  void _showAddMarkerDialog(double lat, double lng) {
    showDialog(
      context: context,
      builder: (context) => AddMarkerDialog(
        latitude: lat,
        longitude: lng,
        onMarkerAdded: () {
          _loadMarkers();
        },
      ),
    );
  }

  void _showMarkerInfo(marker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MarkerInfoPopup(marker: marker),
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen to marker changes
    ref.listenManual(mapProvider.select((state) => state.markers),
        (previous, next) {
      if (mounted) {
        _loadMarkers();
      }
    });
  }
}
