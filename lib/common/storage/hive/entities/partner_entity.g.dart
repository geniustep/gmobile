// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PartnerEntityAdapter extends TypeAdapter<PartnerEntity> {
  @override
  final int typeId = 1;

  @override
  PartnerEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PartnerEntity(
      id: fields[0] as int,
      name: fields[1] as String,
      displayName: fields[2] as String?,
      email: fields[3] as String?,
      phone: fields[4] as String?,
      mobile: fields[5] as String?,
      street: fields[6] as String?,
      city: fields[7] as String?,
      country: fields[8] as String?,
      vat: fields[9] as String?,
      isCompany: fields[10] as bool?,
      image128: fields[11] as String?,
      creditLimit: fields[12] as double?,
      propertyPaymentTermId: fields[13] as int?,
      propertyProductPricelistId: fields[14] as int?,
      lastSync: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PartnerEntity obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.mobile)
      ..writeByte(6)
      ..write(obj.street)
      ..writeByte(7)
      ..write(obj.city)
      ..writeByte(8)
      ..write(obj.country)
      ..writeByte(9)
      ..write(obj.vat)
      ..writeByte(10)
      ..write(obj.isCompany)
      ..writeByte(11)
      ..write(obj.image128)
      ..writeByte(12)
      ..write(obj.creditLimit)
      ..writeByte(13)
      ..write(obj.propertyPaymentTermId)
      ..writeByte(14)
      ..write(obj.propertyProductPricelistId)
      ..writeByte(15)
      ..write(obj.lastSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartnerEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
