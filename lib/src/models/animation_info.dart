/// Different types of animation progress to be passed to Renderables
class AnimationsInfo {
  double _newTickPercent = 1;
  double _toolTipPercent = 1;
  double _crossHairPercent = 1;

  double get newTickPercent => _newTickPercent;

  double get toolTipPercent => _toolTipPercent;

  double get crossHairPercent => _crossHairPercent;

  /// Updates given animation values.
  void updateValues({
    double newTickPercent,
    double toolTipPercent,
    double crossHairPercent,
  }) {
    _newTickPercent = newTickPercent ?? _newTickPercent;
    _toolTipPercent = toolTipPercent ?? _toolTipPercent;
    _crossHairPercent = crossHairPercent ?? _crossHairPercent;
  }
}
