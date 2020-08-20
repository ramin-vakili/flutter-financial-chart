import 'package:flutter_financial_chart/flutter_financial_chart.dart';
import 'package:flutter_financial_chart/src/chart/x_factor_decider.dart';

import '../../behavior_renderer.dart';

/// To add X-axis to the chart
abstract class XAxis<T extends BaseEntry> extends BehaviorRenderer<T>
    implements XFactorDecider<T> {}
