import 'dart:math';

import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';

class LrcLine extends UnsyncLyricLine {
  bool isBlank;
  Duration length;

  LrcLine(super.start, super.content,
      {required this.isBlank, this.length = Duration.zero});

  static LrcLine defaultLine = LrcLine(
    Duration.zero,
    "无歌词",
    isBlank: false,
    length: Duration.zero,
  );

  @override
  String toString() {
    return {"time": start.toString(), "content": content}.toString();
  }

  /// line: [mm:ss.msms]content
  static LrcLine? fromLine(String line, [int? offset]) {
    if (line.trim().isEmpty) {
      return null;
    }

    final left = line.indexOf("[");
    final right = line.indexOf("]");

    if (left == -1 || right == -1) {
      return null;
    }

    var lrcTimeString = line.substring(left + 1, right);

    // replace [mm:ss.msms...] with ""
    var content = line
        .substring(right + 1)
        .trim()
        .replaceAll(RegExp(r"\[\d{2}:\d{2}\.\d{2,}\]"), "");

    var timeList = lrcTimeString.split(":");
    int? minute;
    double? second;
    if (timeList.length >= 2) {
      minute = int.tryParse(timeList[0]);
      second = double.tryParse(timeList[1]);
    }

    if (minute == null || second == null) {
      return null;
    }

    var inMilliseconds = ((minute * 60 + second) * 1000).toInt();

    return LrcLine(
      Duration(
        milliseconds: max(inMilliseconds - (offset ?? 0), 0),
      ),
      content,
      isBlank: content.isEmpty,
    );
  }

  /// Parse enhanced LRC format 1: [mm:ss.msms]Word[mm:ss.msms]Word[mm:ss.msms]Word[mm:ss.msms]
  static SyncLyricLine? fromEnhancedLrcFormat1(String line, [int? offset]) {
    if (line.trim().isEmpty) {
      return null;
    }

    final lineStartMatch = RegExp(r'^\[(\d{2}:\d{2}\.\d{2,})\]').firstMatch(line);
    if (lineStartMatch == null) {
      return null;
    }

    final lineStartTimeString = lineStartMatch.group(1)!;
    final lineStartTimeList = lineStartTimeString.split(":");
    int? lineStartMinute = int.tryParse(lineStartTimeList[0]);
    double? lineStartSecond = double.tryParse(lineStartTimeList[1]);
    if (lineStartMinute == null || lineStartSecond == null) {
      return null;
    }

    final lineStartInMilliseconds = ((lineStartMinute * 60 + lineStartSecond) * 1000).toInt();
    final lineStart = Duration(milliseconds: max(lineStartInMilliseconds - (offset ?? 0), 0));

    final wordMatches = RegExp(r'\[(\d{2}:\d{2}\.\d{2,})\]([^[]+)').allMatches(line);
    if (wordMatches.isEmpty) {
      return null;
    }

    final words = <SyncLyricWord>[];
    Duration previousWordEnd = lineStart;
    for (final match in wordMatches) {
      final wordEndTimeString = match.group(1)!;
      final wordEndTimeList = wordEndTimeString.split(":");
      int? wordEndMinute = int.tryParse(wordEndTimeList[0]);
      double? wordEndSecond = double.tryParse(wordEndTimeList[1]);
      if (wordEndMinute == null || wordEndSecond == null) {
        continue;
      }

      final wordEndInMilliseconds = ((wordEndMinute * 60 + wordEndSecond) * 1000).toInt();
      final wordEnd = Duration(milliseconds: max(wordEndInMilliseconds - (offset ?? 0), 0));

      final wordContent = match.group(2)!;
      final wordStart = previousWordEnd;
      final wordLength = wordEnd - wordStart;

      words.add(SyncLyricWord(wordStart, wordLength, wordContent));
      previousWordEnd = wordEnd;
    }

    final lineLength = previousWordEnd - lineStart;
    return SyncLyricLine(lineStart, lineLength, words);
  }

