
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

  (function($) {
    return $.plugin(function() {
      var create, lazy_load;
      create = function(elementName, props) {
        return Object.Extend(document.createElement(elementName), props);
      };
      lazy_load = function(elementName, props) {
        var depends, n, provides;
        depends = provides = null;
        n = create(elementName, Object.Extend(props, {
          "onload!": function() {
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
              "src!": src
            });
          },
          style: function(src) {
            return lazy_load("link", {
              "href!": src,
              "rel!": "stylesheet"
            });
          }
        }
      };
    });
  })(Bling);
(function(e){return e.plugin(function(){var e,f,d;f={};d=function(a,b){return f[a]=b};e=function(a){return f[a.TYPE]};Object.Type.extend("unknown",{compact:function(a){return Object.String(a)}});Object.Type.extend("string",{compact:function(a){return a}});Object.Type.extend("number",{compact:function(a){return Object.String(a)}});Object.Type.extend("array",{compact:function(a){var b,c,g,h;h=[];c=0;for(g=a.length;c<g;c++)b=a[c],h.push(Object.Compact(b));return h.join("")}});Object.Type.extend("bling",
{compact:function(a){return a.map(Object.Compact).join("")}});Object.Type.extend("undefined",{compact:function(){return""}});Object.Type.extend("null",{compact:function(){return""}});Object.Type.extend("object",{compact:function(a){var b;return Object.Compact(null!=(b=e(a))?b.prune.call(a,a):void 0)}});Object.Compact=function(a){var b;return null!=(b=Object.Type.lookup(a))?b.compact(a):void 0};Object.Extend(Object.Compact,{register:d,lookup:e});d("page",{prune:function(a){return["<!DOCTYPE html><html><head>",
a.HEAD,"</head><body>",a.BODY,"</body></html>"]}});d("text",{prune:function(a){return a.EN}});d("link",{prune:function(a){var b,c,g,h,j;b=["<a"];j=["href","name","target"];g=0;for(h=j.length;g<h;g++)c=j[g],c in a&&Array.Extend(b,[" ",c,"='",a[c],"'"]);Array.Extend(b,[">",a.CONTENT,"</a>"]);return b}});"<!DOCTYPE html><html><head></head><body>Hello World</body></html>"===Object.Compact({TYPE:"page",HEAD:[],BODY:{TYPE:"text",EN:"Hello World"}});return{name:"Compact"}})})(Bling);
(function(e){return e.plugin(function(){var i,f;i=function(d,a){return Object.Extend(document.createElement(d),a)};f=function(d,a){var b,c,g;b=g=null;c=i(d,Object.Extend(a,{"onload!":function(){if(null!=g)return e.publish(g)}}));e("head").delay(10,function(){var a=this;return null!=b?e.subscribe(b,function(){return a.append(c)}):this.append(c)});c=e(c);return Object.Extend(c,{depends:function(a){b=d+"-"+a;return c},provides:function(a){g=d+"-"+a;return c}})};return{name:"LazyLoader",$:{script:function(d){return f("script",
{"src!":d})},style:function(d){return f("link",{"href!":d,"rel!":"stylesheet"})}}}})})(Bling);
(function(e){return e.plugin(function(){var i,f,d,a,b,c,g,h,j,k,q,r,l,m,s,p;q=/!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g;j=/\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g;i=
/\d+\.*\d*/g;f=/\$(\(|\.)/g;p=/\t/g;l=/\/\/.*?(?:\n|$)/;k=/\/\*(?:.|\n)*?\*\//;a=function(a){return a?"<span class='com'>"+a+"</span>":""};r=function(a){return a?"<span class='str'>"+a+"</span>":""};c=function(a,b){var h,c;h=a.indexOf('"',b);c=a.indexOf("'",b);-1===h&&(h=a.length);-1===c&&(c=a.length);return h===c?[null,-1]:h<c?['"',h]:["'",c]};d=function(a,b,h){for(b=a.indexOf(h,b);"\\"===a.charAt(b-1)&&0<b&&b<a.length;)b=a.indexOf(h,b+1);return b};s=function(a){var b,h,g,j,k;b=0;g=a.length;k=[];
if(!Object.IsString(a))if(Object.IsFunction(a.toString))a=a.toString(),g=a.length;else throw TypeError("invalid string argument to split_quoted");for(;b<g;){j=c(a,b);h=j[1];if(-1===h){k.push(a.substring(b));break}k.push(a.substring(b,h));b=d(a,h+1,j[0]);if(-1===b)throw Error("unclosed quote: "+j[0]+" starting at "+h);k.push(a.substring(h,b+1));b+=1}return k};b=function(a){var b;b=a.match(l);a=a.match(k);return b===a?[-1,null]:null===b&&null!==a?[a.index,a[0]]:null!==b&&null===a?[b.index,b[0]]:a.index<
b.index?[a.index,a[0]]:[b.index,b[0]]};m=function(a){var h,c,g,j,k,d;k=[];h=0;for(g=a.length;h<g;)if(d=a.substring(h),j=b(d),c=j[0],-1<c)k.push(d.substring(0,c)),k.push(j[1]),h+=c+j[1].length;else{k.push(d);break}return k};g=function(a,b){return a.replace(q,"<span class='opr'>$&</span>").replace(i,"<span class='num'>$&</span>").replace(j,"<span class='kwd'>$&</span>").replace(f,"<span class='bln'>$$</span>$1").replace(p,"&nbsp;&nbsp;")+r(b)};h=function(b,h){return e(s(b)).fold(g).join("")+a(h)};return{name:"PrettyPrint",
$:{prettyPrint:function(a,b){var c,j;Object.IsFunction(a)&&(a=a.toString());if(!Object.IsString(a))throw TypeError("prettyPrint requires a function or string to format, not '"+Object.Type(a)+"'");if(0===e("style#prettyPrint").length){j="code.pp .bln { font-size: 17px; } ";b=Object.Extend({opr:"#880",str:"#008",com:"#080",kwd:"#088",num:"#808",bln:"#800"},b);for(c in b)j+="code.pp ."+c+" { color: "+b[c]+"; } ";e.synth("style#prettyPrint").text(j).appendTo("head")}return"<code class='pp'>"+e(m(a)).fold(h).join("")+
"</code>"}}}})})(Bling);
(function(){var e=Object.prototype.hasOwnProperty,i=function(f,d){function a(){this.constructor=f}for(var b in d)e.call(d,b)&&(f[b]=d[b]);a.prototype=d.prototype;f.prototype=new a;f.__super__=d.prototype;return f};(function(e){e.plugin(function(){return{name:"StateMachine",$:{StateMachine:function(){function d(a){this.reset();this.table=a;Object.defineProperty(this,"modeline",{get:this.table[this._mode]});Object.defineProperty(this,"mode",{set:function(a){var c;this._lastMode=this._mode;this._mode=
a;if(this._mode!==this._lastMode&&null!=this.modeline&&"enter"in this.modeline)for(c=this.modeline.enter.call(this);Object.IsFunction(c);)c=c.call(this);return a},get:function(){return this._mode}})}d.prototype.reset=function(){return this._lastMode=this._mode=null};d.prototype.GO=function(a){return function(){return this.mode=a}};d.GO=function(a){return function(){return this.mode=a}};d.prototype.run=function(a){var b,c,g,h,j,k;h=this.mode=0;for(j=a.length;h<j;h++){b=a[h];g=this.modeline;null==g?
c=null:b in g?c=g[b]:"def"in g&&(c=g.def);for(;Object.IsFunction(c);)c=c.call(this,b)}if(Object.IsFunction(null!=(k=this.modeline)?k.eof:void 0))c=this.modeline.eof.call(this);for(;Object.IsFunction(c);)c=c.call(this);this.reset();return this};return d}()}}});return e.plugin(function(){var d;d=function(){function a(){a.__super__.constructor.call(this,a.STATE_TABLE);this.fragment=this.parent=document.createDocumentFragment()}i(a,e.StateMachine);a.STATE_TABLE=[{enter:function(){this.tag=this.id=this.cls=
this.attr=this.val=this.text="";this.attrs={};return this.GO(1)}},{'"':a.GO(6),"'":a.GO(7),"#":a.GO(2),".":a.GO(3),"[":a.GO(4)," ":a.GO(9),"+":a.GO(11),",":a.GO(10),def:function(a){return this.tag+=a},eof:a.GO(13)},{".":a.GO(3),"[":a.GO(4)," ":a.GO(9),"+":a.GO(11),",":a.GO(10),def:function(a){return this.id+=a},eof:a.GO(13)},{enter:function(){if(0<this.cls.length)return this.cls+=" "},"#":a.GO(2),".":a.GO(3),"[":a.GO(4)," ":a.GO(9),"+":a.GO(11),",":a.GO(10),def:function(a){return this.cls+=a},eof:a.GO(13)},
{"=":a.GO(5),"]":function(){this.attrs[this.attr]=this.val;return this.GO(1)},def:function(a){return this.attr+=a},eof:a.GO(12)},{"]":function(){this.attrs[this.attr]=this.val;return this.GO(1)},def:function(a){return this.val+=a},eof:a.GO(12)},{'"':a.GO(8),def:function(a){return this.text+=a},eof:a.GO(12)},{"'":a.GO(8),def:function(a){return this.text+=a},eof:a.GO(12)},{enter:function(){this.emitText();return this.GO(0)}},{enter:function(){this.emitNode();return this.GO(0)}},{enter:function(){this.emitNode();
this.parent=null;return this.GO(0)}},{enter:function(){var a;this.emitNode();this.parent=null!=(a=this.parent)?a.parentNode:void 0;return this.GO(0)}},{enter:function(){return e.log("Error in synth expression: "+this.input)}},{enter:function(){this.tag.length&&this.emitNode();if(this.text.length)return this.emitText()}}];a.prototype.emitNode=function(){var a,c;c=document.createElement(this.tag);c.id=this.id||null;c.className=this.cls||null;for(a in this.attrs)c.setAttribute(a,this.attrs[a]);this.parent.appendChild(c);
return this.parent=c};a.prototype.emitText=function(){this.parent.appendChild(e.HTML.parse(this.text));return this.text=""};return a}();return{name:"Synth",$:{synth:function(a){var b;b=new d;b.run(a);return 1===b.fragment.childNodes.length?e(b.fragment.childNodes[0]):e(b.fragment)}}}})})(Bling)}).call(this);
(function(){var e=Object.prototype.hasOwnProperty,i=function(f,d){function a(){this.constructor=f}for(var b in d)e.call(d,b)&&(f[b]=d[b]);a.prototype=d.prototype;f.prototype=new a;f.__super__=d.prototype;return f};(function(e){var d,a;d={};e.plugin(function(){var a,c;a=null;d={};c={register_engine:function(c,h){d[c]=h;if(null==a)return a=c},render:function(c,h){if(a in d)return d[a](c,h)}};c.__defineSetter__("engine",function(c){if(!c in d)throw Error("invalid template engine: "+c+" not one of "+
Object.Keys(d));return a=c});c.__defineGetter__("engine",function(){return a});return{name:"Template",$:{template:c}}});e.template.register_engine("null",function(){return function(a){return a}}());a=function(a,c,g,h,j){var k,d,e;null==j&&(j=-1);k=1;0>j&&(j=a.length+1+j);for(d=h;h<=j?d<j:d>j;h<=j?d++:d--)if(e=a[d],e===g?k+=1:e===c&&(k-=1),0===k)return d;return-1};e.template.register_engine("pythonic",function(){var b,c,g;g=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;b=/%[\(\/]/;c=
function(h){var c,k,d,e,l,m,f,h=h.split(b);l=h.length;f=[h[0]];for(k=d=1;1<=l?k<l:k>l;1<=l?k++:k--){c=a(h[k],")","(",0,-1);if(-1===c)return"Template syntax error: unmatched '%(' starting at: "+h[k].substring(0,15);e=h[k].substring(0,c);m=h[k].substring(c);c=g.exec(m);if(null===c)return"Template syntax error: invalid type specifier starting at '"+m+"'";m=c[4];f[d++]=e;f[d++]=c[1]|0;f[d++]=c[2]|0;f[d++]=c[3];f[d++]=m}return f};c.cache={};return function(a,b){var g,d,e,f,m,i,p,n,t,o,u;g=c.cache[a];null==
g&&(g=c.cache[a]=c(a));i=[g[0]];f=1;d=g.length;e=1;for(u=d-5;e<=u;e+=5){n=g.slice(e,e+4+1||9E9);m=n[0];p=n[1];d=n[2];t=n[3];n=n[4];o=b[m];null==o&&(o="missing value: "+m);switch(t){case "d":i[f++]=""+parseInt(o,10);break;case "f":i[f++]=parseFloat(o).toFixed(d);break;case "s":i[f++]=""+o;break;default:i[f++]=""+o}0<p&&(i[f]=String.PadLeft(i[f],p));i[f++]=n}return i.join("")}}());return e.template.register_engine("js-eval",function(){(function(){function a(){a.__super__.constructor.apply(this,arguments)}
i(a,e.StateMachine);a.STATE_TABLE=[{enter:function(){this.data=[];return this.GO(1)}},{}];return a})();return function(a){return a}}())})(Bling)}).call(this);
(function(e){return e.plugin(function(){var i,f,d;d=function(a){var b,c,g,h;b=a.indexOf(":");if(0<b)return g=parseInt(a.slice(0,b),10),c=a.slice(b+1,b+1+g),h=a[b+1+g],a=a.slice(b+g+2),c=function(){switch(h){case "#":return Number(c);case "'":return""+c;case "!":return"true"===c;case "~":return null;case "]":return i(c);case "}":return f(c)}}(),[c,a]};i=function(a){var b,c;for(b=[];0<a.length;)a=d(a),c=a[0],a=a[1],b.push(c);return b};f=function(a){var b,c,g;for(b={};0<a.length;)g=d(a),c=g[0],a=g[1],
a=d(a),g=a[0],a=a[1],b[c]=g;return b};return{name:"TNET",$:{TNET:{stringify:function(a){var b,c,g;g=function(){switch(Object.Type(a)){case "number":return[""+a,"#"];case "string":return[a,"'"];case "function":return[""+a,"'"];case "boolean":return[""+!!a,"!"];case "null":return["","~"];case "undefined":return["","~"];case "array":return[function(){var b,g,d;d=[];b=0;for(g=a.length;b<g;b++)c=a[b],d.push(e.TNET.stringify(c));return d}().join(""),"]"];case "object":return[function(){var b;b=[];for(c in a)b.push(e.TNET.stringify(c)+
e.TNET.stringify(a[c]));return b}().join(""),"}"]}}();b=g[0];return(b.length|0)+":"+b+g[1]},parse:function(a){var b;return null!=(b=d(a))?b[0]:void 0}}}}})})(Bling);
(function(e){return e.plugin(function(){var i,f,d,a,b,c;f=function(a,b){var c,b=Object.Extend({autoOpen:!1,draggable:!0},b);c=e(a).addClass("dialog");b.draggable&&c.draggable();b.autoOpen&&c.show().center();c.find("button.close, .close-button").bind("click touchstart",function(){c.hide();return!1});return c};d=function(a,b){var c,d,f,i,l,b=Object.Extend({handleCSS:{}},b);b.handleCSS=Object.Extend({position:"absolute",top:"0px",left:"0px",width:"100%",height:"6px"},b.handleCSS);c=e(a);f=!1;i=l=0;d=
e.synth("div.handle").defaultCss({background:"-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",height:"6px","border-radius":"3px",cursor:"move"}.css(b.handleCSS.bind("mousedown, touchstart",function(a){f=!0;i||(i=a.pageX);l||(l=a.pageY);return!1})));e(document.bind("mousemove, touchmove",function(a){var b;if(f)return b=a.pageX-i,a=a.pageY-l,c.transform({translate:[b,a]},0).trigger("drag",{dragObject:c}),!1})).bind("mouseup, touchend",
function(){var a;if(f)return f=!1,a=d.position()[0],e(document.elementFromPoint(a.left,a.top-1).trigger("drop",{dropObject:c}))});return c.addClass("draggable").css({position:"relative","padding-top":c.css("padding-top").map(Number.AtLeast(parseInt(b.handleCSS.height,10))).px().first()}.append(d))};a=function(a,b){var c,d,f,i,b=Object.Extend({change:Function.Empty,backgroundColor:"#fff",barColor:"rgba(0,128,0,0.5)",textColor:"white",reset:!1},b);c=e(a).addClass("progress-bar");i=0;b.reset&&(d=c.css("background").first(),
f=c.css("color").first());return c.zap("updateProgress",function(a){for(;a>1;)a=a/100;i=a;a===1&&b.reset?c.css("background",d).css("color",f):c.css({background:"-webkit-gradient(linear, 0 0, "+parseInt(a*100)+"% 0, color-stop(0, "+b.barColor+"), color-stop(0.98, "+b.barColor+"), color-stop(1.0, "+b.backgroundColor+"))",color:b.textColor});if(Object.IsFunc(b.change))return b.change(i)})};i=function(a,b){var c,d,b=Object.Extend({exclusive:!1,sticky:!1},b);d=e(a).addClass("accordion");c=function(a){var c,
g,f,a=e(a).children().first().filter("*");if(2!==a.len())throw Exception("accordion row requires 2 elements, not "+a.len());f=a.eq(0).addClass("title");c=a.eq(1).addClass("body").hide();g=!1;return f.click(function(){b.exclusive&&d.find(".body").hide();if(g){if(b.sticky)return c.show().addClass("visible"),f.addClass("selected").trigger("select"),g=!0;c.hide().removeClass("visible");f.removeClass("selected").trigger("deselect");return g=!1}c.show().addClass("visible");f.addClass("selected").trigger("select");
return g=!0})};d.bind("DOMNodeInserted",function(a){var b;b=d.children().first().filter("*");a=e(a.target).parents().first();return c(a.intersect(b))});d.children().first().filter("*").map(c);return d};c=function(a){var b,c,d;c=e(a).css({position:"relative",top:"0px",left:"0px"}.hide().map(e));b=0;c[b].show();c.next=function(){c[b].hide();b=++b%nn;return c[b].show()};c.activate=function(a){c[b].hide();b=a;return c[a].show()};a=0;for(d=c.len();0<=d?a<d:a>d;0<=d?a++:a--)c[a].zap("_viewIndex",a.zap("activate",
function(){return c.activate(this._viewIndex)}));return c};b=function(a,b){var c,d,f;f=e(a);b=e(b).viewStack();d=f.len();for(c=0;0<=d?c<=d:c>=d;0<=d?c++:c--)f._tabIndex=c;e(f[0]).addClass("active");return f.click(function(){f.removeClass("active");b.activate(this._tabIndex);return e(this).addClass("active")})};return{name:"UI",$:{UI:{Draggable:d,ProgressBar:a,ViewStack:c,Tabs:b,Accordion:i}},dialog:function(a){return f(this,a)},progressBar:function(b){return a(this,b)},viewStack:function(a){return c(this,
a)},tabs:function(a){return b(this,a)},accordion:function(a){return i(this,a)},draggable:function(a){return d(this,a)}}})})(Bling);
(function(i){return i.plugin(function(){var g,h,c;h={};c=function(a,b){return h[a]=b};g=function(a){return h[a.TYPE]};Object.Type.extend("unknown",{compact:function(a){return Object.String(a)}});Object.Type.extend("string",{compact:function(a){return a}});Object.Type.extend("number",{compact:function(a){return Object.String(a)}});Object.Type.extend("array",{compact:function(a){var b,d,e,f;f=[];d=0;for(e=a.length;d<e;d++)b=a[d],f.push(Object.Compact(b));return f.join("")}});Object.Type.extend("bling",
{compact:function(a){return a.map(Object.Compact).join("")}});Object.Type.extend("undefined",{compact:function(){return""}});Object.Type.extend("null",{compact:function(){return""}});Object.Type.extend("object",{compact:function(a){var b;return Object.Compact(null!=(b=g(a))?b.prune.call(a,a):void 0)}});Object.Compact=function(a){var b;return null!=(b=Object.Type.lookup(a))?b.compact(a):void 0};Object.Extend(Object.Compact,{register:c,lookup:g});c("page",{prune:function(a){return["<!DOCTYPE html><html><head>",
a.HEAD,"</head><body>",a.BODY,"</body></html>"]}});c("text",{prune:function(a){return a.EN}});c("link",{prune:function(a){var b,d,e,f,c;b=["<a"];c=["href","name","target"];e=0;for(f=c.length;e<f;e++)d=c[e],d in a&&Array.Extend(b,[" ",d,"='",a[d],"'"]);Array.Extend(b,[">",a.CONTENT,"</a>"]);return b}});"<!DOCTYPE html><html><head></head><body>Hello World</body></html>"===Object.Compact({TYPE:"page",HEAD:[],BODY:{TYPE:"text",EN:"Hello World"}});return{name:"Compact"}})})(Bling);
(function(f){return f.plugin(function(){var h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w;r=/!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g;p=/\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g;
h=/\d+\.*\d*/g;i=/\$(\(|\.)/g;w=/\t/g;t=/\/\/.*?(?:\n|$)/;q=/\/\*(?:.|\n)*?\*\//;k=function(a){return a?"<span class='com'>"+a+"</span>":""};s=function(a){return a?"<span class='str'>"+a+"</span>":""};m=function(a,b){var c,d;c=a.indexOf('"',b);d=a.indexOf("'",b);-1===c&&(c=a.length);-1===d&&(d=a.length);return c===d?[null,-1]:c<d?['"',c]:["'",d]};j=function(a,b,c){for(b=a.indexOf(c,b);"\\"===a.charAt(b-1)&&0<b&&b<a.length;)b=a.indexOf(c,b+1);return b};v=function(a){var b,c,d,g,e;b=0;d=a.length;e=
[];if(!Object.IsString(a))if(Object.IsFunction(a.toString))a=a.toString(),d=a.length;else throw TypeError("invalid string argument to split_quoted");for(;b<d;){g=m(a,b);c=g[1];if(-1===c){e.push(a.substring(b));break}e.push(a.substring(b,c));b=j(a,c+1,g[0]);if(-1===b)throw Error("unclosed quote: "+g[0]+" starting at "+c);e.push(a.substring(c,b+1));b+=1}return e};l=function(a){var b;b=a.match(t);a=a.match(q);return b===a?[-1,null]:null===b&&null!==a?[a.index,a[0]]:null!==b&&null===a?[b.index,b[0]]:
a.index<b.index?[a.index,a[0]]:[b.index,b[0]]};u=function(a){var b,c,d,g,e,f;e=[];b=0;for(d=a.length;b<d;)if(f=a.substring(b),g=l(f),c=g[0],-1<c)e.push(f.substring(0,c)),e.push(g[1]),b+=c+g[1].length;else{e.push(f);break}return e};n=function(a,b){return a.replace(r,"<span class='opr'>$&</span>").replace(h,"<span class='num'>$&</span>").replace(p,"<span class='kwd'>$&</span>").replace(i,"<span class='bln'>$$</span>$1").replace(w,"&nbsp;&nbsp;")+s(b)};o=function(a,b){return f(v(a)).fold(n).join("")+
k(b)};return{name:"PrettyPrint",$:{prettyPrint:function(a,b){var c,d;Object.IsFunction(a)&&(a=a.toString());if(!Object.IsString(a))throw TypeError("prettyPrint requires a function or string to format, not '"+Object.Type(a)+"'");if(0===f("style#prettyPrint").length){d="code.pp .bln { font-size: 17px; } ";b=Object.Extend({opr:"#880",str:"#008",com:"#080",kwd:"#088",num:"#808",bln:"#800"},b);for(c in b)d+="code.pp ."+c+" { color: "+b[c]+"; } ";f.synth("style#prettyPrint").text(d).appendTo("head")}return"<code class='pp'>"+
f(u(a)).fold(o).join("")+"</code>"}}}})})(Bling);
(function(){var h=Object.prototype.hasOwnProperty,i=function(d,c){function a(){this.constructor=d}for(var e in c)h.call(c,e)&&(d[e]=c[e]);a.prototype=c.prototype;d.prototype=new a;d.__super__=c.prototype;return d};(function(d){d.plugin(function(){return{name:"StateMachine",$:{StateMachine:function(){function c(a){this.reset();this.table=a;Object.defineProperty(this,"modeline",{get:this.table[this._mode]});Object.defineProperty(this,"mode",{set:function(a){var b;this._lastMode=this._mode;this._mode=
a;if(this._mode!==this._lastMode&&null!=this.modeline&&"enter"in this.modeline)for(b=this.modeline.enter.call(this);Object.IsFunction(b);)b=b.call(this);return a},get:function(){return this._mode}})}c.prototype.reset=function(){return this._lastMode=this._mode=null};c.prototype.GO=function(a){return function(){return this.mode=a}};c.GO=function(a){return function(){return this.mode=a}};c.prototype.run=function(a){var e,b,c,d,f,g;d=this.mode=0;for(f=a.length;d<f;d++){e=a[d];c=this.modeline;null==c?
b=null:e in c?b=c[e]:"def"in c&&(b=c.def);for(;Object.IsFunction(b);)b=b.call(this,e)}if(Object.IsFunction(null!=(g=this.modeline)?g.eof:void 0))b=this.modeline.eof.call(this);for(;Object.IsFunction(b);)b=b.call(this);this.reset();return this};return c}()}}});return d.plugin(function(){var c;c=function(){function a(){a.__super__.constructor.call(this,a.STATE_TABLE);this.fragment=this.parent=document.createDocumentFragment()}i(a,d.StateMachine);a.STATE_TABLE=[{enter:function(){this.tag=this.id=this.cls=
this.attr=this.val=this.text="";this.attrs={};return this.GO(1)}},{'"':a.GO(6),"'":a.GO(7),"#":a.GO(2),".":a.GO(3),"[":a.GO(4)," ":a.GO(9),"+":a.GO(11),",":a.GO(10),def:function(a){return this.tag+=a},eof:a.GO(13)},{".":a.GO(3),"[":a.GO(4)," ":a.GO(9),"+":a.GO(11),",":a.GO(10),def:function(a){return this.id+=a},eof:a.GO(13)},{enter:function(){if(0<this.cls.length)return this.cls+=" "},"#":a.GO(2),".":a.GO(3),"[":a.GO(4)," ":a.GO(9),"+":a.GO(11),",":a.GO(10),def:function(a){return this.cls+=a},eof:a.GO(13)},
{"=":a.GO(5),"]":function(){this.attrs[this.attr]=this.val;return this.GO(1)},def:function(a){return this.attr+=a},eof:a.GO(12)},{"]":function(){this.attrs[this.attr]=this.val;return this.GO(1)},def:function(a){return this.val+=a},eof:a.GO(12)},{'"':a.GO(8),def:function(a){return this.text+=a},eof:a.GO(12)},{"'":a.GO(8),def:function(a){return this.text+=a},eof:a.GO(12)},{enter:function(){this.emitText();return this.GO(0)}},{enter:function(){this.emitNode();return this.GO(0)}},{enter:function(){this.emitNode();
this.parent=null;return this.GO(0)}},{enter:function(){var a;this.emitNode();this.parent=null!=(a=this.parent)?a.parentNode:void 0;return this.GO(0)}},{enter:function(){return d.log("Error in synth expression: "+this.input)}},{enter:function(){this.tag.length&&this.emitNode();if(this.text.length)return this.emitText()}}];a.prototype.emitNode=function(){var a,b;b=document.createElement(this.tag);b.id=this.id||null;b.className=this.cls||null;for(a in this.attrs)b.setAttribute(a,this.attrs[a]);this.parent.appendChild(b);
return this.parent=b};a.prototype.emitText=function(){this.parent.appendChild(d.HTML.parse(this.text));return this.text=""};return a}();return{name:"Synth",$:{synth:function(a){var e;e=new c;e.run(a);return 1===e.fragment.childNodes.length?d(e.fragment.childNodes[0]):d(e.fragment)}}}})})(Bling)}).call(this);
(function(){var r=Object.prototype.hasOwnProperty,s=function(b,a){function j(){this.constructor=b}for(var c in a)r.call(a,c)&&(b[c]=a[c]);j.prototype=a.prototype;b.prototype=new j;b.__super__=a.prototype;return b};(function(b){var a,j;a={};b.plugin(function(){var c,o;c=null;a={};o={register_engine:function(g,l){a[g]=l;if(null==c)return c=g},render:function(g,l){if(c in a)return a[c](g,l)}};o.__defineSetter__("engine",function(g){if(!g in a)throw Error("invalid template engine: "+g+" not one of "+
Object.Keys(a));return c=g});o.__defineGetter__("engine",function(){return c});return{name:"Template",$:{template:o}}});b.template.register_engine("null",function(){return function(c){return c}}());j=function(c,a,g,l,e){var d,f,n;null==e&&(e=-1);d=1;0>e&&(e=c.length+1+e);for(f=l;l<=e?f<e:f>e;l<=e?f++:f--)if(n=c[f],n===g?d+=1:n===a&&(d-=1),0===d)return f;return-1};b.template.register_engine("pythonic",function(){var c,a,g;g=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;c=/%[\(\/]/;a=
function(a){var e,d,f,n,i,b,h,a=a.split(c);i=a.length;h=[a[0]];for(d=f=1;1<=i?d<i:d>i;1<=i?d++:d--){e=j(a[d],")","(",0,-1);if(-1===e)return"Template syntax error: unmatched '%(' starting at: "+a[d].substring(0,15);n=a[d].substring(0,e);b=a[d].substring(e);e=g.exec(b);if(null===e)return"Template syntax error: invalid type specifier starting at '"+b+"'";b=e[4];h[f++]=n;h[f++]=e[1]|0;h[f++]=e[2]|0;h[f++]=e[3];h[f++]=b}return h};a.cache={};return function(c,e){var d,f,b,i,g,h,j,k,p,m,q;d=a.cache[c];null==
d&&(d=a.cache[c]=a(c));h=[d[0]];i=1;f=d.length;b=1;for(q=f-5;b<=q;b+=5){k=d.slice(b,b+4+1||9E9);g=k[0];j=k[1];f=k[2];p=k[3];k=k[4];m=e[g];null==m&&(m="missing value: "+g);switch(p){case "d":h[i++]=""+parseInt(m,10);break;case "f":h[i++]=parseFloat(m).toFixed(f);break;case "s":h[i++]=""+m;break;default:h[i++]=""+m}0<j&&(h[i]=String.PadLeft(h[i],j));h[i++]=k}return h.join("")}}());return b.template.register_engine("js-eval",function(){(function(){function a(){a.__super__.constructor.apply(this,arguments)}
s(a,b.StateMachine);a.STATE_TABLE=[{enter:function(){this.data=[];return this.GO(1)}},{}];return a})();return function(a){return a}}())})(Bling)}).call(this);
(function(f){return f.plugin(function(){var g,h,e;e=function(a){var b,c,d,i;b=a.indexOf(":");if(0<b)return d=parseInt(a.slice(0,b),10),c=a.slice(b+1,b+1+d),i=a[b+1+d],a=a.slice(b+d+2),c=function(){switch(i){case "#":return Number(c);case "'":return""+c;case "!":return"true"===c;case "~":return null;case "]":return g(c);case "}":return h(c)}}(),[c,a]};g=function(a){var b,c;for(b=[];0<a.length;)a=e(a),c=a[0],a=a[1],b.push(c);return b};h=function(a){var b,c,d;for(b={};0<a.length;)d=e(a),c=d[0],a=d[1],
a=e(a),d=a[0],a=a[1],b[c]=d;return b};return{name:"TNET",$:{TNET:{stringify:function(a){var b,c,d;d=function(){switch(Object.Type(a)){case "number":return[""+a,"#"];case "string":return[a,"'"];case "function":return[""+a,"'"];case "boolean":return[""+!!a,"!"];case "null":return["","~"];case "undefined":return["","~"];case "array":return[function(){var b,d,e;e=[];b=0;for(d=a.length;b<d;b++)c=a[b],e.push(f.TNET.stringify(c));return e}().join(""),"]"];case "object":return[function(){var b;b=[];for(c in a)b.push(f.TNET.stringify(c)+
f.TNET.stringify(a[c]));return b}().join(""),"}"]}}();b=d[0];return(b.length|0)+":"+b+d[1]},parse:function(a){var b;return null!=(b=e(a))?b[0]:void 0}}}}})})(Bling);
(function(e){return e.plugin(function(){var j,o,k,l,m,n;o=function(c,b){var a,b=Object.Extend({autoOpen:!1,draggable:!0},b);a=e(c).addClass("dialog");b.draggable&&a.draggable();b.autoOpen&&a.show().center();a.find("button.close, .close-button").bind("click touchstart",function(){a.hide();return!1});return a};k=function(c,b){var a,d,f,h,g,b=Object.Extend({handleCSS:{}},b);b.handleCSS=Object.Extend({position:"absolute",top:"0px",left:"0px",width:"100%",height:"6px"},b.handleCSS);a=e(c);f=!1;h=g=0;d=
e.synth("div.handle").defaultCss({background:"-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",height:"6px","border-radius":"3px",cursor:"move"}.css(b.handleCSS.bind("mousedown, touchstart",function(a){f=!0;h||(h=a.pageX);g||(g=a.pageY);return!1})));e(document.bind("mousemove, touchmove",function(b){var c;if(f)return c=b.pageX-h,b=b.pageY-g,a.transform({translate:[c,b]},0).trigger("drag",{dragObject:a}),!1})).bind("mouseup, touchend",
function(){var b;if(f)return f=!1,b=d.position()[0],e(document.elementFromPoint(b.left,b.top-1).trigger("drop",{dropObject:a}))});return a.addClass("draggable").css({position:"relative","padding-top":a.css("padding-top").map(Number.AtLeast(parseInt(b.handleCSS.height,10))).px().first()}.append(d))};l=function(c,b){var a,d,f,h,b=Object.Extend({change:Function.Empty,backgroundColor:"#fff",barColor:"rgba(0,128,0,0.5)",textColor:"white",reset:!1},b);a=e(c).addClass("progress-bar");h=0;b.reset&&(d=a.css("background").first(),
f=a.css("color").first());return a.zap("updateProgress",function(c){for(;c>1;)c=c/100;h=c;c===1&&b.reset?a.css("background",d).css("color",f):a.css({background:"-webkit-gradient(linear, 0 0, "+parseInt(c*100)+"% 0, color-stop(0, "+b.barColor+"), color-stop(0.98, "+b.barColor+"), color-stop(1.0, "+b.backgroundColor+"))",color:b.textColor});if(Object.IsFunc(b.change))return b.change(h)})};j=function(c,b){var a,d,b=Object.Extend({exclusive:!1,sticky:!1},b);d=e(c).addClass("accordion");a=function(a){var c,
g,i,a=e(a).children().first().filter("*");if(2!==a.len())throw Exception("accordion row requires 2 elements, not "+a.len());i=a.eq(0).addClass("title");c=a.eq(1).addClass("body").hide();g=!1;return i.click(function(){b.exclusive&&d.find(".body").hide();if(g){if(b.sticky)return c.show().addClass("visible"),i.addClass("selected").trigger("select"),g=!0;c.hide().removeClass("visible");i.removeClass("selected").trigger("deselect");return g=!1}c.show().addClass("visible");i.addClass("selected").trigger("select");
return g=!0})};d.bind("DOMNodeInserted",function(b){var c;c=d.children().first().filter("*");b=e(b.target).parents().first();return a(b.intersect(c))});d.children().first().filter("*").map(a);return d};n=function(c){var b,a,d;a=e(c).css({position:"relative",top:"0px",left:"0px"}.hide().map(e));b=0;a[b].show();a.next=function(){a[b].hide();b=++b%nn;return a[b].show()};a.activate=function(c){a[b].hide();b=c;return a[c].show()};c=0;for(d=a.len();0<=d?c<d:c>d;0<=d?c++:c--)a[c].zap("_viewIndex",c.zap("activate",
function(){return a.activate(this._viewIndex)}));return a};m=function(c,b){var a,d,f;f=e(c);b=e(b).viewStack();d=f.len();for(a=0;0<=d?a<=d:a>=d;0<=d?a++:a--)f._tabIndex=a;e(f[0]).addClass("active");return f.click(function(){f.removeClass("active");b.activate(this._tabIndex);return e(this).addClass("active")})};return{name:"UI",$:{UI:{Draggable:k,ProgressBar:l,ViewStack:n,Tabs:m,Accordion:j}},dialog:function(c){return o(this,c)},progressBar:function(c){return l(this,c)},viewStack:function(c){return n(this,
c)},tabs:function(c){return m(this,c)},accordion:function(c){return j(this,c)},draggable:function(c){return k(this,c)}}})})(Bling);

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
          if (!Object.IsFunction(s.toString)) {
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
            if (Object.IsFunction(js)) js = js.toString();
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
(function() {
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  (function($) {
    var engines, match_forward;
    engines = {};
    $.plugin(function() {
      var current_engine, template;
      current_engine = null;
      engines = {};
      template = {
        register_engine: function(name, render_func) {
          engines[name] = render_func;
          if (!(current_engine != null)) return current_engine = name;
        },
        render: function(text, args) {
          if (current_engine in engines) {
            return engines[current_engine](text, args);
          }
        }
      };
      template.__defineSetter__('engine', function(v) {
        if (!v in engines) {
          throw new Error("invalid template engine: " + v + " not one of " + (Object.Keys(engines)));
        } else {
          return current_engine = v;
        }
      });
      template.__defineGetter__('engine', function() {
        return current_engine;
      });
      return {
        name: 'Template',
        $: {
          template: template
        }
      };
    });
    $.template.register_engine('null', (function() {
      return function(text, values) {
        return text;
      };
    })());
    match_forward = function(text, find, against, start, stop) {
      var count, i, t;
      if (stop == null) stop = -1;
      count = 1;
      if (stop < 0) stop = text.length + 1 + stop;
      for (i = start; start <= stop ? i < stop : i > stop; start <= stop ? i++ : i--) {
        t = text[i];
        if (t === against) {
          count += 1;
        } else if (t === find) {
          count -= 1;
        }
        if (count === 0) return i;
      }
      return -1;
    };
    $.template.register_engine('pythonic', (function() {
      var chunk_re, compile, render, type_re;
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
        var cache, fixed, i, j, key, n, output, pad, rest, type, value, _ref, _ref2;
        cache = compile.cache[text];
        if (!(cache != null)) cache = compile.cache[text] = compile(text);
        output = [cache[0]];
        j = 1;
        n = cache.length;
        for (i = 1, _ref = n - 5; i <= _ref; i += 5) {
          _ref2 = cache.slice(i, (i + 4) + 1 || 9e9), key = _ref2[0], pad = _ref2[1], fixed = _ref2[2], type = _ref2[3], rest = _ref2[4];
          value = values[key];
          if (!(value != null)) value = "missing value: " + key;
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
          if (pad > 0) output[j] = String.PadLeft(output[j], pad);
          output[j++] = rest;
        }
        return output.join("");
      };
      return render;
    })());
    return $.template.register_engine('js-eval', (function() {
      var TemplateMachine;
      TemplateMachine = (function() {

        __extends(TemplateMachine, $.StateMachine);

        function TemplateMachine() {
          TemplateMachine.__super__.constructor.apply(this, arguments);
        }

        TemplateMachine.STATE_TABLE = [
          {
            enter: function() {
              this.data = [];
              return this.GO(1);
            }
          }, {}
        ];

        return TemplateMachine;

      })();
      return function(text, values) {
        return text;
      };
    })());
  })(Bling);

}).call(this);

  (function($) {
    return $.plugin(function() {
      var parseArray, parseObject, parseOne;
      parseOne = function(data) {
        var extra, i, item, len, type;
        i = data.indexOf(":");
        if (i > 0) {
          len = parseInt(data.slice(0, i), 10);
          item = data.slice(i + 1, (i + 1 + len));
          type = data[i + 1 + len];
          extra = data.slice(i + len + 2);
          item = (function() {
            switch (type) {
              case "#":
                return Number(item);
              case "'":
                return String(item);
              case "!":
                return item === "true";
              case "~":
                return null;
              case "]":
                return parseArray(item);
              case "}":
                return parseObject(item);
            }
          })();
          return [item, extra];
        }
      };
      parseArray = function(x) {
        var data, one, _ref;
        data = [];
        while (x.length > 0) {
          _ref = parseOne(x), one = _ref[0], x = _ref[1];
          data.push(one);
        }
        return data;
      };
      parseObject = function(x) {
        var data, key, value, _ref, _ref2;
        data = {};
        while (x.length > 0) {
          _ref = parseOne(x), key = _ref[0], x = _ref[1];
          _ref2 = parseOne(x), value = _ref2[0], x = _ref2[1];
          data[key] = value;
        }
        return data;
      };
      return {
        name: 'TNET',
        $: {
          TNET: {
            stringify: function(x) {
              var data, type, y, _ref;
              _ref = (function() {
                switch (Object.Type(x)) {
                  case "number":
                    return [String(x), "#"];
                  case "string":
                    return [x, "'"];
                  case "function":
                    return [String(x), "'"];
                  case "boolean":
                    return [String(!!x), "!"];
                  case "null":
                    return ["", "~"];
                  case "undefined":
                    return ["", "~"];
                  case "array":
                    return [
                      ((function() {
                        var _i, _len, _results;
                        _results = [];
                        for (_i = 0, _len = x.length; _i < _len; _i++) {
                          y = x[_i];
                          _results.push($.TNET.stringify(y));
                        }
                        return _results;
                      })()).join(''), "]"
                    ];
                  case "object":
                    return [
                      ((function() {
                        var _results;
                        _results = [];
                        for (y in x) {
                          _results.push($.TNET.stringify(y) + $.TNET.stringify(x[y]));
                        }
                        return _results;
                      })()).join(''), "}"
                    ];
                }
              })(), data = _ref[0], type = _ref[1];
              return (data.length | 0) + ":" + data + type;
            },
            parse: function(x) {
              var _ref;
              return (_ref = parseOne(x)) != null ? _ref[0] : void 0;
            }
          }
        }
      };
    });
  })(Bling);

  (function($) {
    return $.plugin(function() {
      var Accordion, Dialog, Draggable, ProgressBar, Tabs, ViewStack;
      Dialog = function(selector, opts) {
        var dialog;
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
      };
      Draggable = function(selector, opts) {
        var dragObject, handle, moving, oX, oY;
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
      };
      ProgressBar = function(selector, opts) {
        var node, _bg, _color, _progress;
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
      };
      Accordion = function(selector, opts) {
        var initRow, node, selectedChild;
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
      };
      ViewStack = function(selector, opts) {
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
      };
      Tabs = function(selector, views) {
        var i, nn, tabs;
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
      };
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
