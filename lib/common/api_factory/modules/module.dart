import 'dart:async';
import 'package:gsloution_mobile/common/config/import.dart';

class Module {
  Module._();

  // generer les recordes
  static Future<void> getRecordsController<T>({
    required String model, // Modelo genérico (ej. "product.product")
    List<String>? fields, // Campos opcionales
    List domain = const [], // Dominio opcional
    int limit = 50, // Límite de registros por defecto
    int offset = 0, // Offset por defecto
    T Function(Map<String, dynamic>)?
    fromJson, // Función para convertir JSON a modelo
    OnResponse? onResponse, // Callback para manejar la respuesta
    bool? showGlobalLoading, // ✅ nullable parameter
  }) async {
    try {
      List<String> dynamicFields = await getValidFields(model);

      List<String> validFields = [...?fields, ...dynamicFields];
      // generateModelFiles(validFields, model);
      final fetchedRecords = await searchRead<T>(
        model: model,
        domain: domain,
        fields: validFields,
        fromJson: fromJson, // Conversión específica para el modelo
        limit: limit,
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );

      if (onResponse != null) {
        onResponse(fetchedRecords);
      }
    } catch (e) {
      print("Error obteniendo registros: $e");
    }
  }

  static Future<List<T>> searchRead<T>({
    required String model, // Modelo genérico (por ejemplo, "product.product").
    required List domain, // Dominio para filtrar registros.
    required List<String> fields, // Campos que deseas recuperar.
    T Function(Map<String, dynamic>)?
    fromJson, // Función de conversión de JSON.
    int limit = 50, // Límite por página.
    bool? showGlobalLoading, // ✅ nullable parameter
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
        kwargs: {"limit": limit, "offset": offset},
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
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
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
          List<String> requiredFields = response.entries
              .where((entry) => entry.value['required'] == true)
              .map((entry) => entry.key)
              .toList();
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

  static addModule({
    required String model,
    required dynamic maps,
    required OnResponse onResponse,
  }) async {
    Api.create(
      model: model,
      values: maps!,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static createModule({
    required String model,
    required dynamic maps,
    required OnResponse onResponse,
    bool? showGlobalLoading,
  }) async {
    Api.create(
      showGlobalLoading: showGlobalLoading,
      model: model,
      values: maps!,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static writeModule({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> values,
    required OnResponse onResponse,
  }) async {
    Api.write(
      model: model,
      ids: ids,
      values: values,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static deleteModule({
    required String model,
    required List<int> ids,
    required Map values,
    required OnResponse onResponse,
  }) async {
    Api.unlink(
      model: model,
      ids: ids,
      onResponse: onResponse,
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }
}
