import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'models/moodboard.dart';
import 'screens/moodboard_detail_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film Production Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  late Future<List<Moodboard>> _moodboards;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMoodboards();
  }

  Future<void> _loadMoodboards() async {
    setState(() {
      _moodboards = _apiService.getMoodboards();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddMoodboardDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddMoodboardDialog(
            apiService: _apiService,
            onMoodboardCreated: _loadMoodboards,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Film Production Tool'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Moodboards'),
            Tab(text: 'Storyboards'),
            Tab(text: 'Shot List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MoodboardListScreen(moodboards: _moodboards, onRefresh: _loadMoodboards),
          const Center(child: Text('Storyboards Coming Soon')),
          const Center(child: Text('Shot List Coming Soon')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMoodboardDialog,
        label: const Text('Add New'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class MoodboardListScreen extends StatelessWidget {
  final Future<List<Moodboard>> moodboards;
  final Future<void> Function() onRefresh;

  const MoodboardListScreen({
    Key? key,
    required this.moodboards,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Moodboard>>(
      future: moodboards,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No moodboards yet."));
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return MoodboardCard(moodboard: snapshot.data![index]);
            },
          ),
        );
      },
    );
  }
}

class AddMoodboardDialog extends StatefulWidget {
  final ApiService apiService;
  final Future<void> Function() onMoodboardCreated;

  const AddMoodboardDialog({
    Key? key,
    required this.apiService,
    required this.onMoodboardCreated,
  }) : super(key: key);

  @override
  _AddMoodboardDialogState createState() => _AddMoodboardDialogState();
}

class _AddMoodboardDialogState extends State<AddMoodboardDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _createMoodboard() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      Moodboard newMoodboard = await widget.apiService.createMoodboard(
        _titleController.text,
        _descriptionController.text,
      );

      if (_selectedImage != null) {
        await widget.apiService.uploadCoverImage(newMoodboard.id, _selectedImage!);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onMoodboardCreated();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create moodboard: $e')),
      );
    } finally {
       if (mounted) {
         setState(() { _isLoading = false; });
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Moodboard'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Title"),
              enabled: !_isLoading,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: "Description"),
               enabled: !_isLoading,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Select Cover Image'),
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected: ${_selectedImage!.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if(_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(child: CircularProgressIndicator()),
              )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createMoodboard,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class MoodboardCard extends StatelessWidget {
  final Moodboard moodboard;
  final String apiBaseUrl = "http://localhost:8080";

  const MoodboardCard({Key? key, required this.moodboard}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoodboardDetailScreen(moodboardId: moodboard.id),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: (moodboard.coverImageUrl != null && moodboard.coverImageUrl!.isNotEmpty)
                  ? Image.network(
                      '$apiBaseUrl${moodboard.coverImageUrl}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 48, color: Colors.grey);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.photo_album, size: 48, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                moodboard.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
