import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  @override
  Widget build(BuildContext context) {
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

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return Card(
                child: ListTile(
                  leading: news['imageUrl'] != null
                      ? Image.network(
                          news['imageUrl'],
                          width: 100,
                        )
                      : null,
                  title: Text(news['title']),
                  subtitle: Text(news['description']),
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
              );
            },
          );
        },
      ),
    );
  }
}
