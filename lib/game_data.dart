import 'package:flutter/material.dart';

class GameLevel {
  final List<String> letters;
  final List<Map<String, dynamic>> grid;
  final int rows;
  final int cols;
  final List<Offset>? preFilled;

  GameLevel({
    required this.letters,
    required this.grid,
    required this.rows,
    required this.cols,
    this.preFilled,
  });
}

final List<GameLevel> allLevels = [
  // LEVEL 1: REDLINE (Theme: Branding)
 GameLevel(
    letters: ["R", "E", "D", "L", "I", "N", "E"],
    rows: 6,
    cols: 7,
    grid: [
      {"word": "REDLINE", "x": 0, "y": 2, "dir": "h"}, 
      {"word": "RED", "x": 0, "y": 2, "dir": "v"},     
      {"word": "LINE", "x": 3, "y": 2, "dir": "v"},    
      {"word": "DEER", "x": 1, "y": 0, "dir": "v"},    // 'E' at index 2 matches REDLINE y=2
      {"word": "REEL", "x": 6, "y": 1, "dir": "v"},    // FIXED: Changed y from 2 to 1
    ],
  ),

  // LEVEL 2: VIOS (Theme: Toyota)
  GameLevel(
    letters: ["V", "I", "O", "S"],
    rows: 4,
    cols: 4,
    grid: [
      {"word": "VIOS", "x": 0, "y": 1, "dir": "h"},
      {"word": "ISO", "x": 1, "y": 1, "dir": "v"}, // Intersects at 'I'
      {"word": "SO", "x": 3, "y": 0, "dir": "v"}, // Intersects at 'S'
    ],
  ),

  // LEVEL 3: CIPHER (Theme: Security)
  GameLevel(
    letters: ["C", "I", "P", "H", "E", "R"],
    rows: 6,
    cols: 6,
    grid: [
      {"word": "CIPHER", "x": 0, "y": 0, "dir": "h"},
      {"word": "HIRE", "x": 3, "y": 0, "dir": "v"}, // Intersects at 'H'
      {
        "word": "RICE",
        "x": 3,
        "y": 3,
        "dir": "h",
      }, // Intersects at 'R' (from HIRE)
      {"word": "PIER", "x": 2, "y": 0, "dir": "v"}, // Intersects at 'P'
      {"word": "CHIP", "x": 0, "y": 0, "dir": "v"}, // Intersects at 'C'
    ],
  ),

  // LEVEL 4: WASH (Theme: Cleaning)
  GameLevel(
    letters: ["W", "A", "S", "H"],
    rows: 5,
    cols: 5,
    grid: [
      {"word": "WASH", "x": 0, "y": 2, "dir": "h"},
      {"word": "HAS", "x": 3, "y": 0, "dir": "v"}, // Intersects at 'H'
      {"word": "SAW", "x": 2, "y": 1, "dir": "v"}, // Intersects at 'A'
      {"word": "ASH", "x": 1, "y": 2, "dir": "v"}, // Intersects at 'A'
    ],
  ),

  // LEVEL 5: GLOSS (Theme: Detailing)
  GameLevel(
    letters: ["G", "L", "O", "S", "S"],
    rows: 6,
    cols: 6,
    grid: [
      {"word": "GLOSS", "x": 0, "y": 2, "dir": "h"},
      {"word": "LOGS", "x": 1, "y": 0, "dir": "v"}, // Intersects at 'L'
      {"word": "SLOG", "x": 3, "y": 2, "dir": "v"}, // Intersects at 'S'
      {"word": "LOSS", "x": 4, "y": 2, "dir": "v"}, // Intersects at 'S'
    ],
  ),

  // LEVEL 6: BRAKE (Theme: Parts)
  GameLevel(
    letters: ["B", "R", "A", "K", "E"],
    rows: 6,
    cols: 6,
    grid: [
      {"word": "BRAKE", "x": 0, "y": 1, "dir": "h"},
      {"word": "BAKE", "x": 0, "y": 1, "dir": "v"}, // Intersects at 'B'
      {"word": "RARE", "x": 1, "y": 0, "dir": "v"}, // Intersects at 'R'
      {
        "word": "EAR",
        "x": 1,
        "y": 3,
        "dir": "h",
      }, // Intersects at 'R' (from RARE)
      {"word": "BARK", "x": 0, "y": 1, "dir": "h"}, // Sub-word of Brake
    ],
  ),

  // LEVEL 7: DRIVE (Theme: Action)
  GameLevel(
    letters: ["D", "R", "I", "V", "E"],
    rows: 6,
    cols: 6,
    grid: [
      {"word": "DRIVE", "x": 0, "y": 2, "dir": "h"},
      {"word": "RIDE", "x": 1, "y": 1, "dir": "v"}, // Intersects at 'R'
      {"word": "DIVE", "x": 0, "y": 2, "dir": "v"}, // Intersects at 'D'
      {
        "word": "RED",
        "x": 1,
        "y": 4,
        "dir": "h",
      }, // Intersects at 'E' (from RIDE)
      {"word": "IRE", "x": 2, "y": 2, "dir": "v"}, // Intersects at 'I'
    ],
  ),

  // LEVEL 8: TOKEN (Theme: Rewards)
  GameLevel(
    letters: ["T", "O", "K", "E", "N"],
    rows: 6,
    cols: 6,
    grid: [
      {"word": "TOKEN", "x": 0, "y": 2, "dir": "h"},
      {"word": "KNOT", "x": 2, "y": 0, "dir": "v"}, // Intersects at 'K'
      {"word": "NOTE", "x": 4, "y": 2, "dir": "v"}, // Intersects at 'N'
      {"word": "TEN", "x": 0, "y": 2, "dir": "v"}, // Intersects at 'T'
      {"word": "ONE", "x": 1, "y": 2, "dir": "v"}, // Intersects at 'O'
    ],
  ),

  // LEVEL 9: STORE (Theme: Business)
  GameLevel(
    letters: ["S", "T", "O", "R", "E"],
    rows: 6,
    cols: 6,
    grid: [
      {"word": "STORE", "x": 0, "y": 2, "dir": "h"},
      {"word": "REST", "x": 3, "y": 1, "dir": "v"}, // Intersects at 'R'
      {"word": "SORT", "x": 0, "y": 2, "dir": "v"}, // Intersects at 'S'
      {"word": "TOE", "x": 1, "y": 2, "dir": "v"}, // Intersects at 'T'
      {
        "word": "ROSE",
        "x": 3,
        "y": 1,
        "dir": "h",
      }, // Intersects at 'R' (from REST)
    ],
  ),

  // LEVEL 10: SHINE (Theme: Result)
  GameLevel(
    letters: ["S", "H", "I", "N", "E"],
    rows: 6,
    cols: 6,
    // Using Offset(column, row)
    preFilled: [
      const Offset(0, 2), // The 'S'
      const Offset(4, 2), // The 'E'
    ],
    grid: [
      {"word": "SHINE", "x": 0, "y": 2, "dir": "h"},
      {"word": "HEN", "x": 1, "y": 1, "dir": "v"},
      {"word": "SIN", "x": 0, "y": 2, "dir": "v"},
      {"word": "SHE", "x": 0, "y": 2, "dir": "v"},
      {"word": "HIS", "x": 0, "y": 3, "dir": "h"},
    ],
  ),
];
