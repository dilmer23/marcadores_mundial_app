import 'package:marcadores_mundial_app/domain/entities/channel.dart';
import 'package:marcadores_mundial_app/domain/repositories/channel_repository.dart';

class FetchActiveChannels {
  final ChannelRepository repository;
  FetchActiveChannels(this.repository);

  Future<List<Channel>> call() => repository.fetchActiveChannels();
}
