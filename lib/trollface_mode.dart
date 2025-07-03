import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';

class TrollfaceModeScreen extends StatefulWidget {
  @override
  _TrollfaceModeScreenState createState() => _TrollfaceModeScreenState();
}

class _TrollfaceModeScreenState extends State<TrollfaceModeScreen>
    with TickerProviderStateMixin {
  bool _trollActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _colorController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;
  
  Timer? _crazinessTimer;
  List<Positioned> _floatingFaces = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Controlador de pulsación
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Controlador de rotación
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Controlador de color
    _colorController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Color(0xFF6C63FF),
      end: Color(0xFFE53E3E),
    ).animate(_colorController);
  }

  void _toggleTroll() async {
    setState(() {
      _trollActive = !_trollActive;
    });
    
    if (_trollActive) {
      _startTrollMode();
      try {
        await _audioPlayer.play(AssetSource('sounds/troll_music.mp3'));
      } catch (e) {
        // Si no hay archivo de audio, continuar sin música
        print('No se pudo reproducir el audio: $e');
      }
    } else {
      _stopTrollMode();
      await _audioPlayer.stop();
    }
  }

  void _startTrollMode() {
    // Iniciar animaciones
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _colorController.repeat(reverse: true);
    
    // Crear caras flotantes cada 500ms
    _crazinessTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _addFloatingFace();
    });
  }

  void _stopTrollMode() {
    _pulseController.stop();
    _rotationController.stop();
    _colorController.stop();
    _crazinessTimer?.cancel();
    
    setState(() {
      _floatingFaces.clear();
    });
  }

  void _addFloatingFace() {
    if (_floatingFaces.length > 10) {
      setState(() {
        _floatingFaces.removeAt(0);
      });
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    setState(() {
      _floatingFaces.add(
        Positioned(
          left: _random.nextDouble() * (screenWidth - 50),
          top: _random.nextDouble() * (screenHeight - 100),
          child: _FloatingTrollFace(
            key: UniqueKey(),
            onComplete: () {
              // Remover la cara cuando termine la animación
            },
          ),
        ),
      );
    });
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
              colors: _trollActive
                  ? [
                      Color(0xFF1A1A1A),
                      Color(0xFF2D1B69),
                      Color(0xFF1A1A1A),
                    ]
                  : [Color(0xFFF5F7FA), Color(0xFFE8EAF6)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _colorAnimation,
                    builder: (context, child) {
                      return Text(
                        _trollActive ? '¡MODO TROLL ACTIVADO!' : 'Modo Troll',
                        style: TextStyle(
                          fontSize: _trollActive ? 28 : 32,
                          fontWeight: FontWeight.w600,
                          color: _trollActive 
                              ? _colorAnimation.value 
                              : Color(0xFF2D3748),
                          shadows: _trollActive ? [
                            Shadow(
                              blurRadius: 10.0,
                              color: _colorAnimation.value ?? Colors.red,
                              offset: Offset(2.0, 2.0),
                            ),
                          ] : null,
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Botón principal troll
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _pulseAnimation,
                      _rotationAnimation,
                      _colorAnimation
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _trollActive ? _pulseAnimation.value : 1.0,
                        child: Transform.rotate(
                          angle: _trollActive ? _rotationAnimation.value : 0,
                          child: GestureDetector(
                            onTap: _toggleTroll,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: _trollActive 
                                    ? _colorAnimation.value?.withOpacity(0.2) 
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _trollActive 
                                      ? (_colorAnimation.value ?? Colors.red)
                                      : Color(0xFF6C63FF),
                                  width: _trollActive ? 4 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _trollActive 
                                        ? (_colorAnimation.value ?? Colors.red).withOpacity(0.3)
                                        : Colors.black.withOpacity(0.1),
                                    blurRadius: _trollActive ? 30 : 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _trollActive 
                                    ? Text(
                                        '😈',
                                        style: TextStyle(fontSize: 80),
                                      )
                                    : Icon(
                                        Icons.face,
                                        size: 80,
                                        color: Color(0xFF6C63FF),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 32),
                  
                  AnimatedBuilder(
                    animation: _colorAnimation,
                    builder: (context, child) {
                      return Text(
                        _trollActive 
                            ? '¡Problem? 😏' 
                            : 'Toca para activar el caos',
                        style: TextStyle(
                          fontSize: 18,
                          color: _trollActive 
                              ? _colorAnimation.value 
                              : Color(0xFF718096),
                          fontWeight: _trollActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    },
                  ),

                  if (_trollActive) ...[
                    SizedBox(height: 40),
                    
                    // Botones de efectos adicionales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildEffectButton(
                          '🔥',
                          'Fuego',
                          () => _addMultipleFloatingFaces(5),
                        ),
                        _buildEffectButton(
                          '⚡',
                          'Rayo',
                          () => _flashScreen(),
                        ),
                        _buildEffectButton(
                          '🌪️',
                          'Caos',
                          () => _addMultipleFloatingFaces(10),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        
        // Caras flotantes
        ..._floatingFaces,
        
        // Overlay de troll cuando está activo
        if (_trollActive)
          Container(
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: TrollParticlesPainter(),
            ),
          ),
      ],
    );
  }

  Widget _buildEffectButton(String emoji, String label, VoidCallback onTap) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: (_colorAnimation.value ?? Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _colorAnimation.value ?? Colors.red,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: TextStyle(fontSize: 24)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: _colorAnimation.value,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addMultipleFloatingFaces(int count) {
    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        _addFloatingFace();
      });
    }
  }

  void _flashScreen() {
    // Implementar flash de pantalla
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.white.withOpacity(0.8),
      builder: (context) => Container(),
    );
    
    Future.delayed(Duration(milliseconds: 200), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _colorController.dispose();
    _crazinessTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Widget para caras flotantes animadas
class _FloatingTrollFace extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const _FloatingTrollFace({Key? key, this.onComplete}) : super(key: key);

  @override
  __FloatingTrollFaceState createState() => __FloatingTrollFaceState();
}

class __FloatingTrollFaceState extends State<_FloatingTrollFace>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Text(
                ['😈', '👹', '🤡', '😜', '🤪'][Random().nextInt(5)],
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Painter para partículas de fondo
class TrollParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = Random();
    
    // Dibujar partículas aleatorias
    for (int i = 0; i < 20; i++) {
      paint.color = [
        Colors.red,
        Colors.purple,
        Colors.orange,
        Colors.pink,
      ][random.nextInt(4)].withOpacity(0.3);
      
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 5 + 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}