// @dart=2.9
import 'package:cgmblekit_flutter/messages.dart';
import 'package:cgmblekit_flutter/messages_extensions.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GlucoseChart extends StatelessWidget {
  final List<charts.Series> seriesList;

  GlucoseChart(this.seriesList);

  /// Creates a [ScatterPlotChart] with sample data and no transition.
  factory GlucoseChart.withGlucoseSamples(List<GlucoseSample> samples) {
    return new GlucoseChart(_createSeries(samples));
  }

  @override
  Widget build(BuildContext context) {
    return new charts.ScatterPlotChart(
      seriesList,
      domainAxis: charts.NumericAxisSpec(
        // TODO: Use StaticDateTimeTickProviderSpec instead.
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
            zeroBound: false, dataIsInWholeNumbers: true),
        tickFormatterSpec:
            charts.BasicNumericTickFormatterSpec(GlucoseChart._formatDomain),
        viewport: GlucoseChart._domainExtents(),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec:
              charts.BasicNumericTickProviderSpec(zeroBound: true)),
    );
  }

  static charts.NumericExtents _domainExtents() {
    DateTime now = DateTime.now();
    DateTime start = now.subtract(Duration(hours: 1));
    DateTime end = now.add(Duration(hours: 7));
    return charts.NumericExtents(start.millisecondsSinceEpoch.toDouble(),
        end.millisecondsSinceEpoch.toDouble());
  }

  static String _formatDomain(num epochMs) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(epochMs.round());
    return DateFormat.j().format(date);
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GlucoseSample, int>> _createSeries(
      List<GlucoseSample> samples) {
    return [
      new charts.Series<GlucoseSample, int>(
        id: 'Glucose',
        domainFn: (GlucoseSample glucose, _) =>
            glucose.date().millisecondsSinceEpoch,
        measureFn: (GlucoseSample glucose, _) => glucose.quantity,
        data: samples,
      )
    ];
  }
}
