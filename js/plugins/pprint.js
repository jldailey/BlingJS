(function() {
  (function($) {
    return $.plugin(function() {
      var all_numbers, bling_html, bling_symbol, closing_quote, comment_html, first_comment, first_quote, keyword_html, keywords, multiline_comment, number_html, operator_html, operators, quoted_html, singleline_comment, split_comments, split_quoted, tab_html, tabs;
      operators = /!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g;
      operator_html = "<span class='opr'>$&</span>";
      keywords = /\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g;
      keyword_html = "<span class='kwd'>$&</span>";
      all_numbers = /\d+\.*\d*/g;
      number_html = "<span class='num'>$&</span>";
      bling_symbol = /\$(\(|\.)/g;
      bling_html = "<span class='bln'>$$</span>$1";
      tabs = /\t/g;
      tab_html = "&nbsp;&nbsp;";
      singleline_comment = /\/\/.*?(?:\n|$)/;
      multiline_comment = /\/\*(?:.|\n)*?\*\//;
      comment_html = function(comment) {
        if (comment) {
          return "<span class='com'>" + comment + "</span>";
        } else {
          return "";
        }
      };
      quoted_html = function(quoted) {
        if (quoted) {
          return "<span class='str'>" + quoted + "</span>";
        } else {
          return "";
        }
      };
      first_quote = function(s, i) {
        var a, b;
        a = s.indexOf('"', i);
        b = s.indexOf("'", i);
        if (a === -1) {
          a = s.length;
        }
        if (b === -1) {
          b = s.length;
        }
        if (a === b) {
          return [null, -1];
        }
        if (a < b) {
          return ['"', a];
        }
        return ["'", b];
      };
      closing_quote = function(s, i, q) {
        var r;
        r = s.indexOf(q, i);
        while (s.charAt(r - 1) === "\\" && (0 < r && r < s.length)) {
          r = s.indexOf(q, r + 1);
        }
        return r;
      };
      split_quoted = function(s) {
        var i, j, k, n, q, ret;
        i = 0;
        n = s.length;
        ret = [];
        if (!Object.IsString(s)) {
          if (!Object.IsFunc(s.toString)) {
            throw TypeError("invalid string argument to split_quoted");
          } else {
            s = s.toString();
            n = s.length;
          }
        }
        while (i < n) {
          q = first_quote(s, i);
          j = q[1];
          if (j === -1) {
            ret.push(s.substring(i));
            break;
          }
          ret.push(s.substring(i, j));
          k = closing_quote(s, j + 1, q[0]);
          if (k === -1) {
            throw Error("unclosed quote: " + q[0] + " starting at " + j);
          }
          ret.push(s.substring(j, k + 1));
          i = k + 1;
        }
        return ret;
      };
      first_comment = function(s) {
        var a, b;
        a = s.match(singleline_comment);
        b = s.match(multiline_comment);
        if (a === b) {
          return [-1, null];
        }
        if (a === null && b !== null) {
          return [b.index, b[0]];
        }
        if (a !== null && b === null) {
          return [a.index, a[0]];
        }
        if (b.index < a.index) {
          return [b.index, b[0]];
        }
        return [a.index, a[0]];
      };
      split_comments = function(s) {
        var i, j, n, q, ret, ss;
        ret = [];
        i = 0;
        n = s.length;
        while (i < n) {
          ss = s.substring(i);
          q = first_comment(ss);
          j = q[0];
          if (j > -1) {
            ret.push(ss.substring(0, j));
            ret.push(q[1]);
            i += j + q[1].length;
          } else {
            ret.push(ss);
            break;
          }
        }
        return ret;
      };
      return {
        name: "PrettyPrint",
        $: {
          prettyPrint: function(js, colors) {
            var cls, css;
            if (Object.IsFunc(js)) {
              js = js.toString();
            }
            if (!Object.IsString(js)) {
              throw TypeError("prettyPrint requires a function or string to format, not '" + Object.Type(js) + "'");
            }
            if ($("style#prettyPrint").length === 0) {
              css = "code.pp .bln { font-size: 17px; } ";
              colors = Object.Extend({
                opr: "#880",
                str: "#008",
                com: "#080",
                kwd: "#088",
                num: "#808",
                bln: "#800"
              }, colors);
              for (cls in colors) {
                css += "code.pp ." + cls + " { color: " + colors[cls] + "; } ";
              }
              $.synth("style#prettyPrint").text(css).appendTo("head");
            }
            return "";
            return "<code class='pp'>" + ($(split_comments(js)).fold(function(text, comment) {
              return $(split_quoted(text)).fold(function(code, quoted) {
                return code.replace(operators, operator_html).replace(all_numbers, number_html).replace(keywords, keyword_html).replace(bling_symbol, bling_html).replace(tabs, tab_html) + quoted_html(quoted);
              }).join('') + comment_html(comment);
            }).join('')) + "</code>";
          }
        }
      };
    });
  })(Bling);
}).call(this);
