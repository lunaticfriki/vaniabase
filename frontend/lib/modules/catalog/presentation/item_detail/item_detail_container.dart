import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_detail_state.dart';
import 'package:frontend/modules/catalog/application/item_detail_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/item_detail_skeleton.dart';
import 'package:frontend/modules/catalog/presentation/item_detail/item_detail_view.dart';
import 'package:go_router/go_router.dart';
import 'package:pixelarticons/pixel.dart';

class ItemDetailContainer extends StatefulWidget {
  const ItemDetailContainer({required this.itemId, super.key});

  final String itemId;

  @override
  State<ItemDetailContainer> createState() => _ItemDetailContainerState();
}

class _ItemDetailContainerState extends State<ItemDetailContainer> {
  late final ItemDetailStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = ItemDetailStateService(getIt<ItemReadService>(), widget.itemId);
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
      child: BlocBuilder<ItemDetailStateService, ItemDetailState>(
        builder: (context, state) => switch (state) {
          ItemDetailLoading() => const ItemDetailSkeleton(),
          ItemDetailError(:final message) => _ItemDetailErrorView(
            message: message,
            onBack: () => _goBack(context),
          ),
          ItemDetailLoaded(:final item) => ItemDetailView(
            item: item,
            onBack: () => _goBack(context),
            onEdit: () => context.go('/items/${item.id}/edit'),
          ),
        },
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/items');
    }
  }
}

class _ItemDetailErrorView extends StatelessWidget {
  const _ItemDetailErrorView({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Pixel.arrowleft),
            label: const Text('Back'),
          ),
          Expanded(child: Center(child: Text(message))),
        ],
      ),
    );
  }
}
