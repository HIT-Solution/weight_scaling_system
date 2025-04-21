import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/network_utils.dart';

class NetworkPasswordScreen extends StatefulWidget {


  const NetworkPasswordScreen({
    super.key,

  });

  @override
  State<NetworkPasswordScreen> createState() => _NetworkPasswordScreenState();
}

class _NetworkPasswordScreenState extends State<NetworkPasswordScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _deviceNameController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false; // Toggles password visibility

  @override
  void initState() {
    super.initState();
    // _ssidController.text = widget.networkName;
  }

  Future<void> _sendCredentials() async {
    setState(() {
      _isLoading = true;
    });
    // final localizations = AppLocalizations.of(context)!;
    final password = _passwordController.text.trim();
    final ssid = _ssidController.text.trim();
    // final deviceName = _deviceNameController.text.trim();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (ssid.isEmpty) {
      _showSnackbar(
          title: "SSID", message: "SSID is empty" );
      setState(() => _isLoading = false);
      return;
    }

    if ( password.isEmpty) {
      _showSnackbar(
          title: "Password", message: "Password is empty");
      setState(() => _isLoading = false);
      return;
    }



    try {
      await NetworkUtils.sendCredentials(
        ssid: ssid,
        password: password,
        userId: userId ?? "",

      );

      setState(() {
        _isLoading = false;
      });

      _showSnackbar(
          title: "Wifi", message: "Connected"

      );

      // final BottomNavbarController bottomNavbarController =
      // Get.find<BottomNavbarController>();
      // bottomNavbarController.selectedIndex.value = 0;
      // Get.offUntil(
      //   MaterialPageRoute(builder: (_) => BottomNavigationScreen()),
      //       (route) => false,
      // );
      //
    } catch (e) {
      _showSnackbar(
          title: "Wifi not connected",
          message: "Please check your Wifi-SSID and Password"
      );
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
        backgroundColor: title == 'Error' ? Colors.red : Colors.green,
      colorText: Colors.white,
      icon: Icon(
        title == 'Error' ? Icons.error : Icons.check_circle,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Device Connection"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildConnectionStatus(),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _ssidController,
              hintText: "Wi-Fi SSID",
              icon: Icons.wifi_rounded,
            ),
            const SizedBox(height: 16.0),

            _buildPasswordField(),
            const SizedBox(height: 16.0),

            _buildEthernetInfo(),
            const SizedBox(height: 16.0),

            // _buildTextField(
            //   controller: _deviceNameController,
            //   hintText: "Device Name",
            //   icon: Icons.device_hub,
            // ),
            const SizedBox(height: 30.0),

            // Send Button
            Center(
              child: SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendCredentials,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : const Text(
                    "Credential",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Connection Status UI
  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.lightGreen,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.wifi_rounded,
            color: Colors.lightGreen,
          ),
          SizedBox(width: 10),
          Text(
            'Connected via Wi-Fi', // You can replace this with any static message
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20), // Equivalent to Colors.green[900]
            ),
          ),
        ],
      ),
    );
  }


  /// Ethernet Info Message
  Widget _buildEthernetInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.lightGreen, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.green[900]),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Ethernet connection is active. Please proceed.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1B5E20), // Equivalent to Colors.green[900]
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// Input Field with Icon
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// **Wi-Fi Password Field with Eye Toggle**
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Wi-Fi Password',

        prefixIcon: const Icon(Icons.lock, color: Colors.blueGrey),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
