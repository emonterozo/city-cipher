import 'package:flutter/material.dart';

class GameLevel {
  final String id;
  final int level;
  final List<String> letters;
  final int rows;
  final int cols;
  final List<WordPlacement> grid;
  final List<Offset> preFilled;

  GameLevel({
    required this.id,
    required this.level,
    required this.letters,
    required this.rows,
    required this.cols,
    required this.grid,
    required this.preFilled,
  });

  factory GameLevel.fromJson(Map<String, dynamic> json) {
    final grid = (json['grid'] as List)
        .map((e) => WordPlacement.fromJson(e))
        .toList();

    final prefillCount = json['prefilled_count'] ?? 0;

    return GameLevel(
      id: json['_id'],
      level: json['level'],
      letters: List<String>.from(json['letters']),
      rows: json['rows'],
      cols: json['cols'],
      grid: grid,
      preFilled: _generatePreFilled(grid, prefillCount),
    );
  }

  static List<Offset> _generatePreFilled(List<WordPlacement> grid, int count) {
    final allCells = <Offset>{};

    for (final word in grid) {
      for (int i = 0; i < word.word.length; i++) {
        if (word.isHorizontal) {
          allCells.add(Offset((word.x + i).toDouble(), word.y.toDouble()));
        } else {
          allCells.add(Offset(word.x.toDouble(), (word.y + i).toDouble()));
        }
      }
    }

    final list = allCells.toList()..shuffle();

    return list.take(count).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'level': level,
      'letters': letters,
      'rows': rows,
      'cols': cols,
      'grid': grid.map((e) => e.toJson()).toList(),
    };
  }
}

class WordPlacement {
  final String id;
  final String word;
  final int x;
  final int y;
  final String dir;

  WordPlacement({
    required this.id,
    required this.word,
    required this.x,
    required this.y,
    required this.dir,
  });

  factory WordPlacement.fromJson(Map<String, dynamic> json) {
    return WordPlacement(
      id: json['_id'],
      word: json['word'],
      x: json['x'],
      y: json['y'],
      dir: json['dir'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'word': word, 'x': x, 'y': y, 'dir': dir};
  }

  bool get isHorizontal => dir == 'h';
  bool get isVertical => dir == 'v';
}
