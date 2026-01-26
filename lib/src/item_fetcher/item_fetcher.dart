import 'package:drift/drift.dart';
import 'package:flutter_offline_first_data/src/utils/read_prams.dart';

/// An abstract class defining the contract for fetching a single item from a remote source.
abstract class ItemRemoteFetcher<T> {
  Future<T> call();
}

/// An abstract class defining the contract for fetching a single item
abstract class ItemFetcher<T, P> {
  Stream<T?> call(
    StreamReadParams<P> params,
    Expression<bool> Function(HasResultSet) filter,
  );
}
