import 'package:drift/drift.dart';

/// Modes for reading data streams.
///
/// Used to specify whether to read data only from the local source or from both remote and local sources.
enum DataStreamReadMode { localOnly, remoteAndLocal }

/// Parameters used when calling data fetcher classes.
///
/// [ReadParams] encapsulates the parameters required for fetching data, including an optional
/// parameter [param], a reference to the local table, and the table info.
class ReadParams<T> {
  ReadParams({this.param, required this.localTable, required this.table});

  /// Optional parameter for the fetch operation.
  final T? param;

  /// Reference to the local table implementation.
  final ResultSetImplementation<HasResultSet, dynamic> localTable;

  /// Table information for the fetch operation.
  final TableInfo<Table, dynamic> table;
}

/// Parameters for streaming data fetch operations.
///
/// Extends [ReadParams] by adding a [dataStreamReadMode] to specify the mode of data streaming.
class StreamReadParams<T> extends ReadParams<T> {
  StreamReadParams({
    required super.localTable,
    required this.dataStreamReadMode,
    required super.table,
    super.param,
  });

  /// Specifies whether to read data only from local or from both remote and local sources.
  final DataStreamReadMode dataStreamReadMode;
}
