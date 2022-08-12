part of 'items_bloc.dart';

enum ItemStatus { initial, success, failure }

class ItemState extends Equatable {
  const ItemState({
    this.status = ItemStatus.initial,
    this.items = const <Item>[],
    this.hasReachedMax = false,
  });

  final ItemStatus status;
  final List<Item> items;
  final bool hasReachedMax;

  ItemState copyWith({
    ItemStatus? status,
    List<Item>? items,
    bool? hasReachedMax,
  }) {
    return ItemState(
      status: status ?? this.status,
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''ItemState { status: $status, hasReachedMax: $hasReachedMax, items: ${items.length} }''';
  }

  @override
  List<Object> get props => [status, hasReachedMax, items];
}
