import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'onboarding.dart';

const _kPrimary    = Color(0xFF55AD9B);
const _kSecondary  = Color(0xFF95D2B3);
const _kLight      = Color(0xFFD8EFD3);
const _kBackground = Color(0xFFF1F8E8);

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String email = "", password = "";

  void register() async {
    try {
      var user = await FirebaseService().register(email, password);

      if (user != null) {
        // Go to onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OnboardingScreen()),
        );
      }
    } catch (e) {
      print("Register Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        title: Text("Create Account",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _kPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // ── Icon ──────────────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _kLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimary.withOpacity(0.2),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      )
                    ],
                  ),
                  child: Icon(Icons.person_add_outlined,
                      size: 40, color: _kPrimary),
                ),
                SizedBox(height: 12),
                Text(
                  "Join HomeChef",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4332),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Create your account to get started",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),

                SizedBox(height: 32),

                // ── Form card ─────────────────────────────────────────
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimary.withOpacity(0.1),
                        blurRadius: 16,
                        offset: Offset(0, 6),
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
                          prefixIcon:
                              Icon(Icons.email_outlined, color: _kPrimary),
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
                          prefixIcon:
                              Icon(Icons.lock_outline, color: _kPrimary),
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
                        child: ElevatedButton.icon(
                          onPressed: register,
                          icon:
                              Icon(Icons.app_registration, color: Colors.white),
                          label: Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPrimary,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
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
