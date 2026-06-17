import 'package:marcadores_mundial_app/domain/entities/channel.dart';

abstract class ChannelRepository {
  Future<List<Channel>> fetchActiveChannels();
  Future<List<Channel>> fetchAllChannels();
  Future<Channel> createChannel(Channel channel);
  Future<Channel> updateChannel(Channel channel);
  Future<void> deleteChannel(int id);
}
