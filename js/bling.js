(function() {
  /*
  bling.js
  --------
  Named after the bling symbol ($) to which it is bound by default.
  This is a jQuery-like framework, written in CoffeeScript.
  Blame: Jesse Dailey <jesse.dailey@gmail.com>
  (Copyright) 2011
  (License) released under the MIT License
  http://creativecommons.org/licenses/MIT/
  */  var Bling, commasep, eventsep_re, object_cruft_re, _log_;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if (!"querySelectorAll" in document) {
    alert("This browser is not supported");
    return;
  }
  if (console && console.log) {
    _log_ = function() {
      var a;
      a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return console.log.apply(console, a);
    };
  } else {
    _log_ = function() {
      var a;
      a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return alert(a.join(", "));
    };
  }
  commasep = ", ";
  eventsep_re = /,* +/;
  object_cruft_re = /\[object (\w+)\]/;
  Bling = function(selector, context) {
    var set, type;
    if (context == null) {
      context = document;
    }
    type = Object.Type(selector);
    if (type === "node" || type === "window" || type === "function") {
      set = [selector];
    } else if (type === "number") {
      set = new Array(selector);
    } else if (type === "string") {
      selector = selector.trimLeft();
      if (selector[0] === "<") {
        set = [Bling.HTML.parse(selector)];
      } else if (context.querySelectorAll) {
        set = context.querySelectorAll(selector);
      } else {
        throw Error("invalid context: " + context + " (type: " + (Object.Type(context)) + ")");
      }
    } else if (type === "array" || type === "bling" || type === "nodelist") {
      set = selector;
    } else if (type === "undefined" || type === "null") {
      set = [];
    } else {
      throw Error("invalid selector: " + selector + " (type: " + (Object.Type(selector)) + ")");
    }
    set.constructor = Bling;
    set.__proto__ = Bling.fn;
    set.selector = selector;
    set.context = context;
    set.length = set.len();
    return set;
  };
  Bling.fn = new Array;
  Object.Keys = function(o, inherited) {
    var i, j, keys;
    if (inherited == null) {
      inherited = false;
    }
    keys = [];
    j = 0;
    for (i in o) {
      if (inherited || o.hasOwnProperty(i)) {
        keys[j++] = i;
      }
    }
    return keys;
  };
  Object.Extend = function(a, b, k) {
    var i, _i, _len, _ref;
    if (Object.prototype.toString.apply(k) === "[object Array]") {
      for (i in k) {
        if (b[k[i]] !== void 0) {
          a[k[i]] = b[k[i]];
        }
      }
    } else {
      _ref = (k = Object.Keys(b));
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        i = _ref[_i];
        a[i] = b[i];
      }
    }
    return a;
  };
  Object.Extend(Object, {
    Type: function(o) {
      var _ref;
      switch (true) {
        case o === void 0:
          return "undefined";
        case o === null:
          return "null";
        case Object.IsString(o):
          return "string";
        case Object.IsType(o, Bling):
          return "bling";
        case Object.IsType(o, NodeList):
          return "nodelist";
        case Object.IsArray(o):
          return "array";
        case Object.IsNumber(o):
          return "number";
        case Object.IsFragment(o):
          return "fragment";
        case Object.IsNode(o):
          return "node";
        case Object.IsFunc(o):
          return "function";
        case Object.IsType(o, "RegExp"):
          return "regexp";
        case (_ref = String(o)) === "true" || _ref === "false":
          return "boolean";
        case Object.IsError(o):
          return "error";
        case Object.IsObject(o):
          if ("setInterval" in o) {
            return "window";
          } else {
            return "object";
          }
      }
    },
    IsType: function(o, T) {
      if (o === null) {
        return o === T;
      } else if (o.constructor === T) {
        return true;
      } else if (typeof T === "string") {
        return o.constructor.name === T || Object.prototype.toString.apply(o).replace(object_cruft_re, "$1") === T;
      } else {
        return Object.IsType(o.__proto__, T);
      }
    },
    IsString: function(o) {
      return (o != null) && (typeof o === "string" || Object.IsType(o, String));
    },
    IsNumber: function(o) {
      return (o != null) && Object.IsType(o, Number);
    },
    IsBoolean: function(o) {
      return typeof o === "boolean";
    },
    IsFunc: function(o) {
      return (o != null) && (typeof o === "function" || Object.IsType(o, Function)) && (o.call != null);
    },
    IsNode: function(o) {
      return (o != null) && o.nodeType > 0;
    },
    IsFragment: function(o) {
      return (o != null) && o.nodeType === 11;
    },
    IsArray: function(o) {
      return (o != null) && (Object.ToString(o) === "[object Array]" || Object.IsType(o, Array));
    },
    IsBling: function(o) {
      return (o != null) && Object.IsType(o, Bling);
    },
    IsError: function(o) {
      var _ref;
      return (o != null) && ((_ref = o.constructor) != null ? _ref.name : void 0) === "Error";
    },
    IsObject: function(o) {
      return (o != null) && typeof o === "object";
    },
    IsDefined: function(o) {
      return o != null;
    },
    Unbox: function(a) {
      if ((a != null) && Object.IsObject(a)) {
        if (Object.IsString(a)) {
          return a.toString();
        }
        if (Object.IsNumber(a)) {
          return Number(a);
        }
      }
      return a;
    },
    ToString: function(x) {
      return Object.prototype.toString.apply(x);
    }
  });
  Object.Extend(Function, {
    Empty: function() {},
    Bound: function(f, t, args) {
      var r;
      if (args == null) {
        args = [];
      }
      if ("bind" in f) {
        args.splice(0, 0, t);
        r = f.bind.apply(f, args);
      } else {
        r = function() {
          var a;
          a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          if (args.length > 0) {
            a = args;
          }
          return f.apply(t, args);
        };
      }
      r.toString = function() {
        return "bound-method of " + t + "." + f.name;
      };
      return r;
    },
    Trace: function(f, label, tracer) {
      var r;
      if (tracer == null) {
        tracer = _log_;
      }
      r = function() {
        var a;
        a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        tracer("" + (label || "") + (this.name || this) + "." + f.name + "(", a, ")");
        return f.apply(this, a);
      };
      tracer("Function.Trace: " + (label || f.name) + " created.");
      r.toString = f.toString;
      return r;
    },
    NotNull: function(x) {
      return x !== null;
    },
    IndexFound: function(x) {
      return x > -1;
    },
    ReduceAnd: function(x) {
      return x && this;
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
    }
  });
  Object.Extend(Array, {
    Coalesce: function() {
      var a, i, _i, _len;
      a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (Object.IsArray(a[0])) {
        return Array.Coalesce.apply(Array, a[0]);
      } else {
        for (_i = 0, _len = a.length; _i < _len; _i++) {
          i = a[_i];
          if (i != null) {
            return i;
          }
        }
      }
    },
    Extend: function(a, b) {
      var i, j, _i, _len;
      j = a.length;
      for (_i = 0, _len = b.length; _i < _len; _i++) {
        i = b[_i];
        a[j++] = i;
      }
      return a;
    }
  });
  Object.Extend(Number, {
    Px: function(x, d) {
      if (d == null) {
        d = 0;
      }
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
  Object.Extend(String, {
    PadLeft: function(s, n, c) {
      if (c == null) {
        c = " ";
      }
      while (s.length < n) {
        s = c + s;
      }
      return s;
    },
    PadRight: function(s, n, c) {
      if (c == null) {
        c = " ";
      }
      while (s.length < n) {
        s = s + c;
      }
      return s;
    },
    Splice: function(s, i, j, n) {
      var end, nn, start;
      nn = s.length;
      end = j;
      if (end < 0) {
        end += nn;
      }
      start = i;
      if (start < 0) {
        start += nn;
      }
      return s.substring(0, start) + n + s.substring(end);
    },
    Checksum: function(s) {
      var i, sum, _ref;
      sum = 0;
      for (i = 0, _ref = s.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        sum += s.charCodeAt(i);
      }
      return sum;
    }
  });
  Object.Extend(Event, {
    Cancel: function(evt) {
      evt.stopPropagation();
      evt.preventDefault();
      evt.cancelBubble = true;
      return evt.returnValue = false;
    },
    Prevent: function(evt) {
      return evt.preventDefault();
    },
    Stop: function(evt) {
      evt.stopPropagation();
      return evt.cancelBubble = true;
    }
  });
  (function($) {
    $.plugins = [];
    $.plugin = function(constructor) {
      var name, plugin;
      try {
        name = constructor.name || plugin.name;
        plugin = constructor.call($, $);
        if (!name) {
          throw Error("plugin requires a 'name'");
        }
        $.plugins.push(name);
        $.plugins[name] = plugin;
        delete plugin.name;
        if (plugin[Bling.symbol]) {
          Object.Extend(Bling, plugin[Bling.symbol]);
          delete plugin[Bling.symbol];
        }
        return Object.Extend(Bling.fn, plugin);
      } catch (error) {
        return console.log("failed to load plugin " + name);
      }
    };
    $.plugin(function() {
      var symbol;
      symbol = null;
      $.__defineSetter__("symbol", function(v) {
        if (symbol in window) {
          delete window[symbol];
        }
        symbol = v;
        return window[v] = Bling;
      });
      $.__defineGetter__("symbol", function() {
        return symbol;
      });
      $.symbol = "$";
      window["Bling"] = Bling;
      return {
        name: "Symbol"
      };
    });
    $.plugin(function() {
      var leftSpaces_re, oldClone, oldToString;
      leftSpaces_re = /^\s+/;
      String.prototype.trimLeft = Array.Coalesce(String.prototype.trimLeft, function() {
        return this.replace(leftSpaces_re, "");
      });
      String.prototype.split = Array.Coalesce(String.prototype.split, function(sep) {
        var a, i, j, n;
        a = [];
        n = 0;
        i = 0;
        while ((j = this.indexOf(sep, i)) > -1) {
          a[n++] = this.substring(i + 1, j + 1);
          i = j + 1;
        }
        return a;
      });
      Array.prototype.join = Array.Coalesce(Array.prototype.join, function(sep) {
        var n, s;
        if (sep == null) {
          sep = '';
        }
        n = this.length;
        if (n === 0) {
          return "";
        }
        s = this[n - 1];
        while (--n > 0) {
          s = this[n - 1] + sep + s;
        }
        return s;
      });
      Element.prototype.matchesSelector = Array.Coalesce(Element.prototype.webkitMatchesSelector, Element.prototype.mozMatchesSelector, Element.prototype.matchesSelector);
      oldToString = Element.prototype.toString;
      Element.prototype.toString = function(css_mode) {
        var name;
        if (css_mode) {
          name = this.nodeName.toLowerCase();
          if (this.id != null) {
            name += "#" + this.id;
          } else if (this.className != null) {
            name += "." + (this.className.split(" ").join("."));
          }
          return name;
        } else {
          return oldToString.apply(this);
        }
      };
      if (Element.prototype.cloneNode.length === 0) {
        oldClone = Element.prototype.cloneNode;
        Element.prototype.cloneNode = function(deep) {
          var i, n, _i, _len, _ref;
          if (deep == null) {
            deep = false;
          }
          n = oldClone.call(this);
          if (deep) {
            _ref = this.childNodes;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              i = _ref[_i];
              n.appendChild(i.cloneNode(true));
            }
          }
          return n;
        };
      }
      return {
        name: "Compat"
      };
    });
    $.plugin(function() {
      var TimeoutQueue, getter, timeoutQueue, zipper;
      TimeoutQueue = (function() {
        __extends(TimeoutQueue, Array);
        function TimeoutQueue() {
          var next;
          next = __bind(function() {
            if (this.length > 0) {
              return this.shift()();
            }
          }, this);
          this.schedule = __bind(function(f, n) {
            var i, nn;
            if (!Object.IsFunc(f)) {
              throw Error("function expected, got: " + (typeof f));
            }
            nn = this.length;
            f.order = n + new Date().getTime();
            if (nn === 0 || f.order > this[nn - 1].order) {
              this[nn] = f;
            } else {
              for (i = 0; 0 <= nn ? i < nn : i > nn; 0 <= nn ? i++ : i--) {
                if (this[i].order > f.order) {
                  this.splice(i, 0, f);
                  break;
                }
              }
            }
            setTimeout(next, n);
            return this;
          }, this);
        }
        return TimeoutQueue;
      })();
      timeoutQueue = new TimeoutQueue;
      getter = function(prop) {
        return function() {
          var v;
          v = this[prop];
          if (Object.IsFunc(v)) {
            return Function.Bound(v, this);
          }
          return v;
        };
      };
      zipper = function(prop) {
        var i;
        i = prop.indexOf(".");
        if (i > -1) {
          return this.zip(prop.substr(0, i)).zip(prop.substr(i + 1));
        }
        return this.map(getter(prop));
      };
      return {
        name: 'Core',
        eq: function(i) {
          var a;
          a = $([this[i]]);
          a.context = this;
          return a.selector = function() {
            return a.context.eq(i);
          };
        },
        each: function(f) {
          var i, _i, _len;
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            i = this[_i];
            f.call(i, i);
          }
          return this;
        },
        map: function(f) {
          var a, i, nn, t;
          a = $();
          a.context = this;
          a.selector = function() {
            return a.context.map(f);
          };
          nn = this.len();
          for (i = 0; 0 <= nn ? i < nn : i > nn; 0 <= nn ? i++ : i--) {
            t = this[i];
            try {
              a[i] = f.call(t, t);
            } catch (err) {
              a[i] = err;
            }
          }
          return a;
        },
        reduce: function(f, init) {
          var a, t;
          a = init;
          t = this;
          if (!(init != null)) {
            a = this[0];
            t = this.skip(1);
          }
          t.each(function() {
            return a = f.call(this, a, this);
          });
          return a;
        },
        union: function(other, strict) {
          var i, j, ret, x;
          ret = $();
          x = i = j = 0;
          ret.context = this;
          ret.selector = function() {
            return ret.context.union(other, strict);
          };
          while (x = this[j++]) {
            if (!ret.contains(x, strict)) {
              ret[i++] = x;
            }
          }
          j = 0;
          while (x = other[j++]) {
            if (!ret.contains(x, strict)) {
              ret[i++] = x;
            }
          }
          return ret;
        },
        intersect: function(other) {
          var i, j, m, n, nn, ret;
          ret = $();
          m = 0;
          n = this.len();
          if (Object.IsFunc(other.len)) {
            nn = other.len();
          } else {
            nn = other.length;
          }
          ret.context = this;
          ret.selector = function() {
            return ret.context.intersect(other);
          };
          for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
            for (j = 0; 0 <= nn ? j < nn : j > nn; 0 <= nn ? j++ : j--) {
              if (this[i] === other[j]) {
                ret[m++] = this[i];
                break;
              }
            }
          }
          return ret;
        },
        distinct: function(strict) {
          return this.union(this, strict);
        },
        contains: function(item, strict) {
          var t, _i, _len;
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            t = this[_i];
            if ((strict && t === item) || (!strict && t === item)) {
              return true;
            }
          }
          return false;
        },
        count: function(item, strict) {
          var ret;
          if (item === void 0) {
            return this.len();
          }
          ret = 0;
          this.each(function(t) {
            if ((strict && t === item) || (!strict && t === item)) {
              return ret++;
            }
          });
          return ret;
        },
        zip: function() {
          var a, i, j, k, list, n, nn, o, set;
          a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          n = a.length;
          switch (n) {
            case 0:
              return $();
            case 1:
              return zipper.call(this, a[0]);
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
          } else {
            return this.each(function() {
              return this[p] = v;
            });
          }
        },
        zipzapmap: function(p, f) {
          var v;
          v = this.zip(p);
          v = v.map(f);
          return this.zap(p, v);
        },
        take: function(n) {
          var a, i;
          n = Math.min(n | 0, this.len());
          a = $();
          a.context = this;
          a.selector = function() {
            return a.context.take(n);
          };
          for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
            a[i] = this[i];
          }
          return a;
        },
        skip: function(n) {
          var a, i, nn;
          if (n == null) {
            n = 0;
          }
          n = Math.min(this.len(), Math.max(0, n | 0));
          nn = this.len() - n;
          a = $();
          a.context = this;
          a.selector = function() {
            return a.context.skip(n);
          };
          for (i = 0; 0 <= nn ? i < nn : i > nn; 0 <= nn ? i++ : i--) {
            a[i] = this[i + n];
          }
          return a;
        },
        first: function(n) {
          if (n == null) {
            n = 1;
          }
          if (n === 1) {
            return this[0];
          } else {
            return this.take(n);
          }
        },
        last: function(n) {
          if (n == null) {
            n = 1;
          }
          if (n === 1) {
            return this[this.len() - 1];
          } else {
            return this.skip(this.len() - n);
          }
        },
        slice: function(start, end) {
          var b, i, j, n;
          if (start == null) {
            start = 0;
          }
          if (end == null) {
            end = this.len();
          }
          j = 0;
          n = this.len();
          if (start < 0) {
            start += n;
          }
          if (end < 0) {
            end += n;
          }
          b = $();
          b.context = this;
          b.selector = function() {
            return b.context.slice(start, end);
          };
          for (i = start; start <= end ? i < end : i > end; start <= end ? i++ : i--) {
            b[j++] = this[i];
          }
          return b;
        },
        concat: function(b) {
          var i, j, n;
          i = this.len() - 1;
          j = -1;
          if (Object.IsFunc(b.len)) {
            n = b.len();
          } else {
            n = b.length;
          }
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
          b.context = this;
          b.selector = function() {
            return b.context.filter(f);
          };
          switch (Object.Type(f)) {
            case "string":
              g = function(x) {
                return x.matchesSelector(f);
              };
              break;
            case "regexp":
              g = function(x) {
                return f.test(x);
              };
              break;
            case "function":
              g = f;
              break;
            default:
              throw new Error("unsupported type passed to filter: " + (Object.Type(f)));
          }
          j = 0;
          for (_i = 0, _len = this.length; _i < _len; _i++) {
            it = this[_i];
            if (g.call(it, it)) {
              b[j++] = it;
            }
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
          var c, i, n, nn, _ref;
          nn = this.len();
          n = b.len();
          i = nn - 1;
          c = $();
          c.context = this;
          c.selector = function() {
            return c.context.weave(b);
          };
          for (i = _ref = nn - 1; _ref <= 0 ? i <= 0 : i >= 0; _ref <= 0 ? i++ : i--) {
            c[(i * 2) + 1] = this[i];
          }
          for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
            c[i * 2] = b[i];
          }
          return c;
        },
        fold: function(f) {
          var b, i, j, n, _ref, _step;
          n = this.len();
          j = 0;
          b = $();
          b.context = this;
          b.selector = function() {
            return b.context.fold(f);
          };
          for (i = 0, _ref = n - 1, _step = 2; 0 <= _ref ? i < _ref : i > _ref; i += _step) {
            b[j++] = f.call(this, this[i], this[i + 1]);
          }
          if ((n % 2) === 1) {
            b[j++] = f.call(this, this[n - 1], void 0);
          }
          return b;
        },
        flatten: function() {
          var b, c, d, i, j, k, n;
          b = $();
          n = this.len();
          k = 0;
          b.context = this;
          b.selector = function() {
            return b.context.flatten();
          };
          for (i = 0; 0 <= n ? i < n : i > n; 0 <= n ? i++ : i--) {
            c = this[i];
            if (Object.IsFunc(c.len)) {
              d = c.len();
            } else {
              d = c.length;
            }
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
            if (Object.IsFunc(this)) {
              return this.apply(context, args);
            } else {
              return this;
            }
          });
        },
        toString: function() {
          return $.symbol + "([" + this.map(function() {
            switch (this) {
              case void 0:
                return "undefined";
              case null:
                return "null";
              case window:
                return "window";
              default:
                return this.toString().replace(_object_re_, "$1");
            }
          }).join(commasep) + "])";
        },
        delay: function(n, f) {
          if (f) {
            timeoutQueue.schedule(Function.Bound(f, this), n);
          }
          return this;
        },
        log: function(label) {
          var n;
          n = this.len();
          if (label) {
            _log_(label, this, n + " items");
          } else {
            _log_(this, n + " items");
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
        }
      };
    });
    $.plugin(function() {
      var after, before, escaper, getCSSProperty, toNode;
      before = function(a, b) {
        return a.parentNode.insertBefore(b, a);
      };
      after = function(a, b) {
        return a.parentNode.insertBefore(b, a.nextSibling);
      };
      toNode = function(x) {
        switch (Object.Type(x)) {
          case "fragment":
            return x;
          case "node":
            return x;
          case "bling":
            return x.toFragment();
          case "string":
            return $(x).toFragment();
          case "function":
            return $(x.toString()).toFragment();
          default:
            throw new Error("toNode called with invalid argument: " + x + " (type: " + (Object.Type(x)) + ")");
        }
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
              if (n === 1) {
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
              switch (Object.Type(n)) {
                case "string":
                  return n;
                case "node":
                  n = n.cloneNode(true);
                  d = document.createElement("div");
                  d.appendChild(n);
                  ret = d.innerHTML;
                  d.removeChild(n);
                  delete n;
                  return ret;
              }
            },
            escape: function(h) {
              var ret;
              escaper || (escaper = $("<div>&nbsp;</div>").child(0));
              ret = escaper.zap('data', h).zip("parentNode.innerHTML").first();
              escaper.zap('data', '');
              return ret;
            }
          }
        },
        html: function(h) {
          switch (Object.Type(h)) {
            case "undefined":
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
          if (x != null) {
            $(x).prepend(this);
          }
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
          return this.map(function(child) {
            var marker, p;
            if (Object.IsFragment(child)) {
              parent.appendChild(child);
            } else if (Object.IsNode(child)) {
              p = child.parentNode;
              if (!p) {
                parent.appendChild(child);
              } else {
                marker = document.createElement("dummy");
                parent.appendChild(p.replaceChild(marker, child));
                p.replaceChild(parent, marker);
              }
            }
            return child;
          });
        },
        unwrap: function() {
          return this.each(function() {
            if (this.parentNode && this.parentNode.parentNode) {
              return this.parentNode.parentNode.replaceChild(this, this.parentNode);
            }
          });
        },
        replace: function(n) {
          var b, j;
          n = toNode(n);
          b = $();
          j = 0;
          this.take(1).each(function() {
            if (this.parentNode) {
              this.parentNode.replaceChild(n, this);
              return b[j++] = n;
            }
          });
          this.skip(1).each(function() {
            var c;
            if (this.parentNode) {
              c = n.cloneNode(true);
              this.parentNode.replaceChild(c, this);
              return b[j++] = c;
            }
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
            return this.className = this.className.split(" ").filter(notx).join(" ");
          });
        },
        toggleClass: function(x) {
          var notx;
          notx = function(y) {
            return y !== x;
          };
          return this.each(function() {
            var cls;
            cls = this.className.split(" ");
            if (cls.indexOf(x) > -1) {
              return this.className = cls.filter(notx).join(" ");
            } else {
              cls.push(x);
              return this.className = cls.join(" ");
            }
          });
        },
        hasClass: function(x) {
          return this.zip('className.split').call(" ").zip('indexOf').call(x).map(Function.IndexFound);
        },
        text: function(t) {
          if (t != null) {
            return this.zap('textContent', t);
          }
          return this.zip('textContent');
        },
        val: function(v) {
          if (v != null) {
            return this.zap('value', v);
          }
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
          $.synth("style").text(style).appendTo("head");
          return this;
        },
        empty: function() {
          return this.html("");
        },
        rect: function() {
          return this.zip('getBoundingClientRect').call();
        },
        width: function(w) {
          if (w === null) {
            return this.rect().zip("width");
          }
          return this.css("width", w);
        },
        height: function(h) {
          if (h === null) {
            return this.rect().zip("height");
          }
          return this.css("height", h);
        },
        top: function(y) {
          if (y === null) {
            return this.rect().zip("top");
          }
          return this.css("top", y);
        },
        left: function(x) {
          if (x === null) {
            return this.rect().zip("left");
          }
          return this.css("left", x);
        },
        bottom: function(x) {
          if (x === null) {
            return this.rect().zip("bottom");
          }
          return this.css("bottom", x);
        },
        right: function(x) {
          if (x === null) {
            return this.rect().zip("right");
          }
          return this.css("right", x);
        },
        position: function(x, y) {
          if (x === null) {
            return this.rect();
          }
          if (y === null) {
            return this.css("left", Number.Px(x));
          }
          return this.css({
            top: Number.Px(y),
            left: Number.Px(x)
          });
        },
        center: function(mode) {
          var body, vh, vw;
          if (mode == null) {
            mode = "viewport";
          }
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
            if (i < 0) {
              i += this.length;
            }
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
            if (this.parentNode) {
              return this.parentNode.removeChild(this);
            }
          });
        },
        find: function(css) {
          return this.filter("*").map(function() {
            return $(css, this);
          }).flatten();
        },
        clone: function(deep) {
          if (deep == null) {
            deep = true;
          }
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
      return {
        name: 'Maths',
        floats: function() {
          return this.map(parseFloat);
        },
        ints: function() {
          return this.map(function() {
            return parseInt(this, 10);
          });
        },
        px: function(delta) {
          if (delta == null) {
            delta = 0;
          }
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
      var bindReady, binder, events, readyBound, readyTriggered, register_live, ret, triggerReady, unregister_live;
      events = ['mousemove', 'mousedown', 'mouseup', 'mouseover', 'mouseout', 'blur', 'focus', 'load', 'unload', 'reset', 'submit', 'keyup', 'keydown', 'change', 'abort', 'cut', 'copy', 'paste', 'selection', 'drag', 'drop', 'orientationchange', 'touchstart', 'touchmove', 'touchend', 'touchcancel', 'gesturestart', 'gestureend', 'gesturecancel', 'hashchange'];
      binder = function(e) {
        return function(f) {
          if (f == null) {
            f = {};
          }
          if (Object.IsFunc(f)) {
            return this.bind(e, f);
          }
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
          c = (e || "").split(eventsep_re);
          h = function(evt) {
            ret = f.apply(this, arguments);
            if (ret === false) {
              Event.Prevent(evt);
            }
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
          c = (e || "").split(eventsep_re);
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
          c = (e || "").split(eventsep_re);
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
          c = (e || "").split(eventsep_re);
          nf = funcs.length;
          cycler = function() {
            var i;
            i = 0;
            return function(evt) {
              funcs[i].call(this, evt);
              return i = ++i % nf;
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
          if (args == null) {
            args = {};
          }
          evts = (evt || "").split(eventsep_re);
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
                _log_("dispatchEvent error:", err);
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
          var context, h, selector;
          selector = this.selector;
          context = this.context;
          h = unregister_live(selector, context, e, f);
          $(context).unbind(e, h);
          return this;
        },
        liveCycle: function() {
          var e, funcs, i;
          e = arguments[0], funcs = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
          i = 0;
          return this.live(e, function(evt) {
            funcs[i].call(this, evt);
            return i = ++i % funcs.length;
          });
        },
        click: function(f) {
          if (f == null) {
            f = {};
          }
          if (this.css("cursor").intersect(["auto", ""]).len() > 0) {
            this.css("cursor", "pointer");
          }
          if (Object.IsFunc(f)) {
            return this.bind('click', f);
          } else {
            return this.trigger('click', f);
          }
        },
        ready: function(f) {
          if (f == null) {
            f = {};
          }
          if (Object.IsFunc(f)) {
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
    $.plugin(function() {
      var accel_props_re, speeds, testStyle, transformProperty, transitionDuration, transitionProperty, transitionTiming, updateDelay;
      speeds = {
        "slow": 700,
        "medium": 500,
        "normal": 300,
        "fast": 100,
        "instant": 0,
        "now": 0
      };
      accel_props_re = /(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/;
      updateDelay = 50;
      testStyle = document.createElement("div").style;
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
      delete testStyle;
      return {
        name: 'Transform',
        $: {
          duration: function(speed) {
            var d;
            d = speeds[speed];
            if (d != null) {
              return d;
            }
            return parseFloat(speed);
          }
        },
        transform: function(end_css, speed, easing, callback) {
          var css, duration, i, ii, p, props, trans;
          if (Object.IsFunc(speed)) {
            callback = speed;
            speed = null;
            easing = null;
          } else if (Object.IsFunc(easing)) {
            callback = easing;
            easing = null;
          }
          if (!(speed != null)) {
            speed = "normal";
          }
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
                ii = $(ii).px().join(commasep);
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
          if (trans) {
            props[p++] = transformProperty;
          }
          css[transitionProperty] = props.join(commasep);
          css[transitionDuration] = props.map(function() {
            return duration;
          }).join(commasep);
          css[transitionTiming] = props.map(function() {
            return easing;
          }).join(commasep);
          if (trans) {
            css[transformProperty] = trans;
          }
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
          if (x == null) {
            x = 0.0;
          }
          if (y == null) {
            y = 0.0;
          }
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
            if (opts == null) {
              opts = {};
            }
            xhr = new XMLHttpRequest();
            if (Object.IsFunc(opts)) {
              opts = {
                success: Function.Bound(opts, xhr)
              };
            }
            opts = Object.Extend({
              method: "GET",
              data: null,
              state: Function.Empty,
              success: Function.Empty,
              error: Function.Empty,
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
              if (opts.state) {
                opts.state();
              }
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
            if (opts == null) {
              opts = {};
            }
            if (Object.IsFunc(opts)) {
              opts = {
                success: opts
              };
            }
            opts.method = "POST";
            return $.http(url, opts);
          },
          get: function(url, opts) {
            if (opts == null) {
              opts = {};
            }
            if (Object.IsFunc(opts)) {
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
      var ATTRMODE, CLSMODE, DTEXTMODE, IDMODE, STEXTMODE, TAGMODE, VALMODE, chunk_re, compile, match_forward, render, synth, type_re;
      match_forward = function(text, find, against, start, stop) {
        var count, i;
        count = 1;
        if (stop === null || stop === -1) {
          stop = text.length;
        }
        for (i = start; start <= stop ? i < stop : i > stop; start <= stop ? i++ : i--) {
          if (text[i] === against) {
            count += 1;
          } else if (text[i] === find) {
            count -= 1;
          }
          if (count === 0) {
            return i;
          }
        }
        return -1;
      };
      type_re = /([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;
      chunk_re = /%[\(\/]/;
      compile = function(text) {
        var chunks, end, i, j, key, match, n, rest, ret;
        chunks = text.split(chunk_re);
        n = chunks.length;
        ret = [chunks[0]];
        j = 1;
        for (i = 1; 1 <= n ? i < n : i > n; 1 <= n ? i++ : i--) {
          end = match_forward(chunks[i], ')', '(', 0, -1);
          if (end === -1) {
            return "Template syntax error: unmatched '%(' starting at: " + (chunks[i].substring(0, 15));
          }
          key = chunks[i].substring(0, end);
          rest = chunks[i].substring(end);
          match = type_re.exec(rest);
          if (match === null) {
            return "Template syntax error: invalid type specifier starting at '" + rest + "'";
          }
          rest = match[4];
          ret[j++] = key;
          ret[j++] = match[1] | 0;
          ret[j++] = match[2] | 0;
          ret[j++] = match[3];
          ret[j++] = rest;
        }
        return ret;
      };
      compile.cache = {};
      render = function(text, values) {
        var cache, fixed, i, j, key, n, output, pad, rest, type, value, _ref, _ref2, _step;
        cache = compile.cache[text];
        if (cache === null) {
          cache = compile.cache[text] = compile(text);
        }
        output = [cache[0]];
        j = 1;
        n = cache.length;
        for (i = 1, _ref = n - 5, _step = 5; 1 <= _ref ? i <= _ref : i >= _ref; i += _step) {
          _ref2 = cache.slice(i, (i + 4 + 1) || 9e9), key = _ref2[0], pad = _ref2[1], fixed = _ref2[2], type = _ref2[3], rest = _ref2[4];
          value = values[key];
          if (!(value != null)) {
            value = "missing value: " + key;
          }
          switch (type) {
            case 'd':
              output[j++] = "" + parseInt(value, 10);
              break;
            case 'f':
              output[j++] = parseFloat(value).toFixed(fixed);
              break;
            case 's':
              output[j++] = "" + value;
              break;
            default:
              output[j++] = "" + value;
          }
          if (pad > 0) {
            output[j] = String.PadLeft(output[j], pad);
          }
          output[j++] = rest;
        }
        return output.join("");
      };
      TAGMODE = 1;
      IDMODE = 2;
      CLSMODE = 3;
      ATTRMODE = 4;
      VALMODE = 5;
      DTEXTMODE = 6;
      STEXTMODE = 7;
      synth = function(expr) {
        var addToAttr, addToClass, addToId, addToTag, addToText, addToVal, attr, attrs, beginAttr, beginClass, beginDText, beginId, beginSText, beginVal, c, cls, emitNode, emitNodeAndReset, emitNodeAndSkip, emitText, endAttr, i, id, mode, modeline, parent, parse_table, ret, tag, text, val;
        parent = null;
        tag = id = cls = attr = val = text = "";
        attrs = {};
        mode = TAGMODE;
        ret = $([]);
        ret.selector = expr;
        emitText = function() {
          var node;
          node = $.HTML.parse(text);
          if (parent) {
            parent.appendChild(node);
          } else {
            ret.push(node);
          }
          text = "";
          return TAGMODE;
        };
        emitNode = function() {
          var k, node;
          node = document.createElement(tag);
          node.id = id || null;
          node.className = cls || null;
          for (k in attrs) {
            node.setAttribute(k, attrs[k]);
          }
          if (parent) {
            parent.appendChild(node);
          } else {
            ret.push(node);
          }
          parent = node;
          tag = id = cls = attr = val = text = "";
          attrs = {};
          return TAGMODE;
        };
        emitNodeAndReset = function() {
          emitNode();
          parent = null;
          return TAGMODE;
        };
        emitNodeAndSkip = function() {
          emitNode();
          if (parent) {
            parent = parent.parentNode;
          }
          return TAGMODE;
        };
        beginClass = function() {
          if (cls.length > 0) {
            cls += " ";
          }
          return CLSMODE;
        };
        addToClass = function(c) {
          cls += c;
          return TAGMODE;
        };
        beginAttr = function() {
          return ATTRMODE;
        };
        addToAttr = function(c) {
          attr += c;
          return TAGMODE;
        };
        beginVal = function() {
          return VALMODE;
        };
        addToVal = function(c) {
          val += c;
          return TAGMODE;
        };
        endAttr = function() {
          attrs[attr] = val;
          attr = val = "";
          return TAGMODE;
        };
        beginId = function() {
          return IDMODE;
        };
        addToId = function(c) {
          id += c;
          return TAGMODE;
        };
        beginDText = function() {
          return DTEXTMODE;
        };
        beginSText = function() {
          return STEXTMODE;
        };
        addToText = function(c) {
          text += c;
          return TAGMODE;
        };
        addToTag = function(c) {
          tag += c;
          return TAGMODE;
        };
        parse_table = {
          TAGMODE: {
            '"': beginDText,
            "'": beginSText,
            "#": beginId,
            ".": beginClass,
            "[": beginAttr,
            "+": emitNodeAndSkip,
            " ": emitNode,
            ",": emitNodeAndReset,
            def: addToTag
          },
          IDMODE: {
            ".": beginClass,
            "[": beginAttr,
            "+": emitNodeAndSkip,
            " ": emitNode,
            ",": emitNodeAndReset,
            def: addToId
          },
          CLSMODE: {
            "#": beginId,
            ".": beginClass,
            "[": beginAttr,
            "+": emitNodeAndSkip,
            " ": emitNode,
            ",": emitNodeAndReset,
            def: addToClass
          },
          ATTRMODE: {
            "=": beginVal,
            "]": endAttr,
            def: addToAttr
          },
          VALMODE: {
            "]": endAttr,
            def: addToVal
          },
          DTEXTMODE: {
            '"': emitText,
            def: addToText
          },
          STEXTMODE: {
            "'": emitText,
            def: addToText
          }
        };
        i = 0;
        while (c = expr[i++]) {
          modeline = parse_table[mode];
          if (c in modeline) {
            mode = modeline[c](c);
          } else {
            mode = modeline['def'](c);
          }
        }
        if (tagname.length > 0) {
          emitNode();
        }
        if (text.length > 0) {
          emitText();
        }
        return ret;
      };
      return {
        name: 'Template',
        $: {
          render: render,
          synth: synth
        },
        template: function(defaults) {
          this.render = function(args) {
            return render(this.map($.HTML.stringify).join(""), Object.Extend(defaults, args));
          };
          return this.remove();
        },
        render: function(args) {
          return render(this.map($.HTML.stringify).join(""), args);
        },
        synth: function(expr) {
          return synth(expr).appendTo(this);
        }
      };
    });
    return $;
  })(Bling);
}).call(this);
