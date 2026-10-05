import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  test('file picker result check', () {
    expect(FilePickerPlatform.instance, isNotNull);
  });
}
