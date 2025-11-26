class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdTime;
  final DateTime updatedTime;
  final bool isArchived;
  final bool isDeleted;
  final bool isPinned;
  final DateTime? archivedTime;
  final DateTime? deletedTime;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdTime,
    required this.updatedTime,
    this.isArchived = false,
    this.isDeleted = false,
    this.isPinned = false,
    this.archivedTime,
    this.deletedTime,
  });

  Note copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdTime,
    DateTime? updatedTime,
    bool? isArchived,
    bool? isDeleted,
    bool? isPinned,
    DateTime? archivedTime,
    DateTime? deletedTime,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdTime: createdTime ?? this.createdTime,
      updatedTime: updatedTime ?? this.updatedTime,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      archivedTime: archivedTime ?? this.archivedTime,
      deletedTime: deletedTime ?? this.deletedTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdTime': createdTime.toIso8601String(),
      'updatedTime': updatedTime.toIso8601String(),
      'isArchived': isArchived ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'isPinned': isPinned ? 1 : 0,
      'archivedTime': archivedTime?.toIso8601String(),
      'deletedTime': deletedTime?.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdTime: DateTime.parse(map['createdTime']),
      updatedTime: DateTime.parse(map['updatedTime']),
      isArchived: map['isArchived'] == 1,
      isDeleted: map['isDeleted'] == 1,
      isPinned: map['isPinned'] == 1,
      archivedTime: map['archivedTime'] != null
          ? DateTime.parse(map['archivedTime'])
          : null,
      deletedTime: map['deletedTime'] != null
          ? DateTime.parse(map['deletedTime'])
          : null,
    );
  }
}
