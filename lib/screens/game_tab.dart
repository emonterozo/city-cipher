import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math' as math;
import '../core/theme.dart';
import 'game_data.dart';

class GameTab extends StatefulWidget {
 
  final VoidCallback? onClose;
  final bool isFullView;

  const GameTab({
    super.key,
    this.onClose,
    this.isFullView = false,
  });

  @override
  State<GameTab> createState() => _GameTabState();
}

class _GameTabState extends State<GameTab> {
  int _currentLevelIdx = 0;
  int _points = 100;
  List<int> _selectedIndices = [];
  Offset? _currentDragPoint;
  List<String> _foundWords = [];
  late List<String> _shuffledLetters;
  List<Offset> _hintedOffsets = [];
  bool _showIntro = true;

  @override
  void initState() {
    super.initState();
    if (widget.isFullView) {
      _initLevel();
      _showIntro = true;
    }
  }

  void _initLevel() {
    final level = allLevels[_currentLevelIdx];
    _shuffledLetters = List.from(level.letters);
    _foundWords = [];
    _hintedOffsets = List.from(level.preFilled ?? []);
    _selectedIndices = [];
  }

  void _shuffle() => setState(() => _shuffledLetters.shuffle());

  void _handleHint() {
    if (_points >= 25) {
      _useHint();
      setState(() => _points -= 25);
    } else {
      _showAdDialog();
    }
  }

  void _useHint() {
    final level = allLevels[_currentLevelIdx];
    List<Offset> hidden = [];
    for (var item in level.grid) {
      if (_foundWords.contains(item['word'])) continue;
      for (int i = 0; i < item['word'].length; i++) {
        int cx = item['dir'] == 'h' ? item['x'] + i : item['x'];
        int cy = item['dir'] == 'v' ? item['y'] + i : item['y'];
        Offset p = Offset(cx.toDouble(), cy.toDouble());
        if (!_hintedOffsets.contains(p)) hidden.add(p);
      }
    }
    if (hidden.isNotEmpty) {
      setState(
        () => _hintedOffsets.add(hidden[math.Random().nextInt(hidden.length)]),
      );
    }
  }

