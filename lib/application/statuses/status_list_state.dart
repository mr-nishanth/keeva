import 'package:flutter/foundation.dart';

import '../../core/errors/app_failure.dart';
import '../../domain/entities/status_item.dart';

/// Sealed hierarchy representing the application state for WhatsApp status discovery.
///
/// Encapsulates all asynchronous transitions and preserves immutable collections
/// using unmodifiable views.
sealed class StatusListState {
  const StatusListState();

  /// Available statuses in the current state, if any.
  List<StatusItem> get items => switch (this) {
    StatusListSuccess(:final items) => items,
    StatusListRefreshing(:final items) => items,
    StatusListFailure(:final previousItems) => previousItems ?? const [],
    _ => const [],
  };

  bool get isInitial => this is StatusListInitial;
  bool get isLoading => this is StatusListLoading;
  bool get isRefreshing => this is StatusListRefreshing;
  bool get isSuccess => this is StatusListSuccess;
  bool get isEmpty => this is StatusListEmpty;
  bool get isFailure => this is StatusListFailure;
}

/// Initial uninitialized state before any status scanning.
final class StatusListInitial extends StatusListState {
  const StatusListInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusListInitial && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StatusListInitial()';
}

/// Status list is loading initially (no previous data).
final class StatusListLoading extends StatusListState {
  const StatusListLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusListLoading && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StatusListLoading()';
}

/// Status list is refreshing in the background while preserving [items].
final class StatusListRefreshing extends StatusListState {
  @override
  final List<StatusItem> items;

  StatusListRefreshing({required List<StatusItem> items})
    : items = List.unmodifiable(items);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusListRefreshing &&
          other.runtimeType == runtimeType &&
          listEquals(other.items, items));

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(items));

  @override
  String toString() => 'StatusListRefreshing(itemsCount: ${items.length})';
}

/// Statuses successfully discovered and loaded into memory.
final class StatusListSuccess extends StatusListState {
  @override
  final List<StatusItem> items;

  StatusListSuccess({required List<StatusItem> items})
    : items = List.unmodifiable(items);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusListSuccess &&
          other.runtimeType == runtimeType &&
          listEquals(other.items, items));

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(items));

  @override
  String toString() => 'StatusListSuccess(itemsCount: ${items.length})';
}

/// Scan completed successfully but zero statuses were found.
final class StatusListEmpty extends StatusListState {
  const StatusListEmpty();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusListEmpty && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StatusListEmpty()';
}

/// Status scanning failed with [failure], optionally retaining [previousItems].
final class StatusListFailure extends StatusListState {
  final AppFailure failure;
  final List<StatusItem>? previousItems;

  StatusListFailure({required this.failure, List<StatusItem>? previousItems})
    : previousItems = previousItems != null
          ? List.unmodifiable(previousItems)
          : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusListFailure &&
          other.runtimeType == runtimeType &&
          other.failure == failure &&
          listEquals(other.previousItems, previousItems));

  @override
  int get hashCode => Object.hash(
    runtimeType,
    failure,
    previousItems != null ? Object.hashAll(previousItems!) : null,
  );

  @override
  String toString() =>
      'StatusListFailure(failure: $failure, previousItemsCount: ${previousItems?.length})';
}
