import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/home_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/home/home_skeleton.dart';
import 'package:frontend/modules/catalog/presentation/home/home_view.dart';
import 'package:frontend/shared/layout/item_view_mode.dart';
import 'package:frontend/shared/layout/item_view_mode_state_service.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({super.key});

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  late final HomeStateService _stateService;
  late final ItemViewModeStateService _viewModeService;

  @override
  void initState() {
    super.initState();
    _stateService = HomeStateService(getIt<ItemReadService>());
    _viewModeService = ItemViewModeStateService(
      getIt<SharedPreferences>(),
      'home_view_mode',
    );
  }

  @override
  void dispose() {
    _stateService.close();
    _viewModeService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _stateService),
        BlocProvider.value(value: _viewModeService),
      ],
      child: BlocBuilder<HomeStateService, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const HomeSkeleton(),
          HomeError(:final message) => Center(child: Text(message)),
          HomeLoaded(:final items) =>
            BlocBuilder<ItemViewModeStateService, ItemViewMode>(
              builder: (context, viewMode) => HomeView(
                items: items,
                viewMode: viewMode,
                onViewModeChanged: (mode) =>
                    context.read<ItemViewModeStateService>().setMode(mode),
                onItemTap: (item) => context.push('/items/${item.id}'),
              ),
            ),
        },
      ),
    );
  }
}
