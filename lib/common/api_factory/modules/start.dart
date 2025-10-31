import 'dart:io';
import 'package:path/path.dart' as path;

class ModelField {
  final String name;
  final String type;
  final String jsonKey;

  ModelField({
    required this.name,
    required this.type,
    required this.jsonKey,
  });
}

void generateModelFiles(List<String> requiredFields, String modelName) {
  final className = modelName.replaceAll('.', '');
  final fileName = modelName.replaceAll('.', '_').toLowerCase();
  final modelFolderName = className.toLowerCase();
  final modelFolderPath = path.join('lib', 'modelodoo', modelFolderName);
  final modelFileName = '${fileName}_model.dart';
  final modelClassFileG = modelFileName.replaceAll(".dart", ".g.dart");

  try {
    // Create the folder
    Directory(modelFolderPath).createSync(recursive: true);
    print('Folder created: $modelFolderPath');
  } catch (e) {
    print('Failed to create folder: $e');
    return;
  }

  try {
    // Generate and write model files
    final modelClass = generateModelClass(
        requiredFields, modelFileName.replaceAll(".dart", ""));
    final modelFile = File(path.join(modelFolderPath, modelFileName));
    modelFile.writeAsStringSync(modelClass);
    print('Model file created: ${modelFile.path}');

    final modelClassG = generateModelClassG(
        requiredFields, modelFileName.replaceAll(".dart", ""));
    final modelFileG = File(path.join(modelFolderPath, modelClassFileG));
    modelFileG.writeAsStringSync(modelClassG);
    print('Generated file created: ${modelFileG.path}');
  } catch (e) {
    print('Failed to write model files: $e');
    return;
  }
}

String convertToCamelCase(String str) {
  List<String> parts = str.split('_');
  List<String> capitalizedParts = parts.map((part) {
    if (part.isNotEmpty) {
      return part[0].toUpperCase() + part.substring(1);
    }
    return part;
  }).toList();
  return capitalizedParts.join();
}

String toCamelCase(String str) {
  List<String> parts = str.split('_').where((part) => part.isNotEmpty).toList();
  for (int i = 1; i < parts.length; i++) {
    parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
  }
  if (parts.isNotEmpty) {
    parts[0] = parts[0].toLowerCase();
  }
  return parts.join();
}

String generateModelClassG(List<String> requiredFields, String fileName) {
  String className = convertToCamelCase(fileName);

  final modelClass = StringBuffer();
  modelClass.writeln('');
  modelClass.writeln('');
  modelClass.writeln("part of '$fileName.dart';");
  modelClass.writeln('');
  modelClass.writeln('');
  modelClass.writeln(
      '$className _\$${className}FromJson(Map<String, dynamic> json) => $className(');
  requiredFields.forEach((field) {
    final fieldName = toCamelCase(field);
    modelClass.writeln("$fieldName: json['$field'] as dynamic,");
  });
  modelClass.writeln(');');
  modelClass.writeln('');
  modelClass.writeln('');
  modelClass.writeln(
      "Map<String, dynamic> _\$${className}ToJson($className instance) =>");
  modelClass.writeln('<String, dynamic>{');
  requiredFields.forEach((field) {
    final fieldName = toCamelCase(field);
    modelClass.writeln("'$field': instance.$fieldName,");
  });
  modelClass.writeln('};');
  return modelClass.toString();
}

String generateModelClass(List<String> requiredFields, String fileName) {
  String className = convertToCamelCase(fileName);

  final modelClass = StringBuffer();
  modelClass
      .writeln('import \'package:json_annotation/json_annotation.dart\';');
  modelClass.writeln('');
  modelClass.writeln('part \'${fileName}.g.dart\';');
  modelClass.writeln('');
  modelClass.writeln('@JsonSerializable()');
  modelClass.writeln('class $className {');
  requiredFields.forEach((field) {
    final fieldName = toCamelCase(field);
    modelClass.writeln('  final dynamic $fieldName;');
  });
  modelClass.writeln('');
  modelClass.writeln('  $className({');
  requiredFields.forEach((field) {
    final fieldName = toCamelCase(field);
    modelClass.writeln('    required this.$fieldName,');
  });
  modelClass.writeln('  });');
  modelClass.writeln('');
  modelClass
      .writeln('  factory $className.fromJson(Map<String, dynamic> json) =>');
  modelClass.writeln('      _\$${className}FromJson(json);');
  modelClass.writeln('');
  modelClass.writeln(
      '  Map<String, dynamic> toJson() => _\$${className}ToJson(this);');
  modelClass.writeln('}');
  return modelClass.toString();
}
