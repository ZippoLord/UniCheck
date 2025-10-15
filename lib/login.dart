import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prog24/components/neptunCodeField.dart';
import 'package:prog24/components/passwordTextField.dart';
import 'package:prog24/components/passwordVerField.dart';
import 'package:prog24/models/login_model.dart';
import 'package:prog24/register.dart';
import 'package:prog24/widgets/customButton.dart';
import 'package:prog24/widgets/customLoginRegister..dart';
import '../controllers/password_controller.dart';
import '../controllers/login_controller.dart';
// import '../models/newmodels/login_model.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
   const LoginPage({
    super.key,
    this.onTap,
  });


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final passwordController = TextEditingController();
  final neptunCodeController = TextEditingController();
  final passwordVerificationController = TextEditingController();
  final LoginController controller = LoginController();

  @override
  void initState() {
    super.initState();
    Get.delete<PasswordController>(force: true);
    Get.put(PasswordController());
  }

  @override
  void dispose() {
    neptunCodeController.dispose();
    passwordController.dispose();
    passwordVerificationController.dispose();
    super.dispose();
  }

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
              bottom: MediaQuery.of(context).viewInsets.bottom, // keyboard miatt
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                          children: [
                             Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Bejelentkezés",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            Colors.black,
                                        fontWeight: FontWeight.w500)),
                              ),
                            SizedBox(
                              height: 250,
                              child: Lottie.asset(
                                "assets/lotties/Education.json",
                              ),
                            ),
                            const SizedBox(height: 25),
                            NeptunCode(controller: neptunCodeController),
                            const SizedBox(height: 10),
                            PasswordTextField(controller: passwordController),
                            const SizedBox(height: 10),
                            //PasswordVerificationTextField(controller: passwordVerificationController),
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
                                      "Regisztráció",
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
                                if (neptunCodeController.text.isNotEmpty &&
                                    passwordController.text.length >= 2) {
                                  LoginModel model = LoginModel(
                                    neptunCode: neptunCodeController.text,
                                    password: passwordController.text,
                                    cardId: "2"
                                  );
                                  controller
                                      .loginFunction(loginModelToJson(model));
                                }
                              },
                              text: "Bejelentkezés",
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
      }),
      
    ),
  );
  }
}
                    
