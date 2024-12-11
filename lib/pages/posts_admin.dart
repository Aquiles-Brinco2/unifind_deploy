import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/post_edit_screen.dart';

import 'package:objetos_perdidos/services/comments_delete.dart';
import 'package:objetos_perdidos/services/comments_get.dart';
import 'package:objetos_perdidos/services/main_class.dart';
import 'package:objetos_perdidos/services/points_create.dart';
import 'package:objetos_perdidos/services/post_complete.dart';
import 'package:objetos_perdidos/services/posts_delete.dart';
import 'package:intl/intl.dart';
import 'package:objetos_perdidos/services/posts_get_Encontrados.dart';
import 'package:objetos_perdidos/services/posts_get_Perdidos.dart';
import 'package:objetos_perdidos/services/users_get_all.dart'; // Para formatear la fecha

// Pantalla de comentarios
class PostsAdmin extends StatefulWidget {
  const PostsAdmin({super.key});

  @override
  _PostsAdminState createState() => _PostsAdminState();
}

class _PostsAdminState extends State<PostsAdmin> {
  late Future<List<Post>> futurePosts;
  final int _selectedIndex = 0;
  bool isLost =
      true; // Variable para saber si estamos viendo "Perdido" o "Encontrado"
  String postStatus = "pendiente"; // Estado por defecto
  final TextEditingController _searchController =
      TextEditingController(); // Controlador de búsqueda

  @override
  void initState() {
    super.initState();
    futurePosts = fetchLostPosts(); // Por defecto, cargamos los posts perdidos
  }

  // Función para refrescar los posts dependiendo del estado (perdido o encontrado)
  Future<void> _refreshPosts() async {
    setState(() {
      futurePosts = isLost
          ? fetchLostPosts(postStatus: postStatus)
          : fetchFoundPosts(postStatus: postStatus);
    });
  }

  Future<void> _searchPosts() async {
    String searchQuery = _searchController.text.trim();
    setState(() {
      // Cuando el usuario presiona el botón de búsqueda, realizamos una nueva consulta
      futurePosts = isLost
          ? fetchLostPosts(postStatus: postStatus, name: searchQuery)
          : fetchFoundPosts(postStatus: postStatus, name: searchQuery);
    });
  }

