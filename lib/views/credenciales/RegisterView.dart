import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AuthLayout.dart';

class Registerview extends StatelessWidget {
  var faInstance = FirebaseAuth.instance;
  late BuildContext miContext;
  TextEditingController userController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController repasswordController = new TextEditingController();

  void funClickCancelar() async {
    Navigator.popAndPushNamed(miContext, "/LoginView");
  }

  Future<void> funClickAceptar() async {
    if (repasswordController.text != passwordController.text) {
      print("LAS CONTRASEÑAS NO COINCIDEN");
    } else {
      try {
        final credencial = await faInstance.createUserWithEmailAndPassword(
          email: userController.text,
          password: passwordController.text,
        );

        if (credencial.user != null && miContext.mounted) {
          Navigator.popAndPushNamed(miContext, "/OnBoardinView");
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    miContext = context;

    return AuthLayout(
      eyebrow: 'Empieza a aprender',
      title: 'Crea tu cuenta',
      description: 'Guarda tus avances y construye tu propio vocabulario.',
      children: [
        TextField(
          controller: userController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          obscureText: true,
          controller: repasswordController,
          decoration: const InputDecoration(
            labelText: 'Repite la contraseña',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: funClickAceptar,
            child: const Text('Crear cuenta'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: funClickCancelar,
            child: const Text('Volver a iniciar sesión'),
          ),
        ),
      ],
    );
  }
}
