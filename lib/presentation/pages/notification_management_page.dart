import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/domain/entities/notification_payload.dart';
import 'package:marcadores_mundial_app/presentation/cubits/notification_cubit.dart';

class NotificationManagementPage extends StatefulWidget {
  const NotificationManagementPage({super.key});

  @override
  State<NotificationManagementPage> createState() => _NotificationManagementPageState();
}

class _NotificationManagementPageState extends State<NotificationManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _userIdCtrl = TextEditingController();
  final _minAgeCtrl = TextEditingController();
  final _maxAgeCtrl = TextEditingController();

  String _targetType = 'all';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _userIdCtrl.dispose();
    _minAgeCtrl.dispose();
    _maxAgeCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = NotificationPayload(
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      targetType: _targetType,
      userId: _targetType == 'user' ? _userIdCtrl.text.trim() : null,
      minAge: _targetType == 'age_range' ? int.tryParse(_minAgeCtrl.text) : null,
      maxAge: _targetType == 'age_range' ? int.tryParse(_maxAgeCtrl.text) : null,
    );

    context.read<NotificationCubit>().send(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Notificación')),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bodyCtrl,
                    decoration: const InputDecoration(labelText: 'Mensaje', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Destinatarios', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 8),
                  _targetOption('Todos los usuarios', 'all'),
                  _targetOption('Por rango de edad', 'age_range'),
                  if (_targetType == 'age_range') ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minAgeCtrl,
                            decoration: const InputDecoration(labelText: 'Edad min', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) => _targetType == 'age_range' && (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _maxAgeCtrl,
                            decoration: const InputDecoration(labelText: 'Edad max', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) => _targetType == 'age_range' && (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                  _targetOption('Usuario específico', 'user'),
                  if (_targetType == 'user') ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _userIdCtrl,
                      decoration: const InputDecoration(labelText: 'ID de usuario', border: OutlineInputBorder()),
                      validator: (v) => _targetType == 'user' && (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state.isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Enviar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  if (state.result != null && state.result!.isSuccess) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: AppColors.success.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text('Enviadas: ${state.result!.sent}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text('Fallidas: ${state.result!.failed}', style: const TextStyle(color: AppColors.textMuted)),
                            if (state.result!.cleaned > 0)
                              Text('Tokens limpiados: ${state.result!.cleaned}', style: const TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _targetOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      groupValue: _targetType,
      onChanged: (v) => setState(() => _targetType = v!),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
