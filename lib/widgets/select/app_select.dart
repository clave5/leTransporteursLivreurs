import 'package:flutter/material.dart';
import 'package:letransporteur_livreur/misc/colors.dart';
import 'package:letransporteur_livreur/widgets/texts/xsmall/xsmall_bold_text.dart';

class AppSelect<T> extends StatefulWidget {
  final List<T> options;
  T selectedOption;
  final void Function(T) onChanged;

  AppSelect({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  _AppSelectState<T> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showOptions,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            XSmallBoldText(text: widget.selectedOption.toString()),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        child: ListView.builder(
          itemCount: widget.options.length,
          itemBuilder: (context, index) {
            final option = widget.options[index];
            return ListTile(
              title: Text(option.toString()),
              onTap: () {
                widget.onChanged(option);
                setState(() {
                  widget.selectedOption = option;
                });
                print("selected ${option.toString()}");
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
