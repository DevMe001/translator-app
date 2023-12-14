import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:translator/controller/approva.dart';
import 'package:translator/services/api-service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TranslatorService _translatorService = TranslatorService();

  var logger = Logger();
  bool isObscure = true;

  void readyToVerify(String username, String password) {
    _translatorService.getUserAccount(username, password).then((isValidUser) {
      if (!isValidUser) {
        showPopupMessage('Invalid credentials.', context, colorStyle: 'error');
      } else {
        setState(() {});
        _usernameController.clear();
        _passwordController.clear();
        // Navigate to the next screen on successful login
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ApprovalScreenContribute()),
        );
      }
    }).catchError((error) {
      // Handle errors, if any
      logger.d('Error during login: $error');
      showPopupMessage('An error occurred during login.', context,
          colorStyle: 'error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9906B),
        title: const Text(
          'Login Form',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set the title color to white
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7F2505),
                    ),
                    textAlign: TextAlign.center,
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      errorStyle: TextStyle(
                        color: Colors.red, // Change the color of the error text
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field is not empty.';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                  TextFormField(
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7F2505),
                    ),
                    obscureText: isObscure,
                    textAlign: TextAlign.center,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                      ),
                      errorStyle: const TextStyle(
                        color: Colors.red, // Change the color of the error text
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field is not empty.';
                      }
                      return null; // Return null if the input is valid
                    },
                  ),
                ],
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() == true) {
            // The form is valid, process the data
            String username = _usernameController.text;
            String enteredPassword = _passwordController.text;

            readyToVerify(username, enteredPassword);
          }
        },
        child: const Icon(Icons.power_settings_new),
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showPopupMessage(
    String message, BuildContext context,
    {String? colorStyle}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // action: SnackBarAction(
      //   label: 'Action',
      //   onPressed: () {
      //     // Code to execute.
      //   },
      // ),
      backgroundColor: colorStyle == 'success'
          ? const Color.fromARGB(255, 130, 143, 30)
          : const Color(0xFFF9906B),
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(milliseconds: 1500),
      width: 280.0, // Width of the SnackBar.

      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  );
}
