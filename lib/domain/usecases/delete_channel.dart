import 'package:marcadores_mundial_app/domain/repositories/channel_repository.dart';

class DeleteChannel {
  final ChannelRepository repository;
  DeleteChannel(this.repository);

  Future<void> call(int id) => repository.deleteChannel(id);
}
