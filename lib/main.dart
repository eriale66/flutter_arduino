import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor de Temperatura',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _trollMode = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  final List<Widget> _screens = [
    TemperatureScreen(),
    HistoryScreen(),
    TrollScreen(),
  ];

  void _toggleTrollMode() async {
    setState(() {
      _trollMode = !_trollMode;
    });
    
    if (_trollMode) {
      // Reproduce música troll
      await _audioPlayer.play(AssetSource('sounds/troll_music.mp3'));
    } else {
      await _audioPlayer.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                if (index != 2) {
                  _trollMode = false;
                  _audioPlayer.stop();
                }
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF6C63FF),
            unselectedItemColor: Colors.grey[400],
            elevation: 10,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Principal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Historial',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.face),
                label: 'Troll',
              ),
            ],
          ),
        ),
        if (_trollMode)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Image.asset(
                '/assets/images/trollfaceborrosojpg.jpg',
                width: 200,
                height: 200,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Pantalla Principal de Temperatura
class TemperatureScreen extends StatefulWidget {
  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  double _temperature = 0.0;
  double _humidity = 0.0;
  bool _isConnected = false;
  Timer? _timer;
  
  // Cambia esta IP por la IP de tu ESP32
  final String espIP = "192.168.1.100";

  @override
  void initState() {
    super.initState();
    _startTemperatureMonitoring();
  }

  void _startTemperatureMonitoring() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchTemperature();
    });
  }

  Future<void> _fetchTemperature() async {
    try {
      final response = await http.get(
        Uri.parse('http://$espIP/temperature'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = data['temperature'].toDouble();
          _humidity = data['humidity'].toDouble();
          _isConnected = true;
        });
        
        // Guardar en historial
        TemperatureHistory.addReading(_temperature, _humidity);
      } else {
        setState(() {
          _isConnected = false;
        });
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
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
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monitor de Temperatura',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isConnected ? Color(0xFF48BB78) : Color(0xFFE53E3E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isConnected ? 'Conectado' : 'Desconectado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 40),
              
              // Tarjeta de Temperatura
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.device_thermostat,
                      size: 48,
                      color: Color(0xFF6C63FF),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${_temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'Temperatura Actual',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Tarjeta de Humedad
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
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
                child: Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 32,
                      color: Color(0xFF4299E1),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_humidity.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          'Humedad',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Spacer(),
              
              // Botón de actualización
              ElevatedButton(
                onPressed: _fetchTemperature,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C63FF),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Actualizar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Pantalla de Historial
class HistoryScreen extends StatelessWidget {
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
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temperaturas Recientes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Gráfica de temperatura
              Container(
                height: 250,
                padding: EdgeInsets.all(16),
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
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: TemperatureHistory.getTemperatureSpots(),
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
                          color: Color(0xFF6C63FF).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Gráfica de humedad
              Container(
                height: 250,
                padding: EdgeInsets.all(16),
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
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: TemperatureHistory.getHumiditySpots(),
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
                          color: Color(0xFF4299E1).withOpacity(0.1),
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
    );
  }
}

// Pantalla Troll
class TrollScreen extends StatefulWidget {
  @override
  _TrollScreenState createState() => _TrollScreenState();
}

class _TrollScreenState extends State<TrollScreen> {
  bool _trollActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _toggleTroll() async {
    setState(() {
      _trollActive = !_trollActive;
    });
    
    if (_trollActive) {
      await _audioPlayer.play(AssetSource('sounds/troll_music.mp3'));
    } else {
      await _audioPlayer.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F7FA), Color(0xFFE8EAF6)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Modo Troll',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  GestureDetector(
                    onTap: _toggleTroll,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.face,
                        size: 80,
                        color: _trollActive ? Color(0xFFE53E3E) : Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  Text(
                    _trollActive ? 'Troll Activado!' : 'Toca para activar',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        if (_trollActive)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Image.asset(
                'assets/images/trollface.png',
                width: 300,
                height: 300,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Clase para manejar el historial de temperaturas
class TemperatureHistory {
  static List<TemperatureReading> _readings = [];
  static const int maxReadings = 20;

  static void addReading(double temperature, double humidity) {
    _readings.add(TemperatureReading(
      temperature: temperature,
      humidity: humidity,
      timestamp: DateTime.now(),
    ));
    
    if (_readings.length > maxReadings) {
      _readings.removeAt(0);
    }
  }

  static List<FlSpot> getTemperatureSpots() {
    return _readings.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.temperature);
    }).toList();
  }

  static List<FlSpot> getHumiditySpots() {
    return _readings.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.humidity);
    }).toList();
  }
}

class TemperatureReading {
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  TemperatureReading({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });
}