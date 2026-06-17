import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/domain/entities/banner.dart';
import 'package:marcadores_mundial_app/presentation/cubits/banner_management_cubit.dart';
import 'package:marcadores_mundial_app/presentation/widgets/confirm_dialog.dart';

class BannerManagementPage extends StatefulWidget {
  const BannerManagementPage({super.key});

  @override
  State<BannerManagementPage> createState() => _BannerManagementPageState();
}

class _BannerManagementPageState extends State<BannerManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<BannerManagementCubit>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BannerManagementCubit, BannerManagementState>(
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
          context.read<BannerManagementCubit>().clearMessages();
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
          context.read<BannerManagementCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('Banner Management', 'Gestión de Banners')),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => context.read<BannerManagementCubit>().loadAll(),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: FloatingActionButton.extended(
              onPressed: () => _showBannerForm(context, null),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.tr('Add Banner', 'Añadir Banner')),
            ),
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(BannerManagementState state) {
    if (state.isLoading && state.banners.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.banners.isEmpty) {
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
              child: const Icon(Icons.image_outlined, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('No banners yet', 'No hay banners aún'),
              style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showBannerForm(context, null),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.tr('Create first banner', 'Crear primer banner')),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BannerManagementCubit>().loadAll(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: state.banners.length,
        itemBuilder: (context, index) => _BannerListItem(
          banner: state.banners[index],
          onEdit: () => _showBannerForm(context, state.banners[index]),
          onDelete: () => _confirmDelete(context, state.banners[index]),
          onToggle: (active) {
            context.read<BannerManagementCubit>().update(
              BannerAd(
                id: state.banners[index].id,
                imageUrl: state.banners[index].imageUrl,
                linkUrl: state.banners[index].linkUrl,
                title: state.banners[index].title,
                isActive: active,
                displayOrder: state.banners[index].displayOrder,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBannerForm(BuildContext context, BannerAd? existing) {
    final isEditing = existing != null;
    final imageCtrl = TextEditingController(text: existing?.imageUrl ?? '');
    final linkCtrl = TextEditingController(text: existing?.linkUrl ?? '');
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final orderCtrl = TextEditingController(
        text: existing?.displayOrder.toString() ?? '0');
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
                              ? context.tr('Edit Banner', 'Editar Banner')
                              : context.tr('New Banner', 'Nuevo Banner'),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _formField(
                            context,
                            label: context.tr('Image URL *', 'URL de imagen *'),
                            controller: imageCtrl,
                            hint: 'https://example.com/banner.jpg',
                          ),
                        ),
                        const SizedBox(width: 8),
                        BlocBuilder<BannerManagementCubit, BannerManagementState>(
                          buildWhen: (prev, curr) =>
                              prev.isUploading != curr.isUploading ||
                              prev.uploadProgress != curr.uploadProgress,
                          builder: (ctx2, cubitState) {
                            final uploading = cubitState.isUploading;
                            final progress = cubitState.uploadProgress;
                            return SizedBox(
                              width: 48,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: uploading
                                    ? null
                                    : () async {
                                        final url = await context
                                            .read<BannerManagementCubit>()
                                            .uploadImage();
                                        if (url != null) {
                                          setSheetState(() => imageCtrl.text = url);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.textLight,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: EdgeInsets.zero,
                                ),
                                child: uploading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircularProgressIndicator(
                                              value: progress > 0
                                                  ? progress / 100.0
                                                  : null,
                                              strokeWidth: 2,
                                              color: AppColors.textLight,
                                            ),
                                            if (progress > 0)
                                              Text(
                                                '$progress%',
                                                style: const TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textLight,
                                                ),
                                              ),
                                          ],
                                        ),
                                      )
                                    : const Icon(Icons.image_rounded, size: 22),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    BlocBuilder<BannerManagementCubit, BannerManagementState>(
                      buildWhen: (prev, curr) => prev.isUploading != curr.isUploading,
                      builder: (ctx2, cubitState) {
                        if (!cubitState.isUploading) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: cubitState.uploadProgress > 0
                                    ? cubitState.uploadProgress / 100.0
                                    : null,
                                backgroundColor: AppColors.primary.withOpacity(0.15),
                                color: AppColors.primary,
                                minHeight: 4,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${cubitState.uploadProgress}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _formField(
                      context,
                      label: context.tr('Link URL', 'URL de enlace'),
                      controller: linkCtrl,
                      hint: context.tr('matches, standings, https://...', 'partidos, clasificacion, https://...'),
                    ),
                    const SizedBox(height: 12),
                    _formField(
                      context,
                      label: context.tr('Title', 'Título'),
                      controller: titleCtrl,
                      hint: context.tr('Sponsor name', 'Nombre del patrocinador'),
                    ),
                    const SizedBox(height: 12),
                    _formField(
                      context,
                      label: context.tr('Display Order', 'Orden'),
                      controller: orderCtrl,
                      hint: '0',
                      keyboardType: TextInputType.number,
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
                          if (imageCtrl.text.isEmpty) return;
                          final banner = BannerAd(
                            id: existing?.id ?? 0,
                            imageUrl: imageCtrl.text,
                            linkUrl: linkCtrl.text.isNotEmpty
                                ? linkCtrl.text
                                : null,
                            title: titleCtrl.text.isNotEmpty
                                ? titleCtrl.text
                                : null,
                            isActive: isActive,
                            displayOrder:
                                int.tryParse(orderCtrl.text) ?? 0,
                          );
                          Navigator.of(ctx).pop();
                          if (isEditing) {
                            context
                                .read<BannerManagementCubit>()
                                .update(banner);
                          } else {
                            context
                                .read<BannerManagementCubit>()
                                .create(banner);
                          }
                        },
                        icon: Icon(isEditing
                            ? Icons.save_rounded
                            : Icons.add_rounded),
                        label: Text(
                          isEditing
                              ? context.tr('Save Changes', 'Guardar Cambios')
                              : context.tr('Create Banner', 'Crear Banner'),
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

  void _confirmDelete(BuildContext context, BannerAd banner) {
    ConfirmDialog.show(
      context,
      title: context.tr('Delete Banner', 'Eliminar Banner'),
      message: context.tr(
        'Are you sure you want to delete this banner?',
        '¿Estás seguro de eliminar este banner?',
      ),
      confirmLabel: context.tr('Delete', 'Eliminar'),
      cancelLabel: context.tr('Cancel', 'Cancelar'),
      onConfirm: () => context.read<BannerManagementCubit>().delete(banner.id),
    );
  }
}

class _BannerListItem extends StatelessWidget {
  final BannerAd banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _BannerListItem({
    required this.banner,
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
          border: !banner.isActive
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 120,
                      color: Colors.grey[800],
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.broken_image_rounded,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (!banner.isActive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Inactive',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (banner.title != null)
                          Text(banner.title!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                        if (banner.linkUrl != null)
                          Text(banner.linkUrl!,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        Text('Order: ${banner.displayOrder}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: banner.isActive,
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
          ],
        ),
      ),
    );
  }
}
