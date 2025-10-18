// lib/screens/auth_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  var _isLogin = true;
  var _isLoading = false;
  String _userEmail = '';
  String _userPassword = '';
  String _displayName = ''; // ✅ NOU

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          // ✅ LOGIN
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _userEmail.trim(),
            password: _userPassword.trim(),
          );

          // Actualizează last login
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await _userService.updateLastLogin(user.uid);
          }
        } else {
          // ✅ SIGN UP
          final userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _userEmail.trim(),
            password: _userPassword.trim(),
          );

          // Creează profilul user-ului
          if (userCredential.user != null) {
            await _userService.createUserProfile(
              uid: userCredential.user!.uid,
              email: _userEmail.trim(),
              displayName: _displayName.trim(),
            );

            // Setează display name în Firebase Auth
            await userCredential.user!.updateDisplayName(_displayName.trim());
          }
        }
      } on FirebaseAuthException catch (err) {
        var message = 'A apărut o eroare, vă rugăm verificați datele.';

        // Mesaje user-friendly
        switch (err.code) {
          case 'email-already-in-use':
            message = 'Acest email este deja folosit.';
            break;
          case 'weak-password':
            message = 'Parola este prea slabă.';
            break;
          case 'user-not-found':
            message = 'Nu există cont cu acest email.';
            break;
          case 'wrong-password':
            message = 'Parolă incorectă.';
            break;
          default:
            if (err.message != null) {
              message = err.message!;
            }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      } catch (err) {
        if (kDebugMode) {
          print(err);
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF7),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Icon(
                  Icons.auto_stories,
                  size: 100,
                  color: Colors.brown[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'Sonant Reader',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cititor inteligent de cărți',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 40),

                // Card cu formular
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _isLogin ? 'Autentificare' : 'Creare cont',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ✅ Display Name (doar la Sign Up)
                          if (!_isLogin) ...[
                            TextFormField(
                              key: const ValueKey('displayName'),
                              validator: (value) {
                                if (value == null || value.trim().length < 2) {
                                  return 'Numele trebuie să conțină cel puțin 2 caractere.';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Nume afișat',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: 'ex: Ion Popescu',
                              ),
                              onSaved: (value) {
                                _displayName = value!;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email
                          TextFormField(
                            key: const ValueKey('email'),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Vă rugăm introduceți o adresă de email validă.';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Adresă de email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onSaved: (value) {
                              _userEmail = value!;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            key: const ValueKey('password'),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Parola trebuie să conțină cel puțin 6 caractere.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Parolă',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: true,
                            onSaved: (value) {
                              _userPassword = value!;
                            },
                          ),
                          const SizedBox(height: 24),

                          if (_isLoading)
                            const CircularProgressIndicator()
                          else ...[
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _trySubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B4513),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _isLogin ? 'Login' : 'Creează cont',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'Creează un cont nou'
                                    : 'Am deja un cont',
                                style: TextStyle(color: Colors.brown[700]),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
