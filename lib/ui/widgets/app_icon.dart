import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppIcons {
  pen,
  reflect_symmetry,
  curved_connector,
  select,
  pencil,
  brush,
  fill,
  eraser,
  spray,
  line,
  circle,
  rectangle,
  layers,
  share,
  home,
  magic_stick,
  album,
  archive_down,
  lasso,
  settings_2,
  image_broken,
  church_window,
  metal_plate,
  sparkles,
  particle,
  wave,
  rotate_right,
  float,
  shake_camera,
  face_melt,
  explosion,
  jelly,
  wipe,
  fog,
  stone_sphere,
  ice,
  mountain_top,
  ocean_sea_water,
  cloud,
  tree_branch,
  leaf,
  city,
  fold_up,
  unfold
}

class AppIcon extends StatelessWidget {
  final AppIcons icon;
  final double? size;
  final Color? color;
  final bool originalColor;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.originalColor = false, // const Color(0xff636363),
  });

  @override
  Widget build(BuildContext context) {
    final size = this.size ?? IconTheme.of(context).size ?? 24.0;
    Widget image = SvgPicture.asset(
      'assets/vectors/${icon.name}.svg',
      height: size,
      width: size,
      color: originalColor ? null : color ?? IconTheme.of(context).color,
    );

    return SizedBox(
      height: size,
      width: size,
      child: Center(child: image),
    );
  }
}
