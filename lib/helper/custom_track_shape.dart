import "package:flutter/material.dart";

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset offset = Offset.zero,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    double? trackHeight = sliderTheme.trackHeight;
    double trackLeft = offset.dx;
    double trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
