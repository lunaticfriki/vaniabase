import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/home_state.dart';
import 'package:frontend/modules/catalog/application/home_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/home/home_skeleton.dart';
import 'package:frontend/modules/catalog/presentation/home/home_view.dart';
import 'package:go_router/go_router.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({super.key});

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  late final HomeStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = HomeStateService(getIt<ItemReadService>());
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
      child: BlocBuilder<HomeStateService, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const HomeSkeleton(),
          HomeError(:final message) => Center(child: Text(message)),
          HomeLoaded(:final items) => HomeView(
            items: items,
            onSeeAll: () => context.go('/items'),
            onItemTap: (item) => context.push('/items/${item.id}'),
          ),
        },
      ),
    );
  }
}
