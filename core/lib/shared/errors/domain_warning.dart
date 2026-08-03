abstract class DomainWarning implements Exception {
  const DomainWarning(this.message);

  final String message;

  @override
  String toString() => message;
}
