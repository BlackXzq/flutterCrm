import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberFormater extends TextInputFormatter {
  int scale = 2; //几位小数

  NumberFormater({this.scale});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String orignalTextStr = newValue.text;
    String resultTextStr = newValue.text;
    int selectionIndex = newValue.selection.end;
    int originalSelectionIndex = selectionIndex;
    final StringBuffer newText = StringBuffer();
    //如果已经有小数点，则不允许第二位小数点
    String curChar = newValue.text.substring(
        originalSelectionIndex - 1 < 0 ? 0 : originalSelectionIndex - 1,
        originalSelectionIndex);
    if (oldValue.text.contains('.') &&
        curChar != null &&
        curChar.endsWith('.')) {
      //当前的是点
      selectionIndex--;
      resultTextStr = orignalTextStr.substring(0, selectionIndex);
      if (selectionIndex + 1 < orignalTextStr.length) {
        resultTextStr += orignalTextStr.substring(selectionIndex + 1);
      }
    }
    //如果当前是小数点后的第三位
    if (newValue.text.contains('.')) {
      List<String> array = newValue.text.split('.');
      if (array != null) {
        if (array.length > 1) {
          String end = array[1];
          if (end.length >= scale + 1) {
            selectionIndex--;
            resultTextStr = orignalTextStr.substring(0, selectionIndex);
            if (selectionIndex + 1 < orignalTextStr.length) {
              resultTextStr += orignalTextStr.substring(selectionIndex + 1);
            }
          }
        }
      }
    }

    newText.write(resultTextStr);
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
