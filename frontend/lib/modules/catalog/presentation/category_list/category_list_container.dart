import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/categories_state.dart';
import 'package:frontend/modules/catalog/application/categories_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:frontend/modules/catalog/presentation/category_list/category_list_view.dart';
import 'package:go_router/go_router.dart';

class CategoryListContainer extends StatefulWidget {
  const CategoryListContainer({super.key});

  @override
  State<CategoryListContainer> createState() => _CategoryListContainerState();
}

class _CategoryListContainerState extends State<CategoryListContainer> {
  late final CategoriesStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = CategoriesStateService(getIt<ItemReadService>(), categoryLabels.keys.toList());
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
      child: BlocBuilder<CategoriesStateService, CategoriesState>(
        builder: (context, state) => switch (state) {
          CategoriesLoading() => const Center(child: CircularProgressIndicator()),
          CategoriesError(:final message) => Center(child: Text(message)),
          CategoriesLoaded(:final previewImageUrls) => CategoryListView(
            previewImageUrls: previewImageUrls,
            onCategoryTap: (category) => context.go('/categories/$category'),
          ),
        },
      ),
    );
  }
}
