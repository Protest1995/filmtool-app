import 'image.dart';

class Moodboard {
  final int id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final List<Image> images;

  Moodboard({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    this.images = const [],
  });

  factory Moodboard.fromJson(Map<String, dynamic> json) {
    var imageList = json['images'] as List? ?? [];
    List<Image> images = imageList.map((i) => Image.fromJson(i)).toList();

    return Moodboard(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      coverImageUrl: json['coverImageUrl'],
      images: images,
    );
  }
} 