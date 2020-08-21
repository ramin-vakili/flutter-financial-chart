import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_financial_chart/src/chart/position_notifier.dart';
import 'package:flutter_financial_chart/src/chart/shared_range.dart';
import 'package:flutter_financial_chart/src/models/animation_info.dart';
import 'package:flutter_financial_chart/src/models/data_series.dart';
import 'package:flutter_financial_chart/src/models/models.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/axes/x_axis/x_axis.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/axes/y_axis/y_axis_renderer.dart';
import 'package:flutter_financial_chart/src/renderers/behaviors/behavior_renderer.dart';

import 'chart_painter.dart';
import '../renderers/entries_renderers/entries_renderer.dart';

class Chart extends StatefulWidget {
  const Chart({
    Key key,
    @required this.chartId,
    this.mainRenderer,
    this.renderers,
    this.sharedRange,
    this.positionNotifier,
    this.positionListener,
    this.behaviors,
    this.xAxis,
    this.yAxis,
  }) : super(key: key);

  final EntriesRenderer mainRenderer;
  final List<EntriesRenderer> renderers;
  final List<BehaviorRenderer> behaviors;
  final SharedRange sharedRange;
  final PositionNotifier positionNotifier;
  final PositionNotifier positionListener;

  final XAxis xAxis;
  final YAxis yAxis;

  final String chartId;

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  GlobalKey _chartKey = GlobalKey();
  AnimationsInfo _animationsInfo = AnimationsInfo();

  AnimationController _maxValueAnimationController;
  AnimationController _minValueAnimationController;
  AnimationController _panningAnimationController;
  AnimationController _tooltipAnimationController;
  AnimationController _newTickAnimationController;
  Animation _newTickAnimation;

  Size _chartSize;
  Orientation _screenOrientation;
  SharedRange _sharedRange;

  PositionNotifier _positionNotifier;
  PositionNotifier _positionListener;

  TouchInfo _touchInfo;

  bool _isIndependentChart;

  /// Each pixel represents this number of ms
  int _prevXFactorInPx;
  int _leftXFactor = 0;

  Size _initSizes() {
    final RenderBox chartBox = _chartKey.currentContext.findRenderObject();
    return chartBox.size;
  }

