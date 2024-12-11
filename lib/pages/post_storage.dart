import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/post_detail_screen.dart';
import 'package:objetos_perdidos/services/main_class.dart';
import 'package:objetos_perdidos/services/posts_get_storage.dart'; // Servicio que trae los posts

class PostCard extends StatelessWidget {
  final Post post;
  final bool isWeb; // Parámetro para saber si estamos en web

  const PostCard({super.key, required this.post, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    // Si estamos en web, limitamos el ancho de la tarjeta y la centramos
    return Card(
      margin: const EdgeInsets.all(10),
      // Limitar el ancho de los PostCards en web
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.lostItem.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text('Descripción: ${post.lostItem.description}'),
            const SizedBox(height: 5),
            Text('Estado: ${post.lostItem.found ? 'Encontrado' : 'Perdido'}'),
            const SizedBox(height: 10),
            // Centrar el botón si estamos en web, pero asegurándonos de que no ocupe todo el ancho
            Center(
              child: SizedBox(
                width: isWeb
                    ? 200
                    : null, // Fijo a 200px en Web, o ancho natural en móvil
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(post: post),
                      ),
                    );
                  },
                  child: const Text('Ver Detalles'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoredPostsScreen extends StatefulWidget {
  const StoredPostsScreen({super.key});

  @override
  _StoredPostsScreenState createState() => _StoredPostsScreenState();
}

class _StoredPostsScreenState extends State<StoredPostsScreen> {
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    // Traer todos los posts con found == true
    futurePosts = fetchFoundPosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      futurePosts = fetchFoundPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Verificamos si estamos en un dispositivo web (pantalla grande)
    bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Almacenados'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<Post>>(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay objetos almacenados'));
            }

            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          isWeb ? 20.0 : 0.0), // Ajuste de margen en Web
                  child: PostCard(
                      post: post, isWeb: isWeb), // Pasar el flag de web
                );
              },
            );
          },
        ),
      ),
    );
  }
}
