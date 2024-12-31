import 'package:equatable/equatable.dart';

class Metadata extends Equatable {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Metadata({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Metadata.create(int id) {
    final now = DateTime.now();
    return Metadata(
      id: id,
      createdAt: now,
      updatedAt: now,
    );
  }

  Metadata copyWith({
    DateTime? updatedAt,
  }) {
    return Metadata(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}
