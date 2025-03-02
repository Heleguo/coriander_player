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
  String? translation;

  LrcLine(
    super.start,
    super.length,
    this.words, [
    this.translation,
  ]);

  @override
  String get content => words.map((w) => w.content).join();

  static LrcLine? fromLine(String line, [int? offset]) {
    final words = <LrcWord>[];
    Duration lineStart = Duration.zero;
    Duration lineEnd = Duration.zero;

    // 解析第一种增强格式：[00:12.34]Hello[00:13.45]World
    final bracketMatches = RegExp(r'\[(\d{2}:\d{2}\.\d{2})\]').allMatches(line);
    if (bracketMatches.length > 1) {
      Duration? prevTime;
      for (int i = 0; i < bracketMatches.length; i++) {
        final match = bracketMatches.elementAt(i);
        final time = _parseTime(match.group(1)!, offset);
        
        if (i == 0) lineStart = time ?? Duration.zero;
        
        if (prevTime != null && time != null) {
          final wordEnd = i < bracketMatches.length - 1 
              ? bracketMatches.elementAt(i).end 
              : line.length;
          final wordContent = line.substring(match.end, wordEnd).trim();
          words.add(LrcWord(
            prevTime,
            time - prevTime,
            wordContent
          ));
        }
        prevTime = time;
        lineEnd = time ?? lineEnd;
      }
      return LrcLine(lineStart, lineEnd - lineStart, words);
    }

    // 解析第二种增强格式：[00:12.34]<00:12.34>Hello<00:13.45>World
    final angleMatches = RegExp(r'<(\d{2}:\d{2}\.\d{2})>').allMatches(line);
    if (angleMatches.isNotEmpty) {
      final lineStartMatch = RegExp(r'^\[(\d{2}:\d{2}\.\d{2})\]').firstMatch(line);
      if (lineStartMatch != null) {
        lineStart = _parseTime(lineStartMatch.group(1)!, offset) ?? Duration.zero;
        
        Duration? currentStart;
        for (int i = 0; i < angleMatches.length; i++) {
          final match = angleMatches.elementAt(i);
          final time = _parseTime(match.group(1)!, offset);
          
          if (currentStart != null && time != null) {
            final wordEnd = i < angleMatches.length - 1 
                ? angleMatches.elementAt(i + 1).start 
                : line.length;
            final wordContent = line.substring(match.end, wordEnd).trim();
            words.add(LrcWord(
              currentStart,
              time - currentStart,
              wordContent
            ));
          }
          currentStart = time;
          lineEnd = time ?? lineEnd;
        }
        return LrcLine(lineStart, lineEnd - lineStart, words);
      }
    }

    // 解析普通LRC格式
    final standardLine = _parseStandardLine(line, offset);
    if (standardLine != null) {
      return LrcLine(
        standardLine.start,
        standardLine.length,
        [LrcWord(standardLine.start, standardLine.length, standardLine.content)],
      );
    }

    return null;
  }

  static LrcLine? _parseStandardLine(String line, int? offset) {
    final regExp = RegExp(r'^\[(\d{2}:\d{2}\.\d{2})\](.*)');
    final match = regExp.firstMatch(line);
    if (match == null) return null;

    final time = _parseTime(match.group(1)!, offset);
    final content = match.group(2)?.trim() ?? '';

    return LrcLine(
      time ?? Duration.zero,
      Duration.zero, // 长度稍后计算
      [LrcWord(time ?? Duration.zero, Duration.zero, content)],
    );
  }

  static Duration? _parseTime(String timeStr, int? offset) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;

    try {
      final minutes = int.parse(parts[0]);
      final seconds = double.parse(parts[1]);
      final totalMs = (minutes * 60 * 1000) + (seconds * 1000).round();
      return Duration(milliseconds: max(totalMs - (offset ?? 0), 0));
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => '[$start-$length]${words.join()}';
}

class Lrc extends Lyric {
  LrcSource source;

  Lrc(super.lines, this.source);

  static Lrc? fromLrcText(String lrc, LrcSource source, {String? separator}) {
    final lines = <LrcLine>[];
    int? offset;

    // 解析offset
    final offsetMatch = RegExp(r'\[offset:\s*([+-]?\d+)\s*\]').firstMatch(lrc);
    if (offsetMatch != null) {
      offset = int.tryParse(offsetMatch.group(1) ?? '');
    }

    // 解析歌词行
    for (final line in lrc.split('\n')) {
      final parsed = LrcLine.fromLine(line, offset);
      if (parsed != null) lines.add(parsed);
    }

    // 计算行持续时间
    for (int i = 0; i < lines.length; i++) {
      if (i < lines.length - 1) {
        lines[i].length = lines[i + 1].start - lines[i].start;
      } else {
        lines[i].length = const Duration(seconds: 5); // 最后一行默认5秒
      }
    }

    // 合并翻译行
    if (separator != null) {
      return _combineTranslations(lines, source, separator);
    }

    return Lrc(lines, source).._sort();
  }

  static Lrc _combineTranslations(List<LrcLine> lines, LrcSource source, String separator) {
    final combined = <LrcLine>[];
    var current = lines.first;

    for (int i = 1; i < lines.length; i++) {
      if (lines[i].start == current.start) {
        final mergedWords = [...current.words, ...lines[i].words];
        current = LrcLine(
          current.start,
          current.length,
          mergedWords,
          lines[i].content, // 保存翻译到translation字段
        );
      } else {
        combined.add(current);
        current = lines[i];
      }
    }
    combined.add(current);

    return Lrc(combined, source).._sort();
  }

  void _sort() => lines.sort((a, b) => a.start.compareTo(b.start));

  // 添加空白行处理
  void addBlankLines() {
    final formatted = <LrcLine>[];
    if (lines.isNotEmpty && lines.first.start > const Duration(seconds: 1)) {
      formatted.add(LrcLine(
        Duration.zero,
        lines.first.start,
        [LrcWord(Duration.zero, lines.first.start, '')],
      ));
    }

    for (int i = 0; i < lines.length - 1; i++) {
      formatted.add(lines[i]);
      final gap = lines[i + 1].start - (lines[i].start + lines[i].length);
      if (gap > const Duration(seconds: 1)) {
        formatted.add(LrcLine(
          lines[i].start + lines[i].length,
          gap,
          [LrcWord(lines[i].start + lines[i].length, gap, '')],
        ));
      }
    }

    if (lines.isNotEmpty) formatted.add(lines.last);
    lines
      ..clear()
      ..addAll(formatted);
  }

  static Future<Lrc?> fromAudioPath(Audio audio, {String? separator}) async {
    final lyricText = await getLyricFromPath(path: audio.path);
    if (lyricText == null) return null;
    
    final lrc = Lrc.fromLrcText(lyricText, LrcSource.local, separator: separator);
    lrc?.addBlankLines();
    return lrc;
  }
}

enum LrcSource { local, web }
