import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weight_scale_v2/home_page.dart';
import 'package:weight_scale_v2/pages/forgot_password_page.dart';
import 'auth_controller.dart';
import 'signup_page.dart'; // Assume you have a SignUpPage defined similarly

class LoginPage extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100),
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.to(HomePage());
                  if (emailController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    _authController.login(
                        emailController.text, passwordController.text);
                  }
                },
                child: const Text("Login"),
                style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.deepPurple,
                  minimumSize: Size(double.infinity,
                      50), // double.infinity is the width and 50 is the height
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => ForgotPasswordPage());
                  // _authController.resetPassword(emailController.text);
                },
                child: const Text("Forgot Password?"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Get.to(() => SignUpPage());
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
