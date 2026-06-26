import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/presentation/cubits/auth_cubit.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  late TabController _tabCtrl;
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _resetEmailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePass = true;
  bool _showReset = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _resetEmailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unconfirmed || state.status == AuthStatus.incompleteProfile || state.status == AuthStatus.authenticated) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (_showReset) return _buildResetPassword(context, state);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                TabBar(
                  controller: _tabCtrl,
                  tabs: [
                    Tab(text: 'Iniciar Sesión'),
                    Tab(text: 'Registrarse'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 380,
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildLoginForm(context, state),
                      _buildRegisterForm(context, state),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _showReset = true),
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context, AuthState state) {
    return Column(
      children: [
        TextField(
          controller: _loginEmailCtrl,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _loginPassCtrl,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
          obscureText: _obscurePass,
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
            onPressed: state.isLoading ? null : () => _login(context),
            child: state.isLoading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context, AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextField(
            controller: _regEmailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regPassCtrl,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            obscureText: _obscurePass,
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
              onPressed: state.isLoading ? null : () => _register(context),
              child: state.isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetPassword(BuildContext context, AuthState state) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.lock_reset, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text('Restablecer Contraseña', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Te enviaremos un enlace para restablecer tu contraseña.'),
          const SizedBox(height: 24),
          TextField(
            controller: _resetEmailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          if (state.error != null) ...[
            const SizedBox(height: 8),
            Text(state.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          if (state.successMessage != null) ...[
            const SizedBox(height: 8),
            Text(state.successMessage!, style: const TextStyle(color: Colors.green, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: state.isLoading ? null : () => _resetPassword(context),
              child: state.isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enviar Enlace'),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _showReset = false;
              _resetEmailCtrl.clear();
            }),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  void _login(BuildContext context) {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) return;
    context.read<AuthCubit>().signIn(email, pass);
  }

  void _register(BuildContext context) {
    final email = _regEmailCtrl.text.trim();
    final pass = _regPassCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) return;
    context.read<AuthCubit>().signUp(email, pass);
  }

  void _resetPassword(BuildContext context) {
    final email = _resetEmailCtrl.text.trim();
    if (email.isEmpty) return;
    context.read<AuthCubit>().sendPasswordReset(email);
  }
}
