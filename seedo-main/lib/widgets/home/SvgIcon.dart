// ignore_for_file: file_names

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String assetPath;
  final Color? color;
  final double? width;
  final double? height;
  final double? size;
  final BoxFit fit;

  const SvgIcon({
    super.key,
    required this.assetPath,
    this.color,
    this.width,
    this.height,
    this.size,
    this.fit = BoxFit.contain,
  }) : assert(
         size == null || (width == null && height == null),
         "Ne pas spécifier size ET width/height en même temps",
       );

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size ?? width,
      height: size ?? height,
      fit: fit,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}
