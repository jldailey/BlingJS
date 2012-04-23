(function() {

  /*
  
  Named after the bling symbol ($) to which it is bound by default.
  Blame: Jesse Dailey <jesse.dailey@gmail.com>
  (Copyright) 2011
  (License) released under the MIT License
  http://creativecommons.org/licenses/MIT/
  */

  var Bling, OBJECT_RE, ORD_A, ORD_Z, ORD_a, capital, default_context, interfaces, log, _ref, _ref2;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

  log = function() {
    var a, _ref;
    a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    try {
      return (_ref = console.log) != null ? _ref.apply(console, a) : void 0;
    } catch (_error) {}
    return alert(a.join(", "));
  };

  Object.defineProperty(Object, 'global', {
    get: function() {
      return typeof window !== "undefined" && window !== null ? window : global;
    }
  });

  OBJECT_RE = /\[object (\w+)\]/;

  ORD_A = "A".charCodeAt(0);

  ORD_Z = "Z".charCodeAt(0);

  ORD_a = "a".charCodeAt(0);

  capital = function(name) {
    return (name.split(" ").map(function(x) {
      return x[0].toUpperCase() + x.substring(1).toLowerCase();
    })).join(" ");
  };

  interfaces = {};

  if ((_ref = Object.Keys) == null) {
    Object.Keys = function(o, inherited) {
      var k, _results;
      if (inherited == null) inherited = false;
      _results = [];
      for (k in o) {
        if (inherited || o.hasOwnProperty(k)) _results.push(k);
      }
      return _results;
    };
  }

  if ((_ref2 = Object.Extend) == null) {
    Object.Extend = function(a, b, k) {
      var key, v, _i, _len;
      if (!Array.isArray(k)) k = Object.Keys(b);
      for (_i = 0, _len = k.length; _i < _len; _i++) {
        key = k[_i];
        v = b[key];
        if (!(v != null)) continue;
        a[key] = v;
      }
      return a;
    };
  }

  Object.Extend(Object, {
    Get: function(o, key, def) {
      var dot;
      dot = key.indexOf('.');
      switch (true) {
        case dot !== -1:
          return Object.Get(Object.Get(o, key.substring(0, dot)), key.substring(dot + 1), def);
        case key in o:
          return o[key];
        default:
          return def;
      }
    },
    IsType: function(T, o) {
      if (!(o != null)) {
        return T === o || T === "null" || T === "undefined";
      } else if (o.constructor === T) {
        return true;
      } else if (typeof T === "string") {
        return o.constructor.name === T || Object.prototype.toString.apply(o).replace(OBJECT_RE, "$1") === T;
      } else {
        return Object.IsType(T, o.__proto__);
      }
    },
    Inherit: function(c, o) {
      if (typeof c === "string" && (interfaces[c] != null)) {
        return Object.Inherit(interfaces[c], o);
      }
      if (typeof c === "function") {
        o.constructor = c;
        c = c.prototype;
      }
      o.__proto__ = c;
      return o;
    },
    Interface: function(name, fields) {
      return interfaces[name] = fields;
    }
  });

  Object.Type = (function() {
    var cache, extend, lookup, order, register;
    order = [];
    cache = {};
    Object.Interface('Type', {
      name: 'unknown',
      match: function(o) {
        return true;
      }
    });
    register = function(name, data) {
      Object["Is" + capital(name)] = function(o) {
        return data.match.call(o, o);
      };
      if (!(name in cache)) order.unshift(name);
      return cache[data.name = name] = Object.Inherit('Type', data);
    };
    extend = function(name, data) {
      var k, _ref3, _results;
      if (!(name != null)) {
        return Object.Extend(interfaces['Type'], data);
      } else if (typeof name === "string") {
        return cache[name] = Object.Extend((_ref3 = cache[name]) != null ? _ref3 : register(name, {}), data);
      } else {
        _results = [];
        for (k in name) {
          _results.push(Object.Type.extend(k, name[k]));
        }
        return _results;
      }
    };
    lookup = function(obj) {
      var name, _i, _len, _ref3;
      for (_i = 0, _len = order.length; _i < _len; _i++) {
        name = order[_i];
        if ((_ref3 = cache[name]) != null ? _ref3.match.call(obj, obj) : void 0) {
          return cache[name];
        }
      }
    };
    register("unknown", {
      match: function() {
        return true;
      }
    });
    register("object", {
      match: function() {
        return typeof this === "object";
      }
    });
    register("error", {
      match: function() {
        return Object.IsType('Error', this);
      }
    });
    register("regexp", {
      match: function() {
        return Object.IsType('RegExp', this);
      }
    });
    register("string", {
      match: function() {
        return typeof this === "string" || Object.IsType(String, this);
      }
    });
    register("number", {
      match: function() {
        return Object.IsType(Number, this);
      }
    });
    register("bool", {
      match: function() {
        var _ref3;
        return typeof this === "boolean" || ((_ref3 = String(this)) === "true" || _ref3 === "false");
      }
    });
    register("array", {
      match: function() {
        return (typeof Array.isArray === "function" ? Array.isArray(this) : void 0) || Object.IsType(Array, this);
      }
    });
    register("function", {
      match: function() {
        return typeof this === "function";
      }
    });
    register("global", {
      match: function() {
        return typeof this === "object" && 'setInterval' in this;
      }
    });
    register("undefined", {
      match: function(x) {
        return x === void 0;
      }
    });
    register("null", {
      match: function(x) {
        return x === null;
      }
    });
    return Object.Extend((function(o) {
      return lookup(o).name;
    }), {
      register: register,
      lookup: lookup,
      extend: extend
    });
  })();

  Object.Extend(Object, {
    IsEmpty: function(o) {
      return o === "" || o === null || o === (void 0);
    },
    IsSimple: function(o) {
      var _ref3;
      return (_ref3 = Object.Type(o)) === "string" || _ref3 === "number" || _ref3 === "bool";
    },
    String: (function() {
      Object.Type.extend(null, {
        toString: function(o) {
          var _ref3;
          return (_ref3 = typeof o.toString === "function" ? o.toString() : void 0) != null ? _ref3 : String(o);
        }
      });
      Object.Type.extend({
        "null": {
          toString: function(o) {
            return "null";
          }
        },
        undefined: {
          toString: function(o) {
            return "undefined";
          }
        },
        string: {
          toString: function(o) {
            return o;
          }
        },
        array: {
          toString: function(o) {
            var x;
            return "[" + ((function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = o.length; _i < _len; _i++) {
                x = o[_i];
                _results.push(Object.String(x));
              }
              return _results;
            })()).join(",") + "]";
          }
        },
        number: {
          toString: function(o) {
            switch (true) {
              case o.precision != null:
                return o.toPrecision(o.precision);
              case o.fixed != null:
                return o.toFixed(o.fixed);
              default:
                return String(o);
            }
          }
        }
      });
      return function(x) {
        return Object.Type.lookup(x).toString(x);
      };
    })(),
    Hash: (function() {
      Object.Type.extend(null, {
        hash: function(o) {
          return String.Checksum(Object.String(o));
        }
      });
      Object.Type.extend({
        object: {
          hash: function(o) {
            var k;
            return ((function() {
              var _results;
              _results = [];
              for (k in o) {
                _results.push(Object.Hash(o[k]));
              }
              return _results;
            })()) + Object.Hash(Object.Keys(o));
          }
        },
        array: {
          hash: function(o) {
            var i;
            return ((function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = x.length; _i < _len; _i++) {
                i = x[_i];
                _results.push(Object.Hash(i));
              }
              return _results;
            })()).reduce(function(a, x) {
              return a + x;
            });
          }
        },
        bool: {
          hash: function(o) {
            return parseInt(o ? 1 : void 0);
          }
        }
      });
      return function(x) {
        return Object.Type.lookup(x).hash(x);
      };
    })(),
    Trace: (function() {
      Object.Type.extend(null, {
        trace: Function.Identity
      });
      Object.Type.extend({
        "function": {
          trace: function(f, label, tracer) {
            var r;
            r = function() {
              var a;
              a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              tracer("" + (this.name || Object.Type(this)) + "." + (label || f.name) + "(", a, ")");
              return f.apply(this, a);
            };
            tracer("Trace: " + (label || f.name) + " created.");
            r.toString = f.toString;
            return r;
          }
        },
        object: {
          trace: function(o, label, tracer) {
            var k, _i, _len, _ref3;
            _ref3 = Object.Keys(o);
            for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
              k = _ref3[_i];
              o[k] = Object.Trace(o[k], "" + label + "." + k, tracer);
            }
            return o;
          }
        },
        array: {
          trace: function(o, label, tracer) {
            var i, _ref3;
            for (i = 0, _ref3 = o.length; 0 <= _ref3 ? i < _ref3 : i > _ref3; 0 <= _ref3 ? i++ : i--) {
              o[i] = Object.Trace(o[i], "" + label + "[" + i + "]", tracer);
            }
            return o;
          }
        }
      });
      return function(o, label, tracer) {
        return Object.Type.lookup(o).trace(o, label, tracer);
      };
    })()
  });

  Object.Extend(Function, {
    Identity: function(o) {
      return o;
    },
    Not: function(f) {
      return function(x) {
        return !f(x);
      };
    },
    Compose: function(f, g) {
      return function(x) {
        var y;
        return f.call(y, (y = g.call(x, x)));
      };
    },
    And: function(f, g) {
      return function(x) {
        return g.call(x, x) && f.call(x, x);
      };
    },
    Bound: function(f, t, args) {
      var r;
      if (args == null) args = [];
      if (Object.IsFunction(f.bind)) {
        args.splice(0, 0, t);
        r = f.bind.apply(f, args);
      } else {
        r = function() {
          var a;
          a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          if (args.length > 0) a = args;
          return f.apply(t, a);
        };
      }
      r.toString = function() {
        return "bound-method of " + t + "." + f.name;
      };
      return r;
    },
    UpperLimit: function(x) {
      return function(y) {
        return Math.min(x, y);
      };
    },
    LowerLimit: function(x) {
      return function(y) {
        return Math.max(x, y);
      };
    },
    Px: function(d) {
      return function() {
        return Number.Px(this, d);
      };
    },
    Memoize: function(f) {
      var cache;
      cache = {};
      return function() {
        var a, _name, _ref3;
        a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return (_ref3 = cache[_name = Object.Hash(a)]) != null ? _ref3 : cache[_name] = f.apply(this, a);
      };
    }
  });

  Object.Extend(String, {
    Capitalize: capital,
    Dashize: function(name) {
      var c, i, ret, _ref3;
      ret = "";
      for (i = 0, _ref3 = (name != null ? name.length : void 0) | 0; 0 <= _ref3 ? i < _ref3 : i > _ref3; 0 <= _ref3 ? i++ : i--) {
        c = name.charCodeAt(i);
        if ((ORD_Z >= c && c >= ORD_A)) {
          c = (c - ORD_A) + ORD_a;
          ret += '-';
        }
        ret += String.fromCharCode(c);
      }
      return ret;
    },
    Camelize: function(name) {
      var i;
      while ((i = name != null ? name.indexOf('-') : void 0) > -1) {
        name = String.Splice(name, i, i + 2, name[i + 1].toUpperCase());
      }
      return name;
    },
    PadLeft: function(s, n, c) {
      if (c == null) c = " ";
      while (s.length < n) {
        s = c + s;
      }
      return s;
    },
    PadRight: function(s, n, c) {
      if (c == null) c = " ";
      while (s.length < n) {
        s = s + c;
      }
      return s;
    },
    Splice: function(s, i, j, n) {
      var end, nn, start;
      nn = s.length;
      end = j;
      if (end < 0) end += nn;
      start = i;
      if (start < 0) start += nn;
      return s.substring(0, start) + n + s.substring(end);
    },
    Checksum: function(s) {
      var a, b, i, _ref3;
      a = 1;
      b = 0;
      for (i = 0, _ref3 = s.length; 0 <= _ref3 ? i < _ref3 : i > _ref3; 0 <= _ref3 ? i++ : i--) {
        a = (a + s.charCodeAt(i)) % 65521;
        b = (b + a) % 65521;
      }
      return (b << 16) | a;
    },
    Builder: function() {
      var items;
      var _this = this;
      if (Object.IsWindow(this)) return new String.Builder();
      items = [];
      this.length = 0;
      this.append = function(s) {
        items.push(s);
        return _this.length += (s != null ? s.toString().length : void 0) | 0;
      };
      this.prepend = function(s) {
        items.splice(0, 0, s);
        return _this.length += (s != null ? s.toString().length : void 0) | 0;
      };
      this.clear = function() {
        var ret;
        ret = _this.toString();
        items = [];
        _this.length = 0;
        return ret;
      };
      this.toString = function() {
        return items.join("");
      };
      return this;
    }
  });

  Object.Extend(Array, {
    Coalesce: function() {
      var a, i, _i, _len;
      a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      for (_i = 0, _len = a.length; _i < _len; _i++) {
        i = a[_i];
        if (Object.IsArray(i)) i = Array.Coalesce.apply(Array, i);
        if (i != null) return i;
      }
      return null;
    },
    Extend: function(a, b) {
      var i, _i, _len;
      for (_i = 0, _len = b.length; _i < _len; _i++) {
        i = b[_i];
        a.push(i);
      }
      return a;
    },
    Swap: function(a, i, j) {
      var _ref3;
      if (i !== j) _ref3 = [a[j], a[i]], a[i] = _ref3[0], a[j] = _ref3[1];
      return a;
    },
    Shuffle: function(a) {
      var i, j;
      i = a.length - 1;
      while (i >= 0) {
        j = Math.floor(Math.random() * i);
        Array.Swap(a, i, j);
        i--;
      }
      return a;
    }
  });

  Object.Extend(Number, {
    Px: function(x, d) {
      if (d == null) d = 0;
      return (x != null) && (parseInt(x, 10) + (d | 0)) + "px";
    },
    AtLeast: function(x) {
      return function(y) {
        return Math.max(parseFloat(y || 0), x);
      };
    },
    AtMost: function(x) {
      return function(y) {
        return Math.min(parseFloat(y || 0), x);
      };
    }
  });

  Object.Type.extend(null, {
    toArray: function(o) {
      return [o];
    }
  });

  Object.Type.extend({
    array: {
      toArray: Function.Identity
    },
    number: {
      toArray: function(o) {
        return new Array(o);
      }
    },
    undefined: {
      toArray: function(o) {
        return [];
      }
    },
    "null": {
      toArray: function(o) {
        return [];
      }
    },
    string: {
      toArray: function(s, c) {
        var set;
        s = s.trimLeft();
        try {
          if (s[0] === "<") {
            return set = [Bling.HTML.parse(s)];
          } else if (c.querySelectorAll) {
            return set = c.querySelectorAll(s);
          } else {
            throw Error("invalid context: " + c + " (type: " + (Object.Type(c)) + ")");
          }
        } catch (e) {
          throw Error("invalid selector: " + s + " (error: " + e + ")");
        }
      }
    }
  });

  default_context = typeof document !== "undefined" && document !== null ? document : {};

  Bling = function(selector, context) {
    var set;
    if (context == null) context = default_context;
    set = Object.Inherit(Bling, Object.Extend(Object.Type.lookup(selector).toArray(selector, context), {
      selector: selector,
      context: context
    }));
    set.length = set.len();
    return set;
  };

  Bling.prototype = new Array;

  Bling.toString = function() {
    return "function Bling(selector, context) { ... }";
  };

  Bling.plugins = [];

  Bling.plugin = function(constructor) {
    var name, plugin;
    try {
      name = constructor.name;
      plugin = constructor.call(Bling, Bling);
      name = name || plugin.name;
      if (!name) throw Error("plugin requires a 'name'");
      Bling.plugins.push(name);
      Bling.plugins[name] = plugin;
      delete plugin.name;
      if ('$' in plugin) {
        Object.Extend(Bling, plugin['$']);
        delete plugin['$'];
      }
      return Object.Extend(Bling.prototype, plugin);
    } catch (error) {
      log("failed to load plugin: '" + name + "', message: '" + error.message + "'");
      throw error;
    }
  };

  Object.Type.register("bling", {
    match: function(o) {
      return Object.IsType(Bling, o);
    },
    hash: function(o) {
      return Object.Hash(o.selector) + o.map(Object.Hash).sum();
    },
    toArray: Function.Identity,
    toString: function(o) {
      return Bling.symbol + "([" + o.map(Object.String).join(", ") + "])";
    }
  });

  (function($) {
    $.plugin(function() {
      var cache, g, symbol;
      symbol = null;
      cache = {};
      g = Object.global;
      g.Bling = Bling;
      Object.defineProperty($, "symbol", {
        set: function(v) {
          g[symbol] = cache[symbol];
          cache[v] = g[v];
          return g[symbol = v] = Bling;
        },
        get: function() {
          return symbol;
        }
      });
      $.symbol = "$";
      return {
        name: "Symbol"
      };
    });
    $.plugin(function() {
      var leftSpaces_re, oldClone, _base, _base2, _base3, _ref3, _ref4, _ref5;
      leftSpaces_re = /^\s+/;
      if ((_ref3 = (_base = String.prototype).trimLeft) == null) {
        _base.trimLeft = function() {
          return this.replace(leftSpaces_re, "");
        };
      }
      if ((_ref4 = (_base2 = String.prototype).split) == null) {
        _base2.split = function(sep) {
          var a, i, j;
          a = [];
          i = 0;
          while ((j = this.indexOf(sep, i)) > -1) {
            a.push(this.substring(i, j));
            i = j + 1;
          }
          return a;
        };
      }
      if ((_ref5 = (_base3 = Array.prototype).join) == null) {
        _base3.join = function(sep) {
          var n, s;
          if (sep == null) sep = '';
          n = this.length;
          if (n === 0) return "";
          s = this[n - 1];
          while (--n > 0) {
            s = this[n - 1] + sep + s;
          }
          return s;
        };
      }
      if (typeof Element !== "undefined" && Element !== null) {
        Element.prototype.matchesSelector = Array.Coalesce(Element.prototype.webkitMatchesSelector, Element.prototype.mozMatchesSelector, Element.prototype.matchesSelector);
        if (Element.prototype.cloneNode.length === 0) {
          oldClone = Element.prototype.cloneNode;
          Element.prototype.cloneNode = function(deep) {
            var i, n, _i, _len, _ref6;
            if (deep == null) deep = false;
            n = oldClone.call(this);
            if (deep) {
              _ref6 = this.childNodes;
              for (_i = 0, _len = _ref6.length; _i < _len; _i++) {
                i = _ref6[_i];
                n.appendChild(i.cloneNode(true));
              }
            }
            return n;
          };
        }
      }
      return {
        name: "Compat"
      };
    });
    $.plugin(function() {
      var TimeoutQueue, getter, timeoutQueue, zipper;
      TimeoutQueue = function() {
        var next, q;
        var _this = this;
        q = [];
        next = function() {
          if (q.length > 0) return q.shift()();
        };
        this.schedule = function(f, n) {
          var i, nq;
          if (!Object.IsFunction(f)) {
            throw Error("function expected, got: " + (Object.Type(f)));
          }
          nq = q.length;
          f.order = n + new Date().getTime();
          if (nq === 0 || f.order > q[nq - 1].order) {
            q.push(f);
          } else {
            for (i = 0; 0 <= nq ? i < nq : i > nq; 0 <= nq ? i++ : i--) {
              if (q[i].order > f.order) {
                q.splice(i, 0, f);
                break;
              }
            }
          }
          setTimeout(next, n);
          return _this;
        };
        this.cancel = function(f) {
          var i, _ref3, _results;
          if (!Object.IsFunction(f)) {
            throw Error("function expected, got " + (Object.Type(f)));
          }
          _results = [];
          for (i = 0, _ref3 = q.length; 0 <= _ref3 ? i < _ref3 : i > _ref3; 0 <= _ref3 ? i++ : i--) {
            if (q[i] === f) {
              q.splice(i, 1);
              break;
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        };
        return this;
      };
      timeoutQueue = new TimeoutQueue();
      getter = function(prop) {
        return function() {
          var v;
          v = this[prop];
          if (Object.IsFunction(v)) return Function.Bound(v, this);
          return v;
        };
      };
      zipper = function(prop) {
        var g, i, ret;
        i = prop.indexOf(".");
        if (i > -1) return this.zip(prop.substr(0, i)).zip(prop.substr(i + 1));
        g = getter(prop);
        ret = this.map(g);
        return ret;
      };
      return {
        name: 'Core',
        $: {
          log: log,
          assert: function(c, m) {
            if (m == null) m = "";
            if (!c) throw new Error("assertion failed: " + m);
          },
          delay: function(n, f) {
            if (f) timeoutQueue.schedule(f, n);
            return {
              cancel: function() {
                return timeoutQueue.cancel(f);
              }
            };
          }
        },
        toString: function() {
          return Object.String(this);
        },
        eq: function(i) {
          return $([this[i]]);
        },
        each: function(f) {
          var t, _i, _len;
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            t = this[_i];
            f.call(t, t);
          }
          return this;
        },
        map: function(f) {
          var t;
          return $((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = this.length; _i < _len; _i++) {
              t = this[_i];
              _results.push(f.call(t, t));
            }
            return _results;
          }).call(this));
        },
        reduce: function(f, a) {
          var t, x, _i, _len;
          t = this;
          if (!(a != null)) {
            a = this[0];
            t = this.skip(1);
          }
          for (_i = 0, _len = t.length; _i < _len; _i++) {
            x = t[_i];
            a = f.call(x, a, x);
          }
          return a;
        },
        union: function(other, strict) {
          var ret, x, _i, _j, _len, _len2;
          if (strict == null) strict = true;
          ret = $();
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            x = this[_i];
            if (!ret.contains(x, strict)) ret.push(x);
          }
          for (_j = 0, _len2 = other.length; _j < _len2; _j++) {
            x = other[_j];
            if (!ret.contains(x, strict)) ret.push(x);
          }
          return ret;
        },
        distinct: function(strict) {
          if (strict == null) strict = true;
          return this.union(this, strict);
        },
        intersect: function(other) {
          var x;
          return $((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = this.length; _i < _len; _i++) {
              x = this[_i];
              if (__indexOf.call(other, x) >= 0) _results.push(x);
            }
            return _results;
          }).call(this));
        },
        contains: function(item, strict) {
          var t;
          if (strict == null) strict = true;
          return ((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = this.length; _i < _len; _i++) {
              t = this[_i];
              _results.push((strict && t === item) || (!strict && t === item));
            }
            return _results;
          }).call(this)).reduce((function(a, x) {
            return a || x;
          }), false);
        },
        count: function(item, strict) {
          var t;
          if (strict == null) strict = true;
          return $((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = this.length; _i < _len; _i++) {
              t = this[_i];
              if ((item === void 0) || (strict && t === item) || (!strict && t === item)) {
                _results.push(1);
              }
            }
            return _results;
          }).call(this)).sum();
        },
        zip: function() {
          var a, i, j, k, list, n, nn, o, ret, set;
          a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          n = a.length;
          switch (n) {
            case 0:
              return $();
            case 1:
              ret = zipper.call(this, a[0]);
              return ret;
            default:
              set = {};
              nn = this.len();
              list = $();
              j = 0;
              for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
                set[a[i]] = zipper.call(this, a[i]);
              }
              for (i = 0; 0 <= nn ? i < nn : i > nn; 0 <= nn ? i++ : i--) {
                o = {};
                for (k in set) {
                  o[k] = set[k].shift();
                }
                list[j++] = o;
              }
              return list;
          }
        },
        zap: function(p, v) {
          var i;
          i = p.indexOf(".");
          if (i > -1) {
            return this.zip(p.substr(0, i)).zap(p.substr(i + 1), v);
          } else if (Object.IsArray(v)) {
            return this.each(function() {
              return this[p] = v[++i % v.length];
            });
          } else if (Object.IsFunction(v)) {
            return this.zap(p, this.zip(p).map(v));
          } else {
            return this.each(function() {
              return this[p] = v;
            });
          }
        },
        take: function(n) {
          var a, end, i, j, nn, start;
          nn = this.len();
          start = 0;
          end = Math.min(n | 0, nn);
          if (n < 0) {
            start = Math.max(0, nn + n);
            end = nn;
          }
          a = $();
          j = 0;
          for (i = start; start <= end ? i < end : i > end; start <= end ? i++ : i--) {
            a[j++] = this[i];
          }
          return a;
        },
        skip: function(n) {
          var a, end, i, j, start;
          if (n == null) n = 0;
          start = Math.max(0, n | 0);
          end = this.len();
          a = $();
          j = 0;
          for (i = start; start <= end ? i < end : i > end; start <= end ? i++ : i--) {
            a[j++] = this[i];
          }
          return a;
        },
        first: function(n) {
          if (n == null) n = 1;
          if (n === 1) {
            return this[0];
          } else {
            return this.take(n);
          }
        },
        last: function(n) {
          if (n == null) n = 1;
          if (n === 1) {
            return this[this.len() - 1];
          } else {
            return this.skip(this.len() - n);
          }
        },
        slice: function(start, end) {
          var b, i, j, n;
          if (start == null) start = 0;
          if (end == null) end = this.len();
          j = 0;
          n = this.len();
          if (start < 0) start += n;
          if (end < 0) end += n;
          b = $();
          for (i = start; start <= end ? i < end : i > end; start <= end ? i++ : i--) {
            b[j++] = this[i];
          }
          return b;
        },
        extend: function(b) {
          var i, j, n, _ref3;
          i = this.len() - 1;
          j = -1;
          n = (_ref3 = typeof b.len === "function" ? b.len() : void 0) != null ? _ref3 : b.length;
          while (j < n - 1) {
            this[++i] = b[++j];
          }
          return this;
        },
        push: function(b) {
          Array.prototype.push.call(this, b);
          return this;
        },
        filter: function(f) {
          var b, g, it, j, _i, _len;
          b = $();
          g = (function() {
            switch (Object.Type(f)) {
              case "string":
                return function(x) {
                  return x.matchesSelector(f);
                };
              case "regexp":
                return function(x) {
                  return f.test(x);
                };
              case "function":
                return f;
              default:
                throw new Error("unsupported type passed to filter: " + (Object.Type(f)));
            }
          })();
          j = 0;
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            it = this[_i];
            if (g.call(it, it)) b[j++] = it;
          }
          return b;
        },
        test: function(regex) {
          return this.map(function() {
            return regex.test(this);
          });
        },
        matches: function(expr) {
          return this.zip('matchesSelector').call(expr);
        },
        querySelectorAll: function(s) {
          return this.filter("*").reduce(function(a, i) {
            return Array.Extend(a, i.querySelectorAll(s));
          }, $());
        },
        weave: function(b) {
          var c, i, n, nn, _ref3;
          nn = this.len();
          n = b.length;
          i = nn - 1;
          c = $();
          for (i = _ref3 = nn - 1; _ref3 <= 0 ? i <= 0 : i >= 0; _ref3 <= 0 ? i++ : i--) {
            c[(i * 2) + 1] = this[i];
          }
          for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
            c[i * 2] = b[i];
          }
          return c;
        },
        fold: function(f) {
          var b, i, j, n, _ref3;
          n = this.len();
          j = 0;
          b = $();
          for (i = 0, _ref3 = n - 1; i < _ref3; i += 2) {
            b[j++] = f.call(this, this[i], this[i + 1]);
          }
          if ((n % 2) === 1) b[j++] = f.call(this, this[n - 1], void 0);
          return b;
        },
        flatten: function() {
          var b, c, d, i, j, k, n, _ref3;
          b = $();
          n = this.len();
          k = 0;
          for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
            c = this[i];
            d = (_ref3 = typeof c.len === "function" ? c.len() : void 0) != null ? _ref3 : c.length;
            for (j = 0; 0 <= d ? j < d : j > d; 0 <= d ? j++ : j--) {
              b[k++] = c[j];
            }
          }
          return b;
        },
        call: function() {
          return this.apply(null, arguments);
        },
        apply: function(context, args) {
          return this.map(function() {
            if (Object.IsFunction(this)) {
              return this.apply(context, args);
            } else {
              return this;
            }
          });
        },
        delay: function(n, f) {
          var g;
          if (Object.Type(f) === "function") {
            g = Function.Bound(f, this);
            timeoutQueue.schedule(g, n);
            this.cancel = function() {
              return timeoutQueue.cancel(g);
            };
          }
          return this;
        },
        log: function(label) {
          var n;
          n = this.len();
          if (label) {
            log(label, this, n + " items");
          } else {
            log(this, n + " items");
          }
          return this;
        },
        len: function() {
          var i;
          i = this.length;
          while (this[i] !== void 0) {
            i++;
          }
          while (i > -1 && this[i] === void 0) {
            i--;
          }
          return i + 1;
        },
        toArray: function() {
          this.__proto__ = Array.prototype;
          return this;
        }
      };
    });
    $.plugin(function() {
      return {
        name: 'Maths',
        $: {
          range: function(start, end, step) {
            var i, steps, _results;
            if (step == null) step = 1;
            if (end < start && step > 0) step *= -1;
            steps = Math.ceil((end - start) / step);
            _results = [];
            for (i = 0; 0 <= steps ? i < steps : i > steps; 0 <= steps ? i++ : i--) {
              _results.push(start + (i * step));
            }
            return _results;
          },
          zeros: function(n) {
            var i, _results;
            _results = [];
            for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
              _results.push(0);
            }
            return _results;
          },
          ones: function(n) {
            var i, _results;
            _results = [];
            for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
              _results.push(1);
            }
            return _results;
          }
        },
        floats: function() {
          return this.map(parseFloat);
        },
        ints: function() {
          return this.map(function() {
            return parseInt(this, 10);
          });
        },
        px: function(delta) {
          if (delta == null) delta = 0;
          return this.ints().map(Function.Px(delta));
        },
        min: function() {
          return this.reduce(function(a) {
            return Math.min(this, a);
          });
        },
        max: function() {
          return this.reduce(function(a) {
            return Math.max(this, a);
          });
        },
        average: function() {
          return this.sum() / this.len();
        },
        sum: function() {
          return this.reduce(function(a) {
            return a + this;
          });
        },
        squares: function() {
          return this.map(function() {
            return this * this;
          });
        },
        magnitude: function() {
          return Math.sqrt(this.floats().squares().sum());
        },
        scale: function(r) {
          return this.map(function() {
            return r * this;
          });
        },
        normalize: function() {
          return this.scale(1 / this.magnitude());
        }
      };
    });
    $.plugin(function() {
      var archive, archive_limit, archive_trim, publish, subscribe, subscribers, unsubscribe;
      subscribers = {};
      archive = {};
      archive_limit = 1000;
      archive_trim = 100;
      publish = function(e, args) {
        var func, _i, _len, _ref3, _ref4, _ref5;
        if (args == null) args = [];
        if ((_ref3 = archive[e]) == null) archive[e] = [];
        archive[e].push(args);
        if (archive[e].length > archive_limit) archive[e].splice(0, archive_trim);
        if ((_ref4 = subscribers[e]) == null) subscribers[e] = [];
        _ref5 = subscribers[e];
        for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
          func = _ref5[_i];
          func.apply(null, args);
        }
        return this;
      };
      subscribe = function(e, func, replay) {
        var args, _i, _len, _ref3, _ref4, _ref5;
        if (replay == null) replay = true;
        if ((_ref3 = subscribers[e]) == null) subscribers[e] = [];
        subscribers[e].push(func);
        if (replay) {
          if ((_ref4 = archive[e]) == null) archive[e] = [];
          _ref5 = archive[e];
          for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
            args = _ref5[_i];
            func.apply(null, args);
          }
        }
        return func;
      };
      unsubscribe = function(e, func) {
        var i, _ref3;
        if (!(func != null)) {
          return subscribers[e] = [];
        } else {
          if ((_ref3 = subscribers[e]) == null) subscribers[e] = [];
          i = subscribers[e].indexOf(func);
          if (i > -1) return subscribers[e].splice(i, i);
        }
      };
      Object.defineProperty(publish, 'limit', {
        set: function(n) {
          var e, _results;
          archive_limit = n;
          _results = [];
          for (e in archive) {
            if (archive[e].length > archive_limit) {
              _results.push(archive[e].splice(0, archive_trim));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        },
        get: function() {
          return archive_limit;
        }
      });
      Object.defineProperty(publish, 'trim', {
        set: function(n) {
          return archive_trim = Math.min(n, archive_limit);
        },
        get: function() {
          return archive_trim;
        }
      });
      return {
        name: "PubSub",
        $: {
          publish: publish,
          subscribe: subscribe,
          unsubscribe: unsubscribe
        }
      };
    });
    if (Object.global.document != null) {
      Object.Type.register("nodelist", {
        match: function(o) {
          return (o != null) && Object.IsType("NodeList", o);
        },
        hash: function(o) {
          var i;
          return $((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = x.length; _i < _len; _i++) {
              i = x[_i];
              _results.push(Object.Hash(i));
            }
            return _results;
          })()).sum();
        },
        toArray: Function.Identity,
        toString: function(o) {
          return "{nodelist:" + $(o).zip('nodeName').join(",") + "}";
        },
        toNode: function() {
          return $(this).toFragment();
        }
      });
      Object.Type.register("node", {
        match: function(o) {
          return (o != null ? o.nodeType : void 0) > 0;
        },
        hash: function(o) {
          return String.Checksum(o.nodeName) + Object.Hash(o.attributes) + String.Checksum(o.innerHTML);
        },
        toString: function(o) {
          return o.toString();
        },
        toNode: Function.Identity
      });
      Object.Type.register("fragment", {
        match: function(o) {
          return (o != null ? o.nodeType : void 0) === 11;
        },
        hash: function(o) {
          var x;
          return $((function() {
            var _i, _len, _ref3, _results;
            _ref3 = o.childNodes;
            _results = [];
            for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
              x = _ref3[_i];
              _results.push(Object.Hash(x));
            }
            return _results;
          })()).sum();
        },
        toString: function(o) {
          return o.toString();
        },
        toNode: Function.Identity
      });
      Object.Type.extend({
        bling: {
          toNode: function() {
            return this.toFragment();
          }
        },
        string: {
          toNode: function() {
            return $(this).toFragment();
          }
        },
        "function": {
          toNode: function() {
            return $(this.toString()).toFragment();
          }
        }
      });
      $.plugin(function() {
        var after, before, escaper, getCSSProperty, toNode;
        before = function(a, b) {
          var df;
          if (!(a.parentNode != null)) {
            df = document.createDocumentFragment();
            df.appendChild(a);
          }
          return a.parentNode.insertBefore(b, a);
        };
        after = function(a, b) {
          var df;
          if (!(a.parentNode != null)) {
            df = document.createDocumentFragment();
            df.appendChild(a);
          }
          return a.parentNode.insertBefore(b, a.nextSibling);
        };
        toNode = function(x) {
          return Object.Type.lookup(x).toNode.call(x, x);
        };
        escaper = null;
        getCSSProperty = function(k) {
          return function() {
            return window.getComputedStyle(this, null).getPropertyValue(k);
          };
        };
        return {
          name: 'Html',
          $: {
            HTML: {
              parse: function(h) {
                var childNodes, df, i, n, node;
                node = document.createElement("div");
                node.innerHTML = h;
                childNodes = node.childNodes;
                n = childNodes.length;
                if (n === 1) return node.removeChild(childNodes[0]);
                df = document.createDocumentFragment();
                for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
                  df.appendChild(node.removeChild(childNodes[0]));
                }
                return df;
              },
              stringify: function(n) {
                var d, ret;
                switch (Object.Type(n)) {
                  case "string":
                    return n;
                  case "node":
                    n = n.cloneNode(true);
                    d = document.createElement("div");
                    d.appendChild(n);
                    ret = d.innerHTML;
                    d.removeChild(n);
                    return ret;
                  default:
                    return "unknown type: " + Object.Type(n);
                }
              },
              escape: function(h) {
                var ret;
                escaper || (escaper = $("<div>&nbsp;</div>").child(0));
                ret = escaper.zap('data', h).zip("parentNode.innerHTML").first();
                escaper.zap('data', '');
                return ret;
              }
            },
            camelName: String.Camelize,
            dashName: String.Dashize
          },
          html: function(h) {
            switch (Object.Type(h)) {
              case "undefined":
              case "null":
                return this.zip('innerHTML');
              case "string":
                return this.zap('innerHTML', h);
              case "bling":
                return this.html(h.toFragment());
              case "node":
                return this.each(function() {
                  var _results;
                  this.replaceChild(this.childNodes[0], h);
                  _results = [];
                  while (this.childNodes.length > 1) {
                    _results.push(this.removeChild(this.childNodes[1]));
                  }
                  return _results;
                });
            }
          },
          append: function(x) {
            var a;
            x = toNode(x);
            a = this.zip('appendChild');
            a.take(1).call(x);
            a.skip(1).each(function(f) {
              return f(x.cloneNode(true));
            });
            return this;
          },
          appendTo: function(x) {
            $(x).append(this);
            return this;
          },
          prepend: function(x) {
            if (x != null) {
              x = toNode(x);
              this.take(1).each(function() {
                return before(this.childNodes[0], x);
              });
              this.skip(1).each(function() {
                return before(this.childNodes[0], x.cloneNode(true));
              });
            }
            return this;
          },
          prependTo: function(x) {
            if (x != null) $(x).prepend(this);
            return this;
          },
          before: function(x) {
            if (x != null) {
              x = toNode(x);
              this.take(1).each(function() {
                return before(this, x);
              });
              this.skip(1).each(function() {
                return before(this, x.cloneNode(true));
              });
            }
            return this;
          },
          after: function(x) {
            if (x != null) {
              x = toNode(x);
              this.take(1).each(function() {
                return after(this, x);
              });
              this.skip(1).each(function() {
                return after(this, x.cloneNode(true));
              });
            }
            return this;
          },
          wrap: function(parent) {
            parent = toNode(parent);
            if (Object.IsFragment(parent)) {
              throw new Error("cannot wrap with a fragment");
            }
            return this.each(function(child) {
              var marker, p;
              switch (Object.Type(child)) {
                case "fragment":
                  return parent.appendChild(child);
                case "node":
                  p = child.parentNode;
                  if (!p) {
                    return parent.appendChild(child);
                  } else {
                    marker = document.createElement("dummy");
                    parent.appendChild(p.replaceChild(marker, child));
                    return p.replaceChild(parent, marker);
                  }
              }
            });
          },
          unwrap: function() {
            return this.each(function() {
              if (this.parentNode && this.parentNode.parentNode) {
                return this.parentNode.parentNode.replaceChild(this, this.parentNode);
              } else if (this.parentNode) {
                return this.parentNode.removeChild(this);
              }
            });
          },
          replace: function(n) {
            var b, j;
            n = toNode(n);
            b = $();
            j = 0;
            this.take(1).each(function() {
              var _ref3;
              if ((_ref3 = this.parentNode) != null) _ref3.replaceChild(n, this);
              return b[j++] = n;
            });
            this.skip(1).each(function() {
              var c, _ref3;
              c = n.cloneNode(true);
              if ((_ref3 = this.parentNode) != null) _ref3.replaceChild(c, this);
              return b[j++] = c;
            });
            return b;
          },
          attr: function(a, v) {
            switch (v) {
              case void 0:
                return this.zip("getAttribute").call(a, v);
              case null:
                return this.zip("removeAttribute").call(a, v);
              default:
                this.zip("setAttribute").call(a, v);
                return this;
            }
          },
          data: function(k, v) {
            k = "data-" + (String.Dashize(k));
            return this.attr(k, v);
          },
          addClass: function(x) {
            return this.removeClass(x).each(function() {
              var c;
              c = this.className.split(" ").filter(function(y) {
                return y !== "";
              });
              c.push(x);
              return this.className = c.join(" ");
            });
          },
          removeClass: function(x) {
            var notx;
            notx = function(y) {
              return y !== x;
            };
            return this.each(function() {
              var c, _ref3;
              c = (_ref3 = this.className) != null ? _ref3.split(" ").filter(notx).join(" ") : void 0;
              if (c.length === 0) return this.removeAttribute('class');
            });
          },
          toggleClass: function(x) {
            var notx;
            notx = function(y) {
              return y !== x;
            };
            return this.each(function() {
              var c, cls, filter;
              cls = this.className.split(" ");
              filter = Function.Not(Object.IsEmpty);
              if (cls.indexOf(x) > -1) {
                filter = Function.And(notx, filter);
              } else {
                cls.push(x);
              }
              c = cls.filter(filter).join(" ");
              this.className = c;
              if (c.length === 0) return this.removeAttribute('class');
            });
          },
          hasClass: function(x) {
            return this.zip('className.split').call(" ").zip('indexOf').call(x).map(function(x) {
              return x > -1;
            });
          },
          text: function(t) {
            if (t != null) return this.zap('textContent', t);
            return this.zip('textContent');
          },
          val: function(v) {
            if (v != null) return this.zap('value', v);
            return this.zip('value');
          },
          css: function(k, v) {
            var cv, i, n, nn, ov, setter;
            if ((v != null) || Object.IsObject(k)) {
              setter = this.zip('style.setProperty');
              nn = setter.len();
              if (Object.IsObject(k)) {
                for (i in k) {
                  setter.call(i, k[i], "");
                }
              } else if (Object.IsString(v)) {
                setter.call(k, v, "");
              } else if (Object.IsArray(v)) {
                n = Math.max(v.length, nn);
                for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
                  setter[i % nn](k, v[i % n], "");
                }
              }
              return this;
            } else {
              cv = this.map(getCSSProperty(k));
              ov = this.zip('style').zip(k);
              return ov.weave(cv).fold(function(x, y) {
                return x || y;
              });
            }
          },
          defaultCss: function(k, v) {
            var i, sel, style;
            sel = this.selector;
            style = "";
            if (Object.IsString(k)) {
              if (Object.IsString(v)) {
                style += "" + sel + " { " + k + ": " + v + " } ";
              } else {
                throw Error("defaultCss requires a value with a string key");
              }
            } else if (Object.IsObject(k)) {
              style += "" + sel + " { ";
              for (i in k) {
                style += "" + i + ": " + k[i] + "; ";
              }
              style += "} ";
            }
            $("<style></style>").text(style).appendTo("head");
            return this;
          },
          empty: function() {
            return this.html("");
          },
          rect: function() {
            return this.zip('getBoundingClientRect').call();
          },
          width: function(w) {
            if (w === null) return this.rect().zip("width");
            return this.css("width", w);
          },
          height: function(h) {
            if (h === null) return this.rect().zip("height");
            return this.css("height", h);
          },
          top: function(y) {
            if (y === null) return this.rect().zip("top");
            return this.css("top", y);
          },
          left: function(x) {
            if (x === null) return this.rect().zip("left");
            return this.css("left", x);
          },
          bottom: function(x) {
            if (x === null) return this.rect().zip("bottom");
            return this.css("bottom", x);
          },
          right: function(x) {
            if (x === null) return this.rect().zip("right");
            return this.css("right", x);
          },
          position: function(x, y) {
            if (x === null) return this.rect();
            if (y === null) return this.css("left", Number.Px(x));
            return this.css({
              top: Number.Px(y),
              left: Number.Px(x)
            });
          },
          center: function(mode) {
            var body, vh, vw;
            if (mode == null) mode = "viewport";
            body = document.body;
            vh = body.scrollTop + (body.clientHeight / 2);
            vw = body.scrollLeft + (body.clientWidth / 2);
            return this.each(function() {
              var h, t, w, x, y;
              t = $(this);
              h = t.height().floats().first();
              w = t.width().floats().first();
              if (mode === "viewport" || mode === "horizontal") {
                x = vw - (w / 2);
              } else {
                x = NaN;
              }
              if (mode === "viewport" || mode === "vertical") {
                y = vh - (h / 2);
              } else {
                y = NaN;
              }
              return t.css({
                position: "absolute",
                left: Number.Px(x),
                top: Number.Px(y)
              });
            });
          },
          scrollToCenter: function() {
            document.body.scrollTop = this.zip('offsetTop')[0] - (window.innerHeight / 2);
            return this;
          },
          child: function(n) {
            return this.zip('childNodes').map(function() {
              var i;
              i = n;
              if (i < 0) i += this.length;
              return this[i];
            });
          },
          children: function() {
            return this.map(function() {
              return $(this.childNodes, this);
            });
          },
          parent: function() {
            return this.zip('parentNode');
          },
          parents: function() {
            return this.map(function() {
              var b, j, p;
              b = $();
              j = 0;
              p = this;
              while (p = p.parentNode) {
                b[j++] = p;
              }
              return b;
            });
          },
          prev: function() {
            return this.map(function() {
              var b, j, p;
              b = $();
              j = 0;
              p = this;
              while (p = p.previousSibling) {
                b[j++] = p;
              }
              return b;
            });
          },
          next: function() {
            return this.map(function() {
              var b, j, p;
              b = $();
              j = 0;
              p = this;
              while (p = p.nextSibling) {
                b[j++] = p;
              }
              return b;
            });
          },
          remove: function() {
            return this.each(function() {
              if (this.parentNode) return this.parentNode.removeChild(this);
            });
          },
          find: function(css) {
            return this.filter("*").map(function() {
              return $(css, this);
            }).flatten();
          },
          clone: function(deep) {
            if (deep == null) deep = true;
            return this.map(function() {
              if (Object.IsNode(this)) {
                return this.cloneNode(deep);
              } else {
                return null;
              }
            });
          },
          toFragment: function() {
            var adder, df;
            if (this.len() > 1) {
              df = document.createDocumentFragment();
              adder = Function.Bound(df.appendChild, df);
              this.map(toNode).map(adder);
              return df;
            }
            return toNode(this[0]);
          }
        };
      });
      $.plugin(function() {
        var COMMASEP, accel_props_re, speeds, testStyle, transformProperty, transitionDuration, transitionProperty, transitionTiming, updateDelay;
        COMMASEP = ", ";
        speeds = {
          "slow": 700,
          "medium": 500,
          "normal": 300,
          "fast": 100,
          "instant": 0,
          "now": 0
        };
        accel_props_re = /(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/;
        updateDelay = 30;
        testStyle = document.createElement("div").style;
        transformProperty = "transform";
        transitionProperty = "transition-property";
        transitionDuration = "transition-duration";
        transitionTiming = "transition-timing-function";
        if ("WebkitTransform" in testStyle) {
          transformProperty = "-webkit-transform";
          transitionProperty = "-webkit-transition-property";
          transitionDuration = "-webkit-transition-duration";
          transitionTiming = "-webkit-transition-timing-function";
        } else if ("MozTransform" in testStyle) {
          transformProperty = "-moz-transform";
          transitionProperty = "-moz-transition-property";
          transitionDuration = "-moz-transition-duration";
          transitionTiming = "-moz-transition-timing-function";
        } else if ("OTransform" in testStyle) {
          transformProperty = "-o-transform";
          transitionProperty = "-o-transition-property";
          transitionDuration = "-o-transition-duration";
          transitionTiming = "-o-transition-timing-function";
        }
        return {
          name: 'Transform',
          $: {
            duration: function(speed) {
              var d;
              d = speeds[speed];
              if (d != null) return d;
              return parseFloat(speed);
            }
          },
          transform: function(end_css, speed, easing, callback) {
            var css, duration, i, ii, p, props, trans;
            if (Object.IsFunction(speed)) {
              callback = speed;
              speed = null;
              easing = null;
            } else if (Object.IsFunction(easing)) {
              callback = easing;
              easing = null;
            }
            if (!(speed != null)) speed = "normal";
            easing || (easing = "ease");
            duration = $.duration(speed) + "ms";
            props = [];
            p = 0;
            trans = "";
            css = {};
            for (i in end_css) {
              if (accel_props_re.test(i)) {
                ii = end_css[i];
                if (ii.join) {
                  ii = $(ii).px().join(COMMASEP);
                } else if (ii.toString) {
                  ii = ii.toString();
                }
                trans += " " + i + "(" + ii + ")";
              } else {
                css[i] = end_css[i];
              }
            }
            for (i in css) {
              props[p++] = i;
            }
            if (trans) props[p++] = transformProperty;
            css[transitionProperty] = props.join(COMMASEP);
            css[transitionDuration] = props.map(function() {
              return duration;
            }).join(COMMASEP);
            css[transitionTiming] = props.map(function() {
              return easing;
            }).join(COMMASEP);
            if (trans) css[transformProperty] = trans;
            this.css(css);
            return this.delay(duration, callback);
          },
          hide: function(callback) {
            return this.each(function() {
              if (this.style) {
                this._display = "";
                if (this.style.display === !"none") {
                  this._display = this.syle.display;
                }
                return this.style.display = "none";
              }
            }).trigger("hide").delay(updateDelay, callback);
          },
          show: function(callback) {
            return this.each(function() {
              if (this.style) {
                this.style.display = this._display;
                return delete this._display;
              }
            }).trigger("show").delay(updateDelay, callback);
          },
          toggle: function(callback) {
            return this.weave(this.css("display")).fold(function(display, node) {
              if (display === "none") {
                node.style.display = node._display || "";
                delete node._display;
                $(node).trigger("show");
              } else {
                node._display = display;
                node.style.display = "none";
                $(node).trigger("hide");
              }
              return node;
            }).delay(updateDelay, callback);
          },
          fadeIn: function(speed, callback) {
            return this.css('opacity', '0.0').show(function() {
              return this.transform({
                opacity: "1.0",
                translate3d: [0, 0, 0]
              }, speed, callback);
            });
          },
          fadeOut: function(speed, callback, x, y) {
            if (x == null) x = 0.0;
            if (y == null) y = 0.0;
            return this.transform({
              opacity: "0.0",
              translate3d: [x, y, 0.0]
            }, speed, function() {
              return this.hide(callback);
            });
          },
          fadeLeft: function(speed, callback) {
            return this.fadeOut(speed, callback, "-" + this.width().first(), 0.0);
          },
          fadeRight: function(speed, callback) {
            return this.fadeOut(speed, callback, this.width().first(), 0.0);
          },
          fadeUp: function(speed, callback) {
            return this.fadeOut(speed, callback, 0.0, "-" + this.height().first());
          },
          fadeDown: function(speed, callback) {
            return this.fadeOut(speed, callback, 0.0, this.height().first());
          }
        };
      });
      $.plugin(function() {
        var formencode;
        formencode = function(obj) {
          var i, j, o, s;
          s = [];
          j = 0;
          o = JSON.parse(JSON.stringify(obj));
          for (i in o) {
            s[j++] = "" + i + "=" + (escape(o[i]));
          }
          return s.join("&");
        };
        return {
          name: 'Http',
          $: {
            http: function(url, opts) {
              var xhr;
              if (opts == null) opts = {};
              xhr = new XMLHttpRequest();
              if (Object.IsFunction(opts)) {
                opts = {
                  success: Function.Bound(opts, xhr)
                };
              }
              opts = Object.Extend({
                method: "GET",
                data: null,
                state: Function.Identity,
                success: Function.Identity,
                error: Function.Identity,
                async: true,
                timeout: 0,
                withCredentials: false,
                followRedirects: false,
                asBlob: false
              }, opts);
              opts.state = Function.Bound(opts.state, xhr);
              opts.success = Function.Bound(opts.success, xhr);
              opts.error = Function.Bound(opts.error, xhr);
              if (opts.data && opts.method === "GET") {
                url += "?" + formencode(opts.data);
              } else if (opts.data && opts.method === "POST") {
                opts.data = formencode(opts.data);
              }
              xhr.open(opts.method, url, opts.async);
              xhr.withCredentials = opts.withCredentials;
              xhr.asBlob = opts.asBlob;
              xhr.timeout = opts.timeout;
              xhr.followRedirects = opts.followRedirects;
              xhr.onreadystatechange = function() {
                if (opts.state) opts.state();
                if (xhr.readyState === 4) {
                  if (xhr.status === 200) {
                    return opts.success(xhr.responseText);
                  } else {
                    return opts.error(xhr.status, xhr.statusText);
                  }
                }
              };
              xhr.send(opts.data);
              return $([xhr]);
            },
            post: function(url, opts) {
              if (opts == null) opts = {};
              if (Object.IsFunction(opts)) {
                opts = {
                  success: opts
                };
              }
              opts.method = "POST";
              return $.http(url, opts);
            },
            get: function(url, opts) {
              if (opts == null) opts = {};
              if (Object.IsFunction(opts)) {
                opts = {
                  success: opts
                };
              }
              opts.method = "GET";
              return $.http(url, opts);
            }
          }
        };
      });
      $.plugin(function() {
        var EVENTSEP_RE, bindReady, binder, events, readyBound, readyTriggered, register_live, ret, triggerReady, unregister_live;
        EVENTSEP_RE = /,* +/;
        events = ['mousemove', 'mousedown', 'mouseup', 'mouseover', 'mouseout', 'blur', 'focus', 'load', 'unload', 'reset', 'submit', 'keyup', 'keydown', 'change', 'abort', 'cut', 'copy', 'paste', 'selection', 'drag', 'drop', 'orientationchange', 'touchstart', 'touchmove', 'touchend', 'touchcancel', 'gesturestart', 'gestureend', 'gesturecancel', 'hashchange'];
        binder = function(e) {
          return function(f) {
            if (f == null) f = {};
            if (Object.IsFunction(f)) return this.bind(e, f);
            return this.trigger(e, f);
          };
        };
        register_live = function(selector, context, e, f, h) {
          return $(context).bind(e, h).each(function() {
            var a, b, c;
            a = (this.__alive__ || (this.__alive__ = {}));
            b = (a[selector] || (a[selector] = {}));
            c = (b[e] || (b[e] = {}));
            return c[f] = h;
          });
        };
        unregister_live = function(selector, context, e, f) {
          var $c;
          $c = $(context);
          return $c.each(function() {
            var a, b, c;
            a = (this.__alive__ || (this.__alive__ = {}));
            b = (a[selector] || (a[selector] = {}));
            c = (b[e] || (b[e] = {}));
            $c.unbind(e, c[f]);
            return delete c[f];
          });
        };
        readyTriggered = 0;
        readyBound = 0;
        triggerReady = function() {
          if (!readyTriggered++) {
            $(document).trigger("ready").unbind("ready");
            if (typeof document.removeEventListener === "function") {
              document.removeEventListener("DOMContentLoaded", triggerReady, false);
            }
            return typeof window.removeEventListener === "function" ? window.removeEventListener("load", triggerReady, false) : void 0;
          }
        };
        bindReady = function() {
          if (!readyBound++) {
            if (typeof document.addEventListener === "function") {
              document.addEventListener("DOMContentLoaded", triggerReady, false);
            }
            return typeof window.addEventListener === "function" ? window.addEventListener("load", triggerReady, false) : void 0;
          }
        };
        bindReady();
        ret = {
          name: 'Events',
          bind: function(e, f) {
            var c, h;
            c = (e || "").split(EVENTSEP_RE);
            h = function(evt) {
              ret = f.apply(this, arguments);
              if (ret === false) Event.Prevent(evt);
              return ret;
            };
            return this.each(function() {
              var i, _i, _len, _results;
              _results = [];
              for (_i = 0, _len = c.length; _i < _len; _i++) {
                i = c[_i];
                _results.push(this.addEventListener(i, h, false));
              }
              return _results;
            });
          },
          unbind: function(e, f) {
            var c;
            c = (e || "").split(EVENTSEP_RE);
            return this.each(function() {
              var i, _i, _len, _results;
              _results = [];
              for (_i = 0, _len = c.length; _i < _len; _i++) {
                i = c[_i];
                _results.push(this.removeEventListener(i, f, null));
              }
              return _results;
            });
          },
          once: function(e, f) {
            var c, i, _i, _len, _results;
            c = (e || "").split(EVENTSEP_RE);
            _results = [];
            for (_i = 0, _len = c.length; _i < _len; _i++) {
              i = c[_i];
              _results.push(this.bind(i, function(evt) {
                f.call(this, evt);
                return this.removeEventListener(evt.type, arguments.callee, null);
              }));
            }
            return _results;
          },
          cycle: function() {
            var c, cycler, e, funcs, j, nf, _i, _len;
            e = arguments[0], funcs = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
            c = (e || "").split(EVENTSEP_RE);
            nf = funcs.length;
            cycler = function() {
              var i;
              i = -1;
              return function(evt) {
                return funcs[i = ++i % nf].call(this, evt);
              };
            };
            for (_i = 0, _len = c.length; _i < _len; _i++) {
              j = c[_i];
              this.bind(j, cycler());
            }
            return this;
          },
          trigger: function(evt, args) {
            var e, evt_i, evts, _i, _len;
            if (args == null) args = {};
            evts = (evt || "").split(EVENTSEP_RE);
            args = Object.Extend({
              bubbles: true,
              cancelable: true
            }, args);
            for (_i = 0, _len = evts.length; _i < _len; _i++) {
              evt_i = evts[_i];
              if (evt_i === "click" || evt_i === "mousemove" || evt_i === "mousedown" || evt_i === "mouseup" || evt_i === "mouseover" || evt_i === "mouseout") {
                e = document.createEvent("MouseEvents");
                args = Object.Extend({
                  detail: 1,
                  screenX: 0,
                  screenY: 0,
                  clientX: 0,
                  clientY: 0,
                  ctrlKey: false,
                  altKey: false,
                  shiftKey: false,
                  metaKey: false,
                  button: 0,
                  relatedTarget: null
                }, args);
                e.initMouseEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY, args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey, args.button, args.relatedTarget);
              } else if (evt_i === "blur" || evt_i === "focus" || evt_i === "reset" || evt_i === "submit" || evt_i === "abort" || evt_i === "change" || evt_i === "load" || evt_i === "unload") {
                e = document.createEvent("UIEvents");
                e.initUIEvent(evt_i, args.bubbles, args.cancelable, window, 1);
              } else if (evt_i === "touchstart" || evt_i === "touchmove" || evt_i === "touchend" || evt_i === "touchcancel") {
                e = document.createEvent("TouchEvents");
                args = Object.Extend({
                  detail: 1,
                  screenX: 0,
                  screenY: 0,
                  clientX: 0,
                  clientY: 0,
                  ctrlKey: false,
                  altKey: false,
                  shiftKey: false,
                  metaKey: false,
                  touches: [],
                  targetTouches: [],
                  changedTouches: [],
                  scale: 1.0,
                  rotation: 0.0
                }, args);
                e.initTouchEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY, args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey, args.touches, args.targetTouches, args.changedTouches, args.scale, args.rotation);
              } else if (evt_i === "gesturestart" || evt_i === "gestureend" || evt_i === "gesturecancel") {
                e = document.createEvent("GestureEvents");
                args = Object.Extend({
                  detail: 1,
                  screenX: 0,
                  screenY: 0,
                  clientX: 0,
                  clientY: 0,
                  ctrlKey: false,
                  altKey: false,
                  shiftKey: false,
                  metaKey: false,
                  target: null,
                  scale: 1.0,
                  rotation: 0.0
                }, args);
                e.initGestureEvent(evt_i, args.bubbles, args.cancelable, window, args.detail, args.screenX, args.screenY, args.clientX, args.clientY, args.ctrlKey, args.altKey, args.shiftKey, args.metaKey, args.target, args.scale, args.rotation);
              } else {
                e = document.createEvent("Events");
                e.initEvent(evt_i, args.bubbles, args.cancelable);
                try {
                  e = Object.Extend(e, args);
                } catch (err) {

                }
              }
              if (!e) {
                continue;
              } else {
                try {
                  this.each(function() {
                    return this.dispatchEvent(e);
                  });
                } catch (err) {
                  log("dispatchEvent error:", err);
                }
              }
            }
            return this;
          },
          live: function(e, f) {
            var context, handler, selector;
            selector = this.selector;
            context = this.context;
            handler = function(evt) {
              return $(selector, context).intersect($(evt.target).parents().first().union($(evt.target))).each(function() {
                evt.target = this;
                return f.call(this, evt);
              });
            };
            register_live(selector, context, e, f, handler);
            return this;
          },
          die: function(e, f) {
            var h;
            h = unregister_live(this.selector, this.context, e, f);
            $(this.context).unbind(e, h);
            return this;
          },
          liveCycle: function() {
            var e, funcs, i, nf;
            e = arguments[0], funcs = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
            i = -1;
            nf = funcs.length;
            return this.live(e, function(evt) {
              return funcs[i = ++i % nf].call(this, evt);
            });
          },
          click: function(f) {
            if (f == null) f = {};
            if (this.css("cursor").intersect(["auto", ""]).len() > 0) {
              this.css("cursor", "pointer");
            }
            if (Object.IsFunction(f)) {
              return this.bind('click', f);
            } else {
              return this.trigger('click', f);
            }
          },
          ready: function(f) {
            if (f == null) f = {};
            if (Object.IsFunction(f)) {
              if (readyTriggered) {
                return f.call(this);
              } else {
                return this.bind("ready", f);
              }
            } else {
              return this.trigger("ready", f);
            }
          }
        };
        events.forEach(function(x) {
          return ret[x] = binder(x);
        });
        return ret;
      });
      return $.plugin(function() {
        var create, lazy_load;
        create = function(elementName, props) {
          return Object.Extend(document.createElement(elementName), props);
        };
        lazy_load = function(elementName, props) {
          var depends, n, provides;
          depends = provides = null;
          n = create(elementName, Object.Extend(props, {
            onload: function() {
              if (provides != null) return $.publish(provides);
            }
          }));
          $("head").delay(10, function() {
            var _this = this;
            if (depends != null) {
              return $.subscribe(depends, function() {
                return _this.append(n);
              });
            } else {
              return this.append(n);
            }
          });
          n = $(n);
          return Object.Extend(n, {
            depends: function(tag) {
              depends = elementName + "-" + tag;
              return n;
            },
            provides: function(tag) {
              provides = elementName + "-" + tag;
              return n;
            }
          });
        };
        return {
          name: "LazyLoader",
          $: {
            script: function(src) {
              return lazy_load("script", {
                src: src
              });
            },
            style: function(src) {
              return lazy_load("link", {
                href: src,
                "rel!": "stylesheet"
              });
            }
          }
        };
      });
    }
  })(Bling);

}).call(this);
