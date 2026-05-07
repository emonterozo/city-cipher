import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:math' as math;
import '../core/providers/game_config_provider.dart';
import '../core/theme.dart';
import '../models/gameConfig/game_config_model.dart';
import 'game_data.dart';

class GameTab extends ConsumerStatefulWidget {
  const GameTab({super.key});

  @override
  ConsumerState<GameTab> createState() => _GameTabState();
}

class _GameTabState extends ConsumerState<GameTab> {
  int _currentLevelIdx = 0;
  int _points = 100;
  int _hintCost = 0;

  List<int> _selectedIndices = [];
  Offset? _currentDragPoint;
  List<String> _foundWords = [];
  late List<String> _shuffledLetters;
  List<Offset> _hintedOffsets = [];

  @override
  void initState() {
    super.initState();
    _initLevel();
    _initializeConfig();
  }

  void _initializeConfig() {
    final config = ref.read(gameConfigProvider);
    final rankConfig = config?.getRankByLevel(1);

    if (rankConfig != null) {
      setState(() {
        _currentLevelIdx = 0;
        _points = 0;
        _hintCost = rankConfig.hintCost;
      });
    }
  }

  void _initLevel() {
    final level = allLevels[_currentLevelIdx];
    _shuffledLetters = List.from(level.letters);
    _shuffledLetters.shuffle();
    _foundWords = [];
    _hintedOffsets = List.from(level.preFilled ?? []);
    _selectedIndices = [];
  }

  void _shuffle() => setState(() => _shuffledLetters.shuffle());

  // --- LOGIC: COMPLETION CHECK ---

  void _checkLevelComplete(GameLevel level) {
    // 1. Get all unique coordinate points that need to be filled
    Set<Offset> requiredPoints = {};
    for (var item in level.grid) {
      String word = item['word'];
      for (int i = 0; i < word.length; i++) {
        int cx = item['dir'] == 'h' ? item['x'] + i : item['x'];
        int cy = item['dir'] == 'v' ? item['y'] + i : item['y'];
        requiredPoints.add(Offset(cx.toDouble(), cy.toDouble()));
      }
    }

    // 2. Check if every point is covered by either a found word or a hint
    bool allFilled = requiredPoints.every((p) {
      bool coveredByWord = level.grid.any(
        (item) => _foundWords.contains(item['word']) && _isPointInWord(p, item),
      );
      bool coveredByHint = _hintedOffsets.contains(p);
      return coveredByWord || coveredByHint;
    });

    if (allFilled) {
      _proceedToNextLevel();
    }
  }

