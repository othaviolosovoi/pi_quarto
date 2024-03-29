import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthException implements Exception {
  String message;
  AuthException(this.message);
}


class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? usuario) {
      usuario = (usuario == null) ? null : usuario;
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  registrar(String email, String senha) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if(e.code == 'weak-password') {
        throw AuthException('Senha muito fraca');
      } else if (e.code =='email-already-in-use') {
          throw AuthException('Email já cadastrado');
      }
    }
  }

  login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if(e.code == 'user-not-found') {
        throw AuthException('Email não encontrado. Cadastre-se');
      } else if (e.code =='wrong-password') {
          throw AuthException('Senha incorreta. Tente novamente');
      }
    }
  }

   Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}