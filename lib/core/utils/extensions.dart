/// Shared Dart extensions used across the app.
/// Import this instead of re-defining helpers per-file.
extension IterableX<E> on Iterable<E> {
  /// Maps an iterable with access to both the index and the element.
  /// Replaces the private _Indexed extension that used to be duplicated in
  /// member_home_screen.dart and owner_dashboard_screen.dart.
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}
