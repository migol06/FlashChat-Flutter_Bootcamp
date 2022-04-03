import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/widgets/flashchat_button.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // FirebaseAuth auth = FirebaseAuth.instance;
  final email = TextEditingController();
  final password = TextEditingController();

  Future<void> register(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
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
                controller: email,
                decoration:
                    kInputDecoration.copyWith(labelText: 'Enter your email'),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(
              height: 8.0,
            ),
            TextField(
                controller: password,
                obscureText: true,
                decoration: kInputDecoration.copyWith(
                    labelText: 'Enter your password')),
            const SizedBox(
              height: 24.0,
            ),
            FlashChatButton(
                text: 'Register',
                onTap: () {
                  if (email.text.isEmpty || password.text.isEmpty) {
                    debugPrint('Please input the required fields');
                  } else {
                    register(email.text, password.text);
                    Navigator.pushNamed(context, ChatScreen.id);
                  }

                  debugPrint(email.text + password.text);
                },
                color: Colors.blueAccent)
          ],
        ),
      ),
    );
  }
}
