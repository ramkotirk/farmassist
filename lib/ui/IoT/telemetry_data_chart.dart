import 'package:farmassist/data/IoT/telemetry_data_repository.dart';
import 'package:farmassist/ui/IoT/telemetry_data_card_item.dart';
import 'package:farmassist/utils/fixed_sized_queue.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TelemetryDataChart extends StatefulWidget {
  TelemetryDataChart({
    required this.data,
    required this.numData,
    required this.cardItem,
  })  : spots = LineChartSpots(numData),
        bottomTitles = FixedSizedQueue(numData),
        xIndexes = Iterable<int>.generate(numData).toList();

  final String data;
  final int numData;
  final LineChartSpots spots;
  final FixedSizedQueue<String> bottomTitles;
  final xIndexes;
  final TelemetryDataCardItem cardItem;

  @override
  _TelemetryDataChartState createState() => _TelemetryDataChartState();
}

class _TelemetryDataChartState extends State<TelemetryDataChart> {
  bool _hasReadPrev = false;
  DateTime _prevTimestamp = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Widget build(BuildContext context) {
    // Tries to read previous telemetry data.
    if (!_hasReadPrev) {
      return FutureBuilder<List<TelemetryData>>(
        // Use Provider.of() method due to stricter restrictions imposed by
        // context.read() method when it is called inside a build function.
        future: RepositoryProvider.of<TelemetryDataRepository>(
          context,
          listen: false,
        ).readPrevReadings(widget.data, widget.numData),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            // Adds previous data into line chart points.
            snapshot.data!.forEach((data) {
              widget.spots.add(data.value);
              widget.bottomTitles.add(DateFormat.ms().format(data.timestamp));
              // Saves timestamp of last added data
              _prevTimestamp = data.timestamp;
            });
            Future.delayed(Duration.zero, () {
              setState(() {
                _hasReadPrev = true;
              });
            });
          } else if (snapshot.hasError) {
            Future.delayed(Duration.zero, () {
              setState(() {
                _hasReadPrev = true;
              });
            });
          }
          return Container();
        },
      );
    }
    // After finished reading previous data,
    else {
      TelemetryData data = context.watch<TelemetryData>();
      // Avoids adding duplicate data since the data stream automatically
      // fetches the last added data in the first fetch.
      if (data != null && data.timestamp != _prevTimestamp) {
        widget.spots.add(data.value);
        widget.bottomTitles.add(DateFormat.ms().format(data.timestamp));
      }

      if (widget.spots.length == 0) {
        return Container();
      } else {
        return _buildlineChart();
      }
    }
  }

  LineChart _buildlineChart() {
    return LineChart(
      LineChartData(
        lineTouchData: _lineTouchData(),
        lineBarsData: _lineBarsData(widget.spots),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            _horizontalLine(widget.cardItem.lowerThreshold),
            _horizontalLine(widget.cardItem.upperThreshold),
          ],
        ),
        clipData: FlClipData.all(),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        // Decrements 1.0 by 0.2 to avoid points be blocked by the drawing region.
        minX: 0.8,
        // Increments by 0.2 to avoid points be blocked by the drawing region.
        maxX: widget.numData.toDouble() + 0.2,
        maxY: widget.cardItem.upperBoundary,
        minY: widget.cardItem.lowerBoundary,
      ),
    );
  }

  List<LineChartBarData> _lineBarsData(LineChartSpots spots) {
    return [
      LineChartBarData(
        spots: spots.toList(),
        showingIndicators: widget.xIndexes,
        isCurved: true,
        curveSmoothness: 0,
        barWidth: 4,
        isStrokeCapRound: true,
        shadow: const Shadow(
          blurRadius: 10,
          color: Colors.black,
        ),
        belowBarData: BarAreaData(
          show: true,
        ),
        dotData: FlDotData(
          show: true,
          getDotPainter: (_, __, ___, ____) {
            return FlDotCirclePainter(
              radius: 5,
              color: Colors.red,
              strokeWidth: 2,
              strokeColor: Colors.black,
            );
          },
        ),
      ),
    ];
  }

  LineTouchData _lineTouchData() {
    return LineTouchData(
      enabled: true,
      handleBuiltInTouches: true,
      getTouchedSpotIndicator: (_, spotIndexes) {
        return spotIndexes.map((_) {
          return TouchedSpotIndicatorData(
            FlLine(color: Colors.pink), FlDotData()
          );
        }).toList();
      },
      touchTooltipData: LineTouchTooltipData(
        tooltipRoundedRadius: 8,
        getTooltipItems: (lineBarsSpot) {
          return lineBarsSpot.map((lineBarSpot) {
            return LineTooltipItem(
              lineBarSpot.y.toString(),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
        },
      ),
    );
  }


  HorizontalLine _horizontalLine(double threshold) {
    return HorizontalLine(
      y: threshold,
      color: Colors.red.withOpacity(0.8),
      strokeWidth: 3,
      dashArray: [20, 2],
      label: HorizontalLineLabel(
        show: true,
        alignment: Alignment.center,
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.pink,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
