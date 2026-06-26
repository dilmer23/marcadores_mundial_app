import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/presentation/cubits/auth_cubit.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Correo')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.incompleteProfile || state.status == AuthStatus.authenticated) {
            // Will be handled by AppRoot's BlocBuilder
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_unread, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  'Revisa tu correo electrónico',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Te hemos enviado un enlace de verificación. Revisa tu bandeja de entrada y haz clic en el enlace para activar tu cuenta.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Si no lo encuentras, revisa la carpeta de spam.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (state.successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      state.successMessage!,
                      style: const TextStyle(color: Colors.green, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => context.read<AuthCubit>().resendConfirmationEmail(),
                    icon: state.isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: const Text('Reenviar correo'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<AuthCubit>().refreshStatus(),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Ya verifiqué mi correo'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<AuthCubit>().signOut(),
                  child: const Text('Cerrar sesión'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
