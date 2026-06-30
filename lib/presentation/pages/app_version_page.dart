import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/data/services/supabase_service.dart';

class AppVersionManagementPage extends StatefulWidget {
  const AppVersionManagementPage({super.key});

  @override
  State<AppVersionManagementPage> createState() => _AppVersionManagementPageState();
}

class _AppVersionManagementPageState extends State<AppVersionManagementPage> {
  final _versionCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _mandatory = false;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _versionCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final service = SupabaseService(Supabase.instance.client);
      final data = await service.getAppVersion();
      if (data != null && mounted) {
        _versionCtrl.text = data['version'] as String? ?? '';
        _urlCtrl.text = data['download_url'] as String? ?? '';
        _mandatory = data['mandatory'] == true;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final service = SupabaseService(Supabase.instance.client);
      await service.updateAppVersion({
        'version': _versionCtrl.text.trim(),
        'download_url': _urlCtrl.text.trim(),
        'mandatory': _mandatory,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('Saved', 'Guardado'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('Error', 'Error')}: $e')),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('App Version', 'Versión App')),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_rounded, size: 20),
            label: Text(context.tr('Save', 'Guardar')),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('Version Info', 'Info de Versión'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _versionCtrl,
                          decoration: InputDecoration(
                            labelText: context.tr('Version number', 'Número de versión'),
                            hintText: '1.0.1',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: isDark ? AppColors.bgCard : Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _urlCtrl,
                          decoration: InputDecoration(
                            labelText: context.tr('Download URL', 'URL de descarga'),
                            hintText: 'https://github.com/.../releases',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: isDark ? AppColors.bgCard : Colors.grey[100],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.tr('Mandatory update', 'Actualización obligatoria')),
                          subtitle: Text(
                            context.tr('Users must update to continue', 'Los usuarios deben actualizar para continuar'),
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          value: _mandatory,
                          activeColor: AppColors.error,
                          onChanged: (v) => setState(() => _mandatory = v),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
