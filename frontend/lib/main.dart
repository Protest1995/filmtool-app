import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filmtool',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_MoodboardListScreenState> _moodboardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAddNew() {
    if (_tabController.index == 0) {
      // Show dialog to add a new Moodboard
      _showAddMoodboardDialog();
    }
    // Add logic for other tabs here later
  }

  Future<void> _showAddMoodboardDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Moodboard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () async {
                final title = titleController.text;
                if (title.isNotEmpty) {
                  try {
                    final response = await http.post(
                      Uri.parse('http://localhost:8080/api/moodboards'),
                      headers: {'Content-Type': 'application/json; charset=UTF-8'},
                      body: jsonEncode({
                        'title': title,
                        'description': descriptionController.text,
                      }),
                    );
                    if (response.statusCode >= 200 && response.statusCode < 300) {
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      _moodboardKey.currentState?.refreshMoodboards();
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create: ${response.body}')),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('An error occurred: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Girl and t...'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Moodboards'),
            Tab(text: 'Storyboards'),
            Tab(text: 'Shot List'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _handleAddNew,
              icon: const Icon(Icons.add),
              label: const Text('Add New'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(backgroundColor: Colors.black),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MoodboardListScreen(key: _moodboardKey),
          const PlaceholderWidget(title: 'Storyboards'),
          const PlaceholderWidget(title: 'Shot List'),
        ],
      ),
    );
  }
}

class MoodboardListScreen extends StatefulWidget {
  const MoodboardListScreen({super.key});

  @override
  _MoodboardListScreenState createState() => _MoodboardListScreenState();
}

class _MoodboardListScreenState extends State<MoodboardListScreen> {
  late Future<List<Moodboard>> _moodboardsFuture;

  @override
  void initState() {
    super.initState();
    refreshMoodboards();
  }

  void refreshMoodboards() {
    setState(() {
      _moodboardsFuture = fetchMoodboards();
    });
  }

  Future<List<Moodboard>> fetchMoodboards() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/moodboards'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((data) => Moodboard.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load moodboards. Status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Moodboard>>(
      future: _moodboardsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No moodboards yet. Use the "Add New" button!'));
        } else {
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        snapshot.data![index].title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;
  const PlaceholderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class Moodboard {
  final int id;
  final String title;
  final String? description;

  Moodboard({required this.id, required this.title, this.description});

  factory Moodboard.fromJson(Map<String, dynamic> json) {
    return Moodboard(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }
}
