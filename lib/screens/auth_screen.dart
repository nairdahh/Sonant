// lib/screens/auth_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/user_service.dart';
import '../theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  GlobalKey<FormState> get _formKey =>
      _isLogin ? _loginFormKey : _signupFormKey;
  final UserService _userService = UserService();

  var _isLogin = true;
  var _isLoading = false;
  String _userEmail = '';
  String _userPassword = '';
  String _displayName = '';

  Future<void> _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!isValid) return;

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _userEmail.trim(),
          password: _userPassword.trim(),
        );

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _userService.updateLastLogin(user.uid);
        }
      } else {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _userEmail.trim(),
          password: _userPassword.trim(),
        );

        final user = userCredential.user;
        if (user != null) {
          await _userService.createUserProfile(
            uid: user.uid,
            email: _userEmail.trim(),
            displayName: _displayName.trim(),
          );

          await user.updateDisplayName(_displayName.trim());
        }
      }
    } on FirebaseAuthException catch (err) {
      final message = _mapFirebaseError(err);

      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapFirebaseError(FirebaseAuthException err) {
    switch (err.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password, please try again.';
      default:
        return err.message ?? 'Something went wrong, please try again.';
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background texture or color
      backgroundColor: AppTheme.warmPaper,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 800;
            // On web, we want a compact book centered. On mobile, it fills more space.
            final bookWidth = isWeb ? 450.0 : constraints.maxWidth * 0.9;
            final bookHeight = isWeb ? 650.0 : null; // Auto height on mobile

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isWeb) ...[
                      Text(
                        "Welcome to Sonant",
                        style: AppTheme.themeData.textTheme.displayMedium
                            ?.copyWith(
                          color: AppTheme.primary,
                          fontSize: 28,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: -0.2, end: 0),
                      const SizedBox(height: 32),
                    ],
                    _BookContainer(
                      width: bookWidth,
                      height: bookHeight,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(_isLogin),
                          child: _AuthFormContent(
                            isLogin: _isLogin,
                            isLoading: _isLoading,
                            formKey: _formKey,
                            onToggle: _toggleAuthMode,
                            onSubmit: _trySubmit,
                            onSavedEmail: (v) => _userEmail = v!,
                            onSavedPassword: (v) => _userPassword = v!,
                            onSavedName: (v) => _displayName = v!,
                          ),
                        ),
                      ),
                    ),
                    if (isWeb) ...[
                      const SizedBox(height: 32),
                      Text(
                        "© 2025 Sonant Library. Crafted for readers.",
                        style:
                            AppTheme.themeData.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary.withValues(alpha: 0.6),
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BookContainer extends StatelessWidget {
  final double width;
  final double? height;
  final Widget child;

  const _BookContainer({
    required this.width,
    this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: const BoxConstraints(minHeight: 500),
      decoration: BoxDecoration(
        color: AppTheme.softCream,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          // Deep shadow for 3D effect
          BoxShadow(
            color: AppTheme.espresso.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(10, 10),
          ),
          // Spine shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(-2, 0),
          ),
        ],
        border: Border.all(
          color: AppTheme.espresso.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Spine visual
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 24,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.espresso.withValues(alpha: 0.1),
                    AppTheme.espresso.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding:
                const EdgeInsets.only(left: 32, right: 24, top: 40, bottom: 40),
            child: child,
          ),
        ],
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }
}

class _AuthFormContent extends StatelessWidget {
  final bool isLogin;
  final bool isLoading;
  final GlobalKey<FormState> formKey;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;
  final FormFieldSetter<String> onSavedEmail;
  final FormFieldSetter<String> onSavedPassword;
  final FormFieldSetter<String> onSavedName;

  const _AuthFormContent({
    required this.isLogin,
    required this.isLoading,
    required this.formKey,
    required this.onToggle,
    required this.onSubmit,
    required this.onSavedEmail,
    required this.onSavedPassword,
    required this.onSavedName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                isLogin ? 'CHAPTER ONE' : 'PROLOGUE',
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 2.0,
                  fontSize: 11,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.5, end: 0),

          const SizedBox(height: 24),

          Text(
            'Sonant',
            style: theme.textTheme.displayLarge
                ?.copyWith(fontSize: 42, color: AppTheme.primary),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 100.ms).scale(),

          const SizedBox(height: 8),

          Text(
            isLogin ? 'The story continues...' : 'Begin your journey.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppTheme.primary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 48),

          // Inputs
          if (!isLogin) ...[
            FractionallySizedBox(
              widthFactor: 0.92,
              child: SizedBox(
                height: 48,
                child: TextFormField(
                  key: const ValueKey('name'),
                  style: GoogleFonts.crimsonText(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Name must be at least 2 characters.';
                    }
                    return null;
                  },
                  onSaved: onSavedName,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(),
            const SizedBox(height: 16),
          ],

          FractionallySizedBox(
            widthFactor: 0.92,
            child: SizedBox(
              height: 48,
              child: TextFormField(
                key: const ValueKey('email'),
                style: GoogleFonts.crimsonText(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                ),
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email.';
                  }
                  return null;
                },
                onSaved: onSavedEmail,
              ),
            ),
          ).animate().fadeIn(delay: isLogin ? 300.ms : 400.ms).slideX(),

          const SizedBox(height: 16),

          FractionallySizedBox(
            widthFactor: 0.92,
            child: SizedBox(
              height: 48,
              child: TextFormField(
                key: const ValueKey('password'),
                style: GoogleFonts.crimsonText(fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                ),
                textAlignVertical: TextAlignVertical.center,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
                onSaved: onSavedPassword,
              ),
            ),
          ).animate().fadeIn(delay: isLogin ? 400.ms : 500.ms).slideX(),

          const Spacer(),

          if (isLoading)
            const Center(
                child: CircularProgressIndicator(color: AppTheme.espresso))
          else
            FractionallySizedBox(
              widthFactor: 0.92,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  child: Text(isLogin ? 'Turn the Page' : 'Start Story'),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),

          const SizedBox(height: 16),

          TextButton(
            onPressed: onToggle,
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text:
                        isLogin ? "New reader? " : "Already have a bookmark? ",
                  ),
                  TextSpan(
                    text: isLogin ? "Write your Prologue" : "Go to Chapter 1",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }
}
