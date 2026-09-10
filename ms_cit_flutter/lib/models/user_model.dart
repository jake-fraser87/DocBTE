/// Plain data model — no business logic, no Flutter widgets.
/// This is the "M" in MVVM.
class UserModel {
  final String username;
  final String displayName;
  final String role;
  final String zone;

  const UserModel({
    required this.username,
    required this.displayName,
    required this.role,
    required this.zone,
  });
}
