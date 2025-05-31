// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translate.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranslationHistoryItemAdapter
    extends TypeAdapter<TranslationHistoryItem> {
  @override
  final int typeId = 3;

  @override
  TranslationHistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranslationHistoryItem(
      fromText: fields[0] as String,
      toText: fields[1] as String,
      fromLanguage: fields[2] as String,
      toLanguage: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TranslationHistoryItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.fromText)
      ..writeByte(1)
      ..write(obj.toText)
      ..writeByte(2)
      ..write(obj.fromLanguage)
      ..writeByte(3)
      ..write(obj.toLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationHistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
