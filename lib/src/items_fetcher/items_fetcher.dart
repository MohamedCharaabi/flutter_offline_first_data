import 'package:drift/drift.dart';
import 'package:flutter_offline_first_data/src/utils/read_prams.dart';

/// Remote fetcher for multiple items.
abstract class ItemsRemoteFetcher<T> {
  Future<List<T>> call();
}

/// Fetcher for multiple items.
abstract class ItemsFetcher<T, P> {
  Stream<List<T>> call(
    StreamReadParams<P> params,
    Expression<bool> Function(HasResultSet)? filter,
    Expression<bool> Function(HasResultSet) Function(dynamic) updateItemFilter,
  );
}
