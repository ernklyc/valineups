import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valineups/components/custom_button.dart';
import 'package:valineups/localization/strings.dart';
import 'package:valineups/screens/login_and_guest.dart';
import 'package:valineups/styles/fonts.dart';
import 'package:valineups/styles/project_color.dart';

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

  Color getRandomColor() {
    Random random = Random();

    // Renk seçimine göre döndür
    List<Color> colors = [
      Colors.yellow,
      const Color.fromARGB(255, 127, 255, 131),
      Colors.teal,
    ];

    return colors[random.nextInt(colors.length)]
        .withAlpha(255); // Rastgele bir renk döndür
  }

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Message'),
          content: Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Kapat dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Kapat dialog
                await _firestore.collection('messages').doc(messageId).delete();
              },
            ),
          ],
        );
      },
    );
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
        backgroundColor: ProjectColor().dark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'JOIN CHAT',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: Fonts().valFonts,
                  ),
                ),
              ),
              CustomButton(
                image: AuthPageText().googleAuth,
                buttonTxt: AuthPageText().google,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginAndGuestScreen()),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    } else {
      // Kullanıcı giriş yapmış ve anonim değilse, sohbet ekranını göster
      return Scaffold(
        backgroundColor: ProjectColor().dark,
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

                      return Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe) // Kullanıcının kendi mesajı değilse avatar göster
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(message['photoURL'] ?? ''),
                              radius: 15,
                            ),
                          GestureDetector(
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
                                  color: isMe
                                      ? ProjectColor().valoRed
                                      : Colors.green[800],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (message['replyTo'] != null)
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        margin:
                                            const EdgeInsets.only(bottom: 8.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Yanıtlanan: ${message['replyToSender']}\n"${message['replyTo']}"',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    if (!isMe) // Kullanıcının kendi mesajı değilse isim göster
                                      Text(
                                        message['sender'],
                                        style: TextStyle(
                                          color: getRandomColor(),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    Text(
                                      message['text'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isMe) // Kullanıcının kendi mesajıysa boş bir widget döndür
                            SizedBox(width: 16), // Boş bir widget
                        ],
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
                        '$_replyToSender\n"$_replyToMessage"',
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
            //---------------
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Message',
                            border: InputBorder.none, // No border inside
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        color: ProjectColor().valoRed,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //---------------
          ],
        ),
      );
    }
  }
}
