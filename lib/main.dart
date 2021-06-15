import 'package:cgmblekit_flutter/cgmblekit_flutter.dart';
import 'package:cgmblekit_flutter/messages.dart';
import 'package:cgmblekit_flutter/messages_extensions.dart';
import 'package:flutter/material.dart';
import 'glucose_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Loop'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<GlucoseSample> _glucoseSamples = List.from([]);

  void _updateLatestGlucose(GlucoseSample glucoseSample) {
    setState(() {
      _glucoseSamples.add(glucoseSample);
    });
  }

  Future<void> initCGM() async {
    await CgmblekitFlutter.listenForTransmitter(
        "8NA0LY", this._updateLatestGlucose);
  }

  @override
  void initState() {
    super.initState();
    initCGM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Latest glucose reading: ${_glucoseSamples.isEmpty ? "none" : _glucoseSamples.last.description()}',
            ),
            GlucoseChart.withGlucoseSamples(_glucoseSamples),
          ],
        ),
      ),
    );
  }
}
