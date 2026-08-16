import 'package:core/shared/pagination/page_request.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/shared/layout/responsive_item_grid.dart';

enum ItemViewMode { list, twoColumns, grid }

/// Below this width the view-mode toggle is shown; at or above it every
/// list always renders as [ItemViewMode.grid] since there's ample room.
const itemViewModeWideBreakpoint = 640.0;

const _gridMobileTargetColumns = 4;
const _gridMobileMinItemWidth = 80.0;
const _gridMobileMaxItemWidth = 130.0;

/// Grid on a narrow/responsive screen: dense, image-only thumbnails capped
/// at [_gridMobileTargetColumns] per row (4 rows' worth per page).
const itemViewModeGridMobilePageSize = 20;

/// Grid on a wide/desktop screen: full cards (image + title/author), column
/// count adapts to the window instead of being capped.
const itemViewModeGridDesktopMinItemWidth = 140.0;
const itemViewModeGridDesktopMaxItemWidth = 220.0;
const itemViewModeGridDesktopRows = 4;
const _unlimitedColumns = 100;

extension ItemViewModeLayout on ItemViewMode {
  int targetColumns(bool isWide) => switch (this) {
    ItemViewMode.list => 1,
    ItemViewMode.twoColumns => 2,
    ItemViewMode.grid => isWide ? _unlimitedColumns : _gridMobileTargetColumns,
  };

  double minItemWidth(bool isWide) {
    if (this != ItemViewMode.grid) return 140;
    return isWide ? itemViewModeGridDesktopMinItemWidth : _gridMobileMinItemWidth;
  }

  double maxItemWidth(bool isWide) => switch (this) {
    ItemViewMode.list => 480,
    ItemViewMode.twoColumns => 220,
    ItemViewMode.grid =>
      isWide ? itemViewModeGridDesktopMaxItemWidth : _gridMobileMaxItemWidth,
  };

  /// Only the narrow/responsive grid hides title/author to stay dense —
  /// desktop always shows full card details, same as list/two-columns.
  bool showDetails(bool isWide) => isWide || this != ItemViewMode.grid;
}

/// The page size that keeps a paginated grid at a consistent number of rows
/// regardless of how many columns actually fit: a fixed row count on a
/// narrow/responsive screen (columns are capped there), or
/// [itemViewModeGridDesktopRows] worth of however many columns fit on a
/// wide screen. Non-grid modes keep the regular list page size.
int itemViewModeGridAwarePageSize(BuildContext context, ItemViewMode mode) {
  final isWide = MediaQuery.sizeOf(context).width >= itemViewModeWideBreakpoint;
  final effectiveMode = isWide ? ItemViewMode.grid : mode;
  if (effectiveMode != ItemViewMode.grid) return PageRequest.defaultPageSize;
  if (!isWide) return itemViewModeGridMobilePageSize;

  final availableWidth = MediaQuery.sizeOf(context).width - 32;
  final columns = ResponsiveItemGrid.columnsThatFit(
    availableWidth: availableWidth,
    minItemWidth: itemViewModeGridDesktopMinItemWidth,
  );
  return columns * itemViewModeGridDesktopRows;
}