  void _showAdDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Out of Points!",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Watch a short video to display hint?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CityCipherTheme.primary,
            ),
            onPressed: () {
              setState(() => _points += 50);
              Navigator.pop(context);
            },
            child: const Text("WATCH AD"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // if (_showIntro) {
    //   return _gameIntro();
    // }
    final level = allLevels[_currentLevelIdx];

    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  LucideIcons.x,
                  color: CityCipherTheme.foreground,
                  size: 24,
                ),
                onPressed: widget.onClose,
              ),
              Row(
                children: [
                  Text(
                    "LEVEL ${_currentLevelIdx + 1}",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      color: CityCipherTheme.foreground,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    color: CityCipherTheme.border,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  const FaIcon(
                    FontAwesomeIcons.coins,
                    size: 24,
                    color: CityCipherTheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "$_points",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      color: CityCipherTheme.foreground,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: CityCipherTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: CityCipherTheme.border,
            height: 1,
            width: double.infinity,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- GRID AREA ---
            Expanded(flex: 5, child: Center(child: _buildGrid(level))),

            // --- PREVIEW WORD ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              height: 50,
              alignment: Alignment.center,
              child: Text(
                _getCurrentWord(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
            ),

            // --- CONTROLS AREA ---
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LEFT SIDE: SHUFFLE
                    _buildCircleButton(
                      icon: Icons.shuffle,
                      color: Colors.white,
                      onTap: _shuffle,
                    ),

                    // CENTER: COMPACT WHEEL
                    GestureDetector(
                      onPanStart: (d) => _updateSelection(d.localPosition),
                      onPanUpdate: (d) => _updateSelection(d.localPosition),
                      onPanEnd: (d) => _onPanEnd(level),
                      child: CustomPaint(
                        size: const Size(180, 180), // Slightly smaller size
                        painter: WheelPainter(
                          letters: _shuffledLetters,
                          selectedIndices: _selectedIndices,
                          currentDragPoint: _currentDragPoint,
                        ),
                      ),
                    ),

                    // RIGHT SIDE: VERTICAL HINTS
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircleButton(
                          icon: Icons.lightbulb,
                          color: Colors.amber,
                          onTap: _handleHint,
                          label: "25",
                        ),
                        const SizedBox(height: 15),
                        _buildCircleButton(
                          icon: Icons.ads_click,
                          color: Colors.blueAccent,
                          onTap: _showAdDialog,
                          label: "FREE",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- ADS BANNER ---
            Container(
              height: 60,
              width: double.infinity,
              color: Colors.black,
              alignment: Alignment.center,
              child: const Text(
                "GOOGLE ADS BANNER",
                style: TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for buttons
  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  // Grid Builder
  Widget _buildGrid(GameLevel level) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: level.cols,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemCount: level.rows * level.cols,
          itemBuilder: (ctx, idx) {
            int x = idx % level.cols;
            int y = idx ~/ level.cols;
            String char = "";
            bool isFound = false;
            bool isCell = false;
            bool isHinted = _hintedOffsets.contains(
              Offset(x.toDouble(), y.toDouble()),
            );

            for (var item in level.grid) {
              for (int i = 0; i < item['word'].length; i++) {
                if (x == (item['dir'] == 'h' ? item['x'] + i : item['x']) &&
                    y == (item['dir'] == 'v' ? item['y'] + i : item['y'])) {
                  isCell = true;
                  char = item['word'][i];
                  if (_foundWords.contains(item['word'])) isFound = true;
                }
              }
            }
            if (!isCell) return const SizedBox.shrink();
            return Container(
              decoration: BoxDecoration(
                color: isFound
                    ? CityCipherTheme.primary
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  isFound || isHinted ? char : "",
                  style: TextStyle(
                    color: isFound ? Colors.white : Colors.white30,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Same update/pan end/intro methods as before...
  void _updateSelection(Offset pos) {
    setState(() {
      _currentDragPoint = pos;
      double size = 180; // Assuming your CustomPaint size is 180
      double centerX = size / 2;
      double centerY = size / 2;

      // MUST MATCH THE PAINTER (size * 0.45)
      double letterRadius = size * 0.45;

      for (int i = 0; i < _shuffledLetters.length; i++) {
        double angle =
            (i * 2 * math.pi / _shuffledLetters.length) - (math.pi / 2);
        Offset p = Offset(
          centerX + letterRadius * math.cos(angle),
          centerY + letterRadius * math.sin(angle),
        );

        // Increased hit-box distance to 35 for better touch response
        if ((pos - p).distance < 35 && !_selectedIndices.contains(i)) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  void _onPanEnd(GameLevel level) {
    String word = _getCurrentWord();
    if (level.grid.any((e) => e['word'] == word) &&
        !_foundWords.contains(word)) {
      setState(() {
        _foundWords.add(word);
        _points += 10;
      });
      if (_foundWords.length == level.grid.length) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (_currentLevelIdx < allLevels.length - 1) {
            setState(() {
              _currentLevelIdx++;
              _initLevel();
            });
          } else {
            widget.onClose?.call();
          }
        });
      }
    }
    setState(() {
      _selectedIndices = [];
      _currentDragPoint = null;
    });
  }

  String _getCurrentWord() =>
      _selectedIndices.map((i) => _shuffledLetters[i]).join("");

  Widget _gameIntro() {
    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.star,
                    size: 100,
                    color: CityCipherTheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "CITY CIPHER",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: CityCipherTheme.foreground,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Decode the city's secrets and master the streets in this ultimate rewards-driven adventure.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      color: CityCipherTheme.mutedForeground,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showIntro = false;
                      });

                      //widget.onStartGame?.call();
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: CityCipherTheme.border.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsGeometry.only(top: 12, bottom: 12),
                        child: const Center(
                          child: Text(
                            "PLAY NOW",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: IconButton(
              onPressed: widget.onClose,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10),
                ),
                child: const Icon(
                  LucideIcons.chevronLeft,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the WheelPainter class from the previous code block at the bottom
class WheelPainter extends CustomPainter {
  final List<String> letters;
  final List<int> selectedIndices;
  final Offset? currentDragPoint;

  WheelPainter({
    required this.letters,
    required this.selectedIndices,
    this.currentDragPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);

    // 1. REMOVED THE PLATE (Background Circle)
    // The platePaint and drawCircle logic has been deleted for a "floating" look.

    // 2. INCREASED SPACE (Padding)
    // We increase the letterRadius to push letters further apart.
    // 0.45 means letters are near the very edge of the widget's boundary.
    double letterRadius = size.width * 0.45;

    Paint linePaint = Paint()
      ..color = CityCipherTheme.primary.withOpacity(0.9)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Generate point positions for letters
    List<Offset> pts = List.generate(letters.length, (i) {
      double angle = (i * 2 * math.pi / letters.length) - (math.pi / 2);
      return center +
          Offset(
            letterRadius * math.cos(angle),
            letterRadius * math.sin(angle),
          );
    });

    // 3. DRAW CONNECTING LINES
    for (int i = 0; i < selectedIndices.length; i++) {
      if (i + 1 < selectedIndices.length) {
        canvas.drawLine(
          pts[selectedIndices[i]],
          pts[selectedIndices[i + 1]],
          linePaint,
        );
      } else if (currentDragPoint != null) {
        // Line from the last selected letter to your finger
        canvas.drawLine(pts[selectedIndices[i]], currentDragPoint!, linePaint);
      }
    }

    // 4. DRAW LETTERS
    for (int i = 0; i < pts.length; i++) {
      bool isSelected = selectedIndices.contains(i);

      // Draw the white or red circle behind the letter
      canvas.drawCircle(
        pts[i],
        28, // Slightly larger letter circles
        Paint()..color = isSelected ? CityCipherTheme.primary : Colors.white,
      );

      // Centered Text
      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 20, // Slightly larger font
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, pts[i] - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) => true;
}
