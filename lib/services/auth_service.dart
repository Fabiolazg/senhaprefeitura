import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //REGISTRO
  Future<User?> register(String email, String password, String username) async{
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password);
      await result.user!.updateDisplayName(username);
      print('Usuário cadastrado: ${result.user!.uid}');
      return result.user;
    } catch (e) {
      print("Erro no registro: $e");
      return null;
    }
  }

  //LOGIN
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Erro no login: $e");
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Inicia o processo de login com Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("Login com Google cancelado");
        return null; // O usuário cancelou o login
      }

      // Obtém a autenticação do Google
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Cria uma credencial para autenticar com Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Faz login com a credencial no Firebase
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Erro no login com Google: $e");
      return null;
    }
  }

}
