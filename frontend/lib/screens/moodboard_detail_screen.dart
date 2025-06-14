import 'package:flutter/material.dart';

class MoodboardDetailScreen extends StatelessWidget {
  final int moodboardId;

  const MoodboardDetailScreen({Key? key, required this.moodboardId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moodboard #$moodboardId'),
      ),
      body: Center(
        child: Text('Details for Moodboard $moodboardId coming soon!'),
      ),
    );
  }
} 