import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';

import '../modules/module.dart';

class Controller extends GetxController {
  int size = 0;
  // قائمة المنتجات
  var products = <ProductModel>[].obs;

  // حالة التحميل
  var isLoading = false.obs;

  Future<void> getRecordsController<T>({
    required String model, // Modelo genérico (ej. "product.product")
    List<String>? fields, // Campos opcionales
    List domain = const [], // Dominio opcional
    int limit = 50, // Límite de registros por defecto
    int offset = 0, // Offset por defecto
    T Function(Map<String, dynamic>)? fromJson, // Función para convertir JSON a modelo
    OnResponse? onResponse, // Callback para manejar la respuesta
  }) async {
    try {
      // Obtén los campos válidos si no se proporcionan explícitamente
      List<String> dynamicFields = await Module.getValidFields(model);

      // Combina los campos recibidos y los obtenidos dinámicamente
      List<String> validFields = [
        ...?fields, // Campos proporcionados (si son null, no se incluyen)
        ...dynamicFields, // Campos required obtenidos del servidor
      ]; // Elimina duplicados y convierte nuevamente a lista

      // Llamada al método searchRead para obtener los datos
      final fetchedRecords = await Module.searchRead<T>(
        model: model,
        domain: domain,
        fields: validFields,
        fromJson: fromJson, // Conversión específica para el modelo
        limit: limit,
      );

      // Procesa los datos obtenidos
      if (onResponse != null) {
        onResponse(fetchedRecords);
      }
    } catch (e) {
      print("Error obteniendo registros: $e");
    }
  }

  Future<void> getProductsController({OnResponse? onResponse}) async {
    try {
      await getRecordsController<ProductModel>(
        model: "product.product",
        fields: ["image_128"],
        fromJson: (data) => ProductModel.fromJson(data),
        onResponse: (response) {
          print("Productos obtenidos: ${response.length}");
          products.clear();
          products.addAll(response);
          onResponse!(products);
        },
      );
    } catch (e) {
      print("Error obteniendo productos: $e");
    }
  }
}
