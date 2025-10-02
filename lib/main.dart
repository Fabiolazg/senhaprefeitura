import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:senhaprefeitura/view/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // ⚠️ Substitua pelos valores reais do Firebase Web do seu projeto
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyACI8quiJkEsJ_iIx_6W8aeT0WGUGO0bbU",
        authDomain: "senha-prefeitura.firebaseapp.com",
        projectId: "senha-prefeitura",
        storageBucket: "senha-prefeitura.firebasestorage.app",
        messagingSenderId: "960847308061",
        appId: "1:960847308061:android:02a875a3935516af81edf4",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Senhas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
        home : const HomePage(userEmail: 'zutionfabiola@gmail.com'),
    );
  }
}
