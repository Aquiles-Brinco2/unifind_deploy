import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:objetos_perdidos/services/points_delete_some.dart';
import 'package:objetos_perdidos/services/users_delete.dart'; // Importamos el servicio
import 'package:objetos_perdidos/services/points_get.dart'; // Servicio para obtener puntos

class UserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserDetailScreen({super.key, required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  int points = 0; // Puntos del usuario

  @override
  void initState() {
    super.initState();
    fetchPoints(); // Obtenemos los puntos del usuario cuando se carga la pantalla
  }

  // Método para obtener los puntos del usuario
  Future<void> fetchPoints() async {
    final userPoints = await getPointsCount(widget.user['_id']);
    setState(() {
      points = userPoints; // Establecemos los puntos del usuario
    });
  }

  Future<void> deleteUser(BuildContext context) async {
    final bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed) {
      try {
        final userService =
            UsersDelete(); // Usamos el servicio para eliminar el usuario
        final success = await userService.deleteUser(
            widget.user['_id']); // Llamamos al método de eliminación

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario eliminado con éxito')),
          );
          Navigator.pop(context); // Regresar a la pantalla anterior
        } else {
          throw Exception('No se pudo eliminar el usuario');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando usuario: $e')),
        );
      }
    }
  }

  // Mostrar la pantalla flotante para ingresar la cantidad de puntos
  void showPointsDialog(BuildContext context) {
    final TextEditingController pointsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Canjear Puntos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tienes $points puntos disponibles.'),
            TextField(
              controller: pointsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad de puntos a canjear',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Solo números
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancelar
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final enteredPoints = int.tryParse(pointsController.text);

              // Validar que el número ingresado sea válido
              if (enteredPoints == null || enteredPoints <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Por favor ingresa un número válido')),
                );
                return;
              }

              // Validar que el número de puntos a canjear no sea mayor a los puntos del usuario
              if (enteredPoints > points) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'No puedes canjear más puntos de los que tienes')),
                );
                return;
              }

              // Llamar al servicio para eliminar los puntos
              deleteRandomPoints(widget.user['_id'], enteredPoints)
                  .then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Puntos canjeados con éxito')),
                  );
                  Navigator.pop(context); // Cerrar el diálogo
                  fetchPoints(); // Actualizar los puntos después del canje
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Error al canjear los puntos')),
                  );
                }
              });
            },
            child: const Text('Canjear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user['name'])),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;
          final contentWidth = isWideScreen ? 600.0 : double.infinity;

          return Center(
            child: Container(
              width: contentWidth,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: MemoryImage(
                        base64Decode(widget.user['image']),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Nombre: ${widget.user['name']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Carrera: ${widget.user['carrera']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Email: ${widget.user['email']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Teléfono: ${widget.user['phone']}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  Text('Puntos: $points', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => deleteUser(context),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Eliminar Usuario'),
                  ),
                  ElevatedButton(
                    onPressed: () => showPointsDialog(
                        context), // Mostrar la pantalla flotante
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Canjear Puntos'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
