import 'dart:async';

import 'package:gsloution_mobile/common/config/import.dart';

class Module {
  Module._();

  static Future<List<T>> searchRead<T>({
    required String model, // Modelo genérico (por ejemplo, "product.product").
    required List domain, // Dominio para filtrar registros.
    required List<String> fields, // Campos que deseas recuperar.
    T Function(Map<String, dynamic>)? fromJson, // Función de conversión de JSON.
    int limit = 50, // Límite por página.
  }) async {
    int offset = 0;
    bool hasMore = true;
    List<T> allRecords = [];

    while (hasMore) {
      final Completer<Map<int, List<T>>> completer = Completer();

      Api.callKW(
        method: 'search_read',
        model: model,
        args: [domain, fields],
        kwargs: {
          "limit": limit,
          "offset": offset,
        },
        onResponse: (response) {
          if (response is List) {
            List<T> fetchedRecords = [];
            for (var element in response) {
              if (element is Map<String, dynamic>) {
                if (fromJson != null) {
                  fetchedRecords.add(fromJson(element));
                }
              }
            }
            completer.complete({fetchedRecords.length: fetchedRecords});
          }
        },
        onError: (error, data) {
          print("Error: $error");
          print("Data: $data");
          completer.completeError(error);
        },
      );

      final response = await completer.future;

      if (response.isNotEmpty) {
        int size = response.keys.first;
        List<T> fetchedRecords = response[size]!;

        allRecords.addAll(fetchedRecords);
        offset += limit;

        hasMore = fetchedRecords.length == limit;
      } else {
        hasMore = false;
      }
    }

    return allRecords;
  }

  static Future<List<String>> getValidFields(String model) async {
    final Completer<List<String>> completer = Completer();
    Api.callKW(
      method: 'fields_get',
      model: model,
      args: [],
      kwargs: {
        "attributes": ["string", "type", "required"],
      },
      onResponse: (response) {
        if (response is Map<String, dynamic>) {
          List<String> requiredFields = response.entries.where((entry) => entry.value['required'] == true).map((entry) => entry.key).toList();
          completer.complete(requiredFields);
        }
      },
      onError: (error, data) {
        print("Error obteniendo campos: $error");
        completer.completeError(error);
      },
    );

    return completer.future;
  }
}
