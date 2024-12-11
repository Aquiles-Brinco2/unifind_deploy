class Comment {
  final String id;
  final String userId; // ID del usuario
  final String userName; // Nombre del usuario
  final String post; // ID del post
  final String content;
  final String createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName, // Ahora incluimos el nombre
    required this.post,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '',
      userId: json['user']['_id'] ?? '', // Obtiene el ID del usuario
      userName: json['user']['name'] ?? '', // Obtiene el nombre del usuario
      post: json['post'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class LostItem {
  final String id;
  final String name;
  final String description;
  final String image;
  final bool found;
  final String category;
  final String location;
  final String career;
  final String status;
  final String createdAt;

  LostItem({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.found,
    required this.category,
    required this.location,
    required this.career,
    required this.status,
    required this.createdAt,
  });

  factory LostItem.fromJson(Map<String, dynamic> json) {
    return LostItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      found: json['found'] ?? false,
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      career: json['career'] ?? '',
      status: json['status'] ?? 'pendiente',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class Post {
  final String id;
  final String user; // ID del usuario
  final LostItem lostItem;
  final String postStatus;
  final String createdAt;
  final String? completeWith;

  Post({
    required this.id,
    required this.user,
    required this.lostItem,
    required this.postStatus,
    required this.createdAt,
    this.completeWith,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      lostItem: LostItem.fromJson(json['lostItem']),
      postStatus: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      completeWith: json['completeWith'] ?? '',
    );
  }
}
