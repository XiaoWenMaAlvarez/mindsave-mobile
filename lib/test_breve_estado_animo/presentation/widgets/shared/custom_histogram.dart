import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomHistogram extends StatefulWidget {
  final String title;
  final int minValue;
  final int maxValue;
  final int horizontalInterval;
  final List<List<int?>> data;

  const CustomHistogram({
    super.key,
    required this.title,
    required this.minValue,
    required this.maxValue,
    required this.horizontalInterval,
    required this.data,
  });

  @override
  State<CustomHistogram> createState() => _CustomHistogramState();
}

class _CustomHistogramState extends State<CustomHistogram> {
  int _currentMonthIndex = DateTime.now().month - 1;
  late final List<String> monthsNames;

  int _interactedSpotIndex = -1;

  @override
  void initState() {
    monthsNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor = Theme.of(context).colorScheme.primary;

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              widget.title,
              maxLines: 2,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mainColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _canGoPrevious ? _previousMonth : null,
                  icon: const Icon(Icons.navigate_before_rounded),
                ),
              ),
            ),
            SizedBox(
              width: 92,
              child: Text(
                monthsNames[_currentMonthIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mainColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _canGoNext ? _nextMonth : null,
                  icon: const Icon(Icons.navigate_next_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AspectRatio(
          aspectRatio: 1.4,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0.0, right: 18.0),
                child: LineChart(
                  LineChartData(
                    minY: widget.minValue - 1,
                    maxY: widget.maxValue + 1,
                    minX: 0,
                    maxX: 32,
                    lineBarsData: getLineChartBarData(
                      widget.data[_currentMonthIndex],
                      mainColor,
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      horizontalInterval: widget.horizontalInterval.toDouble(),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        drawBelowEverything: true,
                        sideTitles: SideTitles(
                          showTitles: true,
                          maxIncluded: false,
                          minIncluded: false,
                          reservedSize: 40,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final text = value.toStringAsFixed(0);
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(text),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            'Días del mes',
                            style: TextStyle(
                              color: mainColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        axisNameSize: 40,
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 38,
                          maxIncluded: false,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return _bottomTitles(
                              value,
                              meta,
                              isDarkMode ? Colors.white : Colors.black,
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchCallback: _touchCallback,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) =>
                            isDarkMode ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<LineChartBarData> getLineChartBarData(List<int?> spots, Color color) {
    List<LineChartBarData> newLinesChartBarData = [];
    List<FlSpot> newSpots = [];
    for (int i = 0; i < spots.length; i++) {
      if (spots[i] != null) {
        double day = i.toDouble() + 1;
        double score = spots[i]!.toDouble();
        FlSpot newSpot = FlSpot(day, score);
        newSpots.add(newSpot);

        if (i == spots.length - 1) {
          LineChartBarData newLineChartBarData = createCHartBarData(
            newSpots,
            color,
          );
          newLinesChartBarData.add(newLineChartBarData);
        }
      } else {
        if (newSpots.isNotEmpty) {
          LineChartBarData newLineChartBarData = createCHartBarData(
            newSpots,
            color,
          );
          newLinesChartBarData.add(newLineChartBarData);
          newSpots = [];
        }
      }
    }

    return newLinesChartBarData;
  }

  LineChartBarData createCHartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      dotData: FlDotData(show: spots.length == 1),
      color: color,
      barWidth: 2,
    );
  }

  bool get _canGoNext => _currentMonthIndex < 11;

  bool get _canGoPrevious => _currentMonthIndex > 0;

  void _previousMonth() {
    if (!_canGoPrevious) {
      return;
    }

    setState(() {
      _currentMonthIndex--;
    });
  }

  void _nextMonth() {
    if (!_canGoNext) {
      return;
    }
    setState(() {
      _currentMonthIndex++;
    });
  }

  Widget _bottomTitles(double value, TitleMeta meta, Color color) {
    final day = value.toInt();
    if (day < 1 || day > 31) {
      return const SizedBox();
    }

    final isDayHovered = _interactedSpotIndex == day;
    final isImportantToShow = day % 5 == 0 || day == 1;

    if (!isImportantToShow && !isDayHovered) {
      return const SizedBox();
    }

    final isAdjacentToHovered =
        _interactedSpotIndex != -1 &&
        (day == _interactedSpotIndex - 1 || day == _interactedSpotIndex + 1);

    return SideTitleWidget(
      meta: meta,
      child: Text(
        day.toString(),
        style: TextStyle(
          color: isDayHovered
              ? color
              : isAdjacentToHovered
              ? color.withValues(alpha: 0.2)
              : color,
          fontSize: 12,
        ),
      ),
    );
  }

  void _touchCallback(FlTouchEvent event, LineTouchResponse? touchResponse) {
    if (!event.isInterestedForInteractions ||
        touchResponse?.lineBarSpots == null ||
        touchResponse!.lineBarSpots!.isEmpty) {
      setState(() {
        _interactedSpotIndex = -1;
      });
      return;
    }

    setState(() {
      _interactedSpotIndex = touchResponse.lineBarSpots!.first.x.toInt();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
