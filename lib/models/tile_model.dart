class TileModel {
  final String id;
  final int value;
  final int row;
  final int col;
  final bool isNew;

  TileModel({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.isNew = false,
  });

  TileModel copyWith({
    String? id,
    int? value,
    int? row,
    int? col,
    bool? isNew,
  }) {
    return TileModel(
      id: id ?? this.id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      isNew: isNew ?? this.isNew,
    );
  }
}