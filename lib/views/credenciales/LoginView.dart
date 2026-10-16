import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../AppRoutes.dart';

class Loginview extends StatelessWidget{
  var faInstance = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late BuildContext miContext;
  TextEditingController userController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  // Inicializa el SDK una sola vez, incluso si se vuelve a abrir esta pantalla.
  // Cada plataforma usa su configuración nativa (Android o Info.plist en iOS).
  static final Future<void> _googleInit = GoogleSignIn.instance.initialize();

  Future<void> funClickGoogle() async {
    // Conserva el contexto de este clic para comprobar si la pantalla sigue abierta.
    final context = miContext;
    try {
      // 1. Espera a que el SDK de Google esté preparado.
      await _googleInit;

      // 2. Abre el acceso nativo de Google para elegir una cuenta.
      // El paquete se encarga de usar el flujo de Android o el de iOS.
      final cuenta = await GoogleSignIn.instance.authenticate();

      // 3. Obtiene el token de identidad que demuestra quién es el usuario.
      final googleAuth = cuenta.authentication;

      // 4. Convierte el token de Google en una credencial para Firebase.
      final credencial = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 5. Inicia sesión en Firebase; si es su primer acceso, crea su usuario Auth.
      // El perfil de Firestore se comprueba por separado en OnboardingView.
      await faInstance.signInWithCredential(credencial);

      // 6. Revisa el perfil y navega a CrearPerfilView o HomeView.
      if (!context.mounted) return;
      Navigator.popAndPushNamed(context, AppRoutes.onboarding);
    } on GoogleSignInException catch (e) {
      // Cerrar el selector de cuentas es una cancelación normal.
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo acceder con Google')),
      );
    } on FirebaseAuthException catch (e) {
      // Google pudo autenticar, pero Firebase rechazó el inicio de sesión.
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error al iniciar sesión')),
      );
    }
  }

  void funClickLogin() async {
    final context = miContext;
    String usuario = userController.text;
    String pass = passwordController.text;

    try {
      await faInstance.signInWithEmailAndPassword(
        email: usuario,
        password: pass,
      );
      // Tras autenticar, comprueba el perfil y abre la pantalla correspondiente.
      if (!context.mounted) return;
      Navigator.popAndPushNamed(context, AppRoutes.onboarding);
    } on FirebaseAuthException catch (e) {
      print("----------------->>>>>> " + e.toString());
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  void funClickRegistro() {
    Navigator.popAndPushNamed(miContext, "/RegisterView");
  }


  @override
  Widget build(BuildContext context) {
    miContext = context;

    return Scaffold(
      appBar: new AppBar(title: new Text("KJSTUDY")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "LOGIN",
            style: TextStyle(fontSize: 30, backgroundColor: Colors.red),
          ),
          TextField(
            controller: userController,
            decoration: InputDecoration(hintText: "Usuario"),
          ),
          TextField(
            obscureText: true,
            controller: passwordController,
            decoration: InputDecoration(hintText: "Contraseña"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: funClickLogin, child: Text("Login")),
              TextButton(onPressed: funClickRegistro, child: Text("Registrarse"),
              ),
            ],
          ),
          TextButton(
            onPressed: funClickGoogle,
            child: const Text('Continuar con Google'),
          ),
        ],
      ),
    );
  }
}
