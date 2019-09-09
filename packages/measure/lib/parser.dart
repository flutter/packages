// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

class CpuGpuResult {
  CpuGpuResult(this.gpuPercentage, this.cpuPercentage);

  final double gpuPercentage;
  final double cpuPercentage;

  @override
  String toString() {
    return 'gpu: $gpuPercentage%, cpu: $cpuPercentage%';
  }

  void writeToJsonFile(String filename) {
    final String output = json.encode(<String, double>{
      'gpu_percentage': gpuPercentage,
      'cpu_percentage': cpuPercentage
    });
    File(filename).writeAsStringSync(output);
  }
}

class IosTraceParser {
  IosTraceParser(this.isVerbose, this.traceUtilityPath);

  final bool isVerbose;
  final String traceUtilityPath;

  List<String> _gpuMeasurements;
  List<String> _cpuMeasurements;

  CpuGpuResult parseCpuGpu(String filename, String processName) {
    final ProcessResult result = Process.runSync(
      traceUtilityPath,
      <String>[filename],
    );
    if (result.exitCode != 0) {
      print('TraceUtility stdout:\n${result.stdout.toString}\n\n');
      print('TraceUtility stderr:\n${result.stderr.toString}\n\n');
      throw Exception('TraceUtility failed with exit code ${result.exitCode}');
    }
    final List<String> lines = result.stderr.toString().split('\n');

    // toSet to remove duplicates
    _gpuMeasurements =
        lines.where((String s) => s.contains('GPU')).toSet().toList();
    _cpuMeasurements =
        lines.where((String s) => s.contains(processName)).toSet().toList();
    _gpuMeasurements.sort();
    _cpuMeasurements.sort();

    if (isVerbose) {
      _gpuMeasurements.forEach(print);
      _cpuMeasurements.forEach(print);
    }

    return CpuGpuResult(_computeGpuPercent(), _computeCpuPercent());
  }

  static final RegExp _percentagePattern = RegExp(r'(\d+(\.\d*)?)%');
  double _parseSingleGpuMeasurement(String line) {
    return double.parse(_percentagePattern.firstMatch(line).group(1));
  }

  double _computeGpuPercent() {
    return _average(_gpuMeasurements.map(_parseSingleGpuMeasurement));
  }

  // The return is a list of 2: the 1st is the time key string, the 2nd is the
  // double percentage
  List<dynamic> _parseSingleCpuMeasurement(String line) {
    final String timeKey = line.substring(0, line.indexOf(','));
    final RegExpMatch match = _percentagePattern.firstMatch(line);
    return <dynamic>[
      timeKey,
      match == null
          ? 0
          : double.parse(_percentagePattern.firstMatch(line).group(1))
    ];
  }

  double _computeCpuPercent() {
    final Iterable<List<dynamic>> results =
        _cpuMeasurements.map(_parseSingleCpuMeasurement);
    final Map<String, double> sums = <String, double>{};
    for (List<dynamic> pair in results) {
      sums[pair[0]] = 0;
    }
    for (List<dynamic> pair in results) {
      sums[pair[0]] += pair[1];
    }

    // This key always has 0% usage. Remove it.
    assert(sums['00:00.000.000'] == 0);
    sums.remove('00:00.000.000');

    if (isVerbose) {
      print('CPU maps: $sums');
    }
    return _average(sums.values);
  }

  double _average(Iterable<double> values) {
    if (values == null || values.isEmpty) {
      _gpuMeasurements.forEach(print);
      _cpuMeasurements.forEach(print);
      throw Exception('No valid measurements found.');
    }
    return values.reduce((double a, double b) => a + b) / values.length;
  }
}
