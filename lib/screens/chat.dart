import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valineups/screens/login_and_guest.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _firestore.collection('messages').add({
        'text': _controller.text,
        'sender': _auth.currentUser?.displayName ?? 'Anonim',
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      // If the user is not logged in or is anonymous, show a message to prompt registration or login
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Konuşmak için ilk önce kayıt olmalısınız',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginAndGuestScreen()),
                  );
                },
                child: const Text('Oturum Aç'),
              ),
            ],
          ),
        ),
      );
    } else {
      // If the user is logged in and not anonymous, show the chat screen
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Text(message['text']),
                        subtitle: Text(message['sender']),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
