
  (function($) {
    return $.plugin(function() {
      var allNumbers, blingHtml, blingSymbol, closingQuote, commentHtml, firstComment, firstQuote, foldCodeAndQuoted, foldTextAndComments, keywordHtml, keywords, multilineComment, numberHtml, operatorHtml, operators, quotedHtml, singlelineComment, splitComments, splitQuoted, tabHtml, tabs;
      operators = /!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g;
      operatorHtml = "<span class='opr'>$&</span>";
      keywords = /\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g;
      keywordHtml = "<span class='kwd'>$&</span>";
      allNumbers = /\d+\.*\d*/g;
      numberHtml = "<span class='num'>$&</span>";
      blingSymbol = /\$(\(|\.)/g;
      blingHtml = "<span class='bln'>$$</span>$1";
      tabs = /\t/g;
      tabHtml = "&nbsp;&nbsp;";
      singlelineComment = /\/\/.*?(?:\n|$)/;
      multilineComment = /\/\*(?:.|\n)*?\*\//;
      commentHtml = function(comment) {
        if (comment) {
          return "<span class='com'>" + comment + "</span>";
        } else {
          return "";
        }
      };
      quotedHtml = function(quoted) {
        if (quoted) {
          return "<span class='str'>" + quoted + "</span>";
        } else {
          return "";
        }
      };
      firstQuote = function(s, i) {
        var a, b;
        a = s.indexOf('"', i);
        b = s.indexOf("'", i);
        if (a === -1) a = s.length;
        if (b === -1) b = s.length;
        if (a === b) return [null, -1];
        if (a < b) return ['"', a];
        return ["'", b];
      };
      closingQuote = function(s, i, q) {
        var r;
        r = s.indexOf(q, i);
        while (s.charAt(r - 1) === "\\" && (0 < r && r < s.length)) {
          r = s.indexOf(q, r + 1);
        }
        return r;
      };
      splitQuoted = function(s) {
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
          q = firstQuote(s, i);
          j = q[1];
          if (j === -1) {
            ret.push(s.substring(i));
            break;
          }
          ret.push(s.substring(i, j));
          k = closingQuote(s, j + 1, q[0]);
          if (k === -1) {
            throw Error("unclosed quote: " + q[0] + " starting at " + j);
          }
          ret.push(s.substring(j, k + 1));
          i = k + 1;
        }
        return ret;
      };
      firstComment = function(s) {
        var a, b;
        a = s.match(singlelineComment);
        b = s.match(multilineComment);
        if (a === b) return [-1, null];
        if (a === null && b !== null) return [b.index, b[0]];
        if (a !== null && b === null) return [a.index, a[0]];
        if (b.index < a.index) return [b.index, b[0]];
        return [a.index, a[0]];
      };
      splitComments = function(s) {
        var i, j, n, q, ret, ss;
        ret = [];
        i = 0;
        n = s.length;
        while (i < n) {
          ss = s.substring(i);
          q = firstComment(ss);
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
      foldCodeAndQuoted = function(code, quoted) {
        return code.replace(operators, operatorHtml).replace(allNumbers, numberHtml).replace(keywords, keywordHtml).replace(blingSymbol, blingHtml).replace(tabs, tabHtml) + quotedHtml(quoted);
      };
      foldTextAndComments = function(text, comment) {
        return $(splitQuoted(text)).fold(foldCodeAndQuoted).join('') + commentHtml(comment);
      };
      return {
        name: "PrettyPrint",
        $: {
          prettyPrint: function(js, colors) {
            var cls, css, ret;
            if (Object.IsFunc(js)) js = js.toString();
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
            return ret = "<code class='pp'>" + ($(splitComments(js)).fold(foldTextAndComments).join('')) + "</code>";
          }
        }
      };
    });
  })(Bling);