  void _toggleLostFound(bool isLostStatus) {
    setState(() {
      isLost = isLostStatus;
      futurePosts = isLost ? fetchLostPosts() : fetchFoundPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Barra de búsqueda con el botón
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    // Barra de texto para buscar por nombre
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // Botón de búsqueda
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed:
                          _searchPosts, // Ejecuta la búsqueda al presionar el botón
                    ),
                  ],
                ),
              ),

              // Fila de botones "Perdido" y "Encontrado"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _toggleLostFound(true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      minimumSize: const Size(150, 50),
                    ),
                    child: const Text(
                      'Perdido',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _toggleLostFound(false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      minimumSize: const Size(150, 50),
                    ),
                    child: const Text(
                      'Encontrado',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 10), // Espacio entre los botones y el dropdown
              DropdownButton<String>(
                value: postStatus,
                items: const [
                  DropdownMenuItem(
                      value: "pendiente", child: Text("Pendiente")),
                  DropdownMenuItem(
                      value: "completado", child: Text("Completado")),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      postStatus = newValue;
                      _refreshPosts();
                    });
                  }
                },
              ),
              const SizedBox(height: 10), // Espacio para separar el dropdown
              Expanded(
                child: FutureBuilder<List<Post>>(
                  future: futurePosts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No hay publicaciones disponibles.'));
                    }

                    final posts = snapshot.data!;
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(
                          post: post,
                          onPostDeleted: () => _refreshPosts(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
///
///

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onPostDeleted;

  const PostCard({super.key, required this.post, required this.onPostDeleted});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Future<List<Comment>> futureComments;

  get postStatus => null;

  @override
  void initState() {
    super.initState();
    futureComments = fetchCommentsByPostId(widget.post.id);
  }

  // Función para eliminar post con confirmación
  Future<void> _deletePost() async {
    // Cuadro de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar esta publicación?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                try {
                  await deletePost(widget.post.id);
                  widget.onPostDeleted(); // Refrescar la lista de posts
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Publicación eliminada')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error al eliminar la publicación')),
                  );
                }
              },
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar comentario con confirmación
  Future<void> _deleteComment(String commentId) async {
    // Cuadro de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas eliminar este comentario?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
                try {
                  await deleteComment(commentId);
                  setState(() {
                    futureComments = fetchCommentsByPostId(widget.post.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comentario eliminado')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error al eliminar el comentario')),
                  );
                }
              },
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImage() {
    try {
      if (widget.post.lostItem.image.isNotEmpty) {
        try {
          Uint8List imageBytes = base64Decode(widget.post.lostItem.image);
          if (imageBytes.isNotEmpty) {
            return Image.memory(
              imageBytes,
              height: 250,
              width: 300,
              fit: BoxFit.cover,
            );
          }
        } catch (e) {
          print('Error decodificando imagen: $e');
        }
      }
      return Image.asset(
        'assets/images/skibidihomero.png',
        height: 250,
        width: 300,
        fit: BoxFit.cover,
      );
    } catch (e) {
      print('Error inesperado con la imagen: $e');
      return Image.asset(
        'assets/images/skibidihomero.png',
        height: 250,
        width: 300,
        fit: BoxFit.cover,
      );
    }
  }

  void showCompletePostBottomSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CompletePostScreen(postId: postId),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verificamos el tamaño de la pantalla
    bool isWeb = MediaQuery.of(context).size.width >
        600; // Detectamos si es un dispositivo web

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child:
              isWeb // Si estamos en Web, usamos un Row, de lo contrario un Column
                  ? Row(
                      children: [
                        // Colocamos la imagen a la izquierda
                        _buildImage(),
                        const SizedBox(
                            width:
                                400), // Espacio entre la imagen y el contenido
                        // El contenido a la derecha
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.lostItem.name,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Descripción: ${widget.post.lostItem.description}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 12),
                              const SizedBox(height: 12),
                              isWeb
                                  ? ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth:
                                              400), // Máximo ancho de 400px en web
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditPostScreen(
                                                      post: widget.post),
                                            ),
                                          );
                                        },
                                        child: const Text('Editar Publicación'),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditPostScreen(
                                                    post: widget.post),
                                          ),
                                        );
                                      },
                                      child: const Text('Editar Publicación'),
                                    ),
                              const SizedBox(height: 12),
                              isWeb
                                  ? ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth:
                                              400), // Máximo ancho de 400px en web
                                      child: ElevatedButton(
                                        onPressed: () {
                                          showCompletePostBottomSheet(
                                              context, widget.post.id);
                                        },
                                        child:
                                            const Text('Completar Publicación'),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        showCompletePostBottomSheet(
                                            context, widget.post.id);
                                      },
                                      child:
                                          const Text('Completar Publicación'),
                                    ),
                              const SizedBox(height: 12),
                              isWeb
                                  ? ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxWidth:
                                              400), // Máximo ancho de 400px en web
                                      child: ElevatedButton(
                                        onPressed: _deletePost,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child:
                                            const Text('Eliminar publicación'),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _deletePost,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Eliminar publicación'),
                                    ),
                              const SizedBox(height: 10),
                              FutureBuilder<List<Comment>>(
                                future: futureComments,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Text(
                                        'No hay comentarios aún.');
                                  }

                                  final comments = snapshot.data!;
                                  return Column(
                                    children: comments
                                        .map((comment) => ListTile(
                                              title: Text(comment.content),
                                              subtitle: Text(
                                                'Publicado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(comment.createdAt))}',
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete),
                                                color: Colors.red,
                                                onPressed: () =>
                                                    _deleteComment(comment.id),
                                              ),
                                            ))
                                        .toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildImage(),
                        Text(
                          widget.post.lostItem.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Descripción: ${widget.post.lostItem.description}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditPostScreen(post: widget.post),
                              ),
                            );
                          },
                          child: const Text('Editar Publicación'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            showCompletePostBottomSheet(
                                context, widget.post.id);
                          },
                          child: const Text('Completar Publicación'),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _deletePost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Eliminar publicación'),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<List<Comment>>(
                          future: futureComments,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text('No hay comentarios aún.');
                            }

                            final comments = snapshot.data!;
                            return Column(
                              children: comments
                                  .map((comment) => ListTile(
                                        title: Text(comment.content),
                                        subtitle: Text(
                                          'Publicado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(comment.createdAt))}',
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () =>
                                              _deleteComment(comment.id),
                                        ),
                                      ))
                                  .toList(),
                            );
                          },
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class CompletePostScreen extends StatefulWidget {
  final String postId;

  const CompletePostScreen({
    super.key,
    required this.postId,
  });

  @override
  State<CompletePostScreen> createState() => _CompletePostScreenState();
}

class _CompletePostScreenState extends State<CompletePostScreen> {
  final UsersGetAll _usersService = UsersGetAll(); // Instancia del servicio
  List<Map<String, String>> users = []; // Lista de usuarios
  String? selectedUserId; // Usuario seleccionado
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Cargar los usuarios al iniciar la pantalla
  }

  Future<void> _loadUsers() async {
    try {
      final fetchedUsers = await _usersService.fetchUsers();
      setState(() {
        users = fetchedUsers
            .map<Map<String, String>>((user) => {
                  'id': user['_id'],
                  'name': user['name'] ?? 'Sin nombre',
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    }
  }

  Future<void> completePost() async {
    if (selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un usuario')),
      );
      return;
    }

    final postUpdated =
        await updatePost(widget.postId, 'completed', selectedUserId!);
    print(
        "print del id para completar${widget.postId}print del id del usuario:${selectedUserId!}");

    if (postUpdated) {
      final pointCreated = await createPoint(selectedUserId!, widget.postId);

      if (pointCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post completado y punto creado')),
        );
        Navigator.pop(context); // Cerrar el BottomSheet
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear el punto')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al completar el post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Completar Post',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedUserId,
                  hint: const Text('Selecciona un usuario'),
                  items: users.map((user) {
                    return DropdownMenuItem<String>(
                      value: user['id'],
                      child: Text(user['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUserId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: completePost,
                  child: const Text('Confirmar'),
                ),
              ],
            ),
    );
  }
}
