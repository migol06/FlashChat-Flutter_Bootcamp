import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var currentUser = FirebaseAuth.instance.currentUser;
  String? messageText;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final sendMessageController = TextEditingController();

  void getUser() {
    if (currentUser != null) {
      print(currentUser?.uid);
    }
  }

  // Future<void> getMessages() async {
  //   final messages = await firestore.collection('message').get();
  //   for (var messages in messages.docs) {
  //     print(messages.data());
  //   }
  // }

  Future<void> getMessages() async {
    await for (var snapshot in firestore.collection('messages').snapshots()) {
      for (var messages in snapshot.docs) {
        print(messages.data());
      }
    }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages = snapshot.data!.docs.reversed;
                    List<MessageBubble> listMessageBubbles = [];

                    for (var element in messages) {
                      final messageText = element['text'];
                      final messageSender = element['sender'];

                      final messageBubble = MessageBubble(
                          sender: messageSender, text: messageText);
                      listMessageBubbles.add(messageBubble);
                    }
                    return Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        children: listMessageBubbles,
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent),
                  );
                },
                stream: firestore.collection('message').snapshots()),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: sendMessageController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      sendMessageController.clear();
                      firestore.collection('message').add({
                        'text': messageText,
                        'sender': currentUser!.email,
                      });
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;

  const MessageBubble({Key? key, required this.sender, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12.0, color: Colors.black54),
          ),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            elevation: 5.0,
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text,
                  style: TextStyle(color: Colors.white, fontSize: 15)),

              // Text('$text from $sender',
              //     style: TextStyle(color: Colors.white, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
