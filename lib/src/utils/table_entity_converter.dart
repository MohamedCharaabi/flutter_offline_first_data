import 'package:drift/drift.dart';

/// Utility class for converting between an entity and a table dataclass.
///
/// This abstract class defines the contract for converting objects of type [T] (entity)
/// to type [C] (table dataclass companion) and vice versa. It is useful for mapping between
/// domain entities and their database representations.
abstract class TableEntityConverter<T, C> {
  /// Converts an entity of type [T] to a Drift [Insertable] companion of type [C].
  Insertable<C> toCompanion(T entity);

  /// Converts a Drift companion of type [C] to an entity of type [T].
  T fromDriftCompanion(C companion);
}
