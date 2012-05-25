
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
(function(a){return a.plugin(function(){var d,e,c,b;e={};c=function(g,h){return e[g]=h};d=function(g){return e[obj.t]};b=[];Object.Type.extend(null,{compact:function(f){return Object.String(f)}});Object.Type.extend("undefined",{compact:function(f){return""}});Object.Type.extend("null",{compact:function(f){return""}});Object.Type.extend("string",{compact:Function.Identity});Object.Type.extend("array",{compact:function(g){var f;return((function(){var j,i,h;h=[];for(j=0,i=g.length;j<i;j++){f=g[j];h.push(Object.Compact(f))}return h})()).join("")}});Object.Type.extend("bling",{compact:function(f){return f.map(Object.Compact).join("")}});Object.Type.extend("object",{compact:function(g){var f;return Object.Compact((f=d(g))!=null?f.call(g,g):void 0)}});Object.Compact=function(g){var f;b.push(g);if((f=Object.Type.lookup(g))!=null){f.compact(g)}return b.pop()};Object.Extend(Object.Compact,{register:c,lookup:d});c("page",function(){return["<!DOCTYPE html><html><head>",this.head,"</head><body>",this.body,"</body></html>"]});c("text",function(){return this.EN});c("link",function(){var g,h,j,f,i;g=a(["<a"]);i=["href","name","target"];for(j=0,f=i.length;j<f;j++){h=i[j];if(h in this){g.extend(" ",h,"='",this[h],"'")}}return g.extend(">",node.content,"</a>")});a.assert(Object.Compact({t:"page",head:[],body:{type:"text",EN:"Hello World"}})==="<!DOCTYPE html><html><head></head><body>Hello World</body></html>");return{name:"Compact"}})})(Bling);(function(a){return a.plugin(function(){var b,c;b=function(d,e){return Object.Extend(document.createElement(d),e)};c=function(d,e){var g,h,f;g=f=null;h=b(d,Object.Extend(e,{"onload!":function(){if(f!=null){return a.publish(f)}}}));a("head").delay(10,function(){var i=this;if(g!=null){return a.subscribe(g,function(){return i.append(h)})}else{return this.append(h)}});h=a(h);return Object.Extend(h,{depends:function(i){g=d+"-"+i;return h},provides:function(i){f=d+"-"+i;return h}})};return{name:"LazyLoader",$:{script:function(d){return c("script",{"src!":d})},style:function(d){return c("link",{"href!":d,"rel!":"stylesheet"})}}}})})(Bling);(function(a){return a.plugin(function(){var v,k,l,m,n,f,o,b,c,e,h,p,s,g,q,r,i,u,d,j,t;q=/!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g;g="<span class='opr'>$&</span>";h=/\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g;e="<span class='kwd'>$&</span>";v=/\d+\.*\d*/g;s="<span class='num'>$&</span>";l=/\$(\(|\.)/g;k="<span class='bln'>$$</span>$1";t=/\t/g;j="&nbsp;&nbsp;";i=/\/\/.*?(?:\n|$)/;p=/\/\*(?:.|\n)*?\*\//;n=function(w){if(w){return"<span class='com'>"+w+"</span>"}else{return""}};r=function(w){if(w){return"<span class='str'>"+w+"</span>"}else{return""}};o=function(z,y){var x,w;x=z.indexOf('"',y);w=z.indexOf("'",y);if(x===-1){x=z.length}if(w===-1){w=z.length}if(x===w){return[null,-1]}if(x<w){return['"',x]}return["'",w]};m=function(x,w,z){var y;y=x.indexOf(z,w);while(x.charAt(y-1)==="\\"&&(0<y&&y<x.length)){y=x.indexOf(z,y+1)}return y};d=function(A){var z,y,w,C,B,x;z=0;C=A.length;x=[];if(!Object.IsString(A)){if(!Object.IsFunction(A.toString)){throw TypeError("invalid string argument to split_quoted")}else{A=A.toString();C=A.length}}while(z<C){B=o(A,z);y=B[1];if(y===-1){x.push(A.substring(z));break}x.push(A.substring(z,y));w=m(A,y+1,B[0]);if(w===-1){throw Error("unclosed quote: "+B[0]+" starting at "+y)}x.push(A.substring(y,w+1));z=w+1}return x};f=function(y){var x,w;x=y.match(i);w=y.match(p);if(x===w){return[-1,null]}if(x===null&&w!==null){return[w.index,w[0]]}if(x!==null&&w===null){return[x.index,x[0]]}if(w.index<x.index){return[w.index,w[0]]}return[x.index,x[0]]};u=function(A){var z,x,C,B,w,y;w=[];z=0;C=A.length;while(z<C){y=A.substring(z);B=f(y);x=B[0];if(x>-1){w.push(y.substring(0,x));w.push(B[1]);z+=x+B[1].length}else{w.push(y);break}}return w};b=function(x,w){return x.replace(q,g).replace(v,s).replace(h,e).replace(l,k).replace(t,j)+r(w)};c=function(w,x){return a(d(w)).fold(b).join("")+n(x)};return{name:"PrettyPrint",$:{prettyPrint:function(A,x){var w,z,y;if(Object.IsFunction(A)){A=A.toString()}if(!Object.IsString(A)){throw TypeError("prettyPrint requires a function or string to format, not '"+Object.Type(A)+"'")}if(a("style#prettyPrint").length===0){z="code.pp .bln { font-size: 17px; } ";x=Object.Extend({opr:"#880",str:"#008",com:"#080",kwd:"#088",num:"#808",bln:"#800"},x);for(w in x){z+="code.pp ."+w+" { color: "+x[w]+"; } "}a.synth("style#prettyPrint").text(z).appendTo("head")}return y="<code class='pp'>"+(a(u(A)).fold(c).join(""))+"</code>"}}}})})(Bling);(function(){var a=Object.prototype.hasOwnProperty,b=function(f,d){for(var c in d){if(a.call(d,c)){f[c]=d[c]}}function e(){this.constructor=f}e.prototype=d.prototype;f.prototype=new e;f.__super__=d.prototype;return f};(function(c){c.plugin(function(){var d;d=(function(){function e(f){this.reset();this.table=f;Object.defineProperty(this,"modeline",{get:this.table[this._mode]});Object.defineProperty(this,"mode",{set:function(g){var h;this._lastMode=this._mode;this._mode=g;if(this._mode!==this._lastMode&&(this.modeline!=null)&&"enter" in this.modeline){h=this.modeline.enter.call(this);while(Object.IsFunction(h)){h=h.call(this)}}return g},get:function(){return this._mode}})}e.prototype.reset=function(){this._mode=null;return this._lastMode=null};e.prototype.GO=function(f){return function(){return this.mode=f}};e.GO=function(f){return function(){return this.mode=f}};e.prototype.run=function(g){var l,h,k,j,f,i;this.mode=0;for(j=0,f=g.length;j<f;j++){l=g[j];k=this.modeline;if(!(k!=null)){h=null}else{if(l in k){h=k[l]}else{if("def" in k){h=k.def}}}while(Object.IsFunction(h)){h=h.call(this,l)}}if(Object.IsFunction((i=this.modeline)!=null?i.eof:void 0)){h=this.modeline.eof.call(this)}while(Object.IsFunction(h)){h=h.call(this)}this.reset();return this};return e})();return{name:"StateMachine",$:{StateMachine:d}}});return c.plugin(function(){var d;d=(function(){b(e,c.StateMachine);e.STATE_TABLE=[{enter:function(){this.tag=this.id=this.cls=this.attr=this.val=this.text="";this.attrs={};return this.GO(1)}},{'"':e.GO(6),"'":e.GO(7),"#":e.GO(2),".":e.GO(3),"[":e.GO(4)," ":e.GO(9),"+":e.GO(11),",":e.GO(10),def:function(f){return this.tag+=f},eof:e.GO(13)},{".":e.GO(3),"[":e.GO(4)," ":e.GO(9),"+":e.GO(11),",":e.GO(10),def:function(f){return this.id+=f},eof:e.GO(13)},{enter:function(){if(this.cls.length>0){return this.cls+=" "}},"#":e.GO(2),".":e.GO(3),"[":e.GO(4)," ":e.GO(9),"+":e.GO(11),",":e.GO(10),def:function(f){return this.cls+=f},eof:e.GO(13)},{"=":e.GO(5),"]":function(){this.attrs[this.attr]=this.val;return this.GO(1)},def:function(f){return this.attr+=f},eof:e.GO(12)},{"]":function(){this.attrs[this.attr]=this.val;return this.GO(1)},def:function(f){return this.val+=f},eof:e.GO(12)},{'"':e.GO(8),def:function(f){return this.text+=f},eof:e.GO(12)},{"'":e.GO(8),def:function(f){return this.text+=f},eof:e.GO(12)},{enter:function(){this.emitText();return this.GO(0)}},{enter:function(){this.emitNode();return this.GO(0)}},{enter:function(){this.emitNode();this.parent=null;return this.GO(0)}},{enter:function(){var f;this.emitNode();this.parent=(f=this.parent)!=null?f.parentNode:void 0;return this.GO(0)}},{enter:function(){return c.log("Error in synth expression: "+this.input)}},{enter:function(){if(this.tag.length){this.emitNode()}if(this.text.length){return this.emitText()}}}];function e(){e.__super__.constructor.call(this,e.STATE_TABLE);this.fragment=this.parent=document.createDocumentFragment()}e.prototype.emitNode=function(){var f,g;g=document.createElement(this.tag);g.id=this.id||null;g.className=this.cls||null;for(f in this.attrs){g.setAttribute(f,this.attrs[f])}this.parent.appendChild(g);return this.parent=g};e.prototype.emitText=function(){this.parent.appendChild(c.HTML.parse(this.text));return this.text=""};return e})();return{name:"Synth",$:{synth:function(f){var e;e=new d();e.run(f);if(e.fragment.childNodes.length===1){return c(e.fragment.childNodes[0])}else{return c(e.fragment)}}}}})})(Bling)}).call(this);(function(){var a=Object.prototype.hasOwnProperty,b=function(f,d){for(var c in d){if(a.call(d,c)){f[c]=d[c]}}function e(){this.constructor=f}e.prototype=d.prototype;f.prototype=new e;f.__super__=d.prototype;return f};(function(e){var d,c;d={};e.plugin(function(){var f,g;f=null;d={};g={register_engine:function(h,i){d[h]=i;if(!(f!=null)){return f=h}},render:function(i,h){if(f in d){return d[f](i,h)}}};g.__defineSetter__("engine",function(h){if(!h in d){throw new Error("invalid template engine: "+h+" not one of "+(Object.Keys(d)))}else{return f=h}});g.__defineGetter__("engine",function(){return f});return{name:"Template",$:{template:g}}});e.template.register_engine("null",(function(){return function(g,f){return g}})());c=function(m,l,f,n,j){var k,h,g;if(j==null){j=-1}k=1;if(j<0){j=m.length+1+j}for(h=n;n<=j?h<j:h>j;n<=j?h++:h--){g=m[h];if(g===f){k+=1}else{if(g===l){k-=1}}if(k===0){return h}}return -1};e.template.register_engine("pythonic",(function(){var h,i,g,f;f=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;h=/%[\(\/]/;i=function(u){var r,m,p,o,t,q,l,k,s;r=u.split(h);l=r.length;s=[r[0]];o=1;for(p=1;1<=l?p<l:p>l;1<=l?p++:p--){m=c(r[p],")","(",0,-1);if(m===-1){return"Template syntax error: unmatched '%(' starting at: "+(r[p].substring(0,15))}t=r[p].substring(0,m);k=r[p].substring(m);q=f.exec(k);if(q===null){return"Template syntax error: invalid type specifier starting at '"+k+"'"}k=q[4];s[o++]=t;s[o++]=q[1]|0;s[o++]=q[2]|0;s[o++]=q[3];s[o++]=k}return s};i.cache={};g=function(z,y){var k,r,u,s,x,o,m,p,l,v,w,t,q;k=i.cache[z];if(!(k!=null)){k=i.cache[z]=i(z)}m=[k[0]];s=1;o=k.length;for(u=1,t=o-5;u<=t;u+=5){q=k.slice(u,(u+4)+1||9000000000),x=q[0],p=q[1],r=q[2],v=q[3],l=q[4];w=y[x];if(!(w!=null)){w="missing value: "+x}switch(v){case"d":m[s++]=""+parseInt(w,10);break;case"f":m[s++]=parseFloat(w).toFixed(r);break;case"s":m[s++]=""+w;break;default:m[s++]=""+w}if(p>0){m[s]=String.PadLeft(m[s],p)}m[s++]=l}return m.join("")};return g})());return e.template.register_engine("js-eval",(function(){var f;f=(function(){b(g,e.StateMachine);function g(){g.__super__.constructor.apply(this,arguments)}g.STATE_TABLE=[{enter:function(){this.data=[];return this.GO(1)}},{}];return g})();return function(h,g){return h}})())})(Bling)}).call(this);(function(a){return a.plugin(function(){var d,c,b;b=function(k){var f,g,j,e,h;g=k.indexOf(":");if(g>0){e=parseInt(k.slice(0,g),10);j=k.slice(g+1,(g+1+e));h=k[g+1+e];f=k.slice(g+e+2);j=(function(){switch(h){case"#":return Number(j);case"'":return String(j);case"!":return j==="true";case"~":return null;case"]":return d(j);case"}":return c(j)}})();return[j,f]}};d=function(e){var h,f,g;h=[];while(e.length>0){g=b(e),f=g[0],e=g[1];h.push(f)}return h};c=function(e){var i,f,h,g,j;i={};while(e.length>0){g=b(e),f=g[0],e=g[1];j=b(e),h=j[0],e=j[1];i[f]=h}return i};return{name:"TNET",$:{TNET:{stringify:function(e){var h,f,i,g;g=(function(){switch(Object.Type(e)){case"number":return[String(e),"#"];case"string":return[e,"'"];case"function":return[String(e),"'"];case"boolean":return[String(!!e),"!"];case"null":return["","~"];case"undefined":return["","~"];case"array":return[((function(){var l,k,j;j=[];for(l=0,k=e.length;l<k;l++){i=e[l];j.push(a.TNET.stringify(i))}return j})()).join(""),"]"];case"object":return[((function(){var j;j=[];for(i in e){j.push(a.TNET.stringify(i)+a.TNET.stringify(e[i]))}return j})()).join(""),"}"]}})(),h=g[0],f=g[1];return(h.length|0)+":"+h+f},parse:function(e){var f;return(f=b(e))!=null?f[0]:void 0}}}}})})(Bling);(function(a){return a.plugin(function(){var d,g,c,f,e,b;g=function(h,j){var i;j=Object.Extend({autoOpen:false,draggable:true},j);i=a(h).addClass("dialog");if(j.draggable){i.draggable()}if(j.autoOpen){i.show().center()}i.find("button.close, .close-button").bind("click touchstart",function(){i.hide();return false});return i};c=function(j,l){var n,m,i,k,h;l=Object.Extend({handleCSS:{}},l);l.handleCSS=Object.Extend({position:"absolute",top:"0px",left:"0px",width:"100%",height:"6px"},l.handleCSS);n=a(j);i=false;k=h=0;m=a.synth("div.handle").defaultCss({background:"-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",height:"6px","border-radius":"3px",cursor:"move"}.css(l.handleCSS.bind("mousedown, touchstart",function(o){i=true;k||(k=o.pageX);h||(h=o.pageY);return false})));a(document.bind("mousemove, touchmove",function(q){var p,o;if(i){p=q.pageX-k;o=q.pageY-h;n.transform({translate:[p,o]},0).trigger("drag",{dragObject:n});return false}})).bind("mouseup, touchend",function(o){var p;if(i){i=false;p=m.position()[0];return a(document.elementFromPoint(p.left,p.top-1).trigger("drop",{dropObject:n}))}});return n.addClass("draggable").css({position:"relative","padding-top":n.css("padding-top").map(Number.AtLeast(parseInt(l.handleCSS.height,10))).px().first()}.append(m))};f=function(h,k){var j,m,l,i;k=Object.Extend({change:Function.Empty,backgroundColor:"#fff",barColor:"rgba(0,128,0,0.5)",textColor:"white",reset:false},k);j=a(h).addClass("progress-bar");i=0;if(k.reset){m=j.css("background").first();l=j.css("color").first()}return j.zap("updateProgress",function(n){while(n>1){n/=100}i=n;if(n===1&&k.reset){j.css("background",m).css("color",l)}else{j.css({background:"-webkit-gradient(linear, 0 0, "+parseInt(n*100)+"% 0, color-stop(0, "+k.barColor+"), color-stop(0.98, "+k.barColor+"), color-stop(1.0, "+k.backgroundColor+"))",color:k.textColor})}if(Object.IsFunc(k.change)){return k.change(i)}})};d=function(h,k){var i,j,l;k=Object.Extend({exclusive:false,sticky:false},k);j=a(h).addClass("accordion");l=null;i=function(r){var o,m,p,q;p=a(r).children().first().filter("*");if(p.len()!==2){throw Exception("accordion row requires 2 elements, not "+(p.len()))}q=p.eq(0).addClass("title");o=p.eq(1).addClass("body").hide();m=false;return q.click(function(){if(k.exclusive){j.find(".body").hide()}if(m){if(!k.sticky){o.hide().removeClass("visible");q.removeClass("selected").trigger("deselect");return m=false}else{o.show().addClass("visible");q.addClass("selected").trigger("select");return m=true}}else{o.show().addClass("visible");q.addClass("selected").trigger("select");return m=true}})};j.bind("DOMNodeInserted",function(m){var o,n;o=j.children().first().filter("*");n=a(m.target).parents().first();return i(n.intersect(o))});j.children().first().filter("*").map(i);return j};b=function(h,l){var n,i,k,m;i=a(h).css({position:"relative",top:"0px",left:"0px"}.hide().map(a));n=0;i[n].show();i.next=function(){i[n].hide();n=++n%nn;return i[n].show()};i.activate=function(j){i[n].hide();n=j;return i[j].show()};for(k=0,m=i.len();0<=m?k<m:k>m;0<=m?k++:k--){i[k].zap("_viewIndex",k.zap("activate",function(){return i.activate(this._viewIndex)}))}return i};e=function(h,j){var l,m,k;k=a(h);j=a(j).viewStack();m=k.len();for(l=0;0<=m?l<=m:l>=m;0<=m?l++:l--){k._tabIndex=l}a(k[0]).addClass("active");return k.click(function(){k.removeClass("active");j.activate(this._tabIndex);return a(this).addClass("active")})};return{name:"UI",$:{UI:{Draggable:c,ProgressBar:f,ViewStack:b,Tabs:e,Accordion:d}},dialog:function(h){return g(this,h)},progressBar:function(h){return f(this,h)},viewStack:function(h){return b(this,h)},tabs:function(h){return e(this,h)},accordion:function(h){return d(this,h)},draggable:function(h){return c(this,h)}}})})(Bling);(function(){var a=Array.prototype.slice;$.plugin(function(){var r,m,k,q,h,i,e,d,p,n,o,j,g,f,l,c;j=["px","pt","pc","em","%","in","cm","mm","ex",""];r=/(\d+\.*\d*)(px|pt|pc|em|%|in|cm|mm|ex)/;d=function(b){return r.exec(b)[2](r.test(b)?void 0:"")};q=function(t,s){return q[t][s]()};p=function(b){return function(){return b}};for(g=0,l=j.length;g<l;g++){m=j[g];for(f=0,c=j.length;f<c;f++){k=j[f];(q[m]||(q[m]={}))[k]=p(+(m===k||m===""||k===""))}}q["in"].pt=function(){return 72};q["in"].px=function(){return 96};q["in"].cm=function(){return 2.54};q.pc.pt=function(){return 12};q.cm.mm=function(){return 10};q.em.px=function(){var s,b;b=$("<span style='font-size:1em;visibility:hidden'>x</span>").appendTo("body");s=b.width().first();b.remove();return s};q.ex.px=function(){var s,b;b=$("<span style='font-size:1ex;visibility:hidden'>x</span>").appendTo("body");s=b.width().first();b.remove();return s};q.ex.em=function(){return 2};e=function(){var u,s,x,v,w,t;t=[];for(v=0,w=j.length;v<w;v++){u=j[v];t.push((function(){var y,z,b;b=[];for(y=0,z=j.length;y<z;y++){s=j[y];if(!q(u,s)&&q(s,u)){console.log("found inverse: "+u+"."+s);q[u][s]=p(1/q(s,u))}b.push((function(){var C,B,A;A=[];for(B=0,C=j.length;B<C;B++){x=j[B];if(!q(u,x)&&q(u,s)&&q(s,x)){console.log("found induction: "+u+"."+x);A.push(q[u][x]=p(q(u,s)*q(s,x)))}else{A.push(void 0)}}return A})())}return b})())}return t};e();e();i=function(s,b){return parseFloat(s)*q[d(s)][b]()+b};$.assert(i("300px","cm")==="10cm");h=function(v,s){var t,u,b;b=[];for(t=0,u=s.length;0<=u?t<u:t>u;0<=u?t++:t--){b.push(s[t]=convertTo(v,s[t]))}return b};Object.Type.register("units",{match:function(b){return r.test(b)}});n=function(b){return function(){var s,t;s=1<=arguments.length?a.call(arguments,0):[];h(t=d(this[0]),this);return(b.apply(this,s))+t}};o=function(b){return function(){var s,t;s=1<=arguments.length?a.call(arguments,0):[];t=this.map(d);return b.apply(this.floats(),s).map(function(){})}};return{min:n(function(){return this.reduce(function(b){return Math.min(parseFloat(this),b)})}),max:n(function(){return this.reduce(function(b){return Math.max(parseFloat(this),b)})}),sum:n(function(){return this.reduce(function(b){return parseFloat(this)+b})}),mean:n(function(){return parseFloat(this.sum())/this.length}),magnitude:n(function(){return Math.sqrt(this.floats().squares().sum())}),squares:function(){return this.map(function(){var b;return(b=parseFloat(this))*b})},scale:function(b){return this.map(function(){return b*parseFloat(this)})},add:function(b){return this.map(function(){return b+this})},normalize:function(){return this.scale(1/this.magnitude())}}})}).call(this);$.plugin(function(){var c,e,d,b,a;e=function(){return"EOF"};c=function(f){f=extend({item:function(){return e},action:Function.Identity,latency:10},f);return extend(new $.EventEmitter(),{run:function(){var g;var h=this;g=function(){var i;if((i=f.action(f.item()))!==e){h.emit("data",i);return setTimeout(g,f.latency)}};return setTimeout(g,f.latency)}})};for(a=0;a<1000;a++){d=a}b=0;return c({item:function(){return d[b++](b<d.length?void 0:e)},action:function(f){return(f*f)-1},latency:10}).on("data",function(f){return console.log("data:",f.on("error",function(g){return console.log("error:",g.run())}))})});(function(a){return a.plugin(function(){var d,e,c,b;e={};c=function(g,h){return e[g]=h};d=function(g){return e[obj.t]};b=[];Object.Type.extend(null,{compact:function(f){return Object.String(f)}});Object.Type.extend("undefined",{compact:function(f){return""}});Object.Type.extend("null",{compact:function(f){return""}});Object.Type.extend("string",{compact:Function.Identity});Object.Type.extend("array",{compact:function(g){var f;return((function(){var j,i,h;h=[];for(j=0,i=g.length;j<i;j++){f=g[j];h.push(Object.Compact(f))}return h})()).join("")}});Object.Type.extend("bling",{compact:function(f){return f.map(Object.Compact).join("")}});Object.Type.extend("object",{compact:function(g){var f;return Object.Compact((f=d(g))!=null?f.call(g,g):void 0)}});Object.Compact=function(g){var f;b.push(g);if((f=Object.Type.lookup(g))!=null){f.compact(g)}return b.pop()};Object.Extend(Object.Compact,{register:c,lookup:d});c("page",function(){return["<!DOCTYPE html><html><head>",this.head,"</head><body>",this.body,"</body></html>"]});c("text",function(){return this.EN});c("link",function(){var g,h,j,f,i;g=a(["<a"]);i=["href","name","target"];for(j=0,f=i.length;j<f;j++){h=i[j];if(h in this){g.extend(" ",h,"='",this[h],"'")}}return g.extend(">",node.content,"</a>")});a.assert(Object.Compact({t:"page",head:[],body:{type:"text",EN:"Hello World"}})==="<!DOCTYPE html><html><head></head><body>Hello World</body></html>");return{name:"Compact"}})})(Bling);(function(a){return a.plugin(function(){var v,k,l,m,n,f,o,b,c,e,h,p,s,g,q,r,i,u,d,j,t;q=/!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g;g="<span class='opr'>$&</span>";h=/\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g;e="<span class='kwd'>$&</span>";v=/\d+\.*\d*/g;s="<span class='num'>$&</span>";l=/\$(\(|\.)/g;k="<span class='bln'>$$</span>$1";t=/\t/g;j="&nbsp;&nbsp;";i=/\/\/.*?(?:\n|$)/;p=/\/\*(?:.|\n)*?\*\//;n=function(w){if(w){return"<span class='com'>"+w+"</span>"}else{return""}};r=function(w){if(w){return"<span class='str'>"+w+"</span>"}else{return""}};o=function(z,y){var x,w;x=z.indexOf('"',y);w=z.indexOf("'",y);if(x===-1){x=z.length}if(w===-1){w=z.length}if(x===w){return[null,-1]}if(x<w){return['"',x]}return["'",w]};m=function(x,w,z){var y;y=x.indexOf(z,w);while(x.charAt(y-1)==="\\"&&(0<y&&y<x.length)){y=x.indexOf(z,y+1)}return y};d=function(A){var z,y,w,C,B,x;z=0;C=A.length;x=[];if(!Object.IsString(A)){if(!Object.IsFunction(A.toString)){throw TypeError("invalid string argument to split_quoted")}else{A=A.toString();C=A.length}}while(z<C){B=o(A,z);y=B[1];if(y===-1){x.push(A.substring(z));break}x.push(A.substring(z,y));w=m(A,y+1,B[0]);if(w===-1){throw Error("unclosed quote: "+B[0]+" starting at "+y)}x.push(A.substring(y,w+1));z=w+1}return x};f=function(y){var x,w;x=y.match(i);w=y.match(p);if(x===w){return[-1,null]}if(x===null&&w!==null){return[w.index,w[0]]}if(x!==null&&w===null){return[x.index,x[0]]}if(w.index<x.index){return[w.index,w[0]]}return[x.index,x[0]]};u=function(A){var z,x,C,B,w,y;w=[];z=0;C=A.length;while(z<C){y=A.substring(z);B=f(y);x=B[0];if(x>-1){w.push(y.substring(0,x));w.push(B[1]);z+=x+B[1].length}else{w.push(y);break}}return w};b=function(x,w){return x.replace(q,g).replace(v,s).replace(h,e).replace(l,k).replace(t,j)+r(w)};c=function(w,x){return a(d(w)).fold(b).join("")+n(x)};return{name:"PrettyPrint",$:{prettyPrint:function(A,x){var w,z,y;if(Object.IsFunction(A)){A=A.toString()}if(!Object.IsString(A)){throw TypeError("prettyPrint requires a function or string to format, not '"+Object.Type(A)+"'")}if(a("style#prettyPrint").length===0){z="code.pp .bln { font-size: 17px; } ";x=Object.Extend({opr:"#880",str:"#008",com:"#080",kwd:"#088",num:"#808",bln:"#800"},x);for(w in x){z+="code.pp ."+w+" { color: "+x[w]+"; } "}a.synth("style#prettyPrint").text(z).appendTo("head")}return y="<code class='pp'>"+(a(u(A)).fold(c).join(""))+"</code>"}}}})})(Bling);(function(){var a=Object.prototype.hasOwnProperty,b=function(f,d){for(var c in d){if(a.call(d,c)){f[c]=d[c]}}function e(){this.constructor=f}e.prototype=d.prototype;f.prototype=new e;f.__super__=d.prototype;return f};(function(c){c.plugin(function(){var d;d=(function(){function e(f){this.reset();this.table=f;Object.defineProperty(this,"modeline",{get:this.table[this._mode]});Object.defineProperty(this,"mode",{set:function(g){var h;this._lastMode=this._mode;this._mode=g;if(this._mode!==this._lastMode&&(this.modeline!=null)&&"enter" in this.modeline){h=this.modeline.enter.call(this);while(Object.IsFunction(h)){h=h.call(this)}}return g},get:function(){return this._mode}})}e.prototype.reset=function(){this._mode=null;return this._lastMode=null};e.prototype.GO=function(f){return function(){return this.mode=f}};e.GO=function(f){return function(){return this.mode=f}};e.prototype.run=function(g){var l,h,k,j,f,i;this.mode=0;for(j=0,f=g.length;j<f;j++){l=g[j];k=this.modeline;if(!(k!=null)){h=null}else{if(l in k){h=k[l]}else{if("def" in k){h=k.def}}}while(Object.IsFunction(h)){h=h.call(this,l)}}if(Object.IsFunction((i=this.modeline)!=null?i.eof:void 0)){h=this.modeline.eof.call(this)}while(Object.IsFunction(h)){h=h.call(this)}this.reset();return this};return e})();return{name:"StateMachine",$:{StateMachine:d}}});return c.plugin(function(){var d;d=(function(){b(e,c.StateMachine);e.STATE_TABLE=[{enter:function(){this.tag=this.id=this.cls=this.attr=this.val=this.text="";this.attrs={};return this.GO(1)}},{'"':e.GO(6),"'":e.GO(7),"#":e.GO(2),".":e.GO(3),"[":e.GO(4)," ":e.GO(9),"+":e.GO(11),",":e.GO(10),def:function(f){return this.tag+=f},eof:e.GO(13)},{".":e.GO(3),"[":e.GO(4)," ":e.GO(9),"+":e.GO(11),",":e.GO(10),def:function(f){return this.id+=f},eof:e.GO(13)},{enter:function(){if(this.cls.length>0){return this.cls+=" "}},"#":e.GO(2),".":e.GO(3),"[":e.GO(4)," ":e.GO(9),"+":e.GO(11),",":e.GO(10),def:function(f){return this.cls+=f},eof:e.GO(13)},{"=":e.GO(5),"]":function(){this.attrs[this.attr]=this.val;return this.GO(1)},def:function(f){return this.attr+=f},eof:e.GO(12)},{"]":function(){this.attrs[this.attr]=this.val;return this.GO(1)},def:function(f){return this.val+=f},eof:e.GO(12)},{'"':e.GO(8),def:function(f){return this.text+=f},eof:e.GO(12)},{"'":e.GO(8),def:function(f){return this.text+=f},eof:e.GO(12)},{enter:function(){this.emitText();return this.GO(0)}},{enter:function(){this.emitNode();return this.GO(0)}},{enter:function(){this.emitNode();this.parent=null;return this.GO(0)}},{enter:function(){var f;this.emitNode();this.parent=(f=this.parent)!=null?f.parentNode:void 0;return this.GO(0)}},{enter:function(){return c.log("Error in synth expression: "+this.input)}},{enter:function(){if(this.tag.length){this.emitNode()}if(this.text.length){return this.emitText()}}}];function e(){e.__super__.constructor.call(this,e.STATE_TABLE);this.fragment=this.parent=document.createDocumentFragment()}e.prototype.emitNode=function(){var f,g;g=document.createElement(this.tag);g.id=this.id||null;g.className=this.cls||null;for(f in this.attrs){g.setAttribute(f,this.attrs[f])}this.parent.appendChild(g);return this.parent=g};e.prototype.emitText=function(){this.parent.appendChild(c.HTML.parse(this.text));return this.text=""};return e})();return{name:"Synth",$:{synth:function(f){var e;e=new d();e.run(f);if(e.fragment.childNodes.length===1){return c(e.fragment.childNodes[0])}else{return c(e.fragment)}}}}})})(Bling)}).call(this);(function(){var a=Object.prototype.hasOwnProperty,b=function(f,d){for(var c in d){if(a.call(d,c)){f[c]=d[c]}}function e(){this.constructor=f}e.prototype=d.prototype;f.prototype=new e;f.__super__=d.prototype;return f};(function(e){var d,c;d={};e.plugin(function(){var f,g;f=null;d={};g={register_engine:function(h,i){d[h]=i;if(!(f!=null)){return f=h}},render:function(i,h){if(f in d){return d[f](i,h)}}};g.__defineSetter__("engine",function(h){if(!h in d){throw new Error("invalid template engine: "+h+" not one of "+(Object.Keys(d)))}else{return f=h}});g.__defineGetter__("engine",function(){return f});return{name:"Template",$:{template:g}}});e.template.register_engine("null",(function(){return function(g,f){return g}})());c=function(m,l,f,n,j){var k,h,g;if(j==null){j=-1}k=1;if(j<0){j=m.length+1+j}for(h=n;n<=j?h<j:h>j;n<=j?h++:h--){g=m[h];if(g===f){k+=1}else{if(g===l){k-=1}}if(k===0){return h}}return -1};e.template.register_engine("pythonic",(function(){var h,i,g,f;f=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;h=/%[\(\/]/;i=function(u){var r,m,p,o,t,q,l,k,s;r=u.split(h);l=r.length;s=[r[0]];o=1;for(p=1;1<=l?p<l:p>l;1<=l?p++:p--){m=c(r[p],")","(",0,-1);if(m===-1){return"Template syntax error: unmatched '%(' starting at: "+(r[p].substring(0,15))}t=r[p].substring(0,m);k=r[p].substring(m);q=f.exec(k);if(q===null){return"Template syntax error: invalid type specifier starting at '"+k+"'"}k=q[4];s[o++]=t;s[o++]=q[1]|0;s[o++]=q[2]|0;s[o++]=q[3];s[o++]=k}return s};i.cache={};g=function(z,y){var k,r,u,s,x,o,m,p,l,v,w,t,q;k=i.cache[z];if(!(k!=null)){k=i.cache[z]=i(z)}m=[k[0]];s=1;o=k.length;for(u=1,t=o-5;u<=t;u+=5){q=k.slice(u,(u+4)+1||9000000000),x=q[0],p=q[1],r=q[2],v=q[3],l=q[4];w=y[x];if(!(w!=null)){w="missing value: "+x}switch(v){case"d":m[s++]=""+parseInt(w,10);break;case"f":m[s++]=parseFloat(w).toFixed(r);break;case"s":m[s++]=""+w;break;default:m[s++]=""+w}if(p>0){m[s]=String.PadLeft(m[s],p)}m[s++]=l}return m.join("")};return g})());return e.template.register_engine("js-eval",(function(){var f;f=(function(){b(g,e.StateMachine);function g(){g.__super__.constructor.apply(this,arguments)}g.STATE_TABLE=[{enter:function(){this.data=[];return this.GO(1)}},{}];return g})();return function(h,g){return h}})())})(Bling)}).call(this);(function(a){return a.plugin(function(){var d,c,b;b=function(k){var f,g,j,e,h;g=k.indexOf(":");if(g>0){e=parseInt(k.slice(0,g),10);j=k.slice(g+1,(g+1+e));h=k[g+1+e];f=k.slice(g+e+2);j=(function(){switch(h){case"#":return Number(j);case"'":return String(j);case"!":return j==="true";case"~":return null;case"]":return d(j);case"}":return c(j)}})();return[j,f]}};d=function(e){var h,f,g;h=[];while(e.length>0){g=b(e),f=g[0],e=g[1];h.push(f)}return h};c=function(e){var i,f,h,g,j;i={};while(e.length>0){g=b(e),f=g[0],e=g[1];j=b(e),h=j[0],e=j[1];i[f]=h}return i};return{name:"TNET",$:{TNET:{stringify:function(e){var h,f,i,g;g=(function(){switch(Object.Type(e)){case"number":return[String(e),"#"];case"string":return[e,"'"];case"function":return[String(e),"'"];case"boolean":return[String(!!e),"!"];case"null":return["","~"];case"undefined":return["","~"];case"array":return[((function(){var l,k,j;j=[];for(l=0,k=e.length;l<k;l++){i=e[l];j.push(a.TNET.stringify(i))}return j})()).join(""),"]"];case"object":return[((function(){var j;j=[];for(i in e){j.push(a.TNET.stringify(i)+a.TNET.stringify(e[i]))}return j})()).join(""),"}"]}})(),h=g[0],f=g[1];return(h.length|0)+":"+h+f},parse:function(e){var f;return(f=b(e))!=null?f[0]:void 0}}}}})})(Bling);(function(a){return a.plugin(function(){var d,g,c,f,e,b;g=function(h,j){var i;j=Object.Extend({autoOpen:false,draggable:true},j);i=a(h).addClass("dialog");if(j.draggable){i.draggable()}if(j.autoOpen){i.show().center()}i.find("button.close, .close-button").bind("click touchstart",function(){i.hide();return false});return i};c=function(j,l){var n,m,i,k,h;l=Object.Extend({handleCSS:{}},l);l.handleCSS=Object.Extend({position:"absolute",top:"0px",left:"0px",width:"100%",height:"6px"},l.handleCSS);n=a(j);i=false;k=h=0;m=a.synth("div.handle").defaultCss({background:"-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",height:"6px","border-radius":"3px",cursor:"move"}.css(l.handleCSS.bind("mousedown, touchstart",function(o){i=true;k||(k=o.pageX);h||(h=o.pageY);return false})));a(document.bind("mousemove, touchmove",function(q){var p,o;if(i){p=q.pageX-k;o=q.pageY-h;n.transform({translate:[p,o]},0).trigger("drag",{dragObject:n});return false}})).bind("mouseup, touchend",function(o){var p;if(i){i=false;p=m.position()[0];return a(document.elementFromPoint(p.left,p.top-1).trigger("drop",{dropObject:n}))}});return n.addClass("draggable").css({position:"relative","padding-top":n.css("padding-top").map(Number.AtLeast(parseInt(l.handleCSS.height,10))).px().first()}.append(m))};f=function(h,k){var j,m,l,i;k=Object.Extend({change:Function.Empty,backgroundColor:"#fff",barColor:"rgba(0,128,0,0.5)",textColor:"white",reset:false},k);j=a(h).addClass("progress-bar");i=0;if(k.reset){m=j.css("background").first();l=j.css("color").first()}return j.zap("updateProgress",function(n){while(n>1){n/=100}i=n;if(n===1&&k.reset){j.css("background",m).css("color",l)}else{j.css({background:"-webkit-gradient(linear, 0 0, "+parseInt(n*100)+"% 0, color-stop(0, "+k.barColor+"), color-stop(0.98, "+k.barColor+"), color-stop(1.0, "+k.backgroundColor+"))",color:k.textColor})}if(Object.IsFunc(k.change)){return k.change(i)}})};d=function(h,k){var i,j,l;k=Object.Extend({exclusive:false,sticky:false},k);j=a(h).addClass("accordion");l=null;i=function(r){var o,m,p,q;p=a(r).children().first().filter("*");if(p.len()!==2){throw Exception("accordion row requires 2 elements, not "+(p.len()))}q=p.eq(0).addClass("title");o=p.eq(1).addClass("body").hide();m=false;return q.click(function(){if(k.exclusive){j.find(".body").hide()}if(m){if(!k.sticky){o.hide().removeClass("visible");q.removeClass("selected").trigger("deselect");return m=false}else{o.show().addClass("visible");q.addClass("selected").trigger("select");return m=true}}else{o.show().addClass("visible");q.addClass("selected").trigger("select");return m=true}})};j.bind("DOMNodeInserted",function(m){var o,n;o=j.children().first().filter("*");n=a(m.target).parents().first();return i(n.intersect(o))});j.children().first().filter("*").map(i);return j};b=function(h,l){var n,i,k,m;i=a(h).css({position:"relative",top:"0px",left:"0px"}.hide().map(a));n=0;i[n].show();i.next=function(){i[n].hide();n=++n%nn;return i[n].show()};i.activate=function(j){i[n].hide();n=j;return i[j].show()};for(k=0,m=i.len();0<=m?k<m:k>m;0<=m?k++:k--){i[k].zap("_viewIndex",k.zap("activate",function(){return i.activate(this._viewIndex)}))}return i};e=function(h,j){var l,m,k;k=a(h);j=a(j).viewStack();m=k.len();for(l=0;0<=m?l<=m:l>=m;0<=m?l++:l--){k._tabIndex=l}a(k[0]).addClass("active");return k.click(function(){k.removeClass("active");j.activate(this._tabIndex);return a(this).addClass("active")})};return{name:"UI",$:{UI:{Draggable:c,ProgressBar:f,ViewStack:b,Tabs:e,Accordion:d}},dialog:function(h){return g(this,h)},progressBar:function(h){return f(this,h)},viewStack:function(h){return b(this,h)},tabs:function(h){return e(this,h)},accordion:function(h){return d(this,h)},draggable:function(h){return c(this,h)}}})})(Bling);
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
(function() {
  var __slice = Array.prototype.slice;

  $.plugin(function() {
    var UNIT_RE, a, b, conv, convertAll, convertUnits, fillIn, parseUnits, trick, unit_scalar, unit_vector, units, _i, _j, _len, _len2;
    units = ["px", "pt", "pc", "em", "%", "in", "cm", "mm", "ex", ""];
    UNIT_RE = /(\d+\.*\d*)(px|pt|pc|em|%|in|cm|mm|ex)/;
    parseUnits = function(s) {
      return UNIT_RE.exec(s)[2](UNIT_RE.test(s) ? void 0 : "");
    };
    conv = function(a, b) {
      return conv[a][b]();
    };
    trick = function(x) {
      return function() {
        return x;
      };
    };
    for (_i = 0, _len = units.length; _i < _len; _i++) {
      a = units[_i];
      for (_j = 0, _len2 = units.length; _j < _len2; _j++) {
        b = units[_j];
        (conv[a] || (conv[a] = {}))[b] = trick(+(a === b || a === "" || b === ""));
      }
    }
    conv["in"].pt = function() {
      return 72;
    };
    conv["in"].px = function() {
      return 96;
    };
    conv["in"].cm = function() {
      return 2.54;
    };
    conv.pc.pt = function() {
      return 12;
    };
    conv.cm.mm = function() {
      return 10;
    };
    conv.em.px = function() {
      var w, x;
      x = $("<span style='font-size:1em;visibility:hidden'>x</span>").appendTo("body");
      w = x.width().first();
      x.remove();
      return w;
    };
    conv.ex.px = function() {
      var w, x;
      x = $("<span style='font-size:1ex;visibility:hidden'>x</span>").appendTo("body");
      w = x.width().first();
      x.remove();
      return w;
    };
    conv.ex.em = function() {
      return 2;
    };
    fillIn = function() {
      var a, b, c, _k, _len3, _results;
      _results = [];
      for (_k = 0, _len3 = units.length; _k < _len3; _k++) {
        a = units[_k];
        _results.push((function() {
          var _l, _len4, _results2;
          _results2 = [];
          for (_l = 0, _len4 = units.length; _l < _len4; _l++) {
            b = units[_l];
            if (!conv(a, b) && conv(b, a)) {
              console.log("found inverse: " + a + "." + b);
              conv[a][b] = trick(1.0 / conv(b, a));
            }
            _results2.push((function() {
              var _len5, _m, _results3;
              _results3 = [];
              for (_m = 0, _len5 = units.length; _m < _len5; _m++) {
                c = units[_m];
                if (!conv(a, c) && conv(a, b) && conv(b, c)) {
                  console.log("found induction: " + a + "." + c);
                  _results3.push(conv[a][c] = trick(conv(a, b) * conv(b, c)));
                } else {
                  _results3.push(void 0);
                }
              }
              return _results3;
            })());
          }
          return _results2;
        })());
      }
      return _results;
    };
    fillIn();
    fillIn();
    convertUnits = function(number, unit) {
      return parseFloat(number) * conv[parseUnits(number)][unit]() + unit;
    };
    $.assert(convertUnits("300px", "cm") === "10cm");
    convertAll = function(to, a) {
      var i, _ref, _results;
      _results = [];
      for (i = 0, _ref = a.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        _results.push(a[i] = convertTo(to, a[i]));
      }
      return _results;
    };
    Object.Type.register("units", {
      match: function(x) {
        return UNIT_RE.test(x);
      }
    });
    unit_scalar = function(f) {
      return function() {
        var a, unit;
        a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        convertAll(unit = parseUnits(this[0]), this);
        return (f.apply(this, a)) + unit;
      };
    };
    unit_vector = function(f) {
      return function() {
        var a, u;
        a = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        u = this.map(parseUnits);
        return f.apply(this.floats(), a).map(function() {});
      };
    };
    return {
      min: unit_scalar(function() {
        return this.reduce(function(a) {
          return Math.min(parseFloat(this), a);
        });
      }),
      max: unit_scalar(function() {
        return this.reduce(function(a) {
          return Math.max(parseFloat(this), a);
        });
      }),
      sum: unit_scalar(function() {
        return this.reduce(function(a) {
          return parseFloat(this) + a;
        });
      }),
      mean: unit_scalar(function() {
        return parseFloat(this.sum()) / this.length;
      }),
      magnitude: unit_scalar(function() {
        return Math.sqrt(this.floats().squares().sum());
      }),
      squares: function() {
        return this.map(function() {
          var x;
          return (x = parseFloat(this)) * x;
        });
      },
      scale: function(n) {
        return this.map(function() {
          return n * parseFloat(this);
        });
      },
      add: function(d) {
        return this.map(function() {
          return d + this;
        });
      },
      normalize: function() {
        return this.scale(1 / this.magnitude());
      }
    };
  });

}).call(this);

  $.plugin(function() {
    var BackgroundQueue, EOF, data, i, x;
    EOF = function() {
      return "EOF";
    };
    BackgroundQueue = function(opts) {
      opts = extend({
        item: function() {
          return EOF;
        },
        action: Function.Identity,
        latency: 10
      }, opts);
      return extend(new $.EventEmitter(), {
        run: function() {
          var r;
          var _this = this;
          r = function() {
            var item;
            if ((item = opts.action(opts.item())) !== EOF) {
              _this.emit("data", item);
              return setTimeout(r, opts.latency);
            }
          };
          return setTimeout(r, opts.latency);
        }
      });
    };
    for (x = 0; x < 1000; x++) {
      data = x;
    }
    i = 0;
    return BackgroundQueue({
      item: function() {
        return data[i++](i < data.length ? void 0 : EOF);
      },
      action: function(item) {
        return (item * item) - 1;
      },
      latency: 10
    }).on("data", function(x) {
      return console.log("data:", x.on("error", function(x) {
        return console.log("error:", x.run());
      }));
    });
  });
