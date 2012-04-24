(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  (function($) {
    $.plugin(function() {
      var StateMachine;
      StateMachine = (function() {

        function StateMachine(stateTable) {
          this.reset();
          this.table = stateTable;
          Object.defineProperty(this, "modeline", {
            get: this.table[this._mode]
          });
          Object.defineProperty(this, "mode", {
            set: function(m) {
              var ret;
              this._lastMode = this._mode;
              this._mode = m;
              if (this._mode !== this._lastMode && (this.modeline != null) && 'enter' in this.modeline) {
                ret = this.modeline['enter'].call(this);
                while (Object.IsFunction(ret)) {
                  ret = ret.call(this);
                }
              }
              return m;
            },
            get: function() {
              return this._mode;
            }
          });
        }

        StateMachine.prototype.reset = function() {
          this._mode = null;
          return this._lastMode = null;
        };

        StateMachine.prototype.GO = function(m) {
          return function() {
            return this.mode = m;
          };
        };

        StateMachine.GO = function(m) {
          return function() {
            return this.mode = m;
          };
        };

        StateMachine.prototype.run = function(input) {
          var c, ret, row, _i, _len, _ref;
          this.mode = 0;
          for (_i = 0, _len = input.length; _i < _len; _i++) {
            c = input[_i];
            row = this.modeline;
            if (!(row != null)) {
              ret = null;
            } else if (c in row) {
              ret = row[c];
            } else if ('def' in row) {
              ret = row['def'];
            }
            while (Object.IsFunction(ret)) {
              ret = ret.call(this, c);
            }
          }
          if (Object.IsFunction((_ref = this.modeline) != null ? _ref.eof : void 0)) {
            ret = this.modeline.eof.call(this);
          }
          while (Object.IsFunction(ret)) {
            ret = ret.call(this);
          }
          this.reset();
          return this;
        };

        return StateMachine;

      })();
      return {
        name: "StateMachine",
        $: {
          StateMachine: StateMachine
        }
      };
    });
    return $.plugin(function() {
      var SynthMachine;
      SynthMachine = (function() {

        __extends(SynthMachine, $.StateMachine);

        SynthMachine.STATE_TABLE = [
          {
            enter: function() {
              this.tag = this.id = this.cls = this.attr = this.val = this.text = "";
              this.attrs = {};
              return this.GO(1);
            }
          }, {
            '"': SynthMachine.GO(6),
            "'": SynthMachine.GO(7),
            "#": SynthMachine.GO(2),
            ".": SynthMachine.GO(3),
            "[": SynthMachine.GO(4),
            " ": SynthMachine.GO(9),
            "+": SynthMachine.GO(11),
            ",": SynthMachine.GO(10),
            def: function(c) {
              return this.tag += c;
            },
            eof: SynthMachine.GO(13)
          }, {
            ".": SynthMachine.GO(3),
            "[": SynthMachine.GO(4),
            " ": SynthMachine.GO(9),
            "+": SynthMachine.GO(11),
            ",": SynthMachine.GO(10),
            def: function(c) {
              return this.id += c;
            },
            eof: SynthMachine.GO(13)
          }, {
            enter: function() {
              if (this.cls.length > 0) return this.cls += " ";
            },
            "#": SynthMachine.GO(2),
            ".": SynthMachine.GO(3),
            "[": SynthMachine.GO(4),
            " ": SynthMachine.GO(9),
            "+": SynthMachine.GO(11),
            ",": SynthMachine.GO(10),
            def: function(c) {
              return this.cls += c;
            },
            eof: SynthMachine.GO(13)
          }, {
            "=": SynthMachine.GO(5),
            "]": function() {
              this.attrs[this.attr] = this.val;
              return this.GO(1);
            },
            def: function(c) {
              return this.attr += c;
            },
            eof: SynthMachine.GO(12)
          }, {
            "]": function() {
              this.attrs[this.attr] = this.val;
              return this.GO(1);
            },
            def: function(c) {
              return this.val += c;
            },
            eof: SynthMachine.GO(12)
          }, {
            '"': SynthMachine.GO(8),
            def: function(c) {
              return this.text += c;
            },
            eof: SynthMachine.GO(12)
          }, {
            "'": SynthMachine.GO(8),
            def: function(c) {
              return this.text += c;
            },
            eof: SynthMachine.GO(12)
          }, {
            enter: function() {
              this.emitText();
              return this.GO(0);
            }
          }, {
            enter: function() {
              this.emitNode();
              return this.GO(0);
            }
          }, {
            enter: function() {
              this.emitNode();
              this.parent = null;
              return this.GO(0);
            }
          }, {
            enter: function() {
              var _ref;
              this.emitNode();
              this.parent = (_ref = this.parent) != null ? _ref.parentNode : void 0;
              return this.GO(0);
            }
          }, {
            enter: function() {
              return $.log("Error in synth expression: " + this.input);
            }
          }, {
            enter: function() {
              if (this.tag.length) this.emitNode();
              if (this.text.length) return this.emitText();
            }
          }
        ];

        function SynthMachine() {
          SynthMachine.__super__.constructor.call(this, SynthMachine.STATE_TABLE);
          this.fragment = this.parent = document.createDocumentFragment();
        }

        SynthMachine.prototype.emitNode = function() {
          var k, node;
          node = document.createElement(this.tag);
          node.id = this.id || null;
          node.className = this.cls || null;
          for (k in this.attrs) {
            node.setAttribute(k, this.attrs[k]);
          }
          this.parent.appendChild(node);
          return this.parent = node;
        };

        SynthMachine.prototype.emitText = function() {
          this.parent.appendChild($.HTML.parse(this.text));
          return this.text = "";
        };

        return SynthMachine;

      })();
      return {
        name: "Synth",
        $: {
          synth: function(expr) {
            var s;
            s = new SynthMachine();
            s.run(expr);
            if (s.fragment.childNodes.length === 1) {
              return $(s.fragment.childNodes[0]);
            } else {
              return $(s.fragment);
            }
          }
        }
      };
    });
  })(Bling);

}).call(this);
