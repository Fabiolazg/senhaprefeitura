import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:senhaprefeitura/view/login_screen.dart';
import 'package:senhaprefeitura/view/register_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/imagens_flutter/fundo.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'BEM VINDO A SENHAS DA PREFEITURA',
              style: GoogleFonts.robotoSlab(
                textStyle: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 2,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Aqui você pode gerenciar suas senhas da identidade',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/imagens_flutter/logo.png',
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Cadastro'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Color(0xFFF595D4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Login'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Color(0xFF1791d5),
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}