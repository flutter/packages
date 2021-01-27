// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(liyuqian): Remove this legacy file once the migration is fully done.
// See go/flutter-metrics-center-migration for detailed plans.
import 'dart:convert';
import 'dart:math';

import 'package:gcloud/db.dart';

import 'common.dart';
import 'constants.dart';
import 'legacy_datastore.dart';

/// This model corresponds to the existing data model 'MetricPoint' used in the
/// flutter-cirrus GCP project.
///
/// The originId and sourceTimeMicros fields are no longer used but we are still
/// providing valid values to them so it's compatible with old code and services
/// during the migration.
@Kind(name: 'MetricPoint', idType: IdType.String)
class LegacyMetricPointModel extends Model<String> {
  /// Initializes a metrics point data model for the flutter-cirrus GCP project.
  LegacyMetricPointModel({MetricPoint fromMetricPoint}) {
    if (fromMetricPoint != null) {
      id = fromMetricPoint.id;
      value = fromMetricPoint.value;
      originId = 'legacy-flutter';
      sourceTimeMicros = null;
      tags = fromMetricPoint.tags.keys
          .map((String key) =>
              jsonEncode(<String, dynamic>{key: fromMetricPoint.tags[key]}))
          .toList();
    }
  }

  /// The value of this metric.
  @DoubleProperty(required: true, indexed: false)
  double value;

  /// Any tags associated with this metric.
  @StringListProperty()
  List<String> tags;

  /// The origin of this metric, which is no longer used.
  @StringProperty(required: true)
  String originId;

  /// The sourceTimeMicros field, which is no longer used.
  @IntProperty(propertyName: kSourceTimeMicrosName)
  int sourceTimeMicros;
}

/// A [FlutterDestination] that is backwards compatible with the flutter-cirrus
/// GCP project.
class LegacyFlutterDestination extends MetricDestination {
  /// Creates a legacy destination compatible with the flutter-cirrus GCP
  /// project.
  LegacyFlutterDestination(this._db);

  /// Creates this destination from a service account credentials JSON file.
  static Future<LegacyFlutterDestination> makeFromCredentialsJson(
    Map<String, dynamic> json, {
    String projectId,
  }) async {
    return LegacyFlutterDestination(
        await datastoreFromCredentialsJson(json, projectId: projectId));
  }

  /// Creates this destination to authorize with an OAuth access token.
  static LegacyFlutterDestination makeFromAccessToken(
      String accessToken, String projectId) {
    return LegacyFlutterDestination(
        datastoreFromAccessToken(accessToken, projectId));
  }

  @override
  Future<void> update(List<MetricPoint> points) async {
    final List<LegacyMetricPointModel> flutterCenterPoints = points
        .map((MetricPoint p) => LegacyMetricPointModel(fromMetricPoint: p))
        .toList();

    for (int start = 0; start < points.length; start += kMaxBatchSize) {
      final int end = min(start + kMaxBatchSize, points.length);
      await _db.withTransaction((Transaction tx) async {
        tx.queueMutations(inserts: flutterCenterPoints.sublist(start, end));
        await tx.commit();
      });
    }
  }

  final DatastoreDB _db;
}
