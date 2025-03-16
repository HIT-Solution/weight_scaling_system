import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import 'login_page.dart';

class SignUpPage extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;

  SignUpPage({super.key});

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
              const Text("Sign Up",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
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
              Obx(() => TextField(
                    controller: confirmPasswordController,
                    obscureText: isConfirmPasswordHidden.value,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      suffixIcon: IconButton(
                        icon: Icon(isConfirmPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => isConfirmPasswordHidden.value =
                            !isConfirmPasswordHidden.value,
                      ),
                    ),
                  )),
              const SizedBox(height: 40),
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
                      if (passwordController.text !=
                          confirmPasswordController.text) {
                        Get.snackbar("Error", "Passwords do not match",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }
                      _authController.createUser(emailController.text,
                          passwordController.text, context);
                    },
                    child: _authController.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up"),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50)),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Login",
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
