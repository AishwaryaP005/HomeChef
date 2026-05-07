import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homechef/register.dart';
import 'main.dart';

const _kPrimary    = Color(0xFF55AD9B);
const _kSecondary  = Color(0xFF95D2B3);
const _kLight      = Color(0xFFD8EFD3);
const _kBackground = Color(0xFFF1F8E8);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "", password = "";
  bool _isLoading = false;

  void login() async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.trim(), password: password);

      User? user = credential.user;

      if (user != null) {
        String username =
            user.displayName ?? user.email?.split('@')[0] ?? "Chef";
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(username: username),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login Failed. Check email/password";
      if (e.code == 'user-not-found')
        message = "No user found with this email.";
      if (e.code == 'wrong-password') message = "Wrong password provided.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      print("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed. Check email/password")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // ── Logo ──────────────────────────────────────────────
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: _kLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimary.withOpacity(0.2),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Icon(Icons.restaurant_menu,
                      size: 48, color: _kPrimary),
                ),
                SizedBox(height: 16),
                Text(
                  "HomeChef",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _kPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "Cook with what you have 🍳",
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),

                SizedBox(height: 36),

                // ── Login card ────────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimary.withOpacity(0.12),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      TextField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.email_outlined,
                              color: _kPrimary),
                          filled: true,
                          fillColor: _kBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                BorderSide(color: _kPrimary, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => email = val,
                      ),

                      SizedBox(height: 14),

                      TextField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: _kPrimary),
                          filled: true,
                          fillColor: _kBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                BorderSide(color: _kPrimary, width: 2),
                          ),
                        ),
                        obscureText: true,
                        onChanged: (val) => password = val,
                      ),

                      SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimary,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => RegisterScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "New user? ",
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Register",
                                style: TextStyle(
                                  color: _kPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
