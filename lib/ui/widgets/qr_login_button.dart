import 'dart:convert';

import 'package:app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:native_qr/native_qr.dart';

class QrLoginButton extends StatelessWidget {
  const QrLoginButton({Key? key, required this.onResult}) : super(key: key);

  final Function({required String host, required String token}) onResult;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Icon(Icons.qr_code, size: 32),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed)) {
            return AppColors.highlight;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed)) {
            return Colors.black;
          }
          return Colors.white;
        }),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(const CircleBorder()),
        elevation: WidgetStateProperty.all(0),
      ),
      onPressed: () async {
        try {
          var nativeQr = NativeQr();
          String? payload = await nativeQr.get();
          if (payload != null) {
            Codec<String, String> stringToBase64 = utf8.fuse(base64);
            var decodedPayload = stringToBase64.decode(payload);
            var payloadJson = jsonDecode(decodedPayload);
            onResult(
              host: payloadJson['host'],
              token: payloadJson['token'],
            );
          }
        } catch (err) {
          print(err);
        }
      },
    );
  }
}
