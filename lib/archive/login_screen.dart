import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/screens/signup_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:todo_app/screens/todo_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // You can add authentication logic here

      _showLoginSuccessDialog(context); // 👈 This triggers the Lottie animation
    }
  }

  void _showLoginSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/success_check.json',
                width: 120,
                repeat: false,
              ),
              const SizedBox(height: 12),
              const Text(
                'Login Successful!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close success dialog

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ToDoScreen(
            isDarkMode: false, // You can pass the real value if needed
            onToggleTheme: () {}, // Add real callback if you have it
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 13, 70, 31),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Login to F-Secure',
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Email
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your email';
                    } else if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Login button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      7,
                      13,
                      7,
                    ), // Or any contrasting color
                    foregroundColor: Colors.white, // Text/icon color
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _handleLogin,
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),

                // Link to sign up
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Don't have an account yet? ",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    children: [
                      TextSpan(
                        text: 'Create Account',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                      ),
                    ],
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
