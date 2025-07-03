import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'main.dart';

class RecentTemperatureScreen extends StatefulWidget {
  @override
  _RecentTemperatureScreenState createState() => _RecentTemperatureScreenState();
}

class _RecentTemperatureScreenState extends State<RecentTemperatureScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTimeRange = 0; // 0: Últimas 10, 1: Últimas 20, 2: Todas

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F7FA), Color(0xFFE8EAF6)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Análisis de Datos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${TemperatureHistory.readings.length} lecturas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filtros de tiempo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildTimeFilter('10', 0),
                  SizedBox(width: 8),
                  _buildTimeFilter('20', 1),
                  SizedBox(width: 8),
                  _buildTimeFilter('Todas', 2),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: Icon(Icons.refresh, color: Color(0xFF6C63FF)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Estadísticas rápidas
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(child: _buildQuickStat(
                    'Promedio',
                    '${TemperatureHistory.getAverageTemperature().toStringAsFixed(1)}°C',
                    Icons.analytics,
                    Color(0xFF38B2AC),
                  )),
                  SizedBox(width: 12),
                  Expanded(child: _buildQuickStat(
                    'Máximo',
                    '${TemperatureHistory.getMaxTemperature().toStringAsFixed(1)}°C',
                    Icons.trending_up,
                    Color(0xFFE53E3E),
                  )),
                  SizedBox(width: 12),
                  Expanded(child: _buildQuickStat(
                    'Mínimo',
                    '${TemperatureHistory.getMinTemperature().toStringAsFixed(1)}°C',
                    Icons.trending_down,
                    Color(0xFF4299E1),
                  )),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.thermostat, size: 18),
                        SizedBox(width: 8),
                        Text('Temperatura'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop, size: 18),
                        SizedBox(width: 8),
                        Text('Humedad'),
                      ],
                    ),
                  ),
                ],
                labelColor: Color(0xFF6C63FF),
                unselectedLabelColor: Color(0xFF718096),
                indicator: BoxDecoration(
                  color: Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTemperatureTab(),
                  _buildHumidityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilter(String label, int index) {
    bool isSelected = _selectedTimeRange == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeRange = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF6C63FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF718096),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureTab() {
    List<TemperatureReading> readings = _getFilteredReadings();
    
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Gráfica principal
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gráfica de Temperatura',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}°C',
                                  style: TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() % 3 == 0 && value.toInt() < readings.length) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: TextStyle(
                                      color: Color(0xFF718096),
                                      fontSize: 10,
                                    ),
                                  );
                                }
                                return Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: max(readings.length - 1, 5).toDouble(),
                        minY: readings.isNotEmpty ? readings.map((r) => r.temperature).reduce(min) - 2 : 0,
                        maxY: readings.isNotEmpty ? readings.map((r) => r.temperature).reduce(max) + 2 : 30,
                        lineBarsData: [
                          LineChartBarData(
                            spots: readings.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(), entry.value.temperature);
                            }).toList(),
                            isCurved: true,
                            color: Color(0xFF6C63FF),
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Color(0xFF6C63FF),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF6C63FF).withOpacity(0.3),
                                  Color(0xFF6C63FF).withOpacity(0.1),
                                  Color(0xFF6C63FF).withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Gráfica de barras para distribución
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distribución de Temperatura',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxCount(readings, true),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}°C',
                                  style: TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _getTemperatureDistribution(readings),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityTab() {
    List<TemperatureReading> readings = _getFilteredReadings();
    
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Gráfica principal
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gráfica de Humedad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 10,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: TextStyle(
                                    color: Color(0xFF718096),
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() % 3 == 0 && value.toInt() < readings.length) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: TextStyle(
                                      color: Color(0xFF718096),
                                      fontSize: 10,
                                    ),
                                  );
                                }
                                return Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: max(readings.length - 1, 5).toDouble(),
                        minY: readings.isNotEmpty ? readings.map((r) => r.humidity).reduce(min) - 5 : 0,
                        maxY: readings.isNotEmpty ? readings.map((r) => r.humidity).reduce(max) + 5 : 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: readings.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(), entry.value.humidity);
                            }).toList(),
                            isCurved: true,
                            color: Color(0xFF4299E1),
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Color(0xFF4299E1),
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF4299E1).withOpacity(0.3),
                                  Color(0xFF4299E1).withOpacity(0.1),
                                  Color(0xFF4299E1).withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Gráfica circular para niveles de humedad
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Niveles de Humedad',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: PieChart(
                            PieChartData(
                              sections: _getHumidityLevels(readings),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLegendItem('Baja (<40%)', Color(0xFFE53E3E)),
                              _buildLegendItem('Normal (40-60%)', Color(0xFF38B2AC)),
                              _buildLegendItem('Alta (>60%)', Color(0xFF4299E1)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF718096),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TemperatureReading> _getFilteredReadings() {
    List<TemperatureReading> readings = TemperatureHistory.readings;
    
    switch (_selectedTimeRange) {
      case 0:
        return readings.length > 10 ? readings.sublist(readings.length - 10) : readings;
      case 1:
        return readings.length > 20 ? readings.sublist(readings.length - 20) : readings;
      case 2:
      default:
        return readings;
    }
  }

  List<BarChartGroupData> _getTemperatureDistribution(List<TemperatureReading> readings) {
    if (readings.isEmpty) return [];

    Map<int, int> distribution = {};
    for (var reading in readings) {
      int temp = reading.temperature.round();
      distribution[temp] = (distribution[temp] ?? 0) + 1;
    }

    return distribution.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Color(0xFF6C63FF),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  List<PieChartSectionData> _getHumidityLevels(List<TemperatureReading> readings) {
    if (readings.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: 'Sin datos',
          radius: 50,
          titleStyle: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ];
    }

    int low = 0, normal = 0, high = 0;
    
    for (var reading in readings) {
      if (reading.humidity < 40) {
        low++;
      } else if (reading.humidity <= 60) {
        normal++;
      } else {
        high++;
      }
    }

    List<PieChartSectionData> sections = [];
    
    if (low > 0) {
      sections.add(PieChartSectionData(
        color: Color(0xFFE53E3E),
        value: low.toDouble(),
        title: '${((low / readings.length) * 100).toInt()}%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ));
    }
    
    if (normal > 0) {
      sections.add(PieChartSectionData(
        color: Color(0xFF38B2AC),
        value: normal.toDouble(),
        title: '${((normal / readings.length) * 100).toInt()}%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ));
    }
    
    if (high > 0) {
      sections.add(PieChartSectionData(
        color: Color(0xFF4299E1),
        value: high.toDouble(),
        title: '${((high / readings.length) * 100).toInt()}%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ));
    }

    return sections;
  }

  double _getMaxCount(List<TemperatureReading> readings, bool isTemperature) {
    if (readings.isEmpty) return 5;

    Map<int, int> distribution = {};
    for (var reading in readings) {
      int value = isTemperature ? reading.temperature.round() : reading.humidity.round();
      distribution[value] = (distribution[value] ?? 0) + 1;
    }

    return distribution.values.isEmpty ? 5 : distribution.values.reduce(max).toDouble() + 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}