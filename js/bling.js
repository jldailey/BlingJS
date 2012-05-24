(function() {
  var Bling, defineProperty, inherit, isType, log, type, _ref;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (__hasProp.call(this, i) && this[i] === item) return i; } return -1; };

  log = function() {
    var a;
    a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    try {
      return console.log.apply(console, a);
    } catch (_error) {}
    return alert(a.join(", "));
  };

  if ((_ref = Object.keys) == null) {
    Object.keys = function(o) {
      var k, _results;
      _results = [];
      for (k in o) {
        _results.push(k);
      }
      return _results;
    };
  }

  if (typeof extend === "undefined" || extend === null) {
    extend = function(a, b) {
      var k, v, _i, _len, _ref2;
      if (!b) return a;
      _ref2 = Object.keys(b);
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        k = _ref2[_i];
        v = b[k];
        if (v != null) a[k] = v;
      }
      return a;
    };
  }

  defineProperty = function(o, name, opts) {
    return Object.defineProperty(o, name, extend({
      configurable: true,
      enumerable: true
    }, opts));
  };

  isType = function(T, o) {
    if (!(o != null)) {
      return T === o || T === "null" || T === "undefined";
    } else {
      return o.constructor === T || o.constructor.name === T || Object.prototype.toString.apply(o) === ("[object " + T + "]") || isType(T, o.__proto__);
    }
  };

  inherit = function(parent, obj) {
    if (typeof parent === "function") {
      obj.constructor = parent;
      parent = parent.prototype;
    }
    obj.__proto__ = parent;
    return obj;
  };

  type = (function() {
    var base, cache, lookup, order, register, _extend;
    cache = {};
    base = {
      name: 'unknown',
      match: function(o) {
        return true;
      }
    };
    order = [];
    register = function(name, data) {
      if (!(name in cache)) order.unshift(name);
      return cache[data.name = name] = base !== data ? inherit(base, data) : data;
    };
    _extend = function(name, data) {
      var k, _ref2, _results;
      if (typeof name === "string") {
        if ((_ref2 = cache[name]) == null) cache[name] = register(name, {});
        return cache[name] = extend(cache[name], data);
      } else if (typeof name === "object") {
        _results = [];
        for (k in name) {
          _results.push(_extend(k, name[k]));
        }
        return _results;
      }
    };
    lookup = function(obj) {
      var name, _i, _len, _ref2;
      for (_i = 0, _len = order.length; _i < _len; _i++) {
        name = order[_i];
        if ((_ref2 = cache[name]) != null ? _ref2.match.call(obj, obj) : void 0) {
          return cache[name];
        }
      }
    };
    register("unknown", base);
    register("object", {
      match: function() {
        return typeof this === "object";
      }
    });
    register("error", {
      match: function() {
        return isType('Error', this);
      }
    });
    register("regexp", {
      match: function() {
        return isType('RegExp', this);
      }
    });
    register("string", {
      match: function() {
        return typeof this === "string" || isType(String, this);
      }
    });
    register("number", {
      match: function() {
        return isType(Number, this);
      }
    });
    register("bool", {
      match: function() {
        var _ref2;
        return typeof this === "boolean" || ((_ref2 = String(this)) === "true" || _ref2 === "false");
      }
    });
    register("array", {
      match: function() {
        return (typeof Array.isArray === "function" ? Array.isArray(this) : void 0) || isType(Array, this);
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
    return extend((function(o) {
      return lookup(o).name;
    }), {
      register: register,
      lookup: lookup,
      extend: _extend,
      is: function(t, o) {
        var _ref2;
        return (_ref2 = cache[t]) != null ? _ref2.match.call(o, o) : void 0;
      }
    });
  })();

  Bling = (function() {
    var done, filt, qu;

    function Bling(selector, context) {
      if (context == null) context = document || {};
      return inherit(Bling, extend(type.lookup(selector).array(selector, context), {
        selector: selector,
        context: context
      }));
    }

    Bling.plugin = function(opts, constructor) {
      var key, plugin;
      var _this = this;
      if (!(constructor != null)) {
        constructor = opts;
        opts = {};
      }
      if ("depends" in opts) {
        return this.depends(opts.depends, function() {
          return _this.plugin({
            provides: opts.provides
          }, constructor);
        });
      }
      try {
        if ((plugin = constructor != null ? constructor.call(this, this) : void 0)) {
          extend(this, plugin != null ? plugin.$ : void 0);
          ['$', 'name'].forEach(function(k) {
            return delete plugin[k];
          });
          extend(this.prototype, plugin);
          for (key in plugin) {
            this[key] || (this[key] = function() {
              var a;
              a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              return _this.prototype[key].apply($(a[0]), a.slice(1));
            });
          }
          if (opts.provides != null) this.provide(opts.provides);
        }
      } catch (error) {
        log("failed to load plugin: " + this.name + " '" + error.message + "'");
        throw error;
      }
      return this;
    };

    qu = [];

    done = {};

    filt = function(n) {
      return ((typeof n) === "string" ? n.split(",") : n).filter(function(x) {
        return !(x in done);
      });
    };

    Bling.depends = function(needs, f) {
      if ((needs = filt(needs)).length === 0) {
        f();
      } else {
        qu.push(function(need) {
          var i;
          return ((i = needs.indexOf(need)) > -1 ? needs.splice(i, 1) : void 0) && needs.length === 0 && f;
        });
      }
      return f;
    };

    Bling.provide = function(needs) {
      var f, i, need, _i, _len, _ref2;
      _ref2 = filt(needs);
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        need = _ref2[_i];
        done[need] = i = 0;
        while (i < qu.length) {
          if ((f = qu[i](need))) {
            qu.splice(i, 1);
            f();
          } else {
            i++;
          }
        }
      }
      return null;
    };

    Bling.provides = function(needs, f) {
      return function() {
        var a, r;
        a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        r = f.apply(null, a);
        Bling.provide(needs);
        return r;
      };
    };

    type.extend({
      unknown: {
        array: function(o) {
          return [o];
        }
      },
      "null": {
        array: function(o) {
          return [];
        }
      },
      undefined: {
        array: function(o) {
          return [];
        }
      },
      array: {
        array: function(o) {
          return o;
        }
      },
      number: {
        array: function(o) {
          return Bling.extend(new Array(o), {
            length: 0
          });
        }
      }
    });

    type.register("bling", {
      match: function(o) {
        return isType(Bling, o);
      },
      array: function(o) {
        return o;
      },
      hash: function(o) {
        return o.map(Bling.hash).sum();
      },
      string: function(o) {
        return Bling.symbol + "([" + o.map(Bling.toString).join(", ") + "])";
      }
    });

    return Bling;

  })();

  Bling.prototype = [];

  (function($) {
    $.plugin({
      provides: "type"
    }, function() {
      return {
        $: {
          inherit: inherit,
          extend: extend,
          isType: isType,
          type: type,
          is: type.is,
          isSimple: function(o) {
            var _ref2;
            return (_ref2 = type(o)) === "string" || _ref2 === "number" || _ref2 === "bool";
          },
          isEmpty: function(o) {
            return o === "" || o === null || o === (void 0);
          }
        }
      };
    });
    $.plugin({
      provides: "symbol"
    }, function() {
      var cache, g, symbol;
      symbol = null;
      cache = {};
      (g = typeof window !== "undefined" && window !== null ? window : global).Bling = Bling;
      defineProperty($, "symbol", {
        set: function(v) {
          g[symbol] = cache[symbol];
          cache[symbol = v] = g[v];
          return g[v] = Bling;
        },
        get: function() {
          return symbol;
        }
      });
      return {
        $: {
          symbol: "$"
        }
      };
    });
    $.plugin(function() {
      var oldClone, _base, _base2, _base3, _base4;
      (_base = String.prototype).trimLeft || (_base.trimLeft = function() {
        return this.replace(/^\s+/, "");
      });
      (_base2 = String.prototype).split || (_base2.split = function(sep) {
        var a, i, j;
        a = [];
        i = 0;
        while ((j = this.indexOf(sep, i)) > -1) {
          a.push(this.substring(i, j));
          i = j + 1;
        }
        return a;
      });
      (_base3 = String.prototype).lastIndexOf || (_base3.lastIndexOf = function(s, c, i) {
        var j;
        if (i == null) i = -1;
        j = -1;
        while ((i = s.indexOf(c, i + 1)) > -1) {
          j = i;
        }
        return j;
      });
      (_base4 = Array.prototype).join || (_base4.join = function(sep) {
        var n, s;
        if (sep == null) sep = '';
        n = this.length;
        if (n === 0) return "";
        s = this[n - 1];
        while (--n > 0) {
          s = this[n - 1] + sep + s;
        }
        return s;
      });
      if (typeof Event !== "undefined" && Event !== null) {
        Event.prototype.preventAll = function() {
          this.preventDefault();
          this.stopPropagation();
          return this.cancelBubble = true;
        };
      }
      if (typeof Element !== "undefined" && Element !== null) {
        Element.prototype.matchesSelector = Element.prototype.webkitMatchesSelector || Element.prototype.mozMatchesSelector || Element.prototype.matchesSelector;
        if (Element.prototype.cloneNode.length === 0) {
          oldClone = Element.prototype.cloneNode;
          Element.prototype.cloneNode = function(deep) {
            var i, n, _i, _len, _ref2;
            if (deep == null) deep = false;
            n = oldClone.call(this);
            if (deep) {
              _ref2 = this.childNodes;
              for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
                i = _ref2[_i];
                n.appendChild(i.cloneNode(true));
              }
            }
            return n;
          };
        }
      }
      return {};
    });
    $.plugin({
      depends: "function",
      provides: "delay"
    }, function() {
      return {
        $: {
          delay: (function() {
            var timeoutQueue;
            timeoutQueue = $.extend([], (function() {
              var next;
              next = function() {
                if (this.length) return this.shift()();
              };
              return {
                add: function(f, n) {
                  var i, _ref2;
                  f.order = n + $.now;
                  for (i = 0, _ref2 = this.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
                    if (this[i].order > f.order) {
                      this.splice(i, 0, f);
                      break;
                    }
                  }
                  setTimeout(next, n);
                  return this;
                },
                cancel: function(f) {
                  var i, _ref2;
                  for (i = 0, _ref2 = this.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
                    if (this[i] === f) {
                      this.splice(i, 1);
                      break;
                    }
                  }
                  return this;
                }
              };
            })());
            return function(n, f) {
              if ($.is("function", f)) timeoutQueue.add(f, n);
              return {
                cancel: function() {
                  return timeoutQueue.cancel(f);
                }
              };
            };
          })()
        },
        delay: function(n, f, c) {
          if (c == null) c = this;
          return $.delay(n, $.bound(c, f));
        }
      };
    });
    $.plugin({
      provides: "core"
    }, function() {
      var index;
      defineProperty($, "now", {
        get: function() {
          return +(new Date);
        }
      });
      index = function(i, o) {
        while (i < 0) {
          i += o.length;
        }
        return Math.min(i, o.length);
      };
      return {
        $: {
          log: log,
          assert: function(c, m) {
            if (m == null) m = "";
            if (!c) throw new Error("assertion failed: " + m);
          },
          coalesce: function() {
            var a;
            a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
            return $(a).coalesce();
          }
        },
        eq: function(i) {
          return $([this[index(i, this)]]);
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
        coalesce: function() {
          var i, _i, _len, _ref2;
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            i = this[_i];
            if ((_ref2 = $.type(i)) === "array" || _ref2 === "bling") {
              i = $(i).coalesce();
            }
            if (i != null) return i;
          }
          return null;
        },
        swap: function(i, j) {
          var _ref2;
          i = index(i, this);
          j = index(j, this);
          if (i !== j) {
            _ref2 = [this[j], this[i]], this[i] = _ref2[0], this[j] = _ref2[1];
          }
          return this;
        },
        shuffle: function() {
          var i;
          i = this.length - 1;
          while (i >= 0) {
            this.swap(--i, Math.floor(Math.random() * i));
          }
          return this;
        },
        select: (function() {
          var getter, select;
          getter = function(prop) {
            return function() {
              var v;
              if ($.is("function", v = this[prop])) {
                return $.bound(this, v);
              } else {
                return v;
              }
            };
          };
          return select = function(p) {
            var i;
            if ((i = p.indexOf('.')) > -1) {
              return this.select(p.substr(0, i)).select(p.substr(i + 1));
            } else {
              return this.map(getter(p));
            }
          };
        })(),
        or: function(x) {
          var i, _ref2;
          for (i = 0, _ref2 = this.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
            this[i] || (this[i] = x);
          }
          return this;
        },
        zap: function(p, v) {
          var head, i, tail;
          i = p.lastIndexOf(".");
          if (i > 0) {
            head = p.substr(0, i);
            tail = p.substr(i + 1);
            this.select(head).zap(tail, v);
            return this;
          }
          switch ($.type(v)) {
            case "array":
            case "bling":
              this.each(function() {
                return this[p] = v[++i % v.length];
              });
              break;
            case "function":
              this.zap(p, this.select(p).map(v));
              break;
            default:
              this.each(function() {
                return this[p] = v;
              });
          }
          return this;
        },
        take: function(n) {
          var end, i;
          if (n == null) n = 1;
          end = Math.min(n, this.length);
          return $((function() {
            var _results;
            _results = [];
            for (i = 0; 0 <= end ? i < end : i > end; 0 <= end ? i++ : i--) {
              _results.push(this[i]);
            }
            return _results;
          }).call(this));
        },
        skip: function(n) {
          var i, start;
          if (n == null) n = 0;
          start = Math.max(0, n | 0);
          return $((function() {
            var _ref2, _results;
            _results = [];
            for (i = start, _ref2 = this.length; start <= _ref2 ? i < _ref2 : i > _ref2; start <= _ref2 ? i++ : i--) {
              _results.push(this[i]);
            }
            return _results;
          }).call(this));
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
            return this[this.length - 1];
          } else {
            return this.skip(this.length - n);
          }
        },
        slice: function(start, end) {
          var i;
          if (start == null) start = 0;
          if (end == null) end = this.length;
          start = index(start, this);
          end = index(end, this);
          return $((function() {
            var _results;
            _results = [];
            for (i = start; start <= end ? i < end : i > end; start <= end ? i++ : i--) {
              _results.push(this[i]);
            }
            return _results;
          }).call(this));
        },
        extend: function(b) {
          var i, _i, _len;
          for (_i = 0, _len = b.length; _i < _len; _i++) {
            i = b[_i];
            this.push(i);
          }
          return this;
        },
        push: function(b) {
          Array.prototype.push.call(this, b);
          return this;
        },
        filter: function(f) {
          var g, it;
          g = (function() {
            switch ($.type(f)) {
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
                throw new Error("unsupported type passed to filter: " + ($.type(f)));
            }
          })();
          return $((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = this.length; _i < _len; _i++) {
              it = this[_i];
              if (g.call(it, it)) _results.push(it);
            }
            return _results;
          }).call(this));
        },
        test: function(regex) {
          return this.map(function() {
            return regex.test(this);
          });
        },
        matches: function(expr) {
          return this.select('matchesSelector').call(expr);
        },
        querySelectorAll: function(s) {
          return this.filter("*").reduce(function(a, i) {
            return a.extend(i.querySelectorAll(s));
          }, $());
        },
        weave: function(b) {
          var c, i, _ref2, _ref3;
          c = $();
          for (i = _ref2 = this.length - 1; _ref2 <= 0 ? i <= 0 : i >= 0; _ref2 <= 0 ? i++ : i--) {
            c[(i * 2) + 1] = this[i];
          }
          for (i = 0, _ref3 = b.length; 0 <= _ref3 ? i < _ref3 : i > _ref3; 0 <= _ref3 ? i++ : i--) {
            c[i * 2] = b[i];
          }
          return c;
        },
        fold: function(f) {
          var b, i, n;
          n = this.length;
          b = $((function() {
            var _ref2, _results;
            _results = [];
            for (i = 0, _ref2 = n - 1; i < _ref2; i += 2) {
              _results.push(f.call(this, this[i], this[i + 1]));
            }
            return _results;
          }).call(this));
          if ((n % 2) === 1) b.push(f.call(this, this[n - 1], void 0));
          return b;
        },
        flatten: function() {
          var b, i, j, _i, _j, _len, _len2;
          b = $([]);
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            i = this[_i];
            for (_j = 0, _len2 = i.length; _j < _len2; _j++) {
              j = i[_j];
              b.push(j);
            }
          }
          return b;
        },
        call: function() {
          return this.apply(null, arguments);
        },
        apply: function(context, args) {
          return this.map(function() {
            if ($.is("function", this)) {
              return this.apply(context, args);
            } else {
              return this;
            }
          });
        },
        log: function(label) {
          if (label) {
            $.log(label, this, this.length + " items");
          } else {
            $.log(this, this.length + " items");
          }
          return this;
        },
        toArray: function() {
          this.__proto__ = Array.prototype;
          return this;
        }
      };
    });
    $.plugin({
      provides: "math",
      depends: "core"
    }, function() {
      return {
        $: {
          range: function(start, end, step) {
            var i;
            if (step == null) step = 1;
            if (end < start && step > 0) step *= -1;
            return $((function() {
              var _ref2, _results;
              _results = [];
              for (i = 0, _ref2 = Math.ceil((end - start) / step); 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
                _results.push(start + (i * step));
              }
              return _results;
            })());
          },
          zeros: function(n) {
            var i;
            return $((function() {
              var _results;
              _results = [];
              for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
                _results.push(0);
              }
              return _results;
            })());
          },
          ones: function(n) {
            var i;
            return $((function() {
              var _results;
              _results = [];
              for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
                _results.push(1);
              }
              return _results;
            })());
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
          return this.ints().map(function() {
            return $.px(this, delta);
          });
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
        mean: function() {
          return this.sum() / this.length;
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
        add: function(d) {
          var i;
          switch ($.type(d)) {
            case "number":
              return this.map(function() {
                return d + this;
              });
            case "bling":
            case "array":
              return $((function() {
                var _ref2, _results;
                _results = [];
                for (i = 0, _ref2 = Math.min(this.length, d.length) - 1; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
                  _results.push(this[i] + d[i]);
                }
                return _results;
              }).call(this));
          }
        },
        normalize: function() {
          return this.scale(1 / this.magnitude());
        }
      };
    });
    $.plugin({
      depends: "function",
      provides: "string"
    }, function() {
      $.type.extend({
        unknown: {
          string: function(o) {
            var _ref2;
            return (_ref2 = typeof o.toString === "function" ? o.toString() : void 0) != null ? _ref2 : String(o);
          }
        },
        "null": {
          string: function() {
            return "null";
          }
        },
        undefined: {
          string: function() {
            return "undefined";
          }
        },
        string: {
          string: $.identity
        },
        array: {
          string: function(a) {
            var x;
            return "[" + ((function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = a.length; _i < _len; _i++) {
                x = a[_i];
                _results.push($.toString(x));
              }
              return _results;
            })()).join(",") + "]";
          }
        },
        object: {
          string: function(o) {
            var k, v;
            return "{" + ((function() {
              var _len, _results;
              _results = [];
              for (v = 0, _len = o.length; v < _len; v++) {
                k = o[v];
                _results.push("" + k + ":" + ($.toString(v)));
              }
              return _results;
            })()).join(", ") + "}";
          }
        },
        number: {
          string: function(n) {
            switch (true) {
              case n.precision != null:
                return n.toPrecision(n.precision);
              case n.fixed != null:
                return n.toFixed(n.fixed);
              default:
                return String(n);
            }
          }
        }
      });
      return {
        $: {
          toString: function(x) {
            return $.type.lookup(x).string(x);
          },
          px: function(x, delta) {
            if (delta == null) delta = 0;
            return (x != null) && (parseInt(x, 10) + (delta | 0)) + "px";
          },
          capitalize: function(name) {
            return (name.split(" ").map(function(x) {
              return x[0].toUpperCase() + x.substring(1).toLowerCase();
            })).join(" ");
          },
          dashize: function(name) {
            var c, i, ret, _ref2;
            ret = "";
            for (i = 0, _ref2 = (name != null ? name.length : void 0) | 0; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
              c = name.charCodeAt(i);
              if ((91 > c && c > 64)) {
                c += 32;
                ret += '-';
              }
              ret += String.fromCharCode(c);
            }
            return ret;
          },
          camelize: function(name) {
            var i;
            name.split('-');
            while ((i = name != null ? name.indexOf('-') : void 0) > -1) {
              name = $.stringSplice(name, i, i + 2, name[i + 1].toUpperCase());
            }
            return name;
          },
          padLeft: function(s, n, c) {
            if (c == null) c = " ";
            while (s.length < n) {
              s = c + s;
            }
            return s;
          },
          padRight: function(s, n, c) {
            if (c == null) c = " ";
            while (s.length < n) {
              s = s + c;
            }
            return s;
          },
          stringCount: function(s, x, i, n) {
            var j;
            if (i == null) i = 0;
            if (n == null) n = 0;
            if ((j = s.indexOf(x, i)) > i - 1) {
              return $.count(s, x, j + 1, n + 1);
            } else {
              return n;
            }
          },
          stringSplice: function(s, i, j, n) {
            var end, nn, start;
            nn = s.length;
            end = j;
            if (end < 0) end += nn;
            start = i;
            if (start < 0) start += nn;
            return s.substring(0, start) + n + s.substring(end);
          },
          checksum: function(s) {
            var a, b, i, _ref2;
            a = 1;
            b = 0;
            for (i = 0, _ref2 = s.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
              a = (a + s.charCodeAt(i)) % 65521;
              b = (b + a) % 65521;
            }
            return (b << 16) | a;
          },
          stringBuilder: function() {
            var items;
            var _this = this;
            if ($.is("window", this)) return new $.stringBuilder();
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
        },
        toString: function() {
          return $.toString(this);
        }
      };
    });
    $.plugin({
      provides: "function",
      depends: "hash"
    }, function() {
      return {
        $: {
          identity: function(o) {
            return o;
          },
          not: function(f) {
            return function() {
              var a;
              a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              return !f.apply(this, a);
            };
          },
          compose: function(f, g) {
            return function(x) {
              var y;
              return f.call(y, (y = g.call(x, x)));
            };
          },
          and: function(f, g) {
            return function(x) {
              return g.call(x, x) && f.call(x, x);
            };
          },
          once: function(f, n) {
            if (n == null) n = 1;
            f.n = n;
            return function() {
              var a;
              a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              if (f.n-- > 0) return f.apply(this, a);
            };
          },
          bound: function(t, f, args) {
            var r;
            if (args == null) args = [];
            if ($.is("function", f.bind)) {
              args.splice(0, 0, t);
              r = f.bind.apply(f, args);
            } else {
              r = function() {
                var a;
                a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                return f.apply(t, args(args.length ? void 0 : a));
              };
            }
            return $.extend(r, {
              toString: function() {
                return "bound-method of " + t + "." + f.name;
              }
            });
          },
          memoize: function(f) {
            var cache;
            cache = {};
            return function() {
              var a, _name, _ref2;
              a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              return (_ref2 = cache[_name = $.hash(a)]) != null ? _ref2 : cache[_name] = f.apply(this, a);
            };
          }
        }
      };
    });
    $.plugin({
      provides: "trace",
      depends: "function,type"
    }, function() {
      $.type.extend({
        unknown: {
          trace: $.identity
        },
        object: {
          trace: function(o, label, tracer) {
            var k, _i, _len, _ref2;
            _ref2 = Object.keys(o);
            for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
              k = _ref2[_i];
              o[k] = $.trace(o[k], "" + label + "." + k, tracer);
            }
            return o;
          }
        },
        array: {
          trace: function(o, label, tracer) {
            var i, _ref2;
            for (i = 0, _ref2 = o.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
              o[i] = $.trace(o[i], "" + label + "[" + i + "]", tracer);
            }
            return o;
          }
        },
        "function": {
          trace: function(f, label, tracer) {
            var r;
            r = function() {
              var a;
              a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              tracer("" + (this.name || $.type(this)) + "." + (label || f.name) + "(", a, ")");
              return f.apply(this, a);
            };
            tracer("Trace: " + (label || f.name) + " created.");
            r.toString = f.toString;
            return r;
          }
        }
      });
      return {
        $: {
          trace: function(o, label, tracer) {
            return $.type.lookup(o).trace(o, label, tracer);
          }
        },
        trace: function(label, tracer) {
          return this.map(function() {
            return $.trace(this, label, tracer);
          });
        }
      };
    });
    $.plugin({
      provides: "hash",
      depends: "type"
    }, function() {
      $.type.extend({
        unknown: {
          hash: function(o) {
            return $.checksum($.toString(o));
          }
        },
        object: {
          hash: function(o) {
            var k;
            return ((function() {
              var _results;
              _results = [];
              for (k in o) {
                _results.push($.hash(o[k]));
              }
              return _results;
            })()) + $.hash(Object.keys(o));
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
                _results.push($.hash(i));
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
      return {
        $: {
          hash: function(x) {
            return $.type.lookup(x).hash(x);
          }
        },
        hash: function() {
          return $.hash(this);
        }
      };
    });
    $.plugin({
      provides: "pubsub"
    }, function() {
      var publish, subscribe, subscribers, unsubscribe;
      subscribers = {};
      publish = function() {
        var args, e, f, _i, _len, _ref2;
        e = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        _ref2 = (subscribers[e] || (subscribers[e] = []));
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          f = _ref2[_i];
          f.apply(null, args);
        }
        return this;
      };
      subscribe = function(e, func) {
        (subscribers[e] || (subscribers[e] = [])).push(func);
        return func;
      };
      unsubscribe = function(e, func) {
        var a, i;
        if (!(func != null)) {
          return subscribers[e] = [];
        } else {
          a = (subscribers[e] || (subscribers[e] = []));
          if ((i = a.indexOf(func)) > -1) return a.splice(i, i);
        }
      };
      return {
        $: {
          publish: publish,
          subscribe: subscribe,
          unsubscribe: unsubscribe
        }
      };
    });
    $.plugin({
      provides: "throttle",
      depends: "core"
    }, function() {
      return {
        $: {
          throttle: function(f, n, last) {
            if (n == null) n = 250;
            if (last == null) last = 0;
            return function() {
              var a, gap;
              a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              gap = $.now - last;
              if (gap > n) {
                last += gap;
                return f.apply(this, a);
              }
              return null;
            };
          },
          debounce: function(f, n, last) {
            if (n == null) n = 250;
            if (last == null) last = 0;
            return function() {
              var a, gap;
              a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
              last += (gap = $.now - last);
              return f.apply(this, a(gap > n ? void 0 : null));
            };
          }
        }
      };
    });
    $.plugin({
      provides: "EventEmitter"
    }, function() {
      var EventEmitter;
      return {
        $: {
          EventEmitter: EventEmitter = (function() {

            function EventEmitter() {
              this.__event = {};
            }

            EventEmitter.prototype.addListener = function(e, h) {
              var _base;
              ((_base = this.__event)[e] || (_base[e] = [])).push(h);
              return this.emit('newListener', e, h);
            };

            EventEmitter.prototype.on = function(e, h) {
              return this.addListener(e, h);
            };

            EventEmitter.prototype.once = function(e, h) {
              var f;
              return this.addListener(e, (f = function() {
                var a;
                a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
                this.removeListener(f);
                return h.apply(null, a);
              }));
            };

            EventEmitter.prototype.removeListener = function(e, h) {
              var i, _base;
              if ((i = ((_base = this.__event)[e] || (_base[e] = [])).indexOf(h)) > -1) {
                return this.__event[e].splice(i, 1);
              }
            };

            EventEmitter.prototype.removeAllListeners = function(e) {
              return this.__event[e] = [];
            };

            EventEmitter.prototype.setMaxListeners = function(n) {};

            EventEmitter.prototype.listeners = function(e) {
              return this.__event[e];
            };

            EventEmitter.prototype.emit = function() {
              var a, e, f, _base, _i, _len, _ref2;
              e = arguments[0], a = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
              _ref2 = ((_base = this.__event)[e] || (_base[e] = []));
              for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
                f = _ref2[_i];
                f.apply(this, a);
              }
              return null;
            };

            return EventEmitter;

          })()
        }
      };
    });
    if ((typeof window !== "undefined" && window !== null ? window : global).document != null) {
      $.plugin({
        depends: "function",
        provides: "dom"
      }, function() {
        var after, before, computeCSSProperty, escaper, getOrSetRect, toFrag, toNode;
        $.type.register("nodelist", {
          match: function(o) {
            return (o != null) && $.isType("NodeList", o);
          },
          hash: function(o) {
            var i;
            return $((function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = x.length; _i < _len; _i++) {
                i = x[_i];
                _results.push($.hash(i));
              }
              return _results;
            })()).sum();
          },
          array: $.identity,
          string: function(o) {
            return "{nodelist:" + $(o).select('nodeName').join(",") + "}";
          },
          node: function(o) {
            return $(o).toFragment();
          }
        });
        $.type.register("node", {
          match: function(o) {
            return (o != null ? o.nodeType : void 0) > 0;
          },
          hash: function(o) {
            return $.checksum(o.nodeName) + $.hash(o.attributes) + $.checksum(o.innerHTML);
          },
          string: function(o) {
            return o.toString();
          },
          node: $.identity
        });
        $.type.register("fragment", {
          match: function(o) {
            return (o != null ? o.nodeType : void 0) === 11;
          },
          hash: function(o) {
            var x;
            return $((function() {
              var _i, _len, _ref2, _results;
              _ref2 = o.childNodes;
              _results = [];
              for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
                x = _ref2[_i];
                _results.push($.hash(x));
              }
              return _results;
            })()).sum();
          },
          string: function(o) {
            return o.toString();
          },
          node: $.identity
        });
        $.type.register("html", {
          match: function(o) {
            var s;
            return typeof o === "string" && (s = o.trimLeft())[0] === "<" && s[s.length - 1] === ">";
          },
          node: function(o) {
            var h;
            return $.type.lookup(h = Bling.HTML.parse(o)).node(h);
          },
          array: function(o, c) {
            var h;
            return $.type.lookup(h = Bling.HTML.parse(o)).array(h, c);
          }
        });
        $.type.extend({
          unknown: {
            node: function() {
              return null;
            }
          },
          bling: {
            node: function(o) {
              return o.toFragment();
            }
          },
          string: {
            node: function(o) {
              return $(o).toFragment();
            },
            array: function(o, c) {
              return typeof c.querySelectorAll === "function" ? c.querySelectorAll(o) : void 0;
            }
          },
          "function": {
            node: function(o) {
              return $(o.toString()).toFragment();
            }
          }
        });
        toFrag = function(a) {
          var df;
          if (!(a.parentNode != null)) {
            df = document.createDocumentFragment();
            df.appendChild(a);
          }
          return a;
        };
        before = function(a, b) {
          return toFrag(a).parentNode.insertBefore(b, a);
        };
        after = function(a, b) {
          return toFrag(a).parentNode.insertBefore(b, a.nextSibling);
        };
        toNode = function(x) {
          return $.type.lookup(x).node(x);
        };
        escaper = null;
        computeCSSProperty = function(k) {
          return function() {
            return window.getComputedStyle(this, null).getPropertyValue(k);
          };
        };
        getOrSetRect = function(p) {
          return function(x) {
            if (x != null) {
              return this.css(p, x);
            } else {
              return this.rect().select(p);
            }
          };
        };
        return {
          $: {
            HTML: {
              parse: function(h) {
                var childNodes, df, i, n, node;
                (node = document.createElement("div")).innerHTML = h;
                if (n = (childNodes = node.childNodes).length === 1) {
                  return node.removeChild(childNodes[0]);
                }
                df = document.createDocumentFragment();
                for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
                  df.appendChild(node.removeChild(childNodes[0]));
                }
                return df;
              },
              stringify: function(n) {
                var d, ret;
                switch ($.type(n)) {
                  case "string":
                  case "html":
                    return n;
                  case "node":
                  case "fragment":
                    d = document.createElement("div");
                    d.appendChild((n = n.cloneNode(true)));
                    ret = d.innerHTML;
                    d.removeChild(n);
                    return ret;
                  default:
                    return "HTML.stringify of unknown type: " + $.type(n);
                }
              },
              escape: function(h) {
                var ret;
                escaper || (escaper = $("<div>&nbsp;</div>").child(0));
                ret = escaper.zap('data', h).select("parentNode.innerHTML").first();
                escaper.zap('data', '');
                return ret;
              }
            }
          },
          html: function(h) {
            switch ($.type(h)) {
              case "undefined":
              case "null":
                return this.select('innerHTML');
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
            x = toNode(x);
            return this.each(function() {
              return this.appendChild(x.cloneNode(true));
            });
          },
          appendTo: function(x) {
            var clones, i;
            clones = this.map(function() {
              return this.cloneNode(true);
            });
            i = 0;
            $(x).each(function() {
              return this.appendChild(clones[i++]);
            });
            return clones;
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
            if ($.is("fragment", parent)) {
              throw new Error("cannot wrap with a fragment");
            }
            return this.each(function(child) {
              var marker, p;
              switch ($.type(child)) {
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
              var _ref2;
              if ((_ref2 = this.parentNode) != null) _ref2.replaceChild(n, this);
              return b[j++] = n;
            });
            this.skip(1).each(function() {
              var c, _ref2;
              c = n.cloneNode(true);
              if ((_ref2 = this.parentNode) != null) _ref2.replaceChild(c, this);
              return b[j++] = c;
            });
            return b;
          },
          attr: function(a, v) {
            switch (v) {
              case void 0:
                return this.select("getAttribute").call(a, v);
              case null:
                return this.select("removeAttribute").call(a, v);
              default:
                this.select("setAttribute").call(a, v);
                return this;
            }
          },
          data: function(k, v) {
            k = "data-" + ($.dashize(k));
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
              var c, _ref2;
              c = (_ref2 = this.className) != null ? _ref2.split(" ").filter(notx).join(" ") : void 0;
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
              filter = $.not($.isEmpty);
              if (cls.indexOf(x) > -1) {
                filter = $.and(notx, filter);
              } else {
                cls.push(x);
              }
              c = cls.filter(filter).join(" ");
              this.className = c;
              if (c.length === 0) return this.removeAttribute('class');
            });
          },
          hasClass: function(x) {
            return this.select('className.split').call(" ").select('indexOf').call(x).map(function(x) {
              return x > -1;
            });
          },
          text: function(t) {
            if (t != null) return this.zap('textContent', t);
            return this.select('textContent');
          },
          val: function(v) {
            if (v != null) return this.zap('value', v);
            return this.select('value');
          },
          css: function(k, v) {
            var cv, i, n, nn, ov, setter, _ref2;
            if ((v != null) || $.is("object", k)) {
              setter = this.select('style.setProperty');
              if ($.is("object", k)) {
                for (i in k) {
                  setter.call(i, k[i], "");
                }
              } else if ($.is("string", v)) {
                setter.call(k, v, "");
              } else if ($.is("array", v)) {
                for (i = 0, _ref2 = n = Math.max(v.length, nn = setter.len()); 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
                  setter[i % nn](k, v[i % n], "");
                }
              }
              return this;
            } else {
              cv = this.map(computeCSSProperty(k));
              ov = this.select('style').select(k);
              return ov.weave(cv).fold(function(x, y) {
                return x || y;
              });
            }
          },
          defaultCss: function(k, v) {
            var i, sel, style;
            sel = this.selector;
            style = "";
            if ($.is("string", k)) {
              if ($.is("string", v)) {
                style += "" + sel + " { " + k + ": " + v + " } ";
              } else {
                throw Error("defaultCss requires a value with a string key");
              }
            } else if ($.is("object", k)) {
              for (i in k + "} ") {
                style += ("" + sel + " { ") + ("" + i + ": " + k[i] + "; ");
              }
            }
            $("<style></style>").text(style).appendTo("head");
            return this;
          },
          rect: function() {
            return this.select('getBoundingClientRect').call();
          },
          width: getOrSetRect("width"),
          height: getOrSetRect("height"),
          top: getOrSetRect("top"),
          left: getOrSetRect("left"),
          bottom: getOrSetRect("bottom"),
          right: getOrSetRect("right"),
          position: function(left, top) {
            switch (true) {
              case !(left != null):
                return this.rect();
              case !(top != null):
                return this.css("left", $.px(left));
              default:
                return this.css({
                  top: $.px(top),
                  left: $.px(left)
                });
            }
          },
          scrollToCenter: function() {
            document.body.scrollTop = this[0].offsetTop - (window.innerHeight / 2);
            return this;
          },
          child: function(n) {
            return this.select('childNodes').map(function() {
              return this[n < 0 ? n + this.length : n];
            });
          },
          parents: function() {
            return this.map(function() {
              var p;
              p = this;
              return $((function() {
                var _results;
                _results = [];
                while (p = p != null ? p.parentNode : void 0) {
                  _results.push(p);
                }
                return _results;
              })());
            });
          },
          prev: function() {
            return this.map(function() {
              var p;
              p = this;
              return $((function() {
                var _results;
                _results = [];
                while (p = p != null ? p.previousSibling : void 0) {
                  _results.push(p);
                }
                return _results;
              })());
            });
          },
          next: function() {
            return this.map(function() {
              var p;
              p = this;
              return $((function() {
                var _results;
                _results = [];
                while (p = p != null ? p.nextSibling : void 0) {
                  _results.push(p);
                }
                return _results;
              })());
            });
          },
          remove: function() {
            return this.each(function() {
              var _ref2;
              return (_ref2 = this.parentNode) != null ? _ref2.removeChild(this) : void 0;
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
              if ($.is("node", this)) return this.cloneNode(deep);
            });
          },
          toFragment: function() {
            var df;
            if (this.length > 1) {
              df = document.createDocumentFragment();
              this.map(toNode).map($.bound(df, df.appendChild));
              return df;
            }
            return toNode(this[0]);
          }
        };
      });
    }
    $.plugin({
      depends: "dom"
    }, function() {
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
        $: {
          duration: function(speed) {
            var d;
            d = speeds[speed];
            if (d != null) return d;
            return parseFloat(speed);
          }
        },
        transform: function(end_css, speed, easing, callback) {
          var css, duration, i, ii, props, trans;
          if ($.is("function", speed)) {
            callback = speed;
            speed = easing = null;
          } else if ($.is("function", easing)) {
            callback = easing;
            easing = null;
          }
          if (speed == null) speed = "normal";
          easing || (easing = "ease");
          duration = $.duration(speed) + "ms";
          props = [];
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
            props.push(i);
          }
          if (trans) props.push(transformProperty);
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
          }).trigger("hide".delay(updateDelay, callback));
        },
        show: function(callback) {
          return this.each(function() {
            if (this.style) {
              this.style.display = this._display;
              return delete this._display;
            }
          }).trigger("show".delay(updateDelay, callback));
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
    $.plugin({
      depends: "dom"
    }, function() {
      var formencode;
      formencode = function(obj) {
        var i, o;
        o = JSON.parse(JSON.stringify(obj));
        return ((function() {
          var _results;
          _results = [];
          for (i in o) {
            _results.push("" + i + "=" + (escape(o[i])));
          }
          return _results;
        })()).join("&");
      };
      $.type.register("http", {
        match: function(o) {
          return $.isType('XMLHttpRequest', o);
        },
        array: function(o) {
          return [o];
        }
      });
      return {
        $: {
          http: function(url, opts) {
            var xhr;
            if (opts == null) opts = {};
            xhr = new XMLHttpRequest();
            if ($.is("function", opts)) {
              opts = {
                success: $.bound(xhr, opts)
              };
            }
            opts = $.extend({
              method: "GET",
              data: null,
              state: $.identity,
              success: $.identity,
              error: $.identity,
              async: true,
              asBlob: false,
              timeout: 0,
              followRedirects: false,
              withCredentials: false
            }, opts);
            opts.state = $.bound(xhr, opts.state);
            opts.success = $.bound(xhr, opts.success);
            opts.error = $.bound(xhr, opts.error);
            if (opts.data && opts.method === "GET") {
              url += "?" + formencode(opts.data);
            } else if (opts.data && opts.method === "POST") {
              opts.data = formencode(opts.data);
            }
            xhr.open(opts.method, url, opts.async);
            xhr = $.extend(xhr, {
              asBlob: opts.asBlob,
              timeout: opts.timeout,
              followRedirects: opts.followRedirects,
              withCredentials: opts.withCredentials,
              onreadystatechange: function() {
                if (typeof opts.state === "function") opts.state();
                if (xhr.readyState === 4) {
                  if (xhr.status === 200) {
                    return opts.success(xhr.responseText);
                  } else {
                    return opts.error(xhr.status, xhr.statusText);
                  }
                }
              }
            });
            xhr.send(opts.data);
            return $(xhr);
          },
          post: function(url, opts) {
            if (opts == null) opts = {};
            if ($.is("function", opts)) {
              opts = {
                success: opts
              };
            }
            opts.method = "POST";
            return $.http(url, opts);
          },
          get: function(url, opts) {
            if (opts == null) opts = {};
            if ($.is("function", opts)) {
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
    $.plugin({
      depends: "dom,function,core",
      provides: "event"
    }, function() {
      var EVENTSEP_RE, bindReady, binder, events, register_live, ret, triggerReady, unregister_live;
      EVENTSEP_RE = /,* +/;
      events = ['mousemove', 'mousedown', 'mouseup', 'mouseover', 'mouseout', 'blur', 'focus', 'load', 'unload', 'reset', 'submit', 'keyup', 'keydown', 'change', 'abort', 'cut', 'copy', 'paste', 'selection', 'drag', 'drop', 'orientationchange', 'touchstart', 'touchmove', 'touchend', 'touchcancel', 'gesturestart', 'gestureend', 'gesturecancel', 'hashchange'];
      binder = function(e) {
        return function(f) {
          return this.bind(e, f)($.is("function", f) ? void 0 : this.trigger(e, f));
        };
      };
      register_live = function(selector, context, evt, f, h) {
        return $(context).bind(evt, h).each(function() {
          var _base, _base2;
          return ((_base = ((_base2 = (this.__alive__ || (this.__alive__ = {})))[selector] || (_base2[selector] = {})))[evt] || (_base[evt] = {}))[f] = h;
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
      triggerReady = $.once(function() {
        $(document).trigger("ready").unbind("ready");
        if (typeof document.removeEventListener === "function") {
          document.removeEventListener("DOMContentLoaded", triggerReady, false);
        }
        return typeof window.removeEventListener === "function" ? window.removeEventListener("load", triggerReady, false) : void 0;
      });
      bindReady = $.once(function() {
        if (typeof document.addEventListener === "function") {
          document.addEventListener("DOMContentLoaded", triggerReady, false);
        }
        return typeof window.addEventListener === "function" ? window.addEventListener("load", triggerReady, false) : void 0;
      });
      bindReady();
      ret = {
        bind: function(e, f) {
          var c, h;
          c = (e || "").split(EVENTSEP_RE);
          h = function(evt) {
            ret = f.apply(this, arguments);
            if (ret === false) evt.preventAll();
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
          cycler = function(i) {
            if (i == null) i = -1;
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
          var e, evt_i, _i, _len, _ref2;
          if (args == null) args = {};
          args = $.extend({
            bubbles: true,
            cancelable: true
          }, args);
          _ref2 = (evt || "").split(EVENTSEP_RE);
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            evt_i = _ref2[_i];
            if (evt_i === "click" || evt_i === "mousemove" || evt_i === "mousedown" || evt_i === "mouseup" || evt_i === "mouseover" || evt_i === "mouseout") {
              e = document.createEvent("MouseEvents");
              args = $.extend({
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
              args = $.extend({
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
              args = $.extend({
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
                e = $.extend(e, args);
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
              return f.call(evt.target = this, evt);
            });
          };
          register_live(selector, context, e, f, handler);
          return this;
        },
        die: function(e, f) {
          $(this.context).unbind(e, unregister_live(this.selector, this.context, e, f));
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
          var _ref2;
          if (f == null) f = {};
          if ((_ref2 = this.css("cursor")) === "auto" || _ref2 === "") {
            this.css("cursor", "pointer");
          }
          if ($.is("function", f)) {
            return this.bind('click', f);
          } else {
            return this.trigger('click', f);
          }
        },
        ready: function(f) {
          if (triggerReady.n <= 0) return f.call(this);
          return this.bind("ready", f);
        }
      };
      events.forEach(function(x) {
        return ret[x] = binder(x);
      });
      return ret;
    });
    return $.plugin({
      depends: "dom",
      provides: "lazy"
    }, function() {
      var lazy_load;
      lazy_load = function(elementName, props) {
        return $("head").append($.extend(document.createElement(elementName), props));
      };
      return {
        $: {
          script: function(src) {
            return lazy_load("script", {
              src: src
            });
          },
          style: function(src) {
            return lazy_load("link", {
              href: src,
              rel: "stylesheet"
            });
          }
        }
      };
    });
  })(Bling);

}).call(this);
