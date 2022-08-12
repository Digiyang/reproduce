import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:reproduce/Items/view/items_list.dart';

import '../bloc/items_bloc.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itemss')),
      body: BlocProvider<ItemBloc>(
        create: (_) => ItemBloc(http.Client())..add(ItemsFetched()),
        child: const ItemsList(),
      ),
    );
  }
}
