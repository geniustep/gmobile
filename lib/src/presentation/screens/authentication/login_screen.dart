import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:gsloution_mobile/common/config/config.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:gsloution_mobile/src/utils/contstants.dart';
import 'package:gsloution_mobile/common/api_factory/modules/authentication_module.dart';
import 'package:gsloution_mobile/common/api_factory/modules/authentication_bridgecore_module.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isChecked = false;
  bool _isPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _dataBase =
      TextEditingController(text: Config.dataBase);

  // final String _defaultEmail = "Admin@gmail.com";
  // final String _defaultPassword = "123456";

  @override
  void initState() {
    // _userEmailAddressController.text = _defaultEmail;
    // _userPasswordController.text = _defaultPassword;
    super.initState();
    getVersionInfoAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white70,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onLongPress: () => _getDataBase(),
                    child: Image.asset(
                      "assets/images/logo/logo.png",
                      width: MediaQuery.of(context).size.width * 0.25,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: buildTextField(
                              "Admin@gmail.com", TextInputType.emailAddress),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: buildPasswordField("123456"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isChecked = !_isChecked;
                          });
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Checkbox(
                                activeColor: ColorSchema.primaryColor,
                                side: const BorderSide(
                                  color: Color(0xFFE2E4E7),
                                ),
                                splashRadius: 0,
                                value: _isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isChecked = value!;
                                  });
                                },
                              ),
                            ),
                            Text(
                              "Remember me",
                              style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.forgotPassword);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.raleway(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.grey),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildElevatedButton(),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                            child: Divider(
                          color: Color(0xFFE2E4E7),
                          thickness: 0.7,
                        )),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "or",
                          style: GoogleFonts.raleway(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Expanded(
                            child: Divider(
                          color: Color(0xFFE2E4E7),
                          thickness: 0.7,
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.raleway(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.contactUs);
                        },
                        child: Text(
                          "Contact Us",
                          style: GoogleFonts.raleway(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: ColorSchema.primaryColor),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: ColorSchema.primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      onPressed: _login,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 40),
        child: Text(
          "Log In",
          style: GoogleFonts.raleway(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  _getDataBase() {
    Get.dialog(AlertDialog(
      title: Text("Change DataBase"),
      content: ListTile(
        leading: Text("Write ur dataBase"),
        title: TextField(
          controller: _dataBase,
          onChanged: (value) {
            Config.dataBase = value;
          },
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: Text("Change"))
      ],
    ));
  }

  _login() {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus!.unfocus();
      if (_emailController.text.isEmpty) {
        showWarning("Please enter email");
      } else if (_passCtrl.text.isEmpty) {
        showWarning("Please enter password");
      } else {
        // Use BridgeCore authentication by default
        // Users can switch to Odoo Direct via Developer Settings
        final apiMode = ApiModeConfig.instance.currentMode;

        if (apiMode == ApiMode.bridgeCore) {
          // BridgeCore authentication (default)
          AuthenticationBridgeCoreModule.signIn(
            email: _emailController.text,
            password: _passCtrl.text,
            database: _dataBase.text,
          );
        } else {
          // Odoo Direct authentication (fallback)
          authenticationAPI(_emailController.text, _passCtrl.text);
        }
      }
    }
  }

  TextFormField buildTextField(String hint, TextInputType keyboardType) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Enter your email address";
        }
        final emailRegEx = RegExp("");
        if (!emailRegEx.hasMatch(value)) {
          return "Enter your valid email address";
        }
        return null;
      },
      controller: _emailController,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: const Icon(
          Icons.account_circle,
          color: Color(0xFFE2E4E7),
        ),
        fillColor: Colors.white,
        filled: true,
        hintText: hint,
        hintStyle: GoogleFonts.raleway(
            textStyle: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E4E7), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: ColorSchema.primaryColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      keyboardType: keyboardType,
    );
  }

  Widget buildPasswordField(String hint) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Enter your password";
        }
        if (value.length < 4) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
      controller: _passCtrl,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        fillColor: Colors.white,
        filled: true,
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
            textStyle: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E4E7), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: ColorSchema.primaryColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isPasswordHidden = !_isPasswordHidden;
            });
          },
          icon: Icon(
            _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
            color: const Color(0xFFE2E4E7),
          ),
        ),
      ),
      obscureText: _isPasswordHidden,
    );
  }
}
