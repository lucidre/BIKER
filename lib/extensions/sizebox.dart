import 'package:biker/common_libs.dart';

extension Sizes on SizedBox {
  SizedBox operator *(num factor) {
    return SizedBox(
      height: (height ?? 0) * factor,
    );
  }
}
