import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/search_state_service.dart';
import 'package:frontend/modules/catalog/presentation/bulk_export_feedback.dart';
import 'package:frontend/modules/catalog/presentation/search/search_view.dart';
import 'package:go_router/go_router.dart';

class SearchContainer extends StatefulWidget {
  const SearchContainer({super.key});

  @override
  State<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  late final SearchStateService _stateService;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stateService = SearchStateService(getIt<ItemReadService>());
  }

  @override
  void dispose() {
    _stateService.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _stateService,
      child: BlocBuilder<SearchStateService, SearchState>(
        builder: (context, state) {
          final loaded = state is SearchLoaded ? state : null;
          return SearchView(
            state: state,
            controller: _controller,
            onQueryChanged: (query) =>
                context.read<SearchStateService>().onQueryChanged(query),
            onItemTap: (item) => context.push('/items/${item.id}'),
            onExport: loaded == null
                ? null
                : () => exportItemsWithFeedback(
                    context,
                    loaded.items,
                    'search-${loaded.query}',
                  ),
          );
        },
      ),
    );
  }
}
