import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  void _addNews() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController fullContentController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add News'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: fullContentController,
                  decoration: InputDecoration(labelText: 'Full Content'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('news').add({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'fullContent': fullContentController.text,
                  'imageUrl': imageUrlController.text,
                  'publicationDate': DateTime.now(), // Add publication date
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNews(String docId) {
    FirebaseFirestore.instance.collection('news').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('news').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          final newsList = snapshot.data?.docs ?? [];

          return Center(
            child: SizedBox(
              height: mediaQueryHeight * 0.8,
              child: Swiper(
                loop: true,
                viewportFraction: 0.8,
                scale: 0.9,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final news = newsList[index];
                  final publicationDate = (news['publicationDate'] as Timestamp).toDate();
                  final formattedDate = DateFormat('dd MMM yyyy').format(publicationDate);
                  final isCurrentUser = _user?.email == 'ernklyc@gmail.com';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: news['imageUrl'] != null
                            ? Image.network(
                                news['imageUrl'],
                                fit: BoxFit.fill,
                                width: 100,
                              )
                            : null,
                        title: Text(news['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(news['description']),
                            SizedBox(height: 5),
                            Text('Published on: $formattedDate', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        trailing: isCurrentUser
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteNews(news.id),
                              )
                            : null,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(news['title']),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      news['imageUrl'] != null
                                          ? Image.network(news['imageUrl'])
                                          : Container(),
                                      SizedBox(height: 10),
                                      Text(news['fullContent']),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
                itemCount: newsList.length,
              ),
            ),
          );
        },
      ),
      floatingActionButton: _user?.email == 'ernklyc@gmail.com'
          ? FloatingActionButton(
              onPressed: _addNews,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
