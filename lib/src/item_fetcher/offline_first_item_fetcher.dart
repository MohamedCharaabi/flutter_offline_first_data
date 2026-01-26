import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_offline_first_data/src/item_fetcher/item_fetcher.dart';
import 'package:flutter_offline_first_data/src/utils/read_prams.dart';
import 'package:flutter_offline_first_data/src/utils/table_entity_converter.dart';

/// Offline-first implementation of [ItemFetcher].
class OfflineFirstItemFetcher<T, P> implements ItemFetcher<T, P> {
  OfflineFirstItemFetcher({
    required this.remoteLoader,
    required this.db,
    required this.tableToEntityConverter,
  });

  /// Remote fetcher for a single item.
  final ItemRemoteFetcher<T?> remoteLoader;

  /// Drift database instance.
  final GeneratedDatabase db;

  /// Converter between table dataclass and entity.
  final TableEntityConverter<T, dynamic> tableToEntityConverter;
  Stream<T?> call(
    StreamReadParams<P> params,
    Expression<bool> Function(HasResultSet) filter,
  ) async* {
    final localValue = await (db.select(
      params.localTable,
    )..where(filter)).getSingleOrNull();

    if (localValue != null) {
      yield tableToEntityConverter.fromDriftCompanion(localValue);
    }

    if (params.dataStreamReadMode == DataStreamReadMode.remoteAndLocal) {
      final remoteResult = await remoteLoader.call();

      if (remoteResult != null) {
        if (localValue == null) {
          await db
              .into(params.table)
              .insert(tableToEntityConverter.toCompanion(remoteResult));
        } else {
          // update
          await (db.update(
            params.table,
          )..where(filter)).write(
            tableToEntityConverter.toCompanion(remoteResult),
          );
        }
      }

      final localValue2 = await (db.select(
        params.localTable,
      )..where(filter)).getSingleOrNull();

      if (localValue2 != null) {
        yield tableToEntityConverter.fromDriftCompanion(localValue2);
      }
    }
  }
}
