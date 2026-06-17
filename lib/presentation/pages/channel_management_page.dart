import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/domain/entities/channel.dart';
import 'package:marcadores_mundial_app/presentation/cubits/channel_management_cubit.dart';
import 'package:marcadores_mundial_app/presentation/widgets/confirm_dialog.dart';

class ChannelManagementPage extends StatefulWidget {
  const ChannelManagementPage({super.key});

  @override
  State<ChannelManagementPage> createState() => _ChannelManagementPageState();
}

class _ChannelManagementPageState extends State<ChannelManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChannelManagementCubit>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChannelManagementCubit, ChannelManagementState>(
      listener: (context, state) {
        if (state.success != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.success!),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
          context.read<ChannelManagementCubit>().clearMessages();
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
          context.read<ChannelManagementCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('Channel Management', 'Gestión de Canales')),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => context.read<ChannelManagementCubit>().loadAll(),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: FloatingActionButton.extended(
              onPressed: () => _showChannelForm(context, null),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.tr('Add Channel', 'Añadir Canal')),
            ),
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(ChannelManagementState state) {
    if (state.isLoading && state.channels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.channels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.live_tv_outlined, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('No channels yet', 'No hay canales aún'),
              style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showChannelForm(context, null),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.tr('Create first channel', 'Crear primer canal')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ChannelManagementCubit>().loadAll(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: state.channels.length,
        itemBuilder: (context, index) => _ChannelListItem(
          channel: state.channels[index],
          onEdit: () => _showChannelForm(context, state.channels[index]),
          onDelete: () => _confirmDelete(context, state.channels[index]),
          onToggle: (active) {
            context.read<ChannelManagementCubit>().update(
              Channel(
                id: state.channels[index].id,
                name: state.channels[index].name,
                channelUrl: state.channels[index].channelUrl,
                logoUrl: state.channels[index].logoUrl,
                isActive: active,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showChannelForm(BuildContext context, Channel? existing) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final urlCtrl = TextEditingController(text: existing?.channelUrl ?? '');
    final logoCtl = TextEditingController(text: existing?.logoUrl ?? '');
    var isActive = existing?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_rounded : Icons.add_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEditing
                              ? context.tr('Edit Channel', 'Editar Canal')
                              : context.tr('New Channel', 'Nuevo Canal'),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _formField(
                      context,
                      label: context.tr('Name *', 'Nombre *'),
                      controller: nameCtrl,
                      hint: context.tr('Channel name', 'Nombre del canal'),
                    ),
                    const SizedBox(height: 12),
                    _formField(
                      context,
                      label: context.tr('Stream URL *', 'URL del stream *'),
                      controller: urlCtrl,
                      hint: 'https://example.com/stream.m3u8',
                    ),
                    const SizedBox(height: 12),
                    _formField(
                      context,
                      label: context.tr('Logo URL', 'URL del logo'),
                      controller: logoCtl,
                      hint: 'https://example.com/logo.png',
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.tr('Active', 'Activo')),
                      value: isActive,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setSheetState(() => isActive = v),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (nameCtrl.text.isEmpty || urlCtrl.text.isEmpty) return;
                          final channel = Channel(
                            id: existing?.id ?? 0,
                            name: nameCtrl.text,
                            channelUrl: urlCtrl.text,
                            logoUrl: logoCtl.text.isNotEmpty ? logoCtl.text : null,
                            isActive: isActive,
                          );
                          Navigator.of(ctx).pop();
                          if (isEditing) {
                            context.read<ChannelManagementCubit>().update(channel);
                          } else {
                            context.read<ChannelManagementCubit>().create(channel);
                          }
                        },
                        icon: Icon(isEditing
                            ? Icons.save_rounded
                            : Icons.add_rounded),
                        label: Text(
                          isEditing
                              ? context.tr('Save Changes', 'Guardar Cambios')
                              : context.tr('Create Channel', 'Crear Canal'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textLight,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _formField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, Channel channel) {
    ConfirmDialog.show(
      context,
      title: context.tr('Delete Channel', 'Eliminar Canal'),
      message: context.tr(
        'Are you sure you want to delete this channel?',
        '¿Estás seguro de eliminar este canal?',
      ),
      confirmLabel: context.tr('Delete', 'Eliminar'),
      cancelLabel: context.tr('Cancel', 'Cancelar'),
      icon: Icons.live_tv_rounded,
      onConfirm: () => context.read<ChannelManagementCubit>().delete(channel.id),
    );
  }
}

class _ChannelListItem extends StatelessWidget {
  final Channel channel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _ChannelListItem({
    required this.channel,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.bgCard : Colors.white,
          border: !channel.isActive
              ? Border.all(color: Colors.grey.withOpacity(0.3))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: channel.logoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: channel.logoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.live_tv_rounded,
                                size: 24, color: Colors.grey),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.live_tv_rounded,
                                size: 24, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.live_tv_rounded,
                              size: 24, color: AppColors.primary),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(channel.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(channel.channelUrl,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Switch(
                value: channel.isActive,
                activeColor: AppColors.primary,
                onChanged: onToggle,
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                onPressed: onEdit,
                color: AppColors.primary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, size: 20),
                onPressed: onDelete,
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
