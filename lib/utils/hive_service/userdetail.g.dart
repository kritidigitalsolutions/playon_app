import 'package:hive/hive.dart';
import 'package:play_on_app/utils/hive_service/userdetail.dart';

class UserDetailsAdapter extends TypeAdapter<UserDetails> {
  @override
  final int typeId = 0;

  @override
  UserDetails read(BinaryReader reader) {

    final numOfFields = reader.readByte();

    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return UserDetails(
      name: fields[0] as String,
      email: fields[1] as String,
      image: fields[2] as String?,
      token: fields[3] as String,
      phone: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserDetails obj) {

    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)

      ..writeByte(1)
      ..write(obj.email)

      ..writeByte(2)
      ..write(obj.image)

      ..writeByte(3)
      ..write(obj.token)

      ..writeByte(4)
      ..write(obj.phone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserDetailsAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
