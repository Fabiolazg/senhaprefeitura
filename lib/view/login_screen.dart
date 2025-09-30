import 'package:flutter/material.dart';
import 'package:senhaprefeitura/services/auth_service.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? isAValidEmail(String? value) {
    if (value == null || value.isEmpty) return 'O campo de e-mail não pode estar vazio';
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value)) return 'Insira um e-mail válido';
    return null;
  }

  String? isAValidPassword(String? value) {
    if (value == null || value.isEmpty) return 'A senha não pode estar vazia';
    if (value.length < 6) return 'A senha deve conter pelo menos 6 caracteres';
    return null;
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, corrija os erros no formulário.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final user = await AuthService().login(email, password);

    setState(() => _isLoading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userEmail: user.email ?? '',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro no login. Verifique seu email e senha.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/imagens_flutter/fundo.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildInput(emailController, 'Email', Icons.email, isAValidEmail),
                  const SizedBox(height: 10),
                  _buildInput(passwordController, 'Senha', Icons.lock, isAValidPassword, obscure: true),
                  const SizedBox(height: 15),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1791d5)),
                    onPressed: _loginUser,
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 20),
                  // Botão Google
                  _googleButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, String? Function(String?) validator, {bool obscure = false}) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscure,
        decoration: InputDecoration(
          label: Text(label),
          icon: Icon(icon),
          hintText: 'Digite seu $label',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _googleButton() {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: () async {
          setState(() => _isLoading = true);
          try {
            final user = await AuthService().signInWithGoogle();
            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(userEmail: user.email ?? ''),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Erro no login com Google'), backgroundColor: Colors.redAccent),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao fazer login com Google: $e'), backgroundColor: Colors.redAccent),
            );
          } finally {
            setState(() => _isLoading = false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/imagens_flutter/google_logo.png', height: 20, width: 20),
            const SizedBox(width: 10),
            const Text("Entrar com Google", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}