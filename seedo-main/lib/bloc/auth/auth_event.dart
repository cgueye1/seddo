import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignupEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final bool activated;
  final String role;
  final String profil;

  const AuthSignupEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    this.activated = true,
    this.role = "USER",
    this.profil = "USER",
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    email,
    password,
    phone,
    activated,
    role,
    profil,
  ];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthForgotPasswordEvent extends AuthEvent {
  final String email;

  const AuthForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}
