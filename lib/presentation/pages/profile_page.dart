import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/presentation/cubits/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) {
          return const Center(child: Text('No hay sesión activa'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              child: Text(
                '${user.nombre?.isNotEmpty == true ? user.nombre![0] : ''}${user.apellido?.isNotEmpty == true ? user.apellido![0] : ''}',
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${user.nombre ?? ''} ${user.apellido ?? ''}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(user.role.toUpperCase(), style: const TextStyle(fontSize: 12)),
              backgroundColor: user.isAdmin ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
            ),
            const SizedBox(height: 24),
            _infoTile(Icons.email_outlined, 'Email', user.email),
            _infoTile(Icons.phone_outlined, 'Teléfono', user.telefono ?? ''),
            _infoTile(Icons.numbers_outlined, 'Edad', user.edad?.toString() ?? ''),
            _infoTile(Icons.person_outline, 'Nombre', user.nombre ?? ''),
            _infoTile(Icons.person_outline, 'Apellido', user.apellido ?? ''),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => context.read<AuthCubit>().signOut(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
