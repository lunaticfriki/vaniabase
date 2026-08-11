import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/topics_state_service.dart';
import 'package:frontend/modules/catalog/presentation/topics/topics_view.dart';
import 'package:go_router/go_router.dart';

class TopicsContainer extends StatefulWidget {
  const TopicsContainer({this.initialTopic, super.key});

  final String? initialTopic;

  @override
  State<TopicsContainer> createState() => _TopicsContainerState();
}

class _TopicsContainerState extends State<TopicsContainer> {
  late final TopicsStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = TopicsStateService(
      getIt<ItemReadService>(),
      initialTopic: widget.initialTopic,
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
      child: BlocBuilder<TopicsStateService, TopicsState>(
        builder: (context, state) => TopicsView(
          state: state,
          onLetterTap: (letter) =>
              context.read<TopicsStateService>().selectLetter(letter),
          onTopicTap: (topic) =>
              context.read<TopicsStateService>().selectTopic(topic),
          onItemTap: (item) => context.push('/items/${item.id}'),
        ),
      ),
    );
  }
}
