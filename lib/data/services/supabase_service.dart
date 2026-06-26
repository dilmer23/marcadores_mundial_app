import 'dart:typed_data';
import 'package:supabase/supabase.dart';
import 'package:marcadores_mundial_app/core/errors/exceptions.dart';
import 'package:marcadores_mundial_app/data/models/user_profile_model.dart';
import 'package:marcadores_mundial_app/data/models/channel_model.dart';
import 'package:marcadores_mundial_app/data/models/banner_model.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  bool get hasSession => _client.auth.currentSession != null;
  String? get currentUserId => _client.auth.currentUser?.id;
  String? get currentUserEmail => _client.auth.currentUser?.email;
  User? get currentUser => _client.auth.currentUser;

  // ── Auth ──

  Future<void> signUp(String email, String password) async {
    final res = await _client.auth.signUp(email: email, password: password);
    if (res.user == null) {
      throw const ServerException('Error al crear la cuenta');
    }
  }

  Future<UserProfileModel> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    final uid = currentUserId;
    if (uid == null) throw const ServerException('Error al iniciar sesión');
    return _fetchOrCreateProfile(uid, email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> resendConfirmationEmail(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  Future<bool> isEmailConfirmed() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;
    return user.emailConfirmedAt != null;
  }

  Future<UserProfileModel?> getProfile(String userId) async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (res == null) return null;
      return UserProfileModel.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<UserProfileModel> completeProfile({
    required String userId,
    required String email,
    required String nombre,
    required String apellido,
    required String telefono,
    required int edad,
    required bool aceptaPoliticas,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final data = <String, dynamic>{
      'id': userId,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'edad': edad,
      'acepta_politicas': aceptaPoliticas,
      'role': 'user',
      'created_at': now,
      'updated_at': now,
    };
    final res = await _client
        .from('profiles')
        .upsert(data)
        .select()
        .maybeSingle();
    if (res == null) throw const ServerException('Error al guardar el perfil');
    return UserProfileModel.fromJson(res as Map<String, dynamic>);
  }

  Future<UserProfileModel> _fetchOrCreateProfile(String uid, String email) async {
    var profile = await getProfile(uid);
    if (profile == null) {
      final now = DateTime.now().toUtc().toIso8601String();
      final data = <String, dynamic>{
        'id': uid,
        'email': email,
        'role': 'user',
        'created_at': now,
        'updated_at': now,
      };
      final res = await _client
          .from('profiles')
          .upsert(data)
          .select()
          .maybeSingle();
      if (res == null) throw const ServerException('Error al crear perfil');
      profile = UserProfileModel.fromJson(res as Map<String, dynamic>);
    }
    return profile;
  }

  // ── Banner Storage ──

  Future<String> uploadBannerImage(List<int> bytes, String fileName) async {
    final path = 'banners/$fileName';
    await _client.storage.from('banners').uploadBinary(
      path,
      Uint8List.fromList(bytes),
    );
    return _client.storage.from('banners').getPublicUrl(path);
  }

  // ── Channels ──

  Future<List<ChannelModel>> fetchActiveChannels() async {
    final res = await _client
        .from('channels')
        .select()
        .eq('is_active', true);
    return (res as List)
        .map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChannelModel>> fetchAllChannels() async {
    final res = await _client
        .from('channels')
        .select()
        .order('name', ascending: true);
    return (res as List)
        .map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChannelModel> createChannel(Map<String, dynamic> data) async {
    final res = await _client.from('channels').insert(data).select().single();
    return ChannelModel.fromJson(res as Map<String, dynamic>);
  }

  Future<ChannelModel> updateChannel(int id, Map<String, dynamic> data) async {
    final res = await _client
        .from('channels')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return ChannelModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteChannel(int id) async {
    await _client.from('channels').delete().eq('id', id);
  }

  // ── Banners ──

  Future<List<BannerModel>> fetchActiveBanners() async {
    final res = await _client
        .from('banners')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);
    return (res as List)
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BannerModel>> fetchAllBanners() async {
    final res = await _client
        .from('banners')
        .select()
        .order('display_order', ascending: true);
    return (res as List)
        .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BannerModel> createBanner(Map<String, dynamic> data) async {
    final res = await _client.from('banners').insert(data).select().single();
    return BannerModel.fromJson(res as Map<String, dynamic>);
  }

  Future<BannerModel> updateBanner(int id, Map<String, dynamic> data) async {
    final res = await _client
        .from('banners')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return BannerModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteBanner(int id) async {
    await _client.from('banners').delete().eq('id', id);
  }
}
