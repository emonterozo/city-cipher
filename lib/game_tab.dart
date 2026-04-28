import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'core_theme.dart';
import 'game_data.dart';

class GameTab extends StatefulWidget {
  final VoidCallback? onStartGame;
  final VoidCallback? onClose;
  final bool isFullView;

  const GameTab({
    super.key,
    this.onStartGame,
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

  @override
  void initState() {
    super.initState();
    if (widget.isFullView) _initLevel();
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
              backgroundColor: CityCipherTheme.primaryRed,
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
    if (!widget.isFullView) return _buildIntro();
    final level = allLevels[_currentLevelIdx];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // --- UPDATED HORIZONTAL TOP BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: widget.onClose,
                  ),
                  // HORIZONTAL LEVEL AND POINTS
                  Row(
                    children: [
                      Text(
                        "LEVEL ${_currentLevelIdx + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 1,
                        color: Colors.white24,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$_points",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 48,
                  ), // Spacer to center the level/points
                ],
              ),
            ),

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
                    ? CityCipherTheme.primaryRed
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

  Widget _buildIntro() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          // Prevents cutting off on small screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.stars_rounded,
                size: 100, // Slightly larger icon
                color: CityCipherTheme.primaryRed,
              ),
              const SizedBox(height: 10),
              const Text(
                "CITY CIPHER",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40), // Increased spacing
              SizedBox(
                width: 200, // Fixed width so it doesn't stretch
                height: 50, // Fixed height to ensure it's not "half"
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CityCipherTheme.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  onPressed: widget.onStartGame,
                  child: const Text(
                    "PLAY NOW",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
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
      ..color = CityCipherTheme.primaryRed.withOpacity(0.9)
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
        Paint()..color = isSelected ? CityCipherTheme.primaryRed : Colors.white,
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
