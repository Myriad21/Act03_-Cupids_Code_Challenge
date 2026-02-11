import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome> with SingleTickerProviderStateMixin {
  
  // Pulse variables
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  bool isPulsing = false;

  // Balloon variables
  final _rng = Random();
  final List<_Balloon> _balloons = [];
  bool _showBalloons = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Balloon Helpers
  void _dropBalloons() {
  setState(() {
    _balloons.clear();
    _showBalloons = true;

    // create 15 balloons with random x positions and delays
    for (int i = 0; i < 15; i++) {
      _balloons.add(
        _Balloon(
          left: _rng.nextDouble() * (MediaQuery.of(context).size.width - 60), // adjust if needed
          delayMs: i * 120,
          size: 50 + _rng.nextDouble() * 50,
        ),
      );
    }
  });

  // hide after the animation finishes
  Future.delayed(const Duration(milliseconds: 2500), () {
    if (!mounted) return;
    setState(() => _showBalloons = false);
  });
}



  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cupid\'s Canvas')),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3), // slightly above center
                radius: 1.2,
                colors: [
                  Color(0xFFFFC1E3), // soft pink
                  Color(0xFFE91E63), // deeper pink/red
                ],
              ),
            ),
          ),

          // Your normal UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 105),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedEmoji,
                    items: emojiOptions
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedEmoji = value ?? selectedEmoji),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => isPulsing = !isPulsing);
                      if (isPulsing) {
                        _pulseController.repeat(reverse: true);
                      } else {
                        _pulseController.stop();
                        _pulseController.reset();
                      }
                    },
                    icon: Icon(isPulsing ? Icons.pause : Icons.play_arrow),
                    label: Text(isPulsing ? 'Stop Pulse' : 'Pulse Heart'),
                  ),

                  ElevatedButton.icon(
                    onPressed: _dropBalloons,
                    icon: const Icon(Icons.celebration),
                    label: const Text('Balloon Celebration!'),
                  ),
                ],
              ),
            ),
          ),


          Center(
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnim.value,
                  child: child,
                );
              },
              child: CustomPaint(
                size: const Size(300, 300),
                painter: HeartEmojiPainter(type: selectedEmoji),
              ),
            ),
          ),

    if (_showBalloons)
      ..._balloons.map((b) => _FallingBalloon(
            left: b.left,
            delayMs: b.delayMs,
            size: b.size,
          )),
  ],
),
);
}
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type});
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Heart base
    final heartPath = Path()
      ..moveTo(center.dx, center.dy + 60)
      ..cubicTo(center.dx + 110, center.dy - 10, center.dx + 60, center.dy - 120, center.dx, center.dy - 40)
      ..cubicTo(center.dx - 60, center.dy - 120, center.dx - 110, center.dy - 10, center.dx, center.dy + 60)
      ..close();

    paint.color = type == 'Party Heart' ? const Color(0xFFF48FB1) : const Color(0xFFE91E63);
    canvas.drawPath(heartPath, paint);

  
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30), 0, 3.14, false, mouthPaint);

    
    if (type == 'Party Heart') {
      final hatPaint = Paint()..color = const Color(0xFFFFD54F);
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) => oldDelegate.type != type;
}

class _Balloon {
  final double left;
  final int delayMs;
  final double size;
  _Balloon({required this.left, required this.delayMs, required this.size});
}

class _FallingBalloon extends StatefulWidget {
  final double left;
  final int delayMs;
  final double size;

  const _FallingBalloon({
    required this.left,
    required this.delayMs,
    required this.size,
  });

  @override
  State<_FallingBalloon> createState() => _FallingBalloonState();
}

class _FallingBalloonState extends State<_FallingBalloon> {
  bool _start = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() => _start = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.pink,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.blue,
    ];

    final color = colors[(widget.left.toInt()) % colors.length];

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeIn,
      left: widget.left,
      top: _start ? MediaQuery.of(context).size.height : 0,
      child: Column(
        children: [
          Image.asset(
            'assets/images/balloons_cele.png',
            width: widget.size,
          ),
          Container(width: 2, height: 30, color: Colors.black26),
        ],
      )

    );
  }
}
