import 'package:core/shared/errors/domain_error.dart';

class PageRequest {
  const PageRequest._(this.page, this.pageSize);

  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  factory PageRequest.create({int page = 1, int pageSize = defaultPageSize}) {
    if (page < 1) {
      throw InvalidPageRequestError('page must be >= 1, got $page');
    }
    if (pageSize < 1 || pageSize > maxPageSize) {
      throw InvalidPageRequestError(
        'pageSize must be between 1 and $maxPageSize, got $pageSize',
      );
    }
    return PageRequest._(page, pageSize);
  }

  factory PageRequest.first({int pageSize = defaultPageSize}) =>
      PageRequest.create(pageSize: pageSize);

  final int page;
  final int pageSize;

  int get limit => pageSize;
  int get offset => (page - 1) * pageSize;

  PageRequest next() => PageRequest.create(page: page + 1, pageSize: pageSize);

  PageRequest previous() =>
      PageRequest.create(page: page > 1 ? page - 1 : 1, pageSize: pageSize);

  @override
  bool operator ==(Object other) =>
      other is PageRequest && other.page == page && other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(page, pageSize);

  @override
  String toString() => 'PageRequest(page: $page, pageSize: $pageSize)';
}

class InvalidPageRequestError extends DomainError {
  InvalidPageRequestError(String reason)
      : super('invalid page request: $reason');
}
