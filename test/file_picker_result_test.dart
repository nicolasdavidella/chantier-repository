import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  test('file picker result check', () async {
    // We just want to see the type of result.
    var result = FilePicker.pickFiles();
    // ignore: avoid_print
    print(result.runtimeType);
  });
}
