import 'dart:math';

import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';

class WordTiming {
  final Duration start;
  final Duration end;
  final String word;

  WordTiming(this.start, this.end, this.word);

  @override
  String toString() => '[$start-$end]$word';
}

class LrcLine extends UnsyncLyricLine {
  bool isBlank;
  Duration length;
  List<WordTiming>? wordTimings;

  LrcLine(
    super.start,
    super.content, {
    required this.isBlank,
    this.length = Duration.zero,
    this.wordTimings,
  });

  static LrcLine defaultLine = LrcLine(
    Duration.zero,
    "无歌词",
    isBlank: false,
    length: Duration.zero,
  );

  @override
  String toString() {
    return {
      "time": start.toString(),
      "content": content,
      "wordTimings": wordTimings?.join(',')
    }.toString();
  }

  static LrcLine? fromLine(String line, [int? offset]) {
    final enhancedLine = _parseEnhancedLine(line, offset);
    if (enhancedLine != null) return enhancedLine;
    return _parseStandardLine(line, offset);
  }

  static LrcLine? _parseEnhancedLine(String line, int? offset) {
    // 尝试解析第一种格式：[mm:ss.ms]Word[mm:ss.ms]Word...
    final bracketPattern = RegExp(r'\[(\d+:\d+\.\d+)\]');
    final bracketMatches = bracketPattern.allMatches(line);
    
    if (bracketMatches.length > 1) {
      final parts = line.split(']');
      final timings = <WordTiming>[];
      Duration? previousTime;
      String combinedContent = '';

      for (var part in parts.skip(1)) {
        final timeMatch = bracketPattern.firstMatch(part);
        if (timeMatch != null) {
          final time = _parseTime(timeMatch.group(1)!, offset);
          if (time != null) {
            final word = part.substring(timeMatch.end).trim();
            if (previousTime != null && word.isNotEmpty) {
              timings.add(WordTiming(previousTime, time, word));
              combinedContent += word;
            }
            previousTime = time;
          }
        }
      }

      if (timings.isNotEmpty) {
        return LrcLine(
          timings.first.start,
          combinedContent,
          isBlank: false,
          wordTimings: timings,
        );
      }
    }

    // 尝试解析第二种格式：[mm:ss.ms]<mm:ss.ms>Word<mm:ss.ms>...
    final anglePattern = RegExp(r'<(\d+:\d+\.\d+)>');
    final angleMatches = anglePattern.allMatches(line);
    
    if (angleMatches.isNotEmpty) {
      final lineStart = _parseTime(line.substring(1, line.indexOf(']')), offset);
      if (lineStart == null) return null;

      final contents = line.split(anglePattern);
      final timings = <WordTiming>[];
      String combinedContent = '';
      Duration? currentStart;

      for (int i = 1; i < contents.length; i += 2) {
        if (i + 1 >= contents.length) break;

        final timeStr = contents[i];
        final word = contents[i + 1].trim();
        final time = _parseTime(timeStr, offset);

        if (time != null && word.isNotEmpty) {
          if (currentStart != null) {
            timings.add(WordTiming(currentStart, time, word));
            combinedContent += word;
          }
          currentStart = time;
        }
      }

      if (timings.isNotEmpty) {
        return LrcLine(
          lineStart,
          combinedContent,
          isBlank: false,
          wordTimings: timings,
        );
      }
    }

    return null;
  }

  static LrcLine? _parseStandardLine(String line, int? offset) {
    final left = line.indexOf("[");
    final right = line.indexOf("]");

    if (left == -1 || right == -1) return null;

    final timeStr = line.substring(left + 1, right);
    final content = line.substring(right + 1)
        .trim()
        .replaceAll(RegExp(r"\[\d{2}:\d{2}\.\d{2,}\]"), "");

    final time = _parseTime(timeStr, offset);
    if (time == null) return null;

    return LrcLine(
      time,
      content,
      isBlank: content.isEmpty,
    );
  }

  static Duration? _parseTime(String timeStr, int? offset) {
    final parts = timeStr.split(":");
    if (parts.length != 2) return null;

    try {
      final minutes = int.parse(parts[0]);
      final seconds = double.parse(parts[1]);
      final totalMs = (minutes * 60 + seconds) * 1000;
      return Duration(milliseconds: max(totalMs - (offset ?? 0), 0));
    } catch (_) {
      return null;
    }
  }
}

enum LrcSource { local, web }

class Lrc extends Lyric {
  LrcSource source;

  Lrc(super.lines, this.source);

  @override
  String toString() => {"type": source, "lyric": lines}.toString();

  void _sort() {
    lines.sort((a, b) => a.start.compareTo(b.start));
  }

  Lrc _combineLrcLine(String separator) {
    final combined = <LrcLine>[];
    var currentLine = lines.first;

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.start == currentLine.start) {
        final mergedContent = '${currentLine.content}$separator${line.content}';
        final mergedTimings = [
          ...?currentLine.wordTimings,
          ...?line.wordTimings,
        ];
        currentLine = LrcLine(
          currentLine.start,
          mergedContent,
          isBlank: false,
          wordTimings: mergedTimings,
        );
      } else {
        combined.add(currentLine);
        currentLine = line;
      }
    }
    combined.add(currentLine);

    return Lrc(combined, source);
  }

  static Lrc? fromLrcText(String lrc, LrcSource source, {String? separator}) {
    final lines = <LrcLine>[];
    int? offset;

    // 解析offset
    final offsetMatch = RegExp(r'\[offset:\s*([+-]?\d+)\s*\]').firstMatch(lrc);
    if (offsetMatch != null) {
      offset = int.tryParse(offsetMatch.group(1) ?? '');
    }

    for (final line in lrc.split('\n')) {
      final parsed = LrcLine.fromLine(line, offset);
      if (parsed != null) lines.add(parsed);
    }

    if (lines.isEmpty) return null;

    // 计算持续时间
    for (int i = 0; i < lines.length; i++) {
      final current = lines[i];
      if (current.wordTimings?.isNotEmpty ?? false) {
        final lastWord = current.wordTimings!.last;
        current.length = lastWord.end - current.start;
      } else if (i < lines.length - 1) {
        current.length = lines[i + 1].start - current.start;
      } else {
        current.length = Duration.zero;
      }
    }

    final result = Lrc(lines, source).._sort();
    return separator != null ? result._combineLrcLine(separator) : result;
  }

  static Future<Lrc?> fromAudioPath(Audio audio, {String? separator}) async {
    final lyricText = await getLyricFromPath(path: audio.path);
    if (lyricText == null) return null;
    return Lrc.fromLrcText(lyricText, LrcSource.local, separator: separator);
  }
}
