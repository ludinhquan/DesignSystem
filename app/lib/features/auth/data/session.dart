/// The signed-in user. `null` session means logged out.
class Session {
  const Session({
    required this.userId,
    required this.email,
    required this.name,
  });

  factory Session.fromJson(Map<String, Object?> json) => switch (json) {
    {
      'id': final String id,
      'email': final String email,
      'name': final String name,
    } =>
      Session(userId: id, email: email, name: name),
    _ => throw FormatException('Bad user: $json'),
  };

  final String userId;
  final String email;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Session &&
      other.userId == userId &&
      other.email == email &&
      other.name == name;

  @override
  int get hashCode => Object.hash(userId, email, name);
}
