import 'package:flutter/material.dart';

import '../models/item.dart';

class ListItems extends StatelessWidget {
  const ListItems({Key? key, required this.item}) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      child: ListTile(
        leading: Text('${item.id}', style: textTheme.caption),
        title: Text(item.title),
        isThreeLine: true,
        subtitle: Text(item.description),
        dense: true,
      ),
    );
  }
}
