// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AuthEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent()';
  }
}

/// @nodoc
class $AuthEventCopyWith<$Res> {
  $AuthEventCopyWith(AuthEvent _, $Res Function(AuthEvent) __);
}

/// Adds pattern-matching-related methods to [AuthEvent].
extension AuthEventPatterns on AuthEvent {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Login value)? login,
    TResult Function(Register value)? register,
    TResult Function(Logout value)? logout,
    TResult Function(ResetPassword value)? resetPassword,
    TResult Function(ClearError value)? clearError,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case Login() when login != null:
        return login(_that);
      case Register() when register != null:
        return register(_that);
      case Logout() when logout != null:
        return logout(_that);
      case ResetPassword() when resetPassword != null:
        return resetPassword(_that);
      case ClearError() when clearError != null:
        return clearError(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Login value) login,
    required TResult Function(Register value) register,
    required TResult Function(Logout value) logout,
    required TResult Function(ResetPassword value) resetPassword,
    required TResult Function(ClearError value) clearError,
  }) {
    final _that = this;
    switch (_that) {
      case Login():
        return login(_that);
      case Register():
        return register(_that);
      case Logout():
        return logout(_that);
      case ResetPassword():
        return resetPassword(_that);
      case ClearError():
        return clearError(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Login value)? login,
    TResult? Function(Register value)? register,
    TResult? Function(Logout value)? logout,
    TResult? Function(ResetPassword value)? resetPassword,
    TResult? Function(ClearError value)? clearError,
  }) {
    final _that = this;
    switch (_that) {
      case Login() when login != null:
        return login(_that);
      case Register() when register != null:
        return register(_that);
      case Logout() when logout != null:
        return logout(_that);
      case ResetPassword() when resetPassword != null:
        return resetPassword(_that);
      case ClearError() when clearError != null:
        return clearError(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String email, String password)? login,
    TResult Function(String email, String password, String username)? register,
    TResult Function()? logout,
    TResult Function(String email)? resetPassword,
    TResult Function()? clearError,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case Login() when login != null:
        return login(_that.email, _that.password);
      case Register() when register != null:
        return register(_that.email, _that.password, _that.username);
      case Logout() when logout != null:
        return logout();
      case ResetPassword() when resetPassword != null:
        return resetPassword(_that.email);
      case ClearError() when clearError != null:
        return clearError();
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String email, String password) login,
    required TResult Function(String email, String password, String username)
        register,
    required TResult Function() logout,
    required TResult Function(String email) resetPassword,
    required TResult Function() clearError,
  }) {
    final _that = this;
    switch (_that) {
      case Login():
        return login(_that.email, _that.password);
      case Register():
        return register(_that.email, _that.password, _that.username);
      case Logout():
        return logout();
      case ResetPassword():
        return resetPassword(_that.email);
      case ClearError():
        return clearError();
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String email, String password)? login,
    TResult? Function(String email, String password, String username)? register,
    TResult? Function()? logout,
    TResult? Function(String email)? resetPassword,
    TResult? Function()? clearError,
  }) {
    final _that = this;
    switch (_that) {
      case Login() when login != null:
        return login(_that.email, _that.password);
      case Register() when register != null:
        return register(_that.email, _that.password, _that.username);
      case Logout() when logout != null:
        return logout();
      case ResetPassword() when resetPassword != null:
        return resetPassword(_that.email);
      case ClearError() when clearError != null:
        return clearError();
      case _:
        return null;
    }
  }
}

/// @nodoc

class Login implements AuthEvent {
  const Login(this.email, this.password);

  final String email;
  final String password;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LoginCopyWith<Login> get copyWith =>
      _$LoginCopyWithImpl<Login>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Login &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  @override
  String toString() {
    return 'AuthEvent.login(email: $email, password: $password)';
  }
}

/// @nodoc
abstract mixin class $LoginCopyWith<$Res> implements $AuthEventCopyWith<$Res> {
  factory $LoginCopyWith(Login value, $Res Function(Login) _then) =
      _$LoginCopyWithImpl;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$LoginCopyWithImpl<$Res> implements $LoginCopyWith<$Res> {
  _$LoginCopyWithImpl(this._self, this._then);

  final Login _self;
  final $Res Function(Login) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(Login(
      null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class Register implements AuthEvent {
  const Register(this.email, this.password, this.username);

  final String email;
  final String password;
  final String username;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RegisterCopyWith<Register> get copyWith =>
      _$RegisterCopyWithImpl<Register>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Register &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.username, username) ||
                other.username == username));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password, username);

  @override
  String toString() {
    return 'AuthEvent.register(email: $email, password: $password, username: $username)';
  }
}

/// @nodoc
abstract mixin class $RegisterCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory $RegisterCopyWith(Register value, $Res Function(Register) _then) =
      _$RegisterCopyWithImpl;
  @useResult
  $Res call({String email, String password, String username});
}

/// @nodoc
class _$RegisterCopyWithImpl<$Res> implements $RegisterCopyWith<$Res> {
  _$RegisterCopyWithImpl(this._self, this._then);

  final Register _self;
  final $Res Function(Register) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? username = null,
  }) {
    return _then(Register(
      null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class Logout implements AuthEvent {
  const Logout();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is Logout);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.logout()';
  }
}

/// @nodoc

class ResetPassword implements AuthEvent {
  const ResetPassword(this.email);

  final String email;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ResetPasswordCopyWith<ResetPassword> get copyWith =>
      _$ResetPasswordCopyWithImpl<ResetPassword>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ResetPassword &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  @override
  String toString() {
    return 'AuthEvent.resetPassword(email: $email)';
  }
}

/// @nodoc
abstract mixin class $ResetPasswordCopyWith<$Res>
    implements $AuthEventCopyWith<$Res> {
  factory $ResetPasswordCopyWith(
          ResetPassword value, $Res Function(ResetPassword) _then) =
      _$ResetPasswordCopyWithImpl;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$ResetPasswordCopyWithImpl<$Res>
    implements $ResetPasswordCopyWith<$Res> {
  _$ResetPasswordCopyWithImpl(this._self, this._then);

  final ResetPassword _self;
  final $Res Function(ResetPassword) _then;

  /// Create a copy of AuthEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? email = null,
  }) {
    return _then(ResetPassword(
      null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ClearError implements AuthEvent {
  const ClearError();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ClearError);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AuthEvent.clearError()';
  }
}

// dart format on
