import 'package:deteccion_persona_f/features/personas/data/getAll.dart';
import 'package:deteccion_persona_f/features/personas/data/personas_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final PersonasService _personasService = PersonasService();
  late Future<List<DatosPersonas>> _personasFuture;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _personasFuture = _personasService.getAllPersonas();
  }

  List<int> _calculateWeeklyStats(List<DatosPersonas> personas) {
    final now = _selectedDate;
    final today = DateTime(now.year, now.month, now.day);
    // Obtener el inicio de la semana (Lunes)
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    List<int> counts = List.filled(7, 0);
    for (var p in personas) {
      // Se asume que DatosPersonas tiene el campo createdAt como DateTime
      final date = p.createdAt.toLocal();
      if (date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && date.isBefore(endOfWeek)) {
        counts[date.weekday - 1]++;
      }
    }
    return counts;
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<DatosPersonas>>(
          future: _personasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
            }

            final personas = snapshot.data ?? [];
            final totalRegistrados = personas.length;
            final encontrados = personas.where((p) => p.encontrado).length;
            final activos = totalRegistrados - encontrados;
            final weeklyCounts = _calculateWeeklyStats(personas);

            return _buildDashboardContent(totalRegistrados, encontrados, activos, weeklyCounts);
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(int total, int encontrados, int activos, List<int> weeklyCounts) {
    final double encontradosPercent = total > 0 ? (encontrados / total) * 100 : 0;
    final double activosPercent = total > 0 ? (activos / total) * 100 : 0;
    final int maxCount = weeklyCounts.reduce((curr, next) => curr > next ? curr : next);
    final double maxY = (maxCount < 5 ? 5 : maxCount + 2).toDouble();

    return SingleChildScrollView(
      child: Column(
            children: [
              Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen General',
                    style: GoogleFonts.outfit(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visión general de los datos',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  //Tarjeta de total registrados
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.people_outline,
                                color: Colors.lightBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Total Registrados',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          total.toString(),
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  //Tajetas de encontrados y no encontrados
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE6F6EC),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Localizado',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                encontrados.toString(),
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFF4E5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_fire_department_outlined,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Pendiente',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                activos.toString(),
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Graficos
                  // pie
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Efectividad de Búsqueda',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        //Lado izquierdo: Grafico de pie
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              // child: const Center(child: Text("Pie Chart")),
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 30,
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.orange,
                                      value: activos.toDouble(),
                                      title: '${activosPercent.toStringAsFixed(0)}%',
                                      radius: 45,
                                      titleStyle: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: encontrados.toDouble(),
                                      title: '${encontradosPercent.toStringAsFixed(0)}%',
                                      radius: 45,
                                      titleStyle: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ), 
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Activos',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Encontrados',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        //Lineal
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Registros Semanales',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_month_outlined, color: Colors.grey),
                              onPressed: _pickDate,
                            ),
                          ],
                        ),
                        //Grafico de Barra
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          // child: const Center(child: Text("Bar Chart")),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceBetween,
                              maxY: maxY,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                          const style = TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          );
                                          String text;
                                          switch (value.toInt()) {
                                            case 0:
                                              text = 'Lun';
                                              break;
                                            case 1:
                                              text = 'Mar';
                                              break;
                                            case 2:
                                              text = 'Mié';
                                              break;
                                            case 3:
                                              text = 'Jue';
                                              break;
                                            case 4:
                                              text = 'Vie';
                                              break;
                                            case 5:
                                              text = 'Sáb';
                                              break;
                                            case 6:
                                              text = 'Dom';
                                              break;
                                            default:
                                              text = '';
                                          }

                                          return SideTitleWidget(
                                            meta:
                                                meta, // <- aquí está la corrección
                                            child: Text(text, style: style),
                                          );
                                        },
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(7, (index) {
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: weeklyCounts[index].toDouble(),
                                      color: const Color.fromARGB(
                                        255,
                                        64,
                                        122,
                                        197,
                                      ),
                                      width: 12,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ],
      ),
    );
  }
}
