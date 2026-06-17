import 'package:marcadores_mundial_app/core/errors/exceptions.dart';
import 'package:marcadores_mundial_app/domain/entities/channel.dart';
import 'package:marcadores_mundial_app/domain/repositories/channel_repository.dart';
import 'package:marcadores_mundial_app/data/models/channel_model.dart';
import 'package:marcadores_mundial_app/data/services/supabase_service.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  final SupabaseService _supabaseService;

  ChannelRepositoryImpl(this._supabaseService);

  @override
  Future<List<Channel>> fetchActiveChannels() async {
    try {
      final models = await _supabaseService.fetchActiveChannels();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<Channel>> fetchAllChannels() async {
    try {
      final models = await _supabaseService.fetchAllChannels();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Channel> createChannel(Channel channel) async {
    try {
      final model = ChannelModel(
        id: 0,
        name: channel.name,
        channelUrl: channel.channelUrl,
        logoUrl: channel.logoUrl,
        isActive: channel.isActive,
      );
      final created = await _supabaseService.createChannel(model.toJson());
      return created.toEntity();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Channel> updateChannel(Channel channel) async {
    try {
      final model = ChannelModel(
        id: channel.id,
        name: channel.name,
        channelUrl: channel.channelUrl,
        logoUrl: channel.logoUrl,
        isActive: channel.isActive,
      );
      final updated = await _supabaseService.updateChannel(channel.id, model.toJson());
      return updated.toEntity();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteChannel(int id) async {
    try {
      await _supabaseService.deleteChannel(id);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
