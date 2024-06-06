package io.flutter.plugins.webviewflutter

/**
 * ResultCompat.
 *
 * It is intended to solve the problem of being unable to obtain [kotlin.Result] in Java.
 */
@Suppress("UNCHECKED_CAST")
class ResultCompat<T>(private val result: Result<T>) {
  val isSuccess = result.isSuccess
  val isFailure = result.isFailure

  companion object {
    @JvmStatic
    fun <T> success(value: T, callback: Any) {
      val a: (Result<T>) -> Unit = callback as (Result<T>) -> Unit
      a(Result.success(value))
    }

    @JvmStatic
    fun failureBoolean(throwable: Throwable, callback: (Result<Boolean>) -> Unit) {
      callback(Result.failure(throwable))
    }
  }

  fun exceptionOrNull(): Throwable? {
    return result.exceptionOrNull()
  }

  fun getOrNull(): T? {
    return result.getOrNull()
  }
}
