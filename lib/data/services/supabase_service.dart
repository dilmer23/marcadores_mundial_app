import 'dart:typed_data';
import 'package:supabase/supabase.dart';
import 'package:marcadores_mundial_app/data/models/channel_model.dart';
import 'package:marcadores_mundial_app/data/models/banner_model.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  Future<void> _ensureSignedIn() async {
    if (_client.auth.currentSession == null) {
      try {
        await _client.auth.signInAnonymously();
      } catch (_) {
        // Anonymous sign-in may fail if disabled in Supabase;
        // storage policies also allow anon uploads as fallback.
      }
    }
  }

  Future<String> uploadBannerImage(List<int> bytes, String fileName) async {
    await _ensureSignedIn();
    final path = 'banners/$fileName';
    await _client.storage.from('banners').uploadBinary(
      path,
      Uint8List.fromList(bytes),
    );
    return _client.storage.from('banners').getPublicUrl(path);
  }

  Future<List<ChannelModel>> fetchActiveChannels() async {
    final response = await _client
        .from('channels')
        .select('*')
        .eq('is_active', true);

    final data = response as List<dynamic>;
    return data
        .map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChannelModel>> fetchAllChannels() async {
    final response = await _client
        .from('channels')
        .select('*')
        .order('name', ascending: true);

    final data = response as List<dynamic>;
    return data
        .map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChannelModel> createChannel(Map<String, dynamic> data) async {
    final response = await _client.from('channels').insert(data).select().single();
    return ChannelModel.fromJson(response as Map<String, dynamic>);
  }

  Future<ChannelModel> updateChannel(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('channels')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return ChannelModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteChannel(int id) async {
    await _client.from('channels').delete().eq('id', id);
  }

  Future<List<BannerModel>> fetchActiveBanners() async {
    final response = await _client
        .from('banners')
        .select('*')
        .eq('is_active', true)
        .order('display_order', ascending: true);

    final data = response as List<dynamic>;
    return data
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BannerModel>> fetchAllBanners() async {
    final response = await _client
        .from('banners')
        .select('*')
        .order('display_order', ascending: true);

    final data = response as List<dynamic>;
    return data
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BannerModel> createBanner(Map<String, dynamic> data) async {
    final response = await _client.from('banners').insert(data).select().single();
    return BannerModel.fromJson(response as Map<String, dynamic>);
  }

  Future<BannerModel> updateBanner(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('banners')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return BannerModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteBanner(int id) async {
    await _client.from('banners').delete().eq('id', id);
  }
}
