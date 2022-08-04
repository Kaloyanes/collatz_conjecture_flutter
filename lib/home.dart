import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _imageFile = null;
  var nController = TextEditingController(text: "");
  ScreenshotController screenshotController = ScreenshotController();

  var datas = <LineChartBarData>[];
  var doneNumbers = <int>[];
  var comboBoxItems = <ComboboxItem<String>>[];

  var placeholder = "History";

  void collatz(int n) {
    if (doneNumbers.contains(n)) {
      showDialog(
        context: context,
        builder: (context) {
          return mat.AlertDialog(
            title: const Text("Error"),
            content: const Text("Number already calculated"),
            actions: [
              Button(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }
    doneNumbers.add(n);

    var spots = <FlSpot>[];
    Color randomColor =
        mat.Colors.primaries[Random().nextInt(mat.Colors.primaries.length)];

    int max = 0;
    int steps = 1;
    spots.add(FlSpot(steps.toDouble(), n.toDouble()));
    while (n > 1) {
      if (n % 2 == 0) {
        n = n ~/ 2;
      } else {
        n = 3 * n + 1;
      }

      if (n > max) {
        max = n;
      }

      steps++;
      spots.add(FlSpot(steps.toDouble(), n.toDouble()));
    }

    var comboBoxString =
        "#${doneNumbers[doneNumbers.length - 1]} | Max: $max | Steps: $steps";

    setState(() {
      datas.add(
        LineChartBarData(
          isCurved: true,
          color: randomColor,
          spots: spots,
          belowBarData: BarAreaData(
            show: true,
            color: randomColor.withOpacity(0.2),
          ),
        ),
      );
      comboBoxItems.add(ComboboxItem<String>(
        value: comboBoxString,
        child: Text(comboBoxString),
      ));
      placeholder = comboBoxString;
    });
  }

  void screenshot() async {
    // get how many files are in the directory
    var dir = Directory("screenshots");
    var files = dir.listSync();

    var fileName = "screenshot ${files.length + 1}.png";

    await screenshotController.captureAndSave(
      "screenshots/",
      fileName: fileName,
      pixelRatio: 4,
    );

    // open in file explorer
    if (Platform.isWindows) {
      Process.runSync(
        "explorer.exe",
        [
          "screenshots",
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Text(
              'N =',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 300,
              child: TextBox(
                controller: nController,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            SizedBox(
              width: 290,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Button(
                    onPressed: () {
                      collatz(int.parse(nController.text));
                    },
                    child: const Text("Generate"),
                  ),
                  Button(
                    onPressed: () {
                      for (int i = int.parse(nController.text); i >= 4; i--) {
                        collatz(i);
                      }
                    },
                    child: const Text("Count to 1"),
                  ),
                  Button(
                    onPressed: () {
                      if (nController.text.isNotEmpty) {
                        int limit = int.parse(nController.text);
                        int value = Random().nextInt(limit) + 1;
                        while (true) {
                          if (value >= 3 && !doneNumbers.contains(value)) {
                            break;
                          }
                          value = Random().nextInt(limit) + 1;
                        }
                        collatz(Random().nextInt(limit) - 1);
                      } else {
                        int value = Random().nextInt(4294967296) + 1;
                        while (true) {
                          if (value >= 3 && !doneNumbers.contains(value)) {
                            break;
                          }
                          value = Random().nextInt(4294967296) + 1;
                        }
                        collatz(value);
                      }
                    },
                    child: const Text("Random"),
                  )
                ],
              ),
            ),
            const Spacer(),
            Combobox<String>(
              onChanged: (value) {
                setState(() {
                  placeholder = value!;
                });
              },
              items: comboBoxItems,
              placeholder: Text(placeholder),
            ),
            const Spacer(),
            Button(
              onPressed: () {
                setState(() {
                  datas = <LineChartBarData>[];
                  doneNumbers = <int>[];
                  comboBoxItems = <ComboboxItem<String>>[];
                  placeholder = "History";
                });
              },
              child: const Text("Clear"),
            ),
            const SizedBox(
              width: 10,
            ),
            Button(
              onPressed: () => screenshot(),
              child: const Text("Screenshot"),
            )
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Screenshot(
          controller: screenshotController,
          child: LineChart(
            LineChartData(
              borderData: FlBorderData(
                show: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text("Steps"),
                  sideTitles: SideTitles(
                    reservedSize: 30,
                    showTitles: false,
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text("Value"),
                  sideTitles: SideTitles(
                    reservedSize: 30,
                    showTitles: false,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
              lineBarsData: datas,
              gridData: FlGridData(
                drawHorizontalLine: false,
                drawVerticalLine: false,
              ),
            ),
            swapAnimationCurve: Curves.easeInOutQuart,
            swapAnimationDuration: const Duration(seconds: 1),
          ),
        ),
      ),
    );
  }
}
