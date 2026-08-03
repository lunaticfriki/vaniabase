import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/home/home_cubit.dart';
import 'package:frontend/modules/catalog/presentation/home/home_skeleton.dart';
import 'package:frontend/modules/catalog/presentation/home/home_state.dart';
import 'package:frontend/modules/catalog/presentation/home/home_view.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(getIt<ItemReadService>()),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const HomeSkeleton(),
          HomeError(:final message) => Center(child: Text(message)),
          HomeLoaded(:final items) => HomeView(
            items: items,
            onSeeAll: () => context.go('/items'),
          ),
        },
      ),
    );
  }
}
