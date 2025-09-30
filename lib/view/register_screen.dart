import 'package:flutter/material.dart';
import 'package:senhaprefeitura/services/auth_service.dart';
import 'home_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? isAValidEmail(String? value) {
    if (value == null || value.isEmpty) return 'O campo de e-mail não pode estar vazio';
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value)) return 'Insira um e-mail válido';
    return null;
  }

  String? isAValidUserName(String? value) {
    if (value == null || value.isEmpty) return 'O campo nome não pode estar vazio';
    return null;
  }

  String? isAValidPassword(String? value) {
    if (value == null || value.isEmpty) return 'A senha não pode estar vazia';
    if (value.length < 6) return 'A senha deve conter pelo menos 6 caracteres';
    if (!RegExp(r'^(?=.*[0-9]).+$').hasMatch(value)) return 'A senha deve conter pelo menos 1 número';
    return null;
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, corrija os erros no formulário.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final user = await AuthService().register(email, password, usernameController.text.trim());

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(userEmail: user.email ?? ''),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao cadastrar'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
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
                  _buildInput(usernameController, 'Nome', Icons.person, isAValidUserName),
                  const SizedBox(height: 10),
                  _buildInput(passwordController, 'Senha', Icons.lock, isAValidPassword, obscure: true),
                  const SizedBox(height: 15),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF595D4)),
                    onPressed: _registerUser,
                    child: const Text('Cadastrar'),
                  ),
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
}