  void _proceedToNextLevel() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _currentLevelIdx < allLevels.length - 1) {
        setState(() {
          _currentLevelIdx++;
          _initLevel();
        });
      }
    });
  }

  // --- LOGIC: HINTS ---

  void _handleHint() {
    if (_points >= 25) {
      _useHint();
    } else {
      _showAdDialog();
    }
  }

  void _useHint() {
    final level = allLevels[_currentLevelIdx];
    List<Offset> hiddenCoords = [];

    for (var item in level.grid) {
      String word = item['word'];
      for (int i = 0; i < word.length; i++) {
        int cx = item['dir'] == 'h' ? item['x'] + i : item['x'];
        int cy = item['dir'] == 'v' ? item['y'] + i : item['y'];
        Offset p = Offset(cx.toDouble(), cy.toDouble());

        bool isVisible =
            _foundWords.contains(word) ||
            _hintedOffsets.contains(p) ||
            level.grid.any(
              (other) =>
                  _foundWords.contains(other['word']) &&
                  _isPointInWord(p, other),
            );

        if (!isVisible && !hiddenCoords.contains(p)) hiddenCoords.add(p);
      }
    }

    if (hiddenCoords.isNotEmpty) {
      setState(() {
        _points -= 25;
        _hintedOffsets.add(
          hiddenCoords[math.Random().nextInt(hiddenCoords.length)],
        );
      });
      _checkLevelComplete(level);
    }
  }

  bool _isPointInWord(Offset p, Map<String, dynamic> item) {
    String word = item['word'];
    for (int i = 0; i < word.length; i++) {
      int cx = item['dir'] == 'h' ? item['x'] + i : item['x'];
      int cy = item['dir'] == 'v' ? item['y'] + i : item['y'];
      if (p.dx == cx && p.dy == cy) return true;
    }
    return false;
  }

  // --- LOGIC: INTERACTION ---

  void _updateSelection(Offset pos) {
    setState(() {
      _currentDragPoint = pos;
      const double size = 160;
      const double centerX = size / 2;
      const double centerY = size / 2;
      const double letterRadius = size * 0.45;

      for (int i = 0; i < _shuffledLetters.length; i++) {
        double angle =
            (i * 2 * math.pi / _shuffledLetters.length) - (math.pi / 2);
        Offset p = Offset(
          centerX + letterRadius * math.cos(angle),
          centerY + letterRadius * math.sin(angle),
        );
        if ((pos - p).distance < 35 && !_selectedIndices.contains(i)) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  void _onPanEnd(GameLevel level) {
    String word = _selectedIndices.map((i) => _shuffledLetters[i]).join("");
    if (level.grid.any((e) => e['word'] == word) &&
        !_foundWords.contains(word)) {
      setState(() {
        _foundWords.add(word);
        _points += 10;
      });
      _checkLevelComplete(level);
    }
    setState(() {
      _selectedIndices = [];
      _currentDragPoint = null;
    });
  }

  // --- UI: GRID ---

  Widget _buildGrid(GameLevel level) {
    int minX = level.cols, maxX = 0, minY = level.rows, maxY = 0;
    for (var item in level.grid) {
      String w = item['word'];
      int x = item['x'], y = item['y'];
      int endX = item['dir'] == 'h' ? x + w.length - 1 : x;
      int endY = item['dir'] == 'v' ? y + w.length - 1 : y;
      if (x < minX) minX = x;
      if (endX > maxX) maxX = endX;
      if (y < minY) minY = y;
      if (endY > maxY) maxY = endY;
    }

    // Reduced padding from +2 to +1 to make grid items LARGER
    int activeCols = (maxX - minX + 1) + 1;
    int activeRows = (maxY - minY + 1) + 1;
    int displaySide = math.max(activeCols, activeRows);
    if (displaySide < 4) displaySide = 4;

    int offsetX = minX - (displaySide - (maxX - minX + 1)) ~/ 2;
    int offsetY = minY - (displaySide - (maxY - minY + 1)) ~/ 2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: displaySide,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: displaySide * displaySide,
          itemBuilder: (ctx, idx) {
            int x = (idx % displaySide) + offsetX;
            int y = (idx ~/ displaySide) + offsetY;
            String? char;
            bool isVisible = false;

            for (var item in level.grid) {
              String w = item['word'];
              for (int i = 0; i < w.length; i++) {
                int cx = item['dir'] == 'h' ? item['x'] + i : item['x'];
                int cy = item['dir'] == 'v' ? item['y'] + i : item['y'];
                if (x == cx && y == cy) {
                  char = w[i];
                  if (_foundWords.contains(w) ||
                      _hintedOffsets.contains(
                        Offset(x.toDouble(), y.toDouble()),
                      )) {
                    isVisible = true;
                  }
                }
              }
            }
            if (char == null) return const SizedBox.shrink();
            return Container(
              decoration: BoxDecoration(
                color: isVisible
                    ? CityCipherTheme.primary
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  isVisible ? char : "",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: displaySide > 7 ? 16 : 24,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameConfigProvider);
    final level = allLevels[_currentLevelIdx];

    return Scaffold(
      backgroundColor: CityCipherTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.x, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Row(
              children: [
                Text(
                  "LEVEL ${_currentLevelIdx + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 15),
                const FaIcon(
                  FontAwesomeIcons.coins,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 6),
                Text(
                  "$_points",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: Center(child: _buildGrid(level)),
            ), // Increased flex for bigger grid

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _selectedIndices.map((i) => _shuffledLetters[i]).join(""),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircleBtn(Icons.shuffle, Colors.white, _shuffle),
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: GestureDetector(
                        onPanStart: (d) => _updateSelection(d.localPosition),
                        onPanUpdate: (d) => _updateSelection(d.localPosition),
                        onPanEnd: (d) => _onPanEnd(level),
                        child: CustomPaint(
                          painter: WheelPainter(
                            letters: _shuffledLetters,
                            selectedIndices: _selectedIndices,
                            currentDragPoint: _currentDragPoint,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircleBtn(
                          Icons.lightbulb,
                          Colors.amber,
                          _handleHint,
                          _hintCost.toString(),
                        ),
                        const SizedBox(height: 15),
                        _buildCircleBtn(
                          Icons.ads_click,
                          Colors.blueAccent,
                          _showAdDialog,
                          "FREE",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Container(
              height: 60,
              width: double.infinity,
              color: Colors.black45,
              child: const Center(
                child: Text(
                  "AD BANNER",
                  style: TextStyle(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(
    IconData icon,
    Color col,
    VoidCallback tap, [
    String? label,
  ]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: tap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white10,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(icon, color: col, size: 24),
          ),
        ),
        if (label != null)
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
      ],
    );
  }

  void _showAdDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Need Points?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
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

    // --- DYNAMIC CALCULATIONS ---
    int count = letters.length;

    // 1. Smaller circles if there are more letters
    // 3-5 letters = ~28px, 8 letters = ~22px, 10 letters = ~18px
    double circleRadius = count <= 5 ? 28 : (count <= 8 ? 22 : 18);

    // 2. Smaller font for more letters
    double fontSize = count <= 5 ? 22 : (count <= 8 ? 18 : 14);

    // 3. Keep letters at the edge
    double letterRadius = size.width * 0.46;

    Paint linePaint = Paint()
      ..color = CityCipherTheme.primary.withOpacity(0.9)
      ..strokeWidth = count > 7
          ? 7
          : 10 // Thinner lines for crowded wheels
      ..strokeCap = StrokeCap.round;

    List<Offset> pts = List.generate(count, (i) {
      double angle = (i * 2 * math.pi / count) - (math.pi / 2);
      return center +
          Offset(
            letterRadius * math.cos(angle),
            letterRadius * math.sin(angle),
          );
    });

    // Draw lines
    for (int i = 0; i < selectedIndices.length; i++) {
      if (i + 1 < selectedIndices.length) {
        canvas.drawLine(
          pts[selectedIndices[i]],
          pts[selectedIndices[i + 1]],
          linePaint,
        );
      } else if (currentDragPoint != null) {
        canvas.drawLine(pts[selectedIndices[i]], currentDragPoint!, linePaint);
      }
    }

    // Draw Letters
    for (int i = 0; i < pts.length; i++) {
      bool isSelected = selectedIndices.contains(i);

      canvas.drawCircle(
        pts[i],
        circleRadius,
        Paint()..color = isSelected ? CityCipherTheme.primary : Colors.white,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: letters[i],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: fontSize,
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
