import 'package:marcadores_mundial_app/domain/entities/channel.dart';
import 'package:marcadores_mundial_app/domain/repositories/channel_repository.dart';

class FetchAllChannels {
  final ChannelRepository repository;
  FetchAllChannels(this.repository);

  Future<List<Channel>> call() => repository.fetchAllChannels();
}
