import 'package:chatapp/screens/chatpage.dart';
import 'package:chatapp/screens/signUp.dart';
import 'package:chatapp/widgets/constants.dart';
import 'package:chatapp/widgets/customButton.dart';
import 'package:chatapp/widgets/customTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

// ignore: must_be_immutable
class Homeview extends StatefulWidget {
  Homeview({super.key, this.email, this.password});
  String? email;
  String? password;
  static String id = "HomeView";

  @override
  State<Homeview> createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  String? email;
  String? password;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: kPrimaryColor,
        body: Padding(
          padding: const EdgeInsets.all(13),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 130),
                Center(child: Image.asset("assets/images/scholar.png")),
                Text(
                  "Scholar App",
                  style: TextStyle(
                    fontFamily: "Pacifico",
                    fontSize: 30,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 60),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                CustomTextField(
                  hintText: "Email",
                  onChanged: (data) {
                    email = data;
                  },
                ),
                SizedBox(height: 8),
                CustomTextField(
                  obscureText: true,
                  hintText: "Password",
                  onChanged: (data) {
                    password = data;
                  },
                ),
                SizedBox(height: 15),
                CustomButton(
                  onTap: () async {
                    isLoading = true;
                    setState(() {});
                    try {
                      var auth = FirebaseAuth.instance;
                      await auth.signInWithEmailAndPassword(
                        email: email!,
                        password: password!,
                      );

                      // ignore: use_build_context_synchronously
                      Navigator.pushNamed(context, Chatpage.id);
                    } on FirebaseAuthException catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message ?? "Login failed")),
                      );
                    }
                    isLoading = false;
                    setState(() {});
                  },
                  text: "Log In",
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dont Have An Account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Signup.id);
                      },
                      child: Text(
                        "Sign Up",
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
      ),
    );
  }
}
