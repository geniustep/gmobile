// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_order_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleOrderEntityAdapter extends TypeAdapter<SaleOrderEntity> {
  @override
  final int typeId = 2;

  @override
  SaleOrderEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleOrderEntity(
      id: fields[0] as int,
      name: fields[1] as String,
      partnerId: fields[2] as int?,
      partnerName: fields[3] as String?,
      dateOrder: fields[4] as String?,
      amountTotal: fields[5] as double?,
      amountUntaxed: fields[6] as double?,
      amountTax: fields[7] as double?,
      state: fields[8] as String?,
      pricelistId: fields[9] as int?,
      paymentTermId: fields[10] as int?,
      note: fields[11] as String?,
      orderLineIds: (fields[12] as List?)?.cast<int>(),
      lastSync: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SaleOrderEntity obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.partnerId)
      ..writeByte(3)
      ..write(obj.partnerName)
      ..writeByte(4)
      ..write(obj.dateOrder)
      ..writeByte(5)
      ..write(obj.amountTotal)
      ..writeByte(6)
      ..write(obj.amountUntaxed)
      ..writeByte(7)
      ..write(obj.amountTax)
      ..writeByte(8)
      ..write(obj.state)
      ..writeByte(9)
      ..write(obj.pricelistId)
      ..writeByte(10)
      ..write(obj.paymentTermId)
      ..writeByte(11)
      ..write(obj.note)
      ..writeByte(12)
      ..write(obj.orderLineIds)
      ..writeByte(13)
      ..write(obj.lastSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleOrderEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
