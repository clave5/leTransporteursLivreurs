// widgets/component/input/custom_reactive_text_filed_component.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;
import 'package:reactive_forms/reactive_forms.dart';

class CustomReactiveTextField extends StatefulWidget {
  InputDecoration decoration = const InputDecoration();
  TextInputType? keyboardType;
  TextCapitalization textCapitalization = TextCapitalization.none;
  TextInputAction? textInputAction;
  TextStyle? style;
  StrutStyle? strutStyle;
  TextDirection? textDirection;
  TextAlign textAlign = TextAlign.start;
  TextAlignVertical? textAlignVertical;
  bool autofocus = false;
  bool readOnly = false;
  EditableTextContextMenuBuilder? contextMenuBuilder;
  bool? showCursor;
  bool obscureText = false;
  String obscuringCharacter = '•';
  bool autocorrect = true;
  SmartDashesType? smartDashesType;
  SmartQuotesType? smartQuotesType;
  bool enableSuggestions = true;
  MaxLengthEnforcement? maxLengthEnforcement;
  int? maxLines = 1;
  int? minLines;
  bool expands = false;
  int? maxLength;
  List<TextInputFormatter>? inputFormatters;
  double cursorWidth = 2.0;
  double? cursorHeight;
  Radius? cursorRadius;
  Color? cursorColor;
  Brightness? keyboardAppearance;
  EdgeInsets scrollPadding = const EdgeInsets.all(20.0);
  bool enableInteractiveSelection = true;
  InputCounterWidgetBuilder? buildCounter;
  ScrollPhysics? scrollPhysics;
  Iterable<String>? autofillHints;
  MouseCursor? mouseCursor;
  DragStartBehavior dragStartBehavior = DragStartBehavior.start;
  AppPrivateCommandCallback? onAppPrivateCommand;
  String? restorationId;
  ScrollController? scrollController;
  TextSelectionControls? selectionControls;
  ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight;
  ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight;
  TextEditingController? controller;
  Clip clipBehavior = Clip.hardEdge;
  bool enableIMEPersonalizedLearning = true;
  bool scribbleEnabled = true;
  ReactiveFormFieldCallback? onTap;
  ReactiveFormFieldCallback? onEditingComplete;
  ReactiveFormFieldCallback? onSubmitted;
  ReactiveFormFieldCallback? onChanged;
  UndoHistoryController? undoController;
  bool? cursorOpacityAnimates;
  TapRegionCallback? onTapOutside;
  ContentInsertionConfiguration? contentInsertionConfiguration;
  bool canRequestFocus = true;
  SpellCheckConfiguration? spellCheckConfiguration;
  TextMagnifierConfiguration? magnifierConfiguration;
  final double height;
  final String? formControlName;
  final FormControl? formControl;
  final Map<String, ValidationMessageFunction>? validationMessages;
  final ControlValueAccessor<dynamic, String>? valueAccessor;
  final ShowErrorsFunction? showErrors;
  final FocusNode? focusNode;

  CustomReactiveTextField({
    super.key,
    this.formControlName,
    this.formControl,
    this.validationMessages,
    this.valueAccessor,
    this.showErrors,
    this.focusNode,
    this.height = 60.0,
    InputDecoration decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    EditableTextContextMenuBuilder? contextMenuBuilder,
    bool? showCursor,
    bool obscureText = false,
    String obscuringCharacter = '•',
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    MouseCursor? mouseCursor,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    AppPrivateCommandCallback? onAppPrivateCommand,
    String? restorationId,
    ScrollController? scrollController,
    TextSelectionControls? selectionControls,
    dynamic selectionHeightStyle,
    dynamic selectionWidthStyle,
    TextEditingController? controller,
    Clip clipBehavior = Clip.hardEdge,
    bool enableIMEPersonalizedLearning = true,
    bool scribbleEnabled = true,
    ReactiveFormFieldCallback? onTap,
    ReactiveFormFieldCallback? onEditingComplete,
    ReactiveFormFieldCallback? onSubmitted,
    ReactiveFormFieldCallback? onChanged,
    UndoHistoryController? undoController,
    bool? cursorOpacityAnimates,
    TapRegionCallback? onTapOutside,
    ContentInsertionConfiguration? contentInsertionConfiguration,
    bool canRequestFocus = true,
    SpellCheckConfiguration? spellCheckConfiguration,
    TextMagnifierConfiguration? magnifierConfiguration,
  }); //});

  @override
  State<CustomReactiveTextField> createState() =>
      _CustomReactiveTextFieldState();
}

class _CustomReactiveTextFieldState extends State<CustomReactiveTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: ReactiveTextField(
        formControlName: widget.formControlName,
        formControl: widget.formControl,
        validationMessages: widget.validationMessages,
        valueAccessor: widget.valueAccessor,
        showErrors: widget.showErrors,
        focusNode: widget.focusNode,
        decoration: widget.decoration,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        textInputAction: widget.textInputAction,
        style: widget.style,
        strutStyle: widget.strutStyle,
        textDirection: widget.textDirection,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        autofocus: widget.autofocus,
        readOnly: widget.readOnly,
        contextMenuBuilder: widget.contextMenuBuilder,
        showCursor: widget.showCursor,
        obscureText: widget.obscureText,
        obscuringCharacter: widget.obscuringCharacter,
        autocorrect: widget.autocorrect,
        smartDashesType: widget.smartDashesType,
        smartQuotesType: widget.smartQuotesType,
        enableSuggestions: widget.enableSuggestions,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        expands: widget.expands,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        buildCounter: widget.buildCounter,
        scrollPhysics: widget.scrollPhysics,
        autofillHints: widget.autofillHints,
        mouseCursor: widget.mouseCursor,
        dragStartBehavior: widget.dragStartBehavior,
        onAppPrivateCommand: widget.onAppPrivateCommand,
        restorationId: widget.restorationId,
        scrollController: widget.scrollController,
        selectionControls: widget.selectionControls,
        selectionHeightStyle: widget.selectionHeightStyle,
        selectionWidthStyle: widget.selectionWidthStyle,
        controller: widget.controller,
        clipBehavior: widget.clipBehavior,
        enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
        scribbleEnabled: widget.scribbleEnabled,
        onTap: widget.onTap,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        onChanged: widget.onChanged,
        undoController: widget.undoController,
        cursorOpacityAnimates: widget.cursorOpacityAnimates,
        onTapOutside: widget.onTapOutside,
        contentInsertionConfiguration: widget.contentInsertionConfiguration,
        canRequestFocus: widget.canRequestFocus,
        spellCheckConfiguration: widget.spellCheckConfiguration,
        magnifierConfiguration: widget.magnifierConfiguration,
      ),
    );
  }
}
