module odsD.dataStructure.trie.BinaryTrie;

import odsD.util.Maybe;
import std.format;
import std.functional;
import std.conv;

class BinaryTrie(T, S = size_t, alias intValue = to!S, alias value = to!T)
if (is(typeof(unaryFun!intValue(T.init)) == S) && is(typeof(unaryFun!value(S.init)) == T)) {

protected:
  alias _intValue = unaryFun!intValue;
  alias _value = unaryFun!value;

  Node dummy;

  Node root;
  size_t n;
  enum size_t w = S.sizeof * 8;

public:
  // O(1)
  this() {
    dummy = new Node;
    root = new Node;
    clear();
  }

  // O(1)
  void clear() {
    root.jump = dummy;
    root.parent = root.prev = root.next = null;
    dummy.prev = dummy.next = dummy;
    n = 0;
  }

  // O(1)
  size_t size() {
    return n;
  }

  // O(w)
  // @return: min{ y \in this | iy >= ix }
  Maybe!T find(T x) in {
    T y = _value(_intValue(x));
    assert(y == x, format!"value(intValue(%s)) is %s, but should be %s"(x, y, x));
  } do {
    size_t i = 0;
    size_t bit = 0;
    S ix = _intValue(x);
    Node node = root;
    while(i < w) {
      bit = (ix >>> (w-i-1)) & 1;
      if (node.children[bit] is null) break;
      node = node.children[bit];
      i++;
    }
    if (i == w) return Just(node.x);
    node = bit==0 ? node.jump : node.jump.next;
    return node is dummy ? None!T : Just(node.x);
  }

  // O(w)
  bool exists(T x) {
    Maybe!T res = find(x);
    return res.isJust && res.get==x;
  }

  // O(w)
  // @return:
  //  true  ... if x was added successfully
  //  false ... if x already exists
  bool add(T x) in {
    T y = _value(_intValue(x));
    assert(y == x, format!"value(intValue(%s)) is %s, but should be %s"(x, y, x));
  } do {
    size_t i = 0;
    size_t bit = 0;
    S ix = _intValue(x);
    Node node = root;
    while(i < w) {
      bit = (ix >>> (w-i-1)) & 1;
      if (node.children[bit] is null) break;
      node = node.children[bit];
      i++;
    }
    if (i == w) {
      assert(node.x == x);
      return false;
    }
    Node prev = bit==1 ? node.jump : node.jump.prev;
    assert(prev is dummy || _intValue(prev.x) < ix);
    assert(prev.next is dummy || _intValue(prev.next.x) > ix);
    node.jump = null;
    while(i < w) {
      bit = (ix >>> (w-i-1)) & 1;
      node.children[bit] = new Node;
      node.children[bit].parent = node;
      node = node.children[bit];
      i++;
    }
    node.x = x;
    node.prev = prev;
    node.next = prev.next;
    node.prev.next = node;
    node.next.prev = node;
    Node v = node.parent;
    while(v !is null) {
      if (
        (v.prev is null && (v.jump is null || _intValue(v.jump.x) > ix)) ||
        (v.next is null && (v.jump is null || _intValue(v.jump.x) < ix))
      ) {
        v.jump = node;
      }
      v = v.parent;
    }

    n++;
    return true;
  }

  // O(w)
  // @return:
  //   true  ... if x was removed successfully
  //   false ... if x didn't exist
  bool remove(T x) in {
    T y = _value(_intValue(x));
    assert(y == x, format!"value(intValue(%s)) is %s, but should be %s"(x, y, x));
  } do {
    size_t bit = 0;
    S ix = _intValue(x);
    Node node = root;
    foreach(i; 0..w) {
      bit = (ix >>> (w-i-1)) & 1;
      if (node.children[bit] is null) return false;
      node = node.children[bit];
    }
    assert(node.x == x);
    node.prev.next = node.next;
    node.next.prev = node.prev;
    Node v = node;
    foreach_reverse(i; 0..w) {
      bit = (ix >>> (w-i-1)) & 1;
      v = v.parent;
      v.children[bit] = null;
      if (v.children[1-bit] !is null) break;
    }
    v.jump = node.children[v.prev is null];
    v = v.parent;
    while(v !is null) {
      if (v.jump is node) {
        v.jump = node.children[v.prev is null];
      }
      v = v.parent;
    }
    n--;
    return true;
  }

protected:

  class Node {
    T x;
    Node parent;
    Node[2] children;
    Node jump;
    this() {
      this.x = T.init;
    }
    @property Node prev() { return children[0]; }
    @property Node prev(Node v) { return children[0] = v; }
    @property Node next() { return children[1]; }
    @property Node next(Node v) { return children[1] = v; }
  }
}
