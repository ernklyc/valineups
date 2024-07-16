import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:valineups/components/news_custom_text_field.dart';
import 'package:valineups/styles/project_color.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _selectedTag;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    tz.initializeTimeZones();
    _fetchTags();
  }

  void _fetchTags() async {
    final tagsSnapshot =
        await FirebaseFirestore.instance.collection('news').get();
    final Set<String> tags = {};
    for (var doc in tagsSnapshot.docs) {
      final newsTags = List<String>.from(doc['tags'] ?? []);
      tags.addAll(newsTags);
    }
    setState(() {
      _tags = tags.toList();
    });
  }

  void _addNews() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController fullContentController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ProjectColor().dark,
          title: const Text(
            'HABER EKLE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                NewsCustomTextField(
                  controller: titleController,
                  labelText: 'Başlık',
                ),
                NewsCustomTextField(
                  controller: descriptionController,
                  labelText: 'Kısa İçerik',
                ),
                NewsCustomTextField(
                  controller: fullContentController,
                  labelText: 'Tam İçerik',
                ),
                NewsCustomTextField(
                  controller: imageUrlController,
                  labelText: 'Resim URL',
                ),
                NewsCustomTextField(
                  controller: tagsController,
                  labelText: 'Etiketler (Virgülle ayrılmış)',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'ÇIK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('news').add({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'fullContent': fullContentController.text,
                  'imageUrl': imageUrlController.text,
                  'tags': tagsController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .toList(),
                  'timestamp': FieldValue.serverTimestamp(),
                }).then((_) {
                  _fetchTags();
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'EKLE',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteNews(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                textAlign: TextAlign.center,
                'SİLMEK İSTİYOR MUSUN?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    backgroundColor: ProjectColor().dark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'HAYIR',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('news')
                        .doc(docId)
                        .delete()
                        .then((_) {
                      _fetchTags();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'SİL',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showNewsDetail(Map<String, dynamic> news) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: ProjectColor().dark,
          title: Text(
            textAlign: TextAlign.center,
            news['title'],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                news['imageUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(news['imageUrl']),
                      )
                    : Container(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    textAlign: TextAlign.left,
                    news['fullContent'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'KAPAT',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _filterByTag(String? tag) {
    setState(() {
      _selectedTag = tag;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double mediaQueryHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _user?.email == 'ernklyc@gmail.com'
          ? AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor: ProjectColor().dark,
              title: const Text(
                'ADMİN PANELİ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            )
          : null,
      backgroundColor: ProjectColor().dark,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _filterByTag(null);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProjectColor().dark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Text('ALL', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _filterByTag('UPDATE');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProjectColor().dark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                      child:
                          Text('UPDATE', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _filterByTag('ESPORTS');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProjectColor().dark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Text('ESPORTS',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _filterByTag('VALINEUPS');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProjectColor().dark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Text('VALINEUPS',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('news')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final tags = List<String>.from(doc['tags'] ?? []);
                  return _selectedTag == null || tags.contains(_selectedTag);
                }).toList();

                return Center(
                  child: SizedBox(
                    height: mediaQueryHeight,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        final news = docs[index];
                        final timestamp = news['timestamp']?.toDate();
                        final localTime = timestamp != null
                            ? tz.TZDateTime.from(timestamp, tz.local)
                            : null;
                        final formattedTimestamp = localTime != null
                            ? DateFormat('dd/MM/yyyy').format(localTime)
                            : 'Bilinmiyor';

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              _showNewsDetail(
                                  news.data() as Map<String, dynamic>);
                            },
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                image: DecorationImage(
                                  image: NetworkImage(news['imageUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          ProjectColor().dark.withOpacity(0.9),
                                          Colors.black.withOpacity(0.0),
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    left: 20,
                                    right: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          news['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          child: Text(
                                            news['description'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          formattedTimestamp,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_user?.email == 'ernklyc@gmail.com')
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: ProjectColor().dark,
                                          ),
                                          onPressed: () {
                                            _deleteNews(news.id);
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: docs.length,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _user?.email == 'ernklyc@gmail.com'
          ? FloatingActionButton(
              backgroundColor: ProjectColor().valoRed,
              onPressed: _addNews,
              child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
            )
          : null,
    );
  }
}
