import 'dart:convert';

import 'package:app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:native_qr/native_qr.dart';

class QrLoginButton extends StatefulWidget {
  const QrLoginButton({Key? key, required this.onResult}) : super(key: key);

  final Function({required String token}) onResult;

  @override
  State<QrLoginButton> createState() => _QrLoginButtonState();
}

class _QrLoginButtonState extends State<QrLoginButton> {
  var _active = false;

  Future<void> _scan() async {
    try {
      var nativeQr = NativeQr();
      String? payload = await nativeQr.get();
      if (payload != null) {
        Codec<String, String> stringToBase64 = utf8.fuse(base64);
        var decodedPayload = stringToBase64.decode(payload);
        var payloadJson = jsonDecode(decodedPayload);
        widget.onResult(token: payloadJson['token']);
      }
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _active ? Colors.black : Colors.white;
    final bgColor = _active ? AppColors.highlight : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _active = true),
      onExit: (_) => setState(() => _active = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _active = true),
        onTapUp: (_) => setState(() => _active = false),
        onTapCancel: () => setState(() => _active = false),
        onTap: _scan,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.qr_code, size: 32, color: iconColor),
        ),
      ),
    );
  }
}
