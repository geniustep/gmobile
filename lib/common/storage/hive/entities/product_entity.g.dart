// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductEntityAdapter extends TypeAdapter<ProductEntity> {
  @override
  final int typeId = 0;

  @override
  ProductEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductEntity(
      id: fields[0] as int,
      name: fields[1] as String,
      displayName: fields[2] as String?,
      listPrice: fields[3] as double?,
      standardPrice: fields[4] as double?,
      barcode: fields[5] as String?,
      defaultCode: fields[6] as String?,
      qtyAvailable: fields[7] as double?,
      virtualAvailable: fields[8] as double?,
      categId: fields[9] as int?,
      image128: fields[10] as String?,
      active: fields[11] as bool?,
      type: fields[12] as String?,
      uomName: fields[13] as String?,
      lastSync: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProductEntity obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.listPrice)
      ..writeByte(4)
      ..write(obj.standardPrice)
      ..writeByte(5)
      ..write(obj.barcode)
      ..writeByte(6)
      ..write(obj.defaultCode)
      ..writeByte(7)
      ..write(obj.qtyAvailable)
      ..writeByte(8)
      ..write(obj.virtualAvailable)
      ..writeByte(9)
      ..write(obj.categId)
      ..writeByte(10)
      ..write(obj.image128)
      ..writeByte(11)
      ..write(obj.active)
      ..writeByte(12)
      ..write(obj.type)
      ..writeByte(13)
      ..write(obj.uomName)
      ..writeByte(14)
      ..write(obj.lastSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
