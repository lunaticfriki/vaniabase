import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/presentation/category_list/category_list_view.dart';
import 'package:go_router/go_router.dart';

class CategoryListContainer extends StatelessWidget {
  const CategoryListContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryListView(onCategoryTap: (category) => context.go('/categories/$category'));
  }
}
