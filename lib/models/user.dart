class User{
  final String id;
  final String username;
  final String email;
  final int userType;
  String jwt;
  String jwtRefresh;
  final String lastLogin;
  final String latestUpdate;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.userType=0,
    this.jwt="",
    this.jwtRefresh="",
    this.lastLogin="",
    this.latestUpdate="",
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      userType: json['user_type'],
    );
  }


  setTokens(jwt, jwtRefresh) {
    this.jwt = jwt;
    this.jwtRefresh = jwtRefresh;
  }
}