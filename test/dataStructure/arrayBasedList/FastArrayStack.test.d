module odsD.test.dataStructure.arrayBasedList.FastArrayStack;

import odsD.dataStructure.arrayBasedList.FastArrayStack;
import odsD.test.util;

unittest {
  writeln(__FILE__, ": Some operations");

  auto stack = new FastArrayStack!long();
  assert(stack.size == 0);

  stack.push(2);
  stack.push(5);
  stack.push(3);
  assert(stack.size == 3);
  assert(stack.get(0) == 2 && stack.get(1) == 5 && stack.get(2) == 3);

  assert(stack.remove(1) == 5);
  assert(stack.size == 2);
  assert(stack.get(0) == 2 && stack.get(1) == 3);

  stack.add(0, 10);
  assert(stack.size == 3);
  assert(stack.get(0) == 10 && stack.get(1) == 2 && stack.get(2) == 3);

  assert(stack.pop() == 3);
  assert(stack.size == 2);
  assert(stack.get(0) == 10 && stack.get(1) == 2);

  stack.clear();
  assert(stack.size == 0);
}

unittest {
  writeln(__FILE__, ": Random `push`");

  auto stack = new FastArrayStack!long();
  long n = 1000;
  long[] xs = randomArray!long(n);

  foreach(i; 0..n) {
    stack.push(xs[i]);
    assert(stack.size == i+1);
    assert(stack.get(i) == xs[i]);
  }
  foreach(i; 0..n) {
    assert(stack.get(i) == xs[i]);
  }
}

unittest {
  writeln(__FILE__, ": Random `pop`");

  auto stack = new FastArrayStack!long();
  long n = 1000;
  long[] xs = randomArray!long(n);

  foreach(i; 0..n) {
    stack.push(xs[i]);
  }
  foreach(i; 0..n) {
    assert(stack.pop() == xs[n-i-1]);
    assert(stack.size == n-i-1);
  }
}

unittest {
  writeln(__FILE__, ": Random `set`");

  auto stack = new FastArrayStack!long();
  long n = 1000;
  long[] xs1 = randomArray!long(n);
  long[] xs2 = randomArray!long(n);

  foreach(i; 0..n) {
    stack.push(xs1[i]);
  }
  foreach(i; 0..n) {
    assert(stack.set(i, xs2[i]) == xs1[i]);
    assert(stack.get(i) == xs2[i]);
  }
}

unittest {
  writeln(__FILE__, ": Random `add` and `remove` 1");

  auto stack = new FastArrayStack!long();
  long n = 1000;
  long[] xs = randomArray!long(n);

  // reverse insertion
  foreach(i; 0..n) {
    stack.add(0, xs[i]);
    assert(stack.size == i+1);
  }
  foreach(i; 0..n) {
    assert(stack.get(i) == xs[n-i-1]);
  }
  foreach(i; 0..n) {
    assert(stack.remove(0) == xs[n-i-1]);
  }
  assert(stack.size == 0);
}

unittest {
  writeln(__FILE__, ": Random `add` and `remove` 2");

  auto stack = new FastArrayStack!long();
  long[] ys = [];

  long n = 1000;
  long[] xs = randomArray!long(n);
  auto rnd = Random(unpredictableSeed);

  foreach(i; 0..n) {
    auto j = uniform(0, stack.size + 1, rnd);
    stack.add(j, xs[i]);
    ys = ys[0..j] ~ xs[i] ~ ys[j..$];
  }
  foreach(i; 0..n) {
    assert(stack.get(i) == ys[i]);
  }
  foreach(i; 0..n) {
    auto j = uniform(0, stack.size, rnd);
    assert(stack.remove(j) == ys[j]);
    ys = ys[0..j] ~ ys[j+1..$];
  }
  assert(stack.size == 0);
}

unittest {
  writeln(__FILE__, ": Time complexity");

  auto stack = new FastArrayStack!long();
  uint iter = 10^^6;
  auto timeLimit = 2000.msecs;

  // FastArrayStack should be able to execute `push` and `pop` 10^^6 times within 2000 ms because the time complexity is amortized O(1)."
  testTimeComplexity!("push", () => stack.push(0))(iter, timeLimit);
  testTimeComplexity!("pop", () => stack.pop())(iter, timeLimit);
}

unittest {
  writeln(__FILE__, ": Really fast?");

  import odsD.dataStructure.arrayBasedList.ArrayStack;

  auto slowStack = new ArrayStack!long();
  auto fastStack = new FastArrayStack!long();
  uint iter = 10^^4;

  auto slowTime = benchmark!(() => slowStack.add(0, 0))(iter);
  auto fastTime = benchmark!(() => fastStack.add(0, 0))(iter);
  assert(fastTime < slowTime);
}
