(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  (function($) {
    return $.plugin(function() {
      var Promise;
      Promise = function(steps) {
        var es, fs, ps;
        if (steps == null) {
          steps = 1;
        }
        this.steps = steps;
        this.state = 0;
        this.value = null;
        fs = [];
        es = [];
        ps = [];
        this.then = __bind(function(f, e, p) {
          if (this.state === this.steps) {
            return f(this.value);
          } else {
            fs.push(f);
          }
          if (this.state === -2) {
            return e(this.value);
          } else {
            es.push(e);
          }
          if (Object.IsFunc(p)) {
            return ps.push(p);
          }
        }, this);
        this.cancel = __bind(function() {
          fs = [];
          es = [];
          ps = [];
          return this.state = -1;
        }, this);
        return this.fulfill = __bind(function(v) {
          var f, p, _i, _len, _results, _results2, _results3;
          this.state += 1;
          this.value = v;
          if (Object.Type(v) === "error") {
            this.state = -2;
            _results = [];
            while (f = es.pop()) {
              _results.push(f(v));
            }
            return _results;
          } else {
            if (this.state === steps) {
              _results2 = [];
              while (f = fs.pop()) {
                _results2.push(f(v));
              }
              return _results2;
            } else {
              _results3 = [];
              for (_i = 0, _len = ps.length; _i < _len; _i++) {
                p = ps[_i];
                _results3.push(p(this.state));
              }
              return _results3;
            }
          }
        }, this);
      };
      return {
        name: "Promises"
      };
    });
  })(Bling);
}).call(this);
