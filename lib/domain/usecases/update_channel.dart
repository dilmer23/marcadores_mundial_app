import 'package:marcadores_mundial_app/domain/entities/channel.dart';
import 'package:marcadores_mundial_app/domain/repositories/channel_repository.dart';

class UpdateChannel {
  final ChannelRepository repository;
  UpdateChannel(this.repository);

  Future<Channel> call(Channel channel) => repository.updateChannel(channel);
}
