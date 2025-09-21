import 'package:chatapp/screens/homeview.dart';
import 'package:chatapp/widgets/constants.dart';
import 'package:chatapp/widgets/customButton.dart';
import 'package:chatapp/widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  static String id = "Sign Up";

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String? email;
  String? password;
  String? confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Padding(
        padding: const EdgeInsets.all(13),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 130),
              Center(child: Image.asset("assets/images/scholar.png")),
              const Text(
                "Scholar App",
                style: TextStyle(
                  fontFamily: "Pacifico",
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 60),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: "Email",
                onChanged: (data) {
                  email = data;
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                obscureText: true,
                hintText: "Password",
                onChanged: (data) {
                  password = data;
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                obscureText: true,

                hintText: "Confirm Password",
                onChanged: (data) {
                  confirmPassword = data;
                },
              ),
              const SizedBox(height: 15),
              CustomButton(
                onTap: () async {
                  if (password == confirmPassword) {
                    try {
                      var auth = FirebaseAuth.instance;
                      await auth.createUserWithEmailAndPassword(
                        email: email!,
                        password: password!,
                      );

                      Navigator.pushNamed(context, Homeview.id);
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message ?? "Signup failed")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Passwords do not match")),
                    );
                  }
                },
                text: "Sign Up",
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already Have An Account?",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Homeview.id);
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
