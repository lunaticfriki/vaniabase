sealed class CategoriesState {
  const CategoriesState();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.previewImageUrls);

  final Map<String, List<String>> previewImageUrls;
}

class CategoriesError extends CategoriesState {
  const CategoriesError(this.message);

  final String message;
}
