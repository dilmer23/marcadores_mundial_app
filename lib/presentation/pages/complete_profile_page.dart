import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/presentation/cubits/auth_cubit.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _aceptaPoliticas = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar Perfil')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Completa tu perfil',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Estos datos son necesarios para usar la aplicación.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 2) return 'Mínimo 2 caracteres';
                      if (v.trim().length > 50) return 'Máximo 50 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apellidoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Apellido *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 2) return 'Mínimo 2 caracteres';
                      if (v.trim().length > 50) return 'Máximo 50 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telefonoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono *',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Obligatorio';
                      if (!RegExp(r'^\d{7,15}$').hasMatch(v.trim())) return 'Debe tener entre 7 y 15 dígitos';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _edadCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Edad *',
                      prefixIcon: Icon(Icons.numbers_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Obligatorio';
                      final edad = int.tryParse(v.trim());
                      if (edad == null) return 'Debe ser un número';
                      if (edad < 18) return 'Debes ser mayor de 18 años';
                      if (edad > 120) return 'Edad no válida';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _aceptaPoliticas,
                        onChanged: (v) => setState(() => _aceptaPoliticas = v ?? false),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _aceptaPoliticas = !_aceptaPoliticas),
                          child: const Text('Acepto las políticas y términos de uso'),
                        ),
                      ),
                    ],
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 8),
                    Text(state.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _save,
                      child: state.isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Guardar Perfil', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptaPoliticas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar las políticas y términos')),
      );
      return;
    }
    context.read<AuthCubit>().completeProfile(
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      edad: int.parse(_edadCtrl.text.trim()),
      aceptaPoliticas: true,
    );
  }
}
