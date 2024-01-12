import 'package:flutter/material.dart';

Image get dust_hi => Image.asset('assets/images/dust_hi.png');
Image get safe => Image.asset('assets/images/safe.png');
Image get temp_hi => Image.asset('assets/images/temp_hi.png');
Image get temp_lo => Image.asset('assets/images/temp_lo.png');
Image get gas_hi => Image.asset('assets/images/gas_hi.png');
Image get sys_on => Image.asset('assets/images/sys_on.png');
Image get sys_off => Image.asset('assets/images/sys_off.png');

extension ImageExtension on Image {
  FittedBox get fit => FittedBox(
        fit: BoxFit.contain,
        child: this,
      );
  FittedBox get fitWidth => FittedBox(
        fit: BoxFit.fitWidth,
        child: this,
      );
  FittedBox get fitHeight => FittedBox(
        fit: BoxFit.fitHeight,
        child: this,
      );
  FittedBox get fitCover => FittedBox(
        fit: BoxFit.cover,
        child: this,
      );
  FittedBox get fitFill => FittedBox(
        fit: BoxFit.fill,
        child: this,
      );
}
