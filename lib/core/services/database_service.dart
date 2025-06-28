import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_marker_model.dart';

class DatabaseService {
  final SupabaseClient _supabase;

  DatabaseService(this._supabase);

  // Get all cart markers
  Future<List<CartMarker>> getCartMarkers() async {
    final response = await _supabase
        .from('cart_markers')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return response
        .map<CartMarker>((json) => CartMarker.fromJson(json))
        .toList();
  }

  // Stream cart markers for real-time updates
  Stream<List<CartMarker>> cartMarkersStream() {
    return _supabase
        .from('cart_markers')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .map((data) =>
            data.map<CartMarker>((json) => CartMarker.fromJson(json)).toList());
  }

  // Add new cart marker
  Future<void> addCartMarker(CartMarker marker) async {
    await _rateLimit(marker.userId);

    await _supabase.from('cart_markers').insert(marker.toJson());
  }

  // Update cart marker
  Future<void> updateCartMarker(CartMarker marker) async {
    await _supabase
        .from('cart_markers')
        .update(marker.toJson())
        .eq('id', marker.id)
        .eq('user_id', marker.userId);
  }

  // Delete cart marker
  Future<void> deleteCartMarker(String markerId, String userId) async {
    await _supabase
        .from('cart_markers')
        .update({'is_active': false})
        .eq('id', markerId)
        .eq('user_id', userId);
  }

  // Fraud protection - Rate limiting
  Future<void> _rateLimit(String userId) async {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    final response = await _supabase
        .from('cart_markers')
        .select('id')
        .eq('user_id', userId)
        .gte('created_at', oneHourAgo.toIso8601String());

    if (response.length >= 5) {
      throw Exception('Rate limit exceeded. Maximum 5 posts per hour.');
    }
  }

  // Upload photo
  Future<String> uploadPhoto(String filePath, String fileName) async {
    final bytes = await _supabase.storage
        .from('cart-photos')
        .uploadBinary(fileName, await _getFileBytes(filePath));

    return _supabase.storage.from('cart-photos').getPublicUrl(fileName);
  }

  Future<List<int>> _getFileBytes(String filePath) async {
    // Implementation depends on how you're handling file reading
    // This is a placeholder
    throw UnimplementedError('File reading implementation needed');
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final supabase = Supabase.instance.client;
  return DatabaseService(supabase);
});