  /// Parse enhanced LRC format 2: [mm:ss.msms]<mm:ss.msms>Word<mm:ss.msms>Word<mm:ss.msms>Word
  static SyncLyricLine? fromEnhancedLrcFormat2(String line, [int? offset]) {
    if (line.trim().isEmpty) {
      return null;
    }

    final lineStartMatch = RegExp(r'^\[(\d{2}:\d{2}\.\d{2,})\]').firstMatch(line);
    if (lineStartMatch == null) {
      return null;
    }

    final lineStartTimeString = lineStartMatch.group(1)!;
    final lineStartTimeList = lineStartTimeString.split(":");
    int? lineStartMinute = int.tryParse(lineStartTimeList[0]);
    double? lineStartSecond = double.tryParse(lineStartTimeList[1]);
    if (lineStartMinute == null || lineStartSecond == null) {
      return null;
    }

    final lineStartInMilliseconds = ((lineStartMinute * 60 + lineStartSecond) * 1000).toInt();
    final lineStart = Duration(milliseconds: max(lineStartInMilliseconds - (offset ?? 0), 0));

    final wordMatches = RegExp(r'<(\d{2}:\d{2}\.\d{2,})>([^<]+)<(\d{2}:\d{2}\.\d{2,})>').allMatches(line);
    if (wordMatches.isEmpty) {
      return null;
    }

    final words = <SyncLyricWord>[];
    for (final match in wordMatches) {
      final wordStartTimeString = match.group(1)!;
      final wordStartTimeList = wordStartTimeString.split(":");
      int? wordStartMinute = int.tryParse(wordStartTimeList[0]);
      double? wordStartSecond = double.tryParse(wordStartTimeList[1]);
      if (wordStartMinute == null || wordStartSecond == null) {
        continue;
      }

      final wordStartInMilliseconds = ((wordStartMinute * 60 + wordStartSecond) * 1000).toInt();
      final wordStart = Duration(milliseconds: max(wordStartInMilliseconds - (offset ?? 0), 0));

      final wordEndTimeString = match.group(3)!;
      final wordEndTimeList = wordEndTimeString.split(":");
      int? wordEndMinute = int.tryParse(wordEndTimeList[0]);
      double? wordEndSecond = double.tryParse(wordEndTimeList[1]);
      if (wordEndMinute == null || wordEndSecond == null) {
        continue;
      }

      final wordEndInMilliseconds = ((wordEndMinute * 60 + wordEndSecond) * 1000).toInt();
      final wordEnd = Duration(milliseconds: max(wordEndInMilliseconds - (offset ?? 0), 0));

      final wordContent = match.group(2)!;
      final wordLength = wordEnd - wordStart;

      words.add(SyncLyricWord(wordStart, wordLength, wordContent));
    }

    final lineLength = words.isNotEmpty ? words.last.start + words.last.length - lineStart : Duration.zero;
    return SyncLyricLine(lineStart, lineLength, words);
  }
}

enum LrcSource {
  /// mp3: USLT frame
  /// flac: LYRICS comment
  local("本地"),
  web("网络");

  final String name;

  const LrcSource(this.name);
}

class Lrc extends Lyric {
  LrcSource source;

  Lrc(super.lines, this.source);

  @override
  String toString() {
    return {"type": source, "lyric": lines}.toString();
  }

  /// 歌词一般是有序的
  /// 按照时间升序排序，保留原文和译文的顺序，需要使用稳定的排序算法
  /// 这里使用插入排序
  void _sort() {
    for (int i = 1; i < lines.length; i++) {
      var temp = lines[i];
      int j;
      for (j = i; j > 0 && lines[j - 1].start > temp.start; j--) {
        lines[j] = lines[j - 1];
      }
      lines[j] = temp;
    }
  }

  /// line_1 and line_2时间戳相同，合并成line_1[separator]line_2
  Lrc _combineLrcLine(String separator) {
    List<LrcLine> combinedLines = [];
    var buf = StringBuffer();
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].start != lines[i - 1].start) {
        buf.write((lines[i - 1] as UnsyncLyricLine).content);
        combinedLines.add(LrcLine(
          lines[i - 1].start,
          buf.toString(),
          isBlank: (lines[i - 1] as LrcLine).isBlank,
          length: (lines[i - 1] as LrcLine).length,
        ));
        buf.clear();
      } else {
        buf.write((lines[i - 1] as UnsyncLyricLine).content);
        buf.write(separator);
      }
    }
    if (lines.isNotEmpty) {
      buf.write((lines.last as UnsyncLyricLine).content);
      combinedLines.add(LrcLine(
        lines.last.start,
        buf.toString(),
        isBlank: (lines.last as LrcLine).isBlank,
        length: (lines.last as LrcLine).length,
      ));
    }

    return Lrc(combinedLines, source);
  }

  /// 如果separator为null，不合并歌词；否则，合并相同时间戳的歌词
  static Lrc? fromLrcText(String lrc, LrcSource source, {String? separator}) {
    var lrcLines = lrc.split("\n");

    int? offsetInMilliseconds;
    final offsetPattern = RegExp(r'\[\s*offset\s*:\s*([+-]?\d+)\s*\]');
    for (var line in lrcLines) {
      final matched = offsetPattern.firstMatch(line);
      if (matched == null) continue;
      offsetInMilliseconds = int.tryParse(matched.group(1) ?? "");
      break;
    }

    var lines = <LyricLine>[];
    for (int i = 0; i < lrcLines.length; i++) {
      var lyricLine = LrcLine.fromLine(lrcLines[i], offsetInMilliseconds);
      if (lyricLine == null) {
        lyricLine = LrcLine.fromEnhancedLrcFormat1(lrcLines[i], offsetInMilliseconds);
        if (lyricLine == null) {
          lyricLine = LrcLine.fromEnhancedLrcFormat2(lrcLines[i], offsetInMilliseconds);
        }
      }
      if (lyricLine != null) {
        lines.add(lyricLine);
      }
    }

    if (lines.isEmpty) {
      return null;
    }

    for (var i = 0; i < lines.length - 1; i++) {
      if (lines[i] is LrcLine && lines[i + 1] is LrcLine) {
        (lines[i] as LrcLine).length = (lines[i + 1] as LrcLine).start - (lines[i] as LrcLine).start;
      }
    }
    if (lines.isNotEmpty && lines.last is LrcLine) {
      (lines.last as LrcLine).length = Duration.zero;
    }

    final result = Lrc(lines, source);
    result._sort();

    if (separator != null) {
      result = result._combineLrcLine(separator);
    }

    return result;
  }
}
