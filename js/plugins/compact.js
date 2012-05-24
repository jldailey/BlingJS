
  (function($) {
    return $.plugin(function() {
      var lookup, pruners, register, stack;
      pruners = {};
      register = function(type, f) {
        return pruners[type] = f;
      };
      lookup = function(f) {
        return pruners[obj.t];
      };
      stack = [];
      Object.Type.extend(null, {
        compact: function(o) {
          return Object.String(o);
        }
      });
      Object.Type.extend("undefined", {
        compact: function(o) {
          return "";
        }
      });
      Object.Type.extend("null", {
        compact: function(o) {
          return "";
        }
      });
      Object.Type.extend("string", {
        compact: Function.Identity
      });
      Object.Type.extend("array", {
        compact: function(o) {
          var x;
          return ((function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = o.length; _i < _len; _i++) {
              x = o[_i];
              _results.push(Object.Compact(x));
            }
            return _results;
          })()).join("");
        }
      });
      Object.Type.extend("bling", {
        compact: function(o) {
          return o.map(Object.Compact).join("");
        }
      });
      Object.Type.extend("object", {
        compact: function(o) {
          var _ref;
          return Object.Compact((_ref = lookup(o)) != null ? _ref.call(o, o) : void 0);
        }
      });
      Object.Compact = function(o) {
        var _ref;
        stack.push(o);
        if ((_ref = Object.Type.lookup(o)) != null) _ref.compact(o);
        return stack.pop();
      };
      Object.Extend(Object.Compact, {
        register: register,
        lookup: lookup
      });
      register('page', function() {
        return ["<!DOCTYPE html><html><head>", this.head, "</head><body>", this.body, "</body></html>"];
      });
      register('text', function() {
        return this.EN;
      });
      register('link', function() {
        var a, k, _i, _len, _ref;
        a = $(["<a"]);
        _ref = ["href", "name", "target"];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          k = _ref[_i];
          if (k in this) a.extend(" ", k, "='", this[k], "'");
        }
        return a.extend(">", node.content, "</a>");
      });
      $.assert(Object.Compact({
        t: "page",
        head: [],
        body: {
          type: "text",
          EN: "Hello World"
        }
      }) === "<!DOCTYPE html><html><head></head><body>Hello World</body></html>");
      return {
        name: "Compact"
      };
    });
  })(Bling);
