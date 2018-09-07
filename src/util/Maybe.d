module odsD.util.Maybe;

import std.functional;

struct Maybe(T) {

private:
  T value = T.init;
  bool _isJust = false;

package:
  this(T value) {
    this.value = value;
    this._isJust = true;
  }

public:
  @property bool isJust() {
    return _isJust;
  }

  @property bool isNone() {
    return !_isJust;
  }

  @property T get() in {
    assert(isJust);
  } do {
    return value;
  }

}

Maybe!T Just(T)(T value) in {
  static if (is(typeof(value is null))) {
    assert(value !is null);
  }
} do {
  return Maybe!T(value);
}

Maybe!T None(T)() {
  return Maybe!T();
}

// fmap :: Maybe!T -> (T -> S) -> Maybe!S
Maybe!S fmap(alias fun, T, S = typeof(unaryFun!fun(T.init)))(Maybe!T m) {
  return m.isNone ? None!S : Just(unaryFun!fun(m.get));
}

// bind :: Maybe!T -> (T -> Maybe!S) -> Maybe!S
Maybe!S bind(alias fun, T, _ : Maybe!S = typeof(unaryFun!fun(T.init)), S)(Maybe!T m) {
  return m.isNone ? None!S : unaryFun!fun(m.get);
}
