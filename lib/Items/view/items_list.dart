import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/items_bloc.dart';
import 'list_items.dart';

class ItemsList extends StatefulWidget {
  const ItemsList({Key? key}) : super(key: key);

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  final _scrollController = ScrollController();
  String? selectedCategory;
  bool _selected = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        List<String> categoryList;
        switch (state.status) {
          case ItemStatus.failure:
            return const Center(child: Text('failed to fetch posts'));
          case ItemStatus.success:
            if (state.items.isEmpty) {
              return const Center(child: Text('no posts'));
            }
            return Column(
              children: [
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: state.items
                          .map((e) => Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: ChoiceChip(
                                  selected: selectedCategory == e.category,
                                  selectedColor: Colors.blue,
                                  label: Text(e.category),
                                  onSelected: (newValue) {
                                    if (newValue) {
                                      selectedCategory = e.category;
                                      BlocProvider.of<ItemBloc>(context).add(
                                          ItemsCategoryFetched(
                                              selectedCategory!));
                                    } else {
                                      BlocProvider.of<ItemBloc>(context)
                                          .add(ItemsFetched());
                                    }
                                  },
                                ),
                              ))
                          .toList(),
                    )),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return index >= state.items.length
                          ? const CircularProgressIndicator()
                          : ListItems(item: state.items[index]);
                    },
                    itemCount: state.hasReachedMax
                        ? state.items.length
                        : state.items.length + 1,
                    controller: _scrollController,
                  ),
                ),
              ],
            );
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<ItemBloc>().add(ItemsFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
