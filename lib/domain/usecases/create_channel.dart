import 'package:marcadores_mundial_app/domain/entities/channel.dart';
import 'package:marcadores_mundial_app/domain/repositories/channel_repository.dart';

class CreateChannel {
  final ChannelRepository repository;
  CreateChannel(this.repository);

  Future<Channel> call(Channel channel) => repository.createChannel(channel);
}
