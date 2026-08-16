import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/search_state_service.dart';
import 'package:frontend/modules/catalog/presentation/bulk_export_feedback.dart';
import 'package:frontend/modules/catalog/presentation/search/search_view.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:frontend/shared/layout/item_view_mode_state_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchContainer extends StatefulWidget {
  const SearchContainer({super.key});

  @override
  State<SearchContainer> createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  late final SearchStateService _stateService;
  late final ItemViewModeStateService _viewModeService;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stateService = SearchStateService(getIt<ItemReadService>());
    _viewModeService = ItemViewModeStateService(
      getIt<SharedPreferences>(),
      'item_list_view_mode',
    );
  }

  @override
  void dispose() {
    _stateService.close();
    _viewModeService.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _stateService),
        BlocProvider.value(value: _viewModeService),
      ],
      child: BlocBuilder<SearchStateService, SearchState>(
        builder: (context, state) {
          final loaded = state is SearchLoaded ? state : null;
          return BlocBuilder<ItemViewModeStateService, ItemViewMode>(
            builder: (context, viewMode) => SearchView(
              state: state,
              controller: _controller,
              onQueryChanged: (query) =>
                  context.read<SearchStateService>().onQueryChanged(query),
              onItemTap: (item) => context.push('/items/${item.id}'),
              viewMode: viewMode,
              onViewModeChanged: (mode) =>
                  context.read<ItemViewModeStateService>().setMode(mode),
              onExport: loaded == null
                  ? null
                  : () => exportItemsWithFeedback(
                      context,
                      loaded.items,
                      'search-${loaded.query}',
                    ),
            ),
          );
        },
      ),
    );
  }
}
