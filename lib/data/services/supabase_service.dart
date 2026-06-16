import 'package:supabase/supabase.dart';
import 'package:marcadores_mundial_app/data/models/channel_model.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

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
}
