// @dart=2.9
import 'package:cgmblekit_flutter/messages.dart';
import 'package:cgmblekit_flutter/messages_extensions.dart';
import 'package:charts_common/common.dart' as charts_common;
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TODO: Add the following data to the chart:
//   - BG prediction curve.
//   - Slider to inspect data. Sync with other charts.
//   - Correct color for correction range.
class GlucoseChart extends StatelessWidget {
  final List<GlucoseSample> samples;
  final List<charts.Series> seriesList;

  final _correctionRangeLower = 85;
  final _correctionRangeUpper = 95;

  GlucoseChart(this.samples, this.seriesList);

  factory GlucoseChart.withGlucoseSamples(List<GlucoseSample> samples) {
    return new GlucoseChart(samples, _createSeries(samples));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                'Glucose',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'Eventually 85 mg/dL',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(150, 0, 0, 0)),
              ),
            ],
          ),
          Container(
            height: 200,
            child: charts.TimeSeriesChart(
              seriesList,
              defaultRenderer: charts.PointRendererConfig(radiusPx: 2),
              domainAxis: charts.DateTimeAxisSpec(
                tickProviderSpec:
                    charts.StaticDateTimeTickProviderSpec(_domainTickSpecs()),
                tickFormatterSpec:
                    charts_common.BasicDateTimeTickFormatterSpec.fromDateFormat(
                        DateFormat.j()),
                showAxisLine: false,
              ),
              primaryMeasureAxis: charts.NumericAxisSpec(
                tickProviderSpec:
                    charts.StaticNumericTickProviderSpec(_measureTickSpecs()),
                showAxisLine: false,
              ),
              behaviors: [
                new charts.RangeAnnotation([
                  new charts.RangeAnnotationSegment(
                      _correctionRangeLower,
                      _correctionRangeUpper,
                      charts.RangeAnnotationAxisType.measure,
                      color: charts.MaterialPalette.gray.shade300),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<charts.TickSpec<DateTime>> _domainTickSpecs() {
    DateTime now = DateTime.now();
    // Show the last full hour of data, starting at the beginning of that hour.
    DateTime start = now.subtract(Duration(
        hours: 1,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond));
    List<charts.TickSpec<DateTime>> tickSpecs = List.from([]);
    for (var i = 0; i < 8; i++) {
      tickSpecs.add(charts.TickSpec(start.add(Duration(hours: i))));
    }
    return tickSpecs;
  }

  List<charts.TickSpec<num>> _measureTickSpecs() {
    // Every 25 mg/dL. Default 75 - 175, but go down to 0 and up to 25 over
    // largest data point in the series.
    const tickSize = 25;
    const defaultMinTick = 75;
    const defaultMaxTick = 175;
    var minSample = samples.reduce((value, element) =>
        value.quantity < element.quantity ? value : element);
    var lowerTickAdjustment =
        ((defaultMinTick - minSample.quantity) / tickSize).floor() * tickSize +
            tickSize;
    var maxSample = samples.reduce((value, element) =>
        value.quantity > element.quantity ? value : element);
    var upperTickAdjustment =
        ((maxSample.quantity - defaultMaxTick) / tickSize).ceil() * tickSize +
            tickSize;
    var minTick = min(defaultMinTick, defaultMinTick + lowerTickAdjustment);
    var maxTick = max(defaultMaxTick, defaultMaxTick + upperTickAdjustment);
    List<charts.TickSpec<num>> tickSpecs = List.from([]);
    for (var t = minTick; t <= maxTick; t += tickSize) {
      tickSpecs.add(charts.TickSpec(t));
    }
    return tickSpecs;
  }

  static List<charts.Series<GlucoseSample, DateTime>> _createSeries(
      List<GlucoseSample> samples) {
    return [
      new charts.Series<GlucoseSample, DateTime>(
        id: 'Glucose',
        domainFn: (GlucoseSample glucose, _) => glucose.date(),
        measureFn: (GlucoseSample glucose, _) => glucose.quantity,
        data: samples,
      )
    ];
  }
}
