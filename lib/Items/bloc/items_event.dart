part of 'items_bloc.dart';

abstract class ItemEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ItemsFetched extends ItemEvent {}

class ItemsCategoryFetched extends ItemEvent {
  final String category;

  ItemsCategoryFetched(this.category);
}
