part of 'sign_up_cubit.dart';

enum ConfirmPasswordValidationError { invalid }

class SignUpState extends Equatable {
  const SignUpState({
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
  });

  final Name name;
  final Email email;
  final Password password;
  final ConfirmedPassword confirmedPassword;

  @override
  List<Object> get props => [name, email, password, confirmedPassword];

  SignUpState copyWith({
    required Name name,
    required Email email,
    required Password password,
    required ConfirmedPassword confirmedPassword,
  }) {
    return SignUpState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmedPassword: confirmedPassword ?? this.confirmedPassword,
    );
  }
}
