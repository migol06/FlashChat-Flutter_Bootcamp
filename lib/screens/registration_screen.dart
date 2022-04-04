import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/widgets/flashchat_button.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isSpinning = false;

  Future<void> register(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      Navigator.pushNamed(context, ChatScreen.id);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('The password provided is too weak.'),
        ));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('The account already exists for that email.'),
        ));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isSpinning,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                  controller: emailController,
                  decoration:
                      kInputDecoration.copyWith(labelText: 'Enter your email'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: kInputDecoration.copyWith(
                      labelText: 'Enter your password')),
              const SizedBox(
                height: 24.0,
              ),
              FlashChatButton(
                  text: 'Register',
                  onTap: () {
                    setState(() {
                      isSpinning = true;
                    });
                    if (emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      debugPrint('Please input the required fields');
                      setState(() {
                        isSpinning = false;
                      });
                    } else {
                      register(emailController.text, passwordController.text);

                      setState(() {
                        isSpinning = false;
                      });
                    }
                  },
                  color: Colors.blueAccent)
            ],
          ),
        ),
      ),
    );
  }
}
