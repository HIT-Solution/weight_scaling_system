import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordHidden =
      true.obs; // Observable for password visibility

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
              const Text("Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 50),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => TextField(
                    controller: passwordController,
                    obscureText: isPasswordHidden.value,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            isPasswordHidden.value = !isPasswordHidden.value,
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              Obx(() => ElevatedButton(
                    onPressed: () {
                      if (emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        Get.snackbar(
                            "Error", "Email and Password cannot be empty",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }
                      _authController.login(
                          emailController.text, passwordController.text);
                    },
                    child: _authController.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50)),
                  )),
              TextButton(
                onPressed: () => Get.to(() => ForgotPasswordPage()),
                child: const Text("Forgot Password?",
                    style: TextStyle(color: Colors.blue)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Get.to(() => SignUpPage()),
                    child: const Text("Sign Up",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
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
