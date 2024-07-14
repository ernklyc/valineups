import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class _ChatState extends State<Chat> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _replyToMessage;
  String? _replyToSender;
  String? _replyToMessageId;
  late TabController _tabController;

  final List<String> _adminEmails = [
    'ernklyc@gmail.com',
    'sevindikemre21@gmail.com',
    'baturaybk@gmail.com'
  ];

  Map<String, GlobalKey> messageKeys = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _sendMessage(String collection) async {
    if (_controller.text.isNotEmpty && _controller.text.length <= 6000) {
      await _firestore.collection(collection).add({
        'text': _controller.text,
        'sender': _auth.currentUser?.displayName ?? 'Anonim',
        'photoURL': _auth.currentUser?.photoURL ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'uid': _auth.currentUser?.uid,
        'replyTo': _replyToMessage,
        'replyToSender': _replyToSender,
      });
      setState(() {
        _controller.clear();
        _replyToMessage = null;
        _replyToSender = null;
      });
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      FocusScope.of(context).requestFocus(FocusNode()); // Close keyboard
    }
  }

  void _deleteMessage(String collection, String messageId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Delete Message',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: ProjectColor().valoRed,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this message?',
            style: TextStyle(color: ProjectColor().dark),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: ProjectColor().valoRed),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _firestore.collection(collection).doc(messageId).delete();
              },
            ),
          ],
        );
      },
    );
  }

  void _replyTo(String messageId, String message, String sender) {
    setState(() {
      _replyToMessageId = messageId;
      _replyToMessage = message;
      _replyToSender = sender;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null || user.isAnonymous) {
      // Show login screen if user is not signed in or is anonymous
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
      bool isAdmin = _adminEmails.contains(user.email);
      return Scaffold(
        backgroundColor: ProjectColor().dark,
        appBar: isAdmin
            ? AppBar(
                backgroundColor: ProjectColor().dark,
                toolbarHeight: 40, // App bar heightini düşürdük
                bottom: isAdmin
                    ? PreferredSize(
                        preferredSize: Size.fromHeight(30.0),
                        child: TabBar(
                          labelColor: Colors.white,
                          indicatorColor: Colors.white,
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'GLOBAL'),
                            Tab(text: 'ADMIN'),
                          ],
                        ),
                      )
                    : null,
              )
            : null,
        body: isAdmin
            ? TabBarView(
                controller: _tabController,
                children: [
                  _buildChatScreen(user, 'messages'),
                  _buildChatScreen(user, 'adminMessages'),
                ],
              )
            : _buildChatScreen(user, 'messages'),
      );
    }
  }

  Widget _buildChatScreen(User user, String collection) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection(collection)
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
                  final messageId = message.id;

                  // Date formatting
                  DateTime? timestamp;
                  if (message['timestamp'] != null) {
                    timestamp = (message['timestamp'] as Timestamp).toDate();
                  } else {
                    // Use current time as default
                    timestamp = DateTime.now();
                  }
                  final timeFormatter = DateFormat.Hm().format(timestamp);

                  if (!messageKeys.containsKey(messageId)) {
                    messageKeys[messageId] = GlobalKey();
                  }

                  return Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe) // Show avatar if not user's own message
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(message['photoURL'] ?? ''),
                              radius: 15,
                            ),
                          GestureDetector(
                            onLongPress: isMe
                                ? () => _deleteMessage(collection, message.id)
                                : null,
                            child: Dismissible(
                              key: messageKeys[messageId]!,
                              direction: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd ||
                                    direction == DismissDirection.endToStart) {
                                  _replyTo(message.id, message['text'],
                                      message['sender']);
                                  return false;
                                }
                                return false;
                              },
                              background: Container(
                                color: Colors.blue,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.reply, color: Colors.white),
                              ),
                              secondaryBackground: Container(
                                color: Colors.blue,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.reply, color: Colors.white),
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? ProjectColor().valoRed
                                      : ProjectColor().white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
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
                                    if (!isMe)
                                      Text(
                                        message['sender'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: ProjectColor().valoRed,
                                        ),
                                      ),
                                    Text(
                                      message['text'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isMe) // Empty widget if user's own message
                            SizedBox(width: 16), // Empty widget
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Text(
                          timeFormatter,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                      maxLength: 6000, // 6000 karakter sınırı
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: InputBorder.none, // No border inside
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        hintStyle: TextStyle(
                          height: 1.5, // Texti dikey olarak ortalamak için
                        ),
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
                    onPressed: () => _sendMessage(collection),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
