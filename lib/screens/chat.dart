import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valineups/screens/login_and_guest.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _replyToMessage;
  String? _replyToSender;

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      await _firestore.collection('messages').add({
        'text': _controller.text,
        'sender': _auth.currentUser?.displayName ?? 'Anonim',
        'photoURL': _auth.currentUser?.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'uid': _auth.currentUser?.uid,
        'replyTo': _replyToMessage,
        'replyToSender': _replyToSender,
      });
      _controller.clear();
      _replyToMessage = null;
      _replyToSender = null;
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }

  void _replyTo(String message, String sender) {
    setState(() {
      _replyToMessage = message;
      _replyToSender = sender;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      // Kullanıcı giriş yapmamış veya anonimse, giriş ekranını göster
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
      // Kullanıcı giriş yapmış ve anonim değilse, sohbet ekranını göster
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
                      final isMe = message['uid'] == user.uid;

                      return GestureDetector(
                        onLongPress:
                            isMe ? () => _deleteMessage(message.id) : null,
                        onTap: () =>
                            _replyTo(message['text'], message['sender']),
                        child: Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? Colors.blueAccent : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (message['replyTo'] != null)
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Yanıtlanan: ${message['replyToSender']}\n"${message['replyTo']}"',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          message['photoURL'] ?? ''),
                                      radius: 15,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      message['sender'],
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  message['text'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_replyToMessage != null)
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Yanıtlanan: $_replyToSender\n"$_replyToMessage"',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _replyToMessage = null;
                          _replyToSender = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        border: OutlineInputBorder(),
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
