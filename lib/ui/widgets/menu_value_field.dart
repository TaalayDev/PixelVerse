import 'package:flutter/material.dart';

import 'customized_popup_menu.dart';

class MenuToolValueField extends StatefulWidget {
  const MenuToolValueField({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.icon,
    required this.child,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final Widget icon;
  final Widget child;
  final Function(int) onChanged;

  @override
  State<MenuToolValueField> createState() => _MenuToolValueFieldState();
}

class _MenuToolValueFieldState extends State<MenuToolValueField> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.2),
        ),
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isMenuOpen = !_isMenuOpen;
            });
          },
          child: CustomizedDropdownMenu(
            menuBuilder: menuBuilder,
            isOpen: _isMenuOpen,
            wrapContentWidth: false,
            menuWidth: 150,
            onClosed: () {
              setState(() {
                _isMenuOpen = false;
              });
            },
            child: Row(
              children: [
                const SizedBox(width: 8),
                widget.icon,
                SizedBox(
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w400,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          widget.child,
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget menuBuilder(BuildContext context) {
    return MenuSlider(
      value: widget.value,
      min: widget.min,
      max: widget.max,
      onChanged: widget.onChanged,
    );
  }
}

class MenuSlider extends StatefulWidget {
  const MenuSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final Function(int) onChanged;

  @override
  State<MenuSlider> createState() => _MenuSliderState();
}

class _MenuSliderState extends State<MenuSlider> {
  late int _value = widget.value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border.all(
          color: const Color.fromRGBO(0, 0, 0, 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Slider(
            value: _value.toDouble(),
            min: widget.min.toDouble(),
            max: widget.max.toDouble(),
            onChanged: (value) {
              setState(() {
                _value = value.toInt();
                widget.onChanged(value.toInt());
              });
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