  @override
  void initState() {
    super.initState();
    _touchInfo =
        TouchInfo(chartId: widget.chartId, y: 0, x: 0, xFactor: 0, value: 0);

    _isIndependentChart = widget.positionListener == null;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _screenOrientation = MediaQuery.of(context).orientation;
      _chartSize = _initSizes();
      _setupSharedRange();
      _setupPositionListener();
      _updateVariables();
      _setupAnimation();
      //_runLastTickAnimation();
      setState(() {});
    });
  }

  void _setupSharedRange() {
    _sharedRange = widget.sharedRange ?? SharedRange();
    _sharedRange.addRangeListener((msInPx, rightXFactor) {
      if (mounted) {
        setState(() {});
      }
    });
    if (widget.mainRenderer != null && widget.mainRenderer.entries.isNotEmpty) {
      final lastEntry = widget.mainRenderer.entries.last;
      final secondLastEntry = widget.mainRenderer.entries
          .get(widget.mainRenderer.entries.length - 2);

      final xFactorDelta =
          widget.xAxis.getXFactorDelta(secondLastEntry, lastEntry);

      // TODO: Move inside if statement
      _sharedRange.initialize(
        minXFactor: widget.xAxis.getXFactor(widget.mainRenderer.entries.first),
        maxXFactor: widget.xAxis.getXFactor(widget.mainRenderer.entries.last),
        xFactorInPxMin: xFactorDelta ~/ (0.17 * _chartSize.width),
        xFactorInPxMax: xFactorDelta ~/ (0.007 * _chartSize.width),
        halfWidth: _chartSize.width ~/ 2,
      );

      if (_isIndependentChart && !_sharedRange.initialized()) {
        _sharedRange.updateRange(
          xFactorInPx: xFactorDelta ~/ (0.04 * _chartSize.width),
          rightXFactor:
              (widget.xAxis.getXFactor(widget.mainRenderer.entries.last) +
                      _sharedRange.xFactorInPx * _chartSize.width / 2)
                  .toInt(),
        );
      }
    }
  }

  void _setupPositionListener() {
    _positionNotifier = widget.positionNotifier ?? PositionNotifier();
    _positionListener = widget.positionListener ?? _positionNotifier;
    _positionListener
        .addPositionListener((chartId, y, x, xFactor, value, status) {
      if (mounted) {
        setState(() => _touchInfo = TouchInfo(
              chartId: chartId,
              x: x,
              y: y,
              xFactor: xFactor,
              value: value,
              status: status,
            ));
      }
    });
  }

  @override
  void didUpdateWidget(Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_screenOrientation != MediaQuery.of(context).orientation) {
      _chartSize = _initSizes();
      _screenOrientation = MediaQuery.of(context).orientation;
    }

    if (widget.mainRenderer != null && widget.mainRenderer.entries.isNotEmpty) {
      _sharedRange.updateMinMax(
        widget.xAxis.getXFactor(widget.mainRenderer.entries.first),
        widget.xAxis.getXFactor(widget.mainRenderer.entries.last),
      );
    }

    _assignPrevLastEntryToRenderers(oldWidget);

    _runLastTickAnimation();
  }

  void _assignPrevLastEntryToRenderers(Chart oldWidget) {
    if (widget.mainRenderer != null &&
        oldWidget.mainRenderer.id == widget.mainRenderer.id &&
        oldWidget.mainRenderer.entries.isNotEmpty) {
      if (widget.mainRenderer.entries.length >
              oldWidget.mainRenderer.entries.length &&
          _sharedRange.rightXFactor >
              widget.xAxis.getXFactor(widget.mainRenderer.entries.last)) {
        // A new entry added to main renderer
        _autoScrollByNewTick(oldWidget);
      }
      widget.mainRenderer.prevLast = oldWidget.mainRenderer.entries.last;
    }
    if (widget.renderers == null || widget.renderers.isEmpty) return;
    for (final renderer in widget.renderers) {
      IndexedData<BaseEntry> prevLastEntry =
          _findPrevLastEntry(renderer, oldWidget);
      renderer.prevLast = prevLastEntry;
    }
  }

  void _autoScrollByNewTick(Chart oldWidget) {
    if (!_isIndependentChart) return;
    _panningAnimationController.value = _sharedRange.rightXFactor.toDouble();
    _panningAnimationController.animateTo(
      (_sharedRange.rightXFactor +
              widget.xAxis.getXFactorDelta(
                oldWidget.mainRenderer.entries.last,
                widget.mainRenderer.entries.last,
              ))
          .toDouble(),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
    );
  }

  void _runLastTickAnimation() {
    if (widget.mainRenderer != null &&
        widget.mainRenderer.entries.isNotEmpty &&
        widget.xAxis.getXFactor(widget.mainRenderer.entries.last) <
            _sharedRange.rightXFactor) {
      _newTickAnimationController.reset();
      _newTickAnimationController.forward();
    }
  }

  IndexedData<BaseEntry> _findPrevLastEntry(
    EntriesRenderer<BaseEntry> renderer,
    Chart oldWidget,
  ) {
    if (oldWidget.renderers?.isEmpty ?? false) return null;

    for (var oldRenderer in oldWidget.renderers) {
      if (oldRenderer.id == renderer.id) {
        return oldRenderer.entries.isEmpty ? null : oldRenderer.entries.last;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _updateVariables();
    return Container(
      constraints: BoxConstraints.expand(),
      child: GestureDetector(
        key: _chartKey,
        onHorizontalDragStart: (details) {
          _panningAnimationController.value =
              _sharedRange.rightXFactor.toDouble();
        },
        onHorizontalDragUpdate: (details) {
          _panningAnimationController.value -=
              details.delta.dx * _sharedRange.xFactorInPx;
        },
        onHorizontalDragEnd: (details) {
          final scrollSimulation = FrictionSimulation(
              0.05, // <- the bigger this value, the less friction is applied
              _panningAnimationController.value,
              -details.velocity.pixelsPerSecond.dx *
                  _sharedRange.xFactorInPx // <- Velocity of inertia
              );
          _panningAnimationController.animateWith(scrollSimulation);
        },
        onScaleStart: (details) => _prevXFactorInPx = _sharedRange.xFactorInPx,
        onScaleUpdate: (details) {
          final newMsInPx = (_prevXFactorInPx ~/ details.scale);
          _sharedRange.updateRange(xFactorInPx: newMsInPx);
        },
        onTapUp: (details) {
          _panningAnimationController?.stop();
          if (_positionNotifier.status == TouchStatus.tapDown) {
            _positionNotifier?.updatePosition(
              chartId: widget.chartId,
              status: TouchStatus.tapUp,
            );
          } else {
            _positionNotifier?.updatePosition(
              chartId: widget.chartId,
              x: details.localPosition.dx,
              y: details.localPosition.dy,
              xFactor: widget.mainRenderer.xToXFactor(details.localPosition.dx),
              value: widget.mainRenderer.yToValue(details.localPosition.dy),
              status: TouchStatus.tapDown,
            );
          }
          if (_tooltipAnimationController.status == AnimationStatus.dismissed) {
            _tooltipAnimationController?.forward();
          } else if (_tooltipAnimationController.status ==
              AnimationStatus.completed) {
            _tooltipAnimationController?.reverse();
          }
        },
        onLongPressStart: (details) {
          _panningAnimationController?.stop();
          final x = details.localPosition.dx;
          final y = details.localPosition.dy;
          _positionNotifier?.updatePosition(
            chartId: widget.chartId,
            x: x,
            y: y,
            xFactor: widget.mainRenderer.xToXFactor(x),
            value: widget.mainRenderer.yToValue(y),
            status: TouchStatus.longPressDown,
          );
        },
        onLongPressMoveUpdate: (details) => _positionNotifier?.updatePosition(
          chartId: widget.chartId,
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          xFactor: widget.mainRenderer.xToXFactor(details.localPosition.dx),
          value: widget.mainRenderer.yToValue(details.localPosition.dy),
        ),
        onLongPressEnd: (details) => _positionNotifier?.updatePosition(
          chartId: widget.chartId,
          x: details.localPosition.dx,
          y: details.localPosition.dy,
          xFactor: widget.mainRenderer.xToXFactor(details.localPosition.dx),
          value: widget.mainRenderer.yToValue(details.localPosition.dy),
          status: TouchStatus.logPressUp,
        ),
        child: _chartSize == null
            ? Container()
            : CustomPaint(
                painter: ChartPainter(
                  animatingMinValue: _minValueAnimationController.value,
                  animatingMaxValue: _maxValueAnimationController.value,
                  renderers: widget.renderers,
                  mainRenderer: widget.mainRenderer,
                  behaviors: widget.behaviors,
                  axes: [widget.xAxis, widget.yAxis],
                  animationsInfo: _animationsInfo,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _newTickAnimationController?.dispose();
    _minValueAnimationController?.dispose();
    _maxValueAnimationController?.dispose();
    _tooltipAnimationController?.dispose();

    super.dispose();
  }

  void _updateVariables() {
    if (_chartSize == null) {
      return;
    }

//    if (_sharedRange.rightXFactor != null) {
//      if (_isIndependentChart) {
    _leftXFactor = _sharedRange.rightXFactor -
        (_sharedRange.xFactorInPx * _chartSize.width).toInt();
//      }
    _updateRenderers();
//    }

    double minValue = _getRenderersMinValue();
    double maxValue = _getRenderersMaxValue();

    _updateAxes(minValue, maxValue);

    _updateBehavior(minValue, maxValue);

    if (_minValueAnimationController != null &&
        minValue != null /*&& !_minValueAnimation.isAnimating*/) {
      _minValueAnimationController?.animateTo(minValue,
          curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
    }
    if (_maxValueAnimationController != null &&
        maxValue != null /*&& !_maxValueAnimation.isAnimating*/) {
      _maxValueAnimationController?.animateTo(maxValue,
          curve: Curves.easeOut, duration: const Duration(milliseconds: 300));
    }
  }

  void _updateAxes(double minValue, double maxValue) {
    widget.xAxis?.chartId = widget.chartId;
    widget.yAxis?.chartId = widget.chartId;

    widget.xAxis?.update(
      leftXFactor: _sharedRange.rightXFactor -
          (_sharedRange.xFactorInPx * _chartSize.width).toInt(),
      rightXFactor: _sharedRange.rightXFactor,
      touchInfo: _touchInfo,
      minValue: minValue ?? 0,
      maxValue: maxValue ?? 1,
      isIndependentChart: _isIndependentChart,
      mainVisibleEntries: _sharedRange.mainVisibleEntries,
    );

    widget.yAxis?.update(
      leftXFactor: _sharedRange.rightXFactor -
          (_sharedRange.xFactorInPx * _chartSize.width).toInt(),
      rightXFactor: _sharedRange.rightXFactor,
      touchInfo: _touchInfo,
      minValue: minValue ?? 0,
      maxValue: maxValue ?? 1,
      isIndependentChart: _isIndependentChart,
    );
  }

  void _updateRenderers() {
    widget.mainRenderer?.setXFactorDecider(widget.xAxis);

    final mainVisibleEntries = widget.mainRenderer?.update(
      leftXFactor: _leftXFactor,
      rightXFactor: _sharedRange.rightXFactor,
      touchInfo: _touchInfo,
      isIndependentChart: _isIndependentChart,
    );

    if (_isIndependentChart) {
      _sharedRange.updateVisibleEntries(mainVisibleEntries);
    }

    widget.mainRenderer?.chartId = widget.chartId;

    if (widget.renderers?.isNotEmpty ?? false) {
      for (final render in widget.renderers) {
        render.chartId = widget.chartId;
        render.setXFactorDecider(widget.xAxis);
        if (render.entries.isNotEmpty) {
          render.update(
            leftXFactor: _leftXFactor,
            rightXFactor: _sharedRange.rightXFactor,
            touchInfo: _touchInfo,
            isIndependentChart: _isIndependentChart,
          );
        }
      }
    }
  }

  void _updateBehavior(double minValue, double maxValue) {
    if (widget.behaviors?.isNotEmpty ?? false) {
      for (final behavior in widget.behaviors) {
        behavior.chartId = widget.chartId;
        behavior.setXFactorDecider(widget.xAxis);
        behavior?.update(
          leftXFactor: _leftXFactor,
          rightXFactor: _sharedRange.rightXFactor,
          touchInfo: _touchInfo,
          minValue: minValue,
          maxValue: maxValue,
          isIndependentChart: _isIndependentChart,
          mainVisibleEntries: _sharedRange.mainVisibleEntries,
        );
      }
    }
  }

  double _getRenderersMinValue() {
    if (widget.mainRenderer == null) return 0;
    if (widget.renderers == null || widget.renderers.isEmpty) {
      return widget.mainRenderer?.minValue ?? 0;
    }

    final renderersInAction = widget.renderers
        .where((renderer) =>
            renderer.rendererable != null && renderer.minValue != null)
        .map((renderer) => renderer.minValue);

    if (renderersInAction.isEmpty) {
      return widget.mainRenderer?.minValue ?? 0;
    } else if (widget.mainRenderer.minValue == null) {
      return renderersInAction.reduce(min);
    }

    return min(widget.mainRenderer.minValue, renderersInAction.reduce(min));
  }

  double _getRenderersMaxValue() {
    if (widget.mainRenderer == null) return 1;
    if (widget.renderers == null || widget.renderers.isEmpty) {
      return widget.mainRenderer?.maxValue ?? 1;
    }

    final renderersInAction = widget.renderers
        .where((renderer) =>
            renderer.rendererable != null && renderer.maxValue != null)
        .map((renderer) => renderer.maxValue);

    if (renderersInAction.isEmpty) {
      return widget.mainRenderer?.maxValue ?? 1;
    } else if (widget.mainRenderer.maxValue == null) {
      return renderersInAction.reduce(max);
    }

    return max(widget.mainRenderer.maxValue, renderersInAction.reduce(max));
  }

  void _setupAnimation() {
    _minValueAnimationController = AnimationController.unbounded(
      vsync: this,
      value: _getRenderersMinValue(),
      duration: const Duration(milliseconds: 200),
    );
    _maxValueAnimationController = AnimationController.unbounded(
      vsync: this,
      value: _getRenderersMaxValue(),
      duration: const Duration(milliseconds: 200),
    );

    // New tick animation
    _newTickAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _newTickAnimation = CurvedAnimation(
      parent: _newTickAnimationController,
      curve: Curves.easeOut,
    );

    _tooltipAnimationController = AnimationController(
      lowerBound: 0,
      upperBound: 1,
      animationBehavior: AnimationBehavior.preserve,
      vsync: this,
      duration: Duration(milliseconds: 400),
    )
      ..addListener(() => setState(() {
            _animationsInfo.updateValues(
                toolTipPercent: _tooltipAnimationController.value);
          }))
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _positionNotifier.updatePosition(status: TouchStatus.none);
        }
      });

    _panningAnimationController = AnimationController.unbounded(
        vsync: this, value: _sharedRange.rightXFactor.toDouble())
      ..addListener(() => _sharedRange.updateRange(
            rightXFactor: _panningAnimationController.value.toInt(),
          ));

    _maxValueAnimationController.addListener(() => setState(() {}));
    _minValueAnimationController.addListener(() => setState(() {}));
    _newTickAnimationController.addListener(() => setState(() =>
        _animationsInfo.updateValues(newTickPercent: _newTickAnimation.value)));
  }
}
