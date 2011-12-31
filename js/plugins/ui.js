
  (function($) {
    return $.plugin(function() {
      Dialog(selector, opts)(function() {
        var dialog, opts;
        opts = Object.Extend({
          autoOpen: false,
          draggable: true
        }, opts);
        dialog = $(selector).addClass("dialog");
        if (opts.draggable) dialog.draggable();
        if (opts.autoOpen) dialog.show().center();
        dialog.find("button.close, .close-button").bind("click touchstart", function() {
          dialog.hide();
          return false;
        });
        return dialog;
      });
      Draggable(selector, opts)(function() {
        var dragObject, handle, moving, oX, oY, opts;
        opts = Object.Extend({
          handleCSS: {}
        }, opts);
        opts.handleCSS = Object.Extend({
          position: "absolute",
          top: "0px",
          left: "0px",
          width: "100%",
          height: "6px"
        }, opts.handleCSS);
        dragObject = $(selector);
        moving = false;
        oX = oY = 0;
        handle = $.synth("div.handle").defaultCss({
          background: "-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",
          height: "6px",
          "border-radius": "3px",
          cursor: "move"
        }.css(opts.handleCSS.bind('mousedown, touchstart', function(evt) {
          moving = true;
          oX || (oX = evt.pageX);
          oY || (oY = evt.pageY);
          return false;
        })));
        $(document.bind('mousemove, touchmove', function(evt) {
          var dX, dY;
          if (moving) {
            dX = evt.pageX - oX;
            dY = evt.pageY - oY;
            dragObject.transform({
              translate: [dX, dY]
            }, 0).trigger('drag', {
              dragObject: dragObject
            });
            return false;
          }
        })).bind('mouseup, touchend', function(evt) {
          var pos;
          if (moving) {
            moving = false;
            pos = handle.position()[0];
            return $(document.elementFromPoint(pos.left, pos.top - 1).trigger('drop', {
              dropObject: dragObject
            }));
          }
        });
        return dragObject.addClass("draggable").css({
          position: "relative",
          "padding-top": dragObject.css("padding-top").map(Number.AtLeast(parseInt(opts.handleCSS.height, 10))).px().first()
        }.append(handle));
      });
      ProgressBar(selector, opts)(function() {
        var node, opts, _bg, _color, _progress;
        opts = Object.Extend({
          change: Function.Empty,
          backgroundColor: "#fff",
          barColor: "rgba(0,128,0,0.5)",
          textColor: "white",
          reset: false
        }, opts);
        node = $(selector).addClass('progress-bar');
        _progress = 0.0;
        if (opts.reset) {
          _bg = node.css("background").first();
          _color = node.css("color").first();
        }
        return node.zap('updateProgress', function(pct) {
          while (pct > 1) {
            pct /= 100;
          }
          _progress = pct;
          if (pct === 1 && opts.reset) {
            node.css("background", _bg).css("color", _color);
          } else {
            node.css({
              background: "-webkit-gradient(linear, 0 0, " + parseInt(pct * 100) + "% 0, " + "color-stop(0, " + opts.barColor + "), " + "color-stop(0.98, " + opts.barColor + "), " + "color-stop(1.0, " + opts.backgroundColor + "))",
              color: opts.textColor
            });
          }
          if (Object.IsFunc(opts.change)) return opts.change(_progress);
        });
      });
      Accordion(selector, opts)(function() {
        var initRow, node, opts, selectedChild;
        opts = Object.Extend({
          exclusive: false,
          sticky: false
        }, opts);
        node = $(selector).addClass("accordion");
        selectedChild = null;
        initRow = function(n) {
          var body, bodyVisible, t, title;
          t = $(n).children().first().filter("*");
          if (t.len() !== 2) {
            throw Exception("accordion row requires 2 elements, not " + (t.len()));
          }
          title = t.eq(0).addClass("title");
          body = t.eq(1).addClass("body").hide();
          bodyVisible = false;
          return title.click(function() {
            if (opts.exclusive) node.find(".body").hide();
            if (bodyVisible) {
              if (!opts.sticky) {
                body.hide().removeClass("visible");
                title.removeClass("selected").trigger("deselect");
                return bodyVisible = false;
              } else {
                body.show().addClass("visible");
                title.addClass("selected").trigger("select");
                return bodyVisible = true;
              }
            } else {
              body.show().addClass("visible");
              title.addClass("selected").trigger("select");
              return bodyVisible = true;
            }
          });
        };
        node.bind("DOMNodeInserted", function(evt) {
          var directChildren, parentsOfInserted;
          directChildren = node.children().first().filter("*");
          parentsOfInserted = $(evt.target).parents().first();
          return initRow(parentsOfInserted.intersect(directChildren));
        });
        node.children().first().filter("*").map(initRow);
        return node;
      });
      ViewStack(selector, opts)(function() {
        var active, items, j, _ref;
        items = $(selector).css({
          position: "relative",
          top: "0px",
          left: "0px"
        }.hide().map($));
        active = 0;
        items[active].show();
        items.next = function() {
          items[active].hide();
          active = ++active % nn;
          return items[active].show();
        };
        items.activate = function(k) {
          items[active].hide();
          active = k;
          return items[k].show();
        };
        for (j = 0, _ref = items.len(); 0 <= _ref ? j < _ref : j > _ref; 0 <= _ref ? j++ : j--) {
          items[j].zap("_viewIndex", j.zap("activate", function() {
            return items.activate(this._viewIndex);
          }));
        }
        return items;
      });
      Tabs(selector, views)(function() {
        var i, nn, tabs, views;
        tabs = $(selector);
        views = $(views).viewStack();
        nn = tabs.len();
        for (i = 0; 0 <= nn ? i <= nn : i >= nn; 0 <= nn ? i++ : i--) {
          tabs._tabIndex = i;
        }
        $(tabs[0]).addClass("active");
        return tabs.click(function() {
          tabs.removeClass("active");
          views.activate(this._tabIndex);
          return $(this).addClass("active");
        });
      });
      return {
        name: 'UI',
        $: {
          UI: {
            Draggable: Draggable,
            ProgressBar: ProgressBar,
            ViewStack: ViewStack,
            Tabs: Tabs,
            Accordion: Accordion
          }
        },
        dialog: function(opts) {
          return Dialog(this, opts);
        },
        progressBar: function(opts) {
          return ProgressBar(this, opts);
        },
        viewStack: function(opts) {
          return ViewStack(this, opts);
        },
        tabs: function(views) {
          return Tabs(this, views);
        },
        accordion: function(opts) {
          return Accordion(this, opts);
        },
        draggable: function(opts) {
          return Draggable(this, opts);
        }
      };
    });
  })(Bling);
