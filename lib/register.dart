import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:prog24/components/neptunCodeField.dart';
import 'package:prog24/components/nametextField.dart';
import 'package:prog24/components/passwordTextField.dart';
import 'package:prog24/components/passwordVerField.dart';
import 'package:prog24/controllers/password_controller.dart';
import 'package:prog24/login.dart';
import 'package:prog24/models/register_model.dart';
import 'package:prog24/widgets/customButton.dart';
import 'package:prog24/widgets/customLoginRegister..dart';
import '../controllers/register_controller.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({
    super.key,
    this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final neptunController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordVerificationController = TextEditingController();
  final RegisterController controller = RegisterController();
  

  @override
  void initState() {
    super.initState();
    Get.delete<PasswordController>(force: true);
    Get.put(PasswordController());
  }

  @override
  void dispose() {
    neptunController.dispose();
    nameController.dispose();
    passwordController.dispose();
    passwordVerificationController.dispose();
    super.dispose();
  }

  @override
  // ...existing code...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Container(),
      ),
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Obx((){
           if (controller.isLoading) {
            // Show loading indicator when isLoading is true
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(22.0),
                        child: Text(
                          "UniCheck",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomLoginRegisterContainer(
                          containerContent: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Regisztráció",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            Colors.black,
                                        fontWeight: FontWeight.w500)),
                              ),
                              Lottie.asset(
                                'assets/lotties/Education.json',
                                height: 150,
                              ),
                              const SizedBox(height: 10),
                              Nametextfield(controller: nameController),
                              const SizedBox(height: 10),
                              NeptunCode(controller: neptunController),
                              const SizedBox(height: 10),
                              PasswordTextField(controller: passwordController),
                              const SizedBox(height: 10),
                              PasswordVerificationTextField(
                                controller: passwordVerificationController,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 12,
                                  bottom: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: widget.onTap,
                                      child: Text(
                                        "Bejelentkezés",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CustomButton(
                                onTap: () {
                                RegisterModel model = RegisterModel(
                                    name: nameController.text,
                                    neptunCode: neptunController.text,
                                    password: passwordController.text,
                                    cardId: "3"
                                  );
                                  controller.registerFunction(jsonEncode(model.toJson()));
                                },
                                text: "Regisztráció",
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        }
      ),
      ),
    );
  }
// ...existing code...
}