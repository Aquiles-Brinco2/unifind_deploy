import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:objetos_perdidos/pages/post_create_screen.dart';
import 'package:objetos_perdidos/pages/post_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:objetos_perdidos/pages/porfile_screen.dart';
import 'package:objetos_perdidos/pages/posts_admin.dart';
import 'package:objetos_perdidos/pages/users_admin.dart';

import 'package:objetos_perdidos/services/dashboard_get_carreers.dart';
import 'package:objetos_perdidos/services/dashboard_get_months.dart';
import 'package:objetos_perdidos/services/dashboard_lost_categories.dart';
import 'package:objetos_perdidos/services/dashboard_lost_locations.dart';

import 'package:flutter/foundation.dart'; // Para detección de la plataforma
import 'package:printing/printing.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _usersStats = [];
  List<Map<String, dynamic>> _lostItemsStatsByMonth = [];
  List<Map<String, dynamic>> _lostItemsStatsByCategory = [];
  List<Map<String, dynamic>> _lostItemsStatsByLocation = [];

  bool _isLoadingUsers = true;
  bool _isLoadingLostItemsByMonth = true;
  bool _isLoadingLostItemsByCategory = true;
  bool _isLoadingLostItemsByLocation = true;

  String _errorUsers = '';
  String _errorLostItemsByMonth = '';
  String _errorLostItemsByCategory = '';
  String _errorLostItemsByLocation = '';

  int _currentIndex = 0; // Para gestionar la selección de la pantalla

  @override
  void initState() {
    super.initState();
    _fetchUsersStatsByCarrera();
    _fetchLostItemsByMonth();
    _fetchLostItemsByCategory();
    _fetchLostItemsByLocation();
  }

  Future<void> _fetchUsersStatsByCarrera() async {
    try {
      final data = await fetchUsersStatsByCarrera();
      setState(() {
        _usersStats = data;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _errorUsers = e.toString();
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _fetchLostItemsByMonth() async {
    try {
      final data = await fetchLostItemsByMonth();
      setState(() {
        _lostItemsStatsByMonth = data;
        _isLoadingLostItemsByMonth = false;
      });
    } catch (e) {
      setState(() {
        _errorLostItemsByMonth = e.toString();
        _isLoadingLostItemsByMonth = false;
      });
    }
  }

  Future<void> _fetchLostItemsByCategory() async {
    try {
      final data = await fetchLostItemsByCategory();
      setState(() {
        _lostItemsStatsByCategory = data;
        _isLoadingLostItemsByCategory = false;
      });
    } catch (e) {
      setState(() {
        _errorLostItemsByCategory = e.toString();
        _isLoadingLostItemsByCategory = false;
      });
    }
  }

  Future<void> _fetchLostItemsByLocation() async {
    try {
      final data = await fetchLostItemsByLocation();
      setState(() {
        _lostItemsStatsByLocation = data;
        _isLoadingLostItemsByLocation = false;
      });
    } catch (e) {
      setState(() {
        _errorLostItemsByLocation = e.toString();
        _isLoadingLostItemsByLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica si la plataforma es web o móvil
    bool isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(title: const Text('Administrador')),
      body: Row(
        children: [
          // Si es web, usa un NavigationRail en lugar del BottomNavigationBar
          if (isWeb)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Usuarios'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Perfil'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.list),
                  label: Text('Publicaciones'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add),
                  label: Text('Publicar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.archive),
                  label: Text('Publicaciones Guardadas'),
                ),
              ],
            ),
          // El contenido principal de la pantalla (a la derecha de NavigationRail o BottomNavigationBar)
          Expanded(
            child: _getScreenForIndex(_currentIndex),
          ),
        ],
      ),
      // En dispositivos móviles, usamos el BottomNavigationBar en la parte inferior
      bottomNavigationBar: !isWeb
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedItemColor: Colors.red,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Usuarios',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'Publicaciones',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Publicar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive),
                  label: 'Publicaciones Guardadas',
                ),
              ],
            )
          : null, // No usamos BottomNavigationBar en la web
      floatingActionButton: FloatingActionButton(
        onPressed: _exportToPdf,
        tooltip: 'Exportar a PDF',
        child: const Icon(Icons.download),
      ),
    );
  }

  // Función que renderiza las pantallas según el índice seleccionado en el BottomNavigationBar
  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return _buildDashboardScreen(); // Pantalla principal (Dashboard)
      case 1:
        return const UserListScreen(); // Pantalla de usuarios con userType: normal
      case 2:
        return const ProfileScreen(); // Pantalla de perfil
      case 3:
        return const PostsAdmin();
      case 4:
        return const CreatePublicationScreen();
      case 5:
        return const StoredPostsScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  Widget _buildDashboardScreen() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildStatsCard(
          title: 'Usuarios por Carrera',
          isLoading: _isLoadingUsers,
          errorMessage: _errorUsers,
          data: _normalizeData(_usersStats),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          title: 'Objetos Perdidos por Mes',
          isLoading: _isLoadingLostItemsByMonth,
          errorMessage: _errorLostItemsByMonth,
          data: _normalizeData(_lostItemsStatsByMonth),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          title: 'Categorías más Perdidas',
          isLoading: _isLoadingLostItemsByCategory,
          errorMessage: _errorLostItemsByCategory,
          data: _normalizeData(_lostItemsStatsByCategory),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          title: 'Ubicaciones con Más Pérdidas',
          isLoading: _isLoadingLostItemsByLocation,
          errorMessage: _errorLostItemsByLocation,
          data: _normalizeData(_lostItemsStatsByLocation),
        ),
      ],
    );
  }

  Future<void> _exportToPdf() async {
    try {
      final pdf = pw.Document();

      // Agregamos los datos de cada sección como tablas al PDF
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              children: [
                pw.Text("Usuarios por Carrera",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                _buildTable(_usersStats),
                pw.SizedBox(height: 20),
                pw.Text("Objetos Perdidos por Mes",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                _buildTable(_lostItemsStatsByMonth),
                pw.SizedBox(height: 20),
                pw.Text("Categorías más Perdidas",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                _buildTable(_lostItemsStatsByCategory),
                pw.SizedBox(height: 20),
                pw.Text("Ubicaciones con Más Pérdidas",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                _buildTable(_lostItemsStatsByLocation),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      // Usar printing para compartir el PDF en web y móviles
      if (kIsWeb) {
        // En la web, usamos printing para compartir el PDF
        await Printing.sharePdf(bytes: pdfBytes, filename: 'dashboard.pdf');
      } else {
        // En dispositivos móviles, guardamos el archivo temporalmente
        final tempDir = await getTemporaryDirectory();
        final pdfFile = File('${tempDir.path}/dashboard.pdf');
        await pdfFile.writeAsBytes(pdfBytes);

        // Abrir el archivo PDF en el dispositivo
        OpenFile.open(pdfFile.path);
      }
    } catch (e) {
      print('Error al exportar PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar PDF: $e')),
      );
    }
  }

// Método para construir las tablas (ejemplo genérico)
  pw.Table _buildTable(List<Map<String, dynamic>> data) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Agregamos las cabeceras de la tabla
        pw.TableRow(
          children: data.isNotEmpty
              ? data[0]
                  .keys
                  .map((header) => pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text(header,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ))
                  .toList()
              : [],
        ),
        // Agregamos las filas de los datos
        ...data.map((row) {
          return pw.TableRow(
            children: row.values
                .map((value) => pw.Padding(
                      padding: const pw.EdgeInsets.all(4.0),
                      child: pw.Text(value.toString(),
                          style: const pw.TextStyle(fontSize: 12)),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildStatsCard({
    required String title,
    required bool isLoading,
    required String errorMessage,
    required Map<String, int> data,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : _buildBarChart(data),
          ],
        ),
      ),
    );
  }

  Map<String, int> _normalizeData(List<Map<String, dynamic>> data) {
    final Map<String, int> combinedData = {};
    for (var item in data) {
      String key = item['_id'].toString();
      int count = item['count'];
      combinedData[key] = (combinedData[key] ?? 0) + count;
    }
    return combinedData;
  }

  Widget _buildBarChart(Map<String, int> data) {
    final dataList = data.keys.toList();

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: true),
          titlesData: _buildTitlesData(dataList),
          borderData: FlBorderData(show: false),
          barGroups: _createBarGroups(data),
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
        ),
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<String> dataList) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= dataList.length) {
              return const SizedBox.shrink();
            }
            return Text(
              dataList[value.toInt()],
              style: const TextStyle(fontSize: 10, color: Colors.black),
            );
          },
        ),
      ),
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _createBarGroups(Map<String, int> data) {
    final dataList = data.keys.toList();

    return List.generate(dataList.length, (index) {
      final value = data[dataList[index]] ?? 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: Colors.blueAccent,
            width: 16,
          ),
        ],
      );
    });
  }
}
