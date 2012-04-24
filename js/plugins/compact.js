
  (function($) {
    return $.plugin(function() {
      var lookup, pruners, register;
      pruners = {};
      register = function(type, obj) {
        return pruners[type] = obj;
      };
      lookup = function(obj) {
        return pruners[obj.TYPE];
      };
      Object.Type.extend("unknown", {
        compact: function(o) {
          return Object.String(o);
        }
      });
      Object.Type.extend("string", {
        compact: function(o) {
          return o;
        }
      });
      Object.Type.extend("number", {
        compact: function(o) {
          return Object.String(o);
        }
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
      Object.Type.extend("object", {
        compact: function(o) {
          var _ref;
          return Object.Compact((_ref = lookup(o)) != null ? _ref.prune.call(o, o) : void 0);
        }
      });
      Object.Compact = function(o) {
        var _ref;
        return (_ref = Object.Type.lookup(o)) != null ? _ref.compact(o) : void 0;
      };
      Object.Extend(Object.Compact, {
        register: register,
        lookup: lookup
      });
      register('page', {
        prune: function(node) {
          return ["<!DOCTYPE html><html><head>", node.HEAD, "</head><body>", node.BODY, "</body></html>"];
        }
      });
      register('text', {
        prune: function(node) {
          return node.EN;
        }
      });
      register('link', {
        prune: function(node) {
          var a, k, _i, _len, _ref;
          a = ["<a"];
          _ref = ["href", "name", "target"];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            k = _ref[_i];
            if (k in node) Array.Extend(a, [" ", k, "='", node[k], "'"]);
          }
          Array.Extend(a, [">", node.CONTENT, "</a>"]);
          return a;
        }
      });
      Object.Compact({
        TYPE: "page",
        HEAD: [],
        BODY: {
          TYPE: "text",
          EN: "Hello World"
        }
      }) === "<!DOCTYPE html><html><head></head><body>Hello World</body></html>";
      return {
        name: "Compact"
      };
    });
  })(Bling);
