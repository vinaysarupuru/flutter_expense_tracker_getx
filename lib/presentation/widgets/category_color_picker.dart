import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategoryColorPicker extends StatelessWidget {
  final Color selectedColor;
  final Function(MaterialColor) onColorSelected;

  const CategoryColorPicker({
    Key? key,
    required this.selectedColor,
    required this.onColorSelected,
  }) : super(key: key);

  MaterialColor _closestMaterialColor(Color color) {
    return Colors.primaries.reduce((a, b) {
      return (a.computeLuminance() - color.computeLuminance()).abs() <
              (b.computeLuminance() - color.computeLuminance()).abs()
          ? a
          : b;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Category Color'),
        GestureDetector(
          onTap: () {
            showDialog(
              context: Get.context!,
              builder: (BuildContext context) {
                Color pickerColor = selectedColor;
                return AlertDialog(
                  title: const Text('Pick a color'),
                  content: SingleChildScrollView(
                    child: MaterialPicker(
                      pickerColor: pickerColor,
                      onColorChanged: (Color color) {
                        pickerColor = color;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final materialColor = _closestMaterialColor(pickerColor);
                        onColorSelected(materialColor);
                        Get.back();
                      },
                      child: const Text('Done'),
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
