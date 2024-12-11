import 'dart:convert'; // Para decodificar la imagen base64
import 'package:flutter/material.dart';
import 'package:objetos_perdidos/pages/users_detail.dart';
import 'package:objetos_perdidos/services/points_get.dart';
import 'package:objetos_perdidos/services/users_get_normal.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController =
      TextEditingController(); // Controlador de la barra de búsqueda

  // Crear una instancia del servicio
  final UsersGetNormal userService = UsersGetNormal();

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Cargar usuarios por defecto
  }

  // Método para obtener los usuarios usando el servicio
  Future<void> fetchUsers({String? name}) async {
    try {
      final data = await userService.fetchUsers(
          name: name); // Pasar el nombre para el filtrado
      for (var user in data) {
        // Obtener los puntos para cada usuario
        final points = await getPointsCount(user['_id']);
        user['points'] = points; // Añadir los puntos al objeto del usuario
      }
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading users: $e';
        isLoading = false;
      });
    }
  }

  // Función que se llama cuando el usuario escribe en la barra de búsqueda
  void _onSearchChanged() {
    setState(() {
      isLoading = true;
    });
    fetchUsers(
        name:
            _searchController.text); // Llamar al servicio con el nombre buscado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        actions: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 250,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _onSearchChanged(); // Actualiza la búsqueda cada vez que el usuario escribe
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: MemoryImage(
                            base64Decode(user['image']),
                          ),
                        ),
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        trailing: Text(
                            'Puntos: ${user['points']}'), // Mostrar los puntos a la derecha
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserDetailScreen(user: user),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
