sealed class AsyncResult<T> {
  const AsyncResult._(T? value) : _value = value;

  const factory AsyncResult.success(T data) = AsyncResultSuccess<T>;
  const factory AsyncResult.error(String? message) = AsyncResultError<T>;
  const factory AsyncResult.empty() = AsyncResultEmpty<T>;
  const factory AsyncResult.loading() = AsyncResultLoading<T>;

  bool get isSuccess => this is AsyncResultSuccess;
  bool get isError => this is AsyncResultError;
  bool get isEmpty => this is AsyncResultEmpty;
  bool get isLoading => this is AsyncResultLoading;

  final T? _value;

  T get value => _value!;
  T? get valueOrNull => _value;

  AsyncResult<T> toLoading() {
    return AsyncResultLoading(previousValue: _value);
  }

  R when<R>({
    required R Function(T value) success,
    required R Function(String? message) error,
    required R Function() empty,
    required R Function() loading,
  }) {
    if (isSuccess) {
      return success(_value!);
    } else if (isError) {
      return error((this as AsyncResultError).message);
    } else if (isEmpty) {
      return empty();
    } else {
      return loading();
    }
  }

  R maybeWhen<R>({
    R Function(T value)? success,
    R Function(String? message)? error,
    R Function()? empty,
    R Function()? loading,
    required R Function() orElse,
  }) {
    if (isSuccess && success != null) {
      return success(_value!);
    } else if (isError && error != null) {
      return error((this as AsyncResultError).message);
    } else if (isEmpty && empty != null) {
      return empty();
    } else if (isLoading && loading != null) {
      return loading();
    } else {
      return orElse();
    }
  }
}

class AsyncResultSuccess<T> extends AsyncResult<T> {
  const AsyncResultSuccess(T super.value) : super._();
}

class AsyncResultError<T> extends AsyncResult<T> {
  final String? message;

  const AsyncResultError(this.message) : super._(null);
}

class AsyncResultEmpty<T> extends AsyncResult<T> {
  const AsyncResultEmpty() : super._(null);
}

class AsyncResultLoading<T> extends AsyncResult<T> {
  const AsyncResultLoading({
    T? previousValue,
  }) : super._(previousValue);

  AsyncResultLoading withPreviousValue(T value) {
    return AsyncResultLoading(previousValue: value);
  }
}
