// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:reproduce/Items/models/item.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:http/http.dart' as http;
part 'items_event.dart';
part 'items_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  ItemBloc(this.httpClient) : super(const ItemState()) {
    on<ItemsFetched>(
      _onItemFetched,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ItemsCategoryFetched>(
      _onItemFetchedCategory,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final http.Client httpClient;

  Future<void> _onItemFetched(
    ItemsFetched event,
    Emitter<ItemState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == ItemStatus.initial) {
        final items = await _fetchItems();
        return emit(state.copyWith(
          status: ItemStatus.success,
          items: items,
          hasReachedMax: false,
        ));
      }
      final items = await _fetchItems(state.items.length.toString());
      items.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
              state.copyWith(
                status: ItemStatus.success,
                items: List.of(state.items)..addAll(items),
                hasReachedMax: false,
              ),
            );
    } catch (_) {
      emit(state.copyWith(status: ItemStatus.failure));
    }
  }

  Future<void> _onItemFetchedCategory(
    ItemsCategoryFetched event,
    Emitter<ItemState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == ItemStatus.success) {
        final items = await _fetchItemsCategory(event.category);
        return emit(state.copyWith(
          status: ItemStatus.success,
          items: items,
          hasReachedMax: false,
        ));
      }
      final items = await _fetchItemsCategory(
          event.category, state.items.length.toString());
      items.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
              state.copyWith(
                status: ItemStatus.success,
                items: List.of(state.items)..addAll(items),
                hasReachedMax: false,
              ),
            );
    } catch (_) {
      emit(state.copyWith(status: ItemStatus.failure));
    }
  }

  Future<List<Item>> _fetchItems([String skip = '0', int limit = 10]) async {
    final response = await httpClient.get(
      Uri.https(
        'dummyjson.com',
        '/products',
        <String, String>{'limit': '$limit', 'skip': skip},
      ),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final body = json.decode(response.body)['products'] as List;
      return body.map((dynamic json) {
        return Item(
          id: json['id'] as int,
          title: json['title'] as String,
          description: json['description'] as String,
          price: json['price'] as int,
          discountPercentage: (json['discountPercentage'] as num).toDouble(),
          rating: (json['rating'] as num).toDouble(),
          stock: json['stock'] as int,
          brand: json['brand'] as String,
          category: json['category'] as String,
          thumbnail: json['thumbnail'] as String,
          images: (json['images'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
        );
      }).toList();
    }
    throw Exception('error fetching posts');
  }

  Future<List<Item>> _fetchItemsCategory(String categoryName,
      [String skip = '0', int limit = 2]) async {
    final response = await httpClient.get(
      Uri.https(
        'dummyjson.com',
        '/products/category/$categoryName',
        <String, String>{'limit': '$limit', 'skip': skip},
      ),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final body = json.decode(response.body)['products'] as List;
      return body.map((dynamic json) {
        return Item(
          id: json['id'] as int,
          title: json['title'] as String,
          description: json['description'] as String,
          price: json['price'] as int,
          discountPercentage: (json['discountPercentage'] as num).toDouble(),
          rating: (json['rating'] as num).toDouble(),
          stock: json['stock'] as int,
          brand: json['brand'] as String,
          category: json['category'] as String,
          thumbnail: json['thumbnail'] as String,
          images: (json['images'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
        );
      }).toList();
    }
    throw Exception('error fetching posts');
  }
}
