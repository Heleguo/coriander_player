// lib/lyric/lrc.dart

import 'dart:convert';
import 'dart:math';

import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';

class LrcWord extends SyncLyricWord {
  LrcWord(super.start, super.length, super.content);

  @override
  String toString() => '[$start-$length]$content';
}

class LrcLine extends SyncLyricLine {
  final List<LrcWord> words;
  final String? translation;
  final bool isBlank;
  
  @override
  final Duration length;

  /// 构造函数明确要求3个位置参数
  LrcLine(
    Duration start,
    this.length,
    this.words, {
    this.translation,
  }) : isBlank = (words.isEmpty || words.every((w) => w.content.trim().isEmpty)), 
       super(start, length);

  static LrcLine get defaultLine => LrcLine(
    Duration.zero,  // start
    Duration.zero,  // length
    [LrcWord(Duration.zero, Duration.zero, "无歌词")], // words
    translation: "",
  );

  @override
  String get content => words.map((w) => w.content).join();

  static LrcLine? fromLine(String line, [int? offset]) {
    // ...（保持解析逻辑不变，确保所有return语句都传递3个参数）...
  }

  static LrcLine? _parseStandardLine(String line, int? offset) {
    final regExp = RegExp(r'^\[(\d{2}:\d{2}\.\d{2})\](.*)');
    final match = regExp.firstMatch(line);
    if (match == null) return null;

    final time = _parseTime(match.group(1)!, offset);
    final content = match.group(2)?.trim() ?? '';

    return LrcLine(
      time ?? Duration.zero,  // start
      Duration.zero,         // length（临时值）
      [LrcWord(time ?? Duration.zero, Duration.zero, content)], // words
    );
  }

  // ...（其他方法保持不变）...
}

class Lrc extends Lyric {
  // ...（保持其他方法不变，关键修复如下）...

  void addBlankLines() {
    final formatted = <LrcLine>[];
    if (lines.isNotEmpty && (lines.first as LrcLine).start > const Duration(seconds: 1)) {
      formatted.add(LrcLine(
        Duration.zero,  // start
        (lines.first as LrcLine).start, // length
        [LrcWord(Duration.zero, (lines.first as LrcLine).start, '')], // words
      ));
    }

    for (int i = 0; i < lines.length - 1; i++) {
      final current = lines[i] as LrcLine;
      final next = lines[i + 1] as LrcLine;
      
      formatted.add(current);
      final gap = next.start - (current.start + current.length);
      if (gap > const Duration(seconds: 1)) {
        formatted.add(LrcLine(
          current.start + current.length, // start
          gap, // length
          [LrcWord(current.start + current.length, gap, '')], // words
        ));
      }
    }

    if (lines.isNotEmpty) formatted.add(lines.last as LrcLine);
    lines
      ..clear()
      ..addAll(formatted);
  }
}
