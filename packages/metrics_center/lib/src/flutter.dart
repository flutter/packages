// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'common.dart';
import 'constants.dart';
import 'legacy_datastore.dart';
import 'legacy_flutter.dart';
import 'skiaperf.dart';

/// Convenient class to capture the benchmarks in the Flutter engine repo.
class FlutterEngineMetricPoint extends MetricPoint {
  /// Creates a metric point for the Flutter engine repository.
  ///
  /// The `name`, `value`, and `gitRevision` parameters must not be null.
  FlutterEngineMetricPoint(
    String name,
    double value,
    String gitRevision, {
    Map<String, String> moreTags = const <String, String>{},
  }) : super(
          value,
          <String, String>{
            kNameKey: name,
            kGithubRepoKey: kFlutterEngineRepo,
            kGitRevisionKey: gitRevision,
          }..addAll(moreTags),
        );
}

/// All Flutter performance metrics (framework, engine, ...) should be written
/// to this destination.
class FlutterDestination extends MetricDestination {
  // TODO(liyuqian): change the implementation of this class (without changing
  // its public APIs) to remove `LegacyFlutterDestination` and directly use
  // `SkiaPerfDestination` once the migration is fully done.
  FlutterDestination._(this._legacyDestination, this._skiaPerfDestination);

  /// Creates a [FlutterDestination] from service account JSON.
  static Future<FlutterDestination> makeFromCredentialsJson(
      Map<String, dynamic> json,
      {bool isTesting = false}) async {
    // Specify the project id for LegacyFlutterDestination as we may get a
    // service account json from another GCP project.
    final LegacyFlutterDestination legacyDestination =
        await LegacyFlutterDestination.makeFromCredentialsJson(json,
            projectId: 'flutter-cirrus');
    final SkiaPerfDestination skiaPerfDestination =
        await SkiaPerfDestination.makeFromGcpCredentials(json,
            isTesting: isTesting);
    return FlutterDestination._(legacyDestination, skiaPerfDestination);
  }

  /// Creates a [FlutterDestination] from an OAuth access token.
  static Future<FlutterDestination> makeFromAccessToken(
      String accessToken, String projectId,
      {bool isTesting = false}) async {
    final LegacyFlutterDestination legacyDestination = LegacyFlutterDestination(
        datastoreFromAccessToken(accessToken, projectId));
    final SkiaPerfDestination skiaPerfDestination =
        await SkiaPerfDestination.makeFromAccessToken(accessToken, projectId,
            isTesting: isTesting);
    return FlutterDestination._(legacyDestination, skiaPerfDestination);
  }

  @override
  Future<void> update(List<MetricPoint> points) async {
    await _legacyDestination.update(points);
    await _skiaPerfDestination.update(points);
  }

  final LegacyFlutterDestination _legacyDestination;
  final SkiaPerfDestination _skiaPerfDestination;
}
