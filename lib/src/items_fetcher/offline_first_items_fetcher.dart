import 'package:drift/drift.dart';
import 'package:flutter_offline_first_data/src/items_fetcher/items_fetcher.dart';
import 'package:flutter_offline_first_data/src/utils/read_prams.dart';
import 'package:flutter_offline_first_data/src/utils/table_entity_converter.dart';

/// An implementation of [ItemsFetcher] that follows the offline-first strategy.
///
/// It first attempts to fetch data from the local database. If the data is not
/// available locally or if the [dataStreamReadMode] is set to [DataStreamReadMode.remoteAndLocal],
/// it fetches data from the remote source and updates
/// the local database accordingly.
class OfflineFirstItemsFetcher<T, P> implements ItemsFetcher<T, P> {
  OfflineFirstItemsFetcher({
    required this.remoteLoader,
    required this.db,
    required this.tableEntityConverter,
  });

  /// The remote data loader to fetch data from the remote source.
  final ItemsRemoteFetcher<T> remoteLoader;

  /// The Drift database instance for local data operations.
  final GeneratedDatabase db;

  /// Converter for transforming between table data and entity objects.
  final TableEntityConverter<T, dynamic> tableEntityConverter;

  Future<List<T>> _readLocal(
    StreamReadParams<P> params,
    Expression<bool> Function(HasResultSet)? filter,
  ) async {
    List<dynamic> localResult;
    if (filter == null) {
      localResult = await db.select(params.localTable).get();
    } else {
      localResult = await (db.select(params.localTable)..where(filter)).get();
    }

    if (localResult.isEmpty) {
      return <T>[];
    }

    final data = localResult
        .map(tableEntityConverter.fromDriftCompanion)
        .toList();

    return data;
  }

  @override
  Stream<List<T>> call(
    StreamReadParams<P> params,
    Expression<bool> Function(HasResultSet)? filter,
    Expression<bool> Function(HasResultSet) Function(dynamic) updateItemFilter,
  ) async* {
    final localResult = await _readLocal(params, filter);

    if (localResult.isNotEmpty) {
      yield localResult;
    }

    if (params.dataStreamReadMode == DataStreamReadMode.remoteAndLocal) {
      final remoteResult = await remoteLoader.call();

      if (remoteResult.isNotEmpty) {
        if (localResult.isEmpty) {
          await db.transaction(() async {
            await db.batch((batch) {
              batch.insertAll(
                params.table,
                remoteResult.map(tableEntityConverter.toCompanion),
              );
            });
          });
        } else {
          // update

          for (final item in remoteResult) {
            await (db.update(
              params.table,
            )..where(updateItemFilter(item))).write(
              tableEntityConverter.toCompanion(item),
            );
          }
        }
      }

      yield await _readLocal(params, filter);
    }
  }
}
