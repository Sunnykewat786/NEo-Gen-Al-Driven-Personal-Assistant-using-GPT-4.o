import 'package:hive/hive.dart';

part 'chat.g.dart'; // This part directive is needed for Hive to generate adapter code.  It should be placed with other imports.

/// This class represents a chat message.  It's used to store individual messages
/// in the chat history.  It is annotated with Hive annotations to allow it to be
/// stored in a Hive database.
  @HiveType(typeId: 1)
  class Chat extends HiveObject {
    @HiveField(0)
    final String msg;
    
    @HiveField(1)
    final ChatType msgType;
    
    @HiveField(2)
    final String? feedbackType; // New field for feedback type
    
    Chat({
      required this.msg, 
      required this.msgType,
      this.feedbackType,
    });

    Map<String, dynamic> toJson() {
      return {
        'msg': msg,
        'msgType': msgType.index,
        'feedbackType': feedbackType,
      };
    }

    factory Chat.fromJson(Map<String, dynamic> json) {
      return Chat(
        msg: json['msg'],
        msgType: ChatType.values[json['msgType']],
        feedbackType: json['feedbackType'],
      );
    }
  }

/// This enum represents the type of a chat message.
enum ChatType {
  user, // Represents a message from the user.
  bot, // Represents a message from the bot.
}

/// This class is a Hive TypeAdapter for the ChatType enum.  It's responsible for
/// converting ChatType values to and from a binary format that Hive can store.
class ChatTypeAdapter extends TypeAdapter<ChatType> {
  @override
  final int typeId = 2; // Each TypeAdapter needs a unique typeId.  This should be different from the Chat class's typeId.

  /// Reads a ChatType value from a binary reader.
  ///
  /// Parameters:
  ///   reader (BinaryReader): The reader to read the value from.
  ///
  /// Returns:
  ///   ChatType: The ChatType value read from the reader.
  @override
  ChatType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChatType.user; // 0 represents ChatType.user
      case 1:
        return ChatType.bot; // 1 represents ChatType.bot
      default:
        return ChatType.user; // Default case.  Consider throwing an exception for an invalid value.
    }
  }

  /// Writes a ChatType value to a binary writer.
  ///
  /// Parameters:
  ///   writer (BinaryWriter): The writer to write the value to.
  ///   obj (ChatType): The ChatType value to write.
  @override
  void write(BinaryWriter writer, ChatType obj) {
    switch (obj) {
      case ChatType.user:
        writer.writeByte(0); // Write 0 for ChatType.user
        break;
      case ChatType.bot:
        writer.writeByte(1); // Write 1 for ChatType.bot
        break;
    }
  }
}
