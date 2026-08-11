import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/tags_state_service.dart';
import 'package:frontend/modules/catalog/presentation/tags/tags_view.dart';
import 'package:go_router/go_router.dart';

class TagsContainer extends StatefulWidget {
  const TagsContainer({this.initialTag, super.key});

  final String? initialTag;

  @override
  State<TagsContainer> createState() => _TagsContainerState();
}

class _TagsContainerState extends State<TagsContainer> {
  late final TagsStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = TagsStateService(
      getIt<ItemReadService>(),
      initialTag: widget.initialTag,
    );
  }

  @override
  void dispose() {
    _stateService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _stateService,
      child: BlocBuilder<TagsStateService, TagsState>(
        builder: (context, state) => TagsView(
          state: state,
          onTagTap: (tag) => context.read<TagsStateService>().selectTag(tag),
          onItemTap: (item) => context.push('/items/${item.id}'),
        ),
      ),
    );
  }
}
