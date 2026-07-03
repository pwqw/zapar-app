import 'dart:convert';

import 'package:app/exceptions/exceptions.dart';
import 'package:app/services/log_service.dart';
import 'package:app/utils/preferences.dart' as preferences;
import 'package:http/http.dart' as Http;

enum HttpMethod { get, post, patch, put, delete }

Future<dynamic> request(
  HttpMethod method,
  String path, {
  Object data = const {},
}) async {
  final Uri uri = Uri.parse('${preferences.apiBaseUrl}/$path');

  const jsonMime = 'application/json';
  final Map<String, String> headers = {
    'Content-Type': jsonMime,
    'Accept': jsonMime,
    'X-Api-Version': preferences.apiVersion,
    if (preferences.apiToken != null) 'Authorization': 'Bearer ${preferences.apiToken}',
  };

  final String methodName = method.name;
  Http.Response? response;

  try {
    switch (method) {
      case HttpMethod.get:
        response = await Http.get(uri, headers: headers);
        break;
      case HttpMethod.post:
        response = await Http.post(
          uri,
          headers: headers,
          body: json.encode(data),
        );
        break;
      case HttpMethod.patch:
        response = await Http.patch(
          uri,
          headers: headers,
          body: json.encode(data),
        );
        break;
      case HttpMethod.put:
        response = await Http.put(
          uri,
          headers: headers,
          body: json.encode(data),
        );
        break;
      case HttpMethod.delete:
        response = await Http.delete(
          uri,
          headers: headers,
          body: json.encode(data),
        );
        break;
    }
  } catch (e, stack) {
    LogService.instance.record(e, stack, extras: {
      'url': uri.toString(),
      'method': methodName,
      'status': response?.statusCode,
      'body': response?.body,
    });
    rethrow;
  }

  final Http.Response res = response!;

  if (res.statusCode >= 200 && res.statusCode < 300) {
    try {
      return json.decode(res.body);
    } catch (e) {
      return null;
    }
  }

  final ex = HttpResponseException.fromResponse(res);
  LogService.instance.record(ex, StackTrace.current, extras: {
    'url': uri.toString(),
    'method': methodName,
    'status': res.statusCode,
    'body': res.body,
  });
  throw ex;
}

Future<dynamic> get(String path) async => request(HttpMethod.get, path);

Future<dynamic> post(String path, {Object data = const {}}) async =>
    request(HttpMethod.post, path, data: data);

Future<dynamic> patch(String path, {Object data = const {}}) async =>
    request(HttpMethod.patch, path, data: data);

Future<dynamic> put(String path, {Object data = const {}}) async =>
    request(HttpMethod.put, path, data: data);

Future<dynamic> delete(String path, {Object data = const {}}) async =>
    request(HttpMethod.delete, path, data: data);
