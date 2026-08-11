import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/publishers_state_service.dart';
import 'package:frontend/modules/catalog/presentation/publishers/publishers_view.dart';
import 'package:go_router/go_router.dart';

class PublishersContainer extends StatefulWidget {
  const PublishersContainer({this.initialPublisher, super.key});

  final String? initialPublisher;

  @override
  State<PublishersContainer> createState() => _PublishersContainerState();
}

class _PublishersContainerState extends State<PublishersContainer> {
  late final PublishersStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = PublishersStateService(
      getIt<ItemReadService>(),
      initialPublisher: widget.initialPublisher,
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
      child: BlocBuilder<PublishersStateService, PublishersState>(
        builder: (context, state) => PublishersView(
          state: state,
          onLetterTap: (letter) =>
              context.read<PublishersStateService>().selectLetter(letter),
          onPublisherTap: (publisher) =>
              context.read<PublishersStateService>().selectPublisher(publisher),
          onItemTap: (item) => context.push('/items/${item.id}'),
        ),
      ),
    );
  }
}
