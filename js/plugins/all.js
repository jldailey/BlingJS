
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
          onload: function() {
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
              src: src
            });
          },
          style: function(src) {
            return lazy_load("link", {
              href: src,
              rel: "stylesheet"
            });
          }
        }
      };
    });
  })(Bling);
(function(d){return d.plugin(function(){var c,a;c=function(a,b){return Object.Extend(document.createElement(a),b)};a=function(a,b){var f,g,h;f=h=null;g=c(a,Object.Extend(b,{onload:function(){if(null!=h)return d.publish(h)}}));d("head").delay(10,function(){var b=this;return null!=f?d.subscribe(f,function(){return b.append(g)}):this.append(g)});g=d(g);return Object.Extend(g,{depends:function(b){f=a+"-"+b;return g},provides:function(b){h=a+"-"+b;return g}})};return{name:"LazyLoader",$:{script:function(c){return a("script",
{src:c})},style:function(c){return a("link",{href:c,rel:"stylesheet"})}}}})})(Bling);
(function(d){return d.plugin(function(){var c,a,e,b,f,g,h,k,s,m,j,n,o,l,i,r;j=/!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g;s=/\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g;c=
/\d+\.*\d*/g;a=/\$(\(|\.)/g;r=/\t/g;o=/\/\/.*?(?:\n|$)/;m=/\/\*(?:.|\n)*?\*\//;b=function(b){return b?"<span class='com'>"+b+"</span>":""};n=function(b){return b?"<span class='str'>"+b+"</span>":""};g=function(b,f){var a,c;a=b.indexOf('"',f);c=b.indexOf("'",f);-1===a&&(a=b.length);-1===c&&(c=b.length);return a===c?[null,-1]:a<c?['"',a]:["'",c]};e=function(b,a,f){for(a=b.indexOf(f,a);"\\"===b.charAt(a-1)&&0<a&&a<b.length;)a=b.indexOf(f,a+1);return a};i=function(b){var a,f,c,h,k;a=0;c=b.length;k=[];
if(!Object.IsString(b))if(Object.IsFunc(b.toString))b=b.toString(),c=b.length;else throw TypeError("invalid string argument to split_quoted");for(;a<c;){h=g(b,a);f=h[1];if(-1===f){k.push(b.substring(a));break}k.push(b.substring(a,f));a=e(b,f+1,h[0]);if(-1===a)throw Error("unclosed quote: "+h[0]+" starting at "+f);k.push(b.substring(f,a+1));a+=1}return k};f=function(b){var a;a=b.match(o);b=b.match(m);return a===b?[-1,null]:null===a&&null!==b?[b.index,b[0]]:null!==a&&null===b?[a.index,a[0]]:b.index<
a.index?[b.index,b[0]]:[a.index,a[0]]};l=function(b){var a,c,g,h,e,k;e=[];a=0;for(g=b.length;a<g;)if(k=b.substring(a),h=f(k),c=h[0],-1<c)e.push(k.substring(0,c)),e.push(h[1]),a+=c+h[1].length;else{e.push(k);break}return e};h=function(b,f){return b.replace(j,"<span class='opr'>$&</span>").replace(c,"<span class='num'>$&</span>").replace(s,"<span class='kwd'>$&</span>").replace(a,"<span class='bln'>$$</span>$1").replace(r,"&nbsp;&nbsp;")+n(f)};k=function(a,f){return d(i(a)).fold(h).join("")+b(f)};return{name:"PrettyPrint",
$:{prettyPrint:function(b,a){var f,c;Object.IsFunc(b)&&(b=b.toString());if(!Object.IsString(b))throw TypeError("prettyPrint requires a function or string to format, not '"+Object.Type(b)+"'");if(0===d("style#prettyPrint").length){c="code.pp .bln { font-size: 17px; } ";a=Object.Extend({opr:"#880",str:"#008",com:"#080",kwd:"#088",num:"#808",bln:"#800"},a);for(f in a)c+="code.pp ."+f+" { color: "+a[f]+"; } ";d.synth("style#prettyPrint").text(c).appendTo("head")}return"<code class='pp'>"+d(l(b)).fold(k).join("")+
"</code>"}}}})})(Bling);
(function(){var d=Object.prototype.hasOwnProperty,c=function(a,c){function b(){this.constructor=a}for(var f in c)d.call(c,f)&&(a[f]=c[f]);b.prototype=c.prototype;a.prototype=new b;a.__super__=c.prototype;return a};(function(a){var e,b;e={};a.plugin(function(){var b,a;b=null;e={};a={register_engine:function(a,c){e[a]=c;if(null==b)return b=a},render:function(a,c){if(b in e)return e[b](a,c)}};a.__defineSetter__("engine",function(a){if(!a in e)throw Error("invalid template engine: "+a+" not one of "+
Object.Keys[e]);return b=a});a.__defineGetter__("engine",function(){return b});return{name:"Template",$:{template:a}}});a.template.register_engine("null",function(){return function(b){return b}}());b=function(b,a,c,e,d){var m,j,n;null==d&&(d=-1);m=1;0>d&&(d=b.length+1+d);for(j=e;e<=d?j<d:j>d;e<=d?j++:j--)if(n=b[j],n===c?m+=1:n===a&&(m-=1),0===m)return j;return-1};a.template.register_engine("pythonic",function(){var a,c,e;e=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;a=/%[\(\/]/;c=
function(c){var g,d,j,n,o,l,i,c=c.split(a);o=c.length;i=[c[0]];for(d=j=1;1<=o?d<o:d>o;1<=o?d++:d--){g=b(c[d],")","(",0,-1);if(-1===g)return"Template syntax error: unmatched '%(' starting at: "+c[d].substring(0,15);n=c[d].substring(0,g);l=c[d].substring(g);g=e.exec(l);if(null===g)return"Template syntax error: invalid type specifier starting at '"+l+"'";l=g[4];i[j++]=n;i[j++]=g[1]|0;i[j++]=g[2]|0;i[j++]=g[3];i[j++]=l}return i};c.cache={};return function(b,a){var f,e,d,h,l,i,r,p,t,q,u;f=c.cache[b];null==
f&&(f=c.cache[b]=c(b));i=[f[0]];h=1;e=f.length;d=1;for(u=e-5;d<=u;d+=5){p=f.slice(d,d+4+1||9E9);l=p[0];r=p[1];e=p[2];t=p[3];p=p[4];q=a[l];null==q&&(q="missing value: "+l);switch(t){case "d":i[h++]=""+parseInt(q,10);break;case "f":i[h++]=parseFloat(q).toFixed(e);break;case "s":i[h++]=""+q;break;default:i[h++]=""+q}0<r&&(i[h]=String.PadLeft(i[h],r));i[h++]=p}return i.join("")}}());return a.template.register_engine("js-eval",function(){(function(){function b(){b.__super__.constructor.apply(this,arguments)}
c(b,a.StateMachine);b.STATE_TABLE=[{enter:function(){this.data=[];return this.GO(1)}},{}];return b})();return function(b){return b}}())})(Bling)}).call(this);
(function(d){return d.plugin(function(){var c,a,e;e=function(b){var f,g,e,d;f=b.indexOf(":");if(0<f)return e=parseInt(b.slice(0,f),10),g=b.slice(f+1,f+1+e),d=b[f+1+e],b=b.slice(f+e+2),g=function(){switch(d){case "#":return Number(g);case "'":return""+g;case "!":return"true"===g;case "~":return null;case "]":return c(g);case "}":return a(g)}}(),[g,b]};c=function(b){var a,c;for(a=[];0<b.length;)b=e(b),c=b[0],b=b[1],a.push(c);return a};a=function(b){var a,c,d;for(a={};0<b.length;)d=e(b),c=d[0],b=d[1],
b=e(b),d=b[0],b=b[1],a[c]=d;return a};return{name:"TNET",$:{TNET:{stringify:function(b){var a,c,e;e=function(){switch(Object.Type(b)){case "number":return[""+b,"#"];case "string":return[b,"'"];case "function":return[""+b,"'"];case "boolean":return[""+!!b,"!"];case "null":return["","~"];case "undefined":return["","~"];case "array":return[function(){var a,e,f;f=[];a=0;for(e=b.length;a<e;a++)c=b[a],f.push(d.TNET.stringify(c));return f}().join(""),"]"];case "object":return[function(){var a;a=[];for(c in b)a.push(d.TNET.stringify(c)+
d.TNET.stringify(b[c]));return a}().join(""),"}"]}}();a=e[0];return(a.length|0)+":"+a+e[1]},parse:function(a){var c;return null!=(c=e(a))?c[0]:void 0}}}}})})(Bling);
(function(d){return d.plugin(function(){Dialog(selector,opts)(function(){var c,a;a=Object.Extend({autoOpen:!1,draggable:!0},a);c=d(selector).addClass("dialog");a.draggable&&c.draggable();a.autoOpen&&c.show().center();c.find("button.close, .close-button").bind("click touchstart",function(){c.hide();return!1});return c});Draggable(selector,opts)(function(){var c,a,e,b,f,g;g=Object.Extend({handleCSS:{}},g);g.handleCSS=Object.Extend({position:"absolute",top:"0px",left:"0px",width:"100%",height:"6px"},
g.handleCSS);c=d(selector);e=!1;b=f=0;a=d.synth("div.handle").defaultCss({background:"-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",height:"6px","border-radius":"3px",cursor:"move"}.css(g.handleCSS.bind("mousedown, touchstart",function(a){e=!0;b||(b=a.pageX);f||(f=a.pageY);return!1})));d(document.bind("mousemove, touchmove",function(a){var d;if(e)return d=a.pageX-b,a=a.pageY-f,c.transform({translate:[d,a]},0).trigger("drag",
{dragObject:c}),!1})).bind("mouseup, touchend",function(){var b;if(e)return e=!1,b=a.position()[0],d(document.elementFromPoint(b.left,b.top-1).trigger("drop",{dropObject:c}))});return c.addClass("draggable").css({position:"relative","padding-top":c.css("padding-top").map(Number.AtLeast(parseInt(g.handleCSS.height,10))).px().first()}.append(a))});ProgressBar(selector,opts)(function(){var c,a,e,b,f;a=Object.Extend({change:Function.Empty,backgroundColor:"#fff",barColor:"rgba(0,128,0,0.5)",textColor:"white",
reset:!1},a);c=d(selector).addClass("progress-bar");f=0;a.reset&&(e=c.css("background").first(),b=c.css("color").first());return c.zap("updateProgress",function(d){for(;d>1;)d=d/100;f=d;d===1&&a.reset?c.css("background",e).css("color",b):c.css({background:"-webkit-gradient(linear, 0 0, "+parseInt(d*100)+"% 0, color-stop(0, "+a.barColor+"), color-stop(0.98, "+a.barColor+"), color-stop(1.0, "+a.backgroundColor+"))",color:a.textColor});if(Object.IsFunc(a.change))return a.change(f)})});Accordion(selector,
opts)(function(){var c,a,e;e=Object.Extend({exclusive:!1,sticky:!1},e);a=d(selector).addClass("accordion");c=function(b){var c,g,h,b=d(b).children().first().filter("*");if(2!==b.len())throw Exception("accordion row requires 2 elements, not "+b.len());h=b.eq(0).addClass("title");c=b.eq(1).addClass("body").hide();g=!1;return h.click(function(){e.exclusive&&a.find(".body").hide();if(g){if(e.sticky)return c.show().addClass("visible"),h.addClass("selected").trigger("select"),g=!0;c.hide().removeClass("visible");
h.removeClass("selected").trigger("deselect");return g=!1}c.show().addClass("visible");h.addClass("selected").trigger("select");return g=!0})};a.bind("DOMNodeInserted",function(b){var e;e=a.children().first().filter("*");b=d(b.target).parents().first();return c(b.intersect(e))});a.children().first().filter("*").map(c);return a});ViewStack(selector,opts)(function(){var c,a,e,b;a=d(selector).css({position:"relative",top:"0px",left:"0px"}.hide().map(d));c=0;a[c].show();a.next=function(){a[c].hide();
c=++c%nn;return a[c].show()};a.activate=function(b){a[c].hide();c=b;return a[b].show()};e=0;for(b=a.len();0<=b?e<b:e>b;0<=b?e++:e--)a[e].zap("_viewIndex",e.zap("activate",function(){return a.activate(this._viewIndex)}));return a});Tabs(selector,views)(function(){var c,a,e,b;e=d(selector);b=d(b).viewStack();a=e.len();for(c=0;0<=a?c<=a:c>=a;0<=a?c++:c--)e._tabIndex=c;d(e[0]).addClass("active");return e.click(function(){e.removeClass("active");b.activate(this._tabIndex);return d(this).addClass("active")})});
return{name:"UI",$:{UI:{Draggable:Draggable,ProgressBar:ProgressBar,ViewStack:ViewStack,Tabs:Tabs,Accordion:Accordion}},dialog:function(c){return Dialog(this,c)},progressBar:function(c){return ProgressBar(this,c)},viewStack:function(c){return ViewStack(this,c)},tabs:function(c){return Tabs(this,c)},accordion:function(c){return Accordion(this,c)},draggable:function(c){return Draggable(this,c)}}})})(Bling);
(function(a){return a.plugin(function(){var g,d;g=function(c,a){return Object.Extend(document.createElement(c),a)};d=function(c,d){var e,b,f;e=f=null;b=g(c,Object.Extend(d,{onload:function(){if(null!=f)return a.publish(f)}}));a("head").delay(10,function(){var c=this;return null!=e?a.subscribe(e,function(){return c.append(b)}):this.append(b)});b=a(b);return Object.Extend(b,{depends:function(a){e=c+"-"+a;return b},provides:function(a){f=c+"-"+a;return b}})};return{name:"LazyLoader",$:{script:function(a){return d("script",
{src:a})},style:function(a){return d("link",{href:a,rel:"stylesheet"})}}}})})(Bling);
(function(f){return f.plugin(function(){var h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w;r=/!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g;p=/\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g;
h=/\d+\.*\d*/g;i=/\$(\(|\.)/g;w=/\t/g;t=/\/\/.*?(?:\n|$)/;q=/\/\*(?:.|\n)*?\*\//;k=function(a){return a?"<span class='com'>"+a+"</span>":""};s=function(a){return a?"<span class='str'>"+a+"</span>":""};m=function(a,b){var c,d;c=a.indexOf('"',b);d=a.indexOf("'",b);-1===c&&(c=a.length);-1===d&&(d=a.length);return c===d?[null,-1]:c<d?['"',c]:["'",d]};j=function(a,b,c){for(b=a.indexOf(c,b);"\\"===a.charAt(b-1)&&0<b&&b<a.length;)b=a.indexOf(c,b+1);return b};v=function(a){var b,c,d,g,e;b=0;d=a.length;e=
[];if(!Object.IsString(a))if(Object.IsFunc(a.toString))a=a.toString(),d=a.length;else throw TypeError("invalid string argument to split_quoted");for(;b<d;){g=m(a,b);c=g[1];if(-1===c){e.push(a.substring(b));break}e.push(a.substring(b,c));b=j(a,c+1,g[0]);if(-1===b)throw Error("unclosed quote: "+g[0]+" starting at "+c);e.push(a.substring(c,b+1));b+=1}return e};l=function(a){var b;b=a.match(t);a=a.match(q);return b===a?[-1,null]:null===b&&null!==a?[a.index,a[0]]:null!==b&&null===a?[b.index,b[0]]:a.index<
b.index?[a.index,a[0]]:[b.index,b[0]]};u=function(a){var b,c,d,g,e,f;e=[];b=0;for(d=a.length;b<d;)if(f=a.substring(b),g=l(f),c=g[0],-1<c)e.push(f.substring(0,c)),e.push(g[1]),b+=c+g[1].length;else{e.push(f);break}return e};n=function(a,b){return a.replace(r,"<span class='opr'>$&</span>").replace(h,"<span class='num'>$&</span>").replace(p,"<span class='kwd'>$&</span>").replace(i,"<span class='bln'>$$</span>$1").replace(w,"&nbsp;&nbsp;")+s(b)};o=function(a,b){return f(v(a)).fold(n).join("")+k(b)};return{name:"PrettyPrint",
$:{prettyPrint:function(a,b){var c,d;Object.IsFunc(a)&&(a=a.toString());if(!Object.IsString(a))throw TypeError("prettyPrint requires a function or string to format, not '"+Object.Type(a)+"'");if(0===f("style#prettyPrint").length){d="code.pp .bln { font-size: 17px; } ";b=Object.Extend({opr:"#880",str:"#008",com:"#080",kwd:"#088",num:"#808",bln:"#800"},b);for(c in b)d+="code.pp ."+c+" { color: "+b[c]+"; } ";f.synth("style#prettyPrint").text(d).appendTo("head")}return"<code class='pp'>"+f(u(a)).fold(o).join("")+
"</code>"}}}})})(Bling);
(function(){var r=Object.prototype.hasOwnProperty,s=function(b,a){function j(){this.constructor=b}for(var c in a)r.call(a,c)&&(b[c]=a[c]);j.prototype=a.prototype;b.prototype=new j;b.__super__=a.prototype;return b};(function(b){var a,j;a={};b.plugin(function(){var c,o;c=null;a={};o={register_engine:function(g,l){a[g]=l;if(null==c)return c=g},render:function(g,l){if(c in a)return a[c](g,l)}};o.__defineSetter__("engine",function(g){if(!g in a)throw Error("invalid template engine: "+g+" not one of "+
Object.Keys[a]);return c=g});o.__defineGetter__("engine",function(){return c});return{name:"Template",$:{template:o}}});b.template.register_engine("null",function(){return function(c){return c}}());j=function(c,a,g,l,e){var d,f,n;null==e&&(e=-1);d=1;0>e&&(e=c.length+1+e);for(f=l;l<=e?f<e:f>e;l<=e?f++:f--)if(n=c[f],n===g?d+=1:n===a&&(d-=1),0===d)return f;return-1};b.template.register_engine("pythonic",function(){var c,a,g;g=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;c=/%[\(\/]/;a=
function(a){var e,d,f,n,i,b,h,a=a.split(c);i=a.length;h=[a[0]];for(d=f=1;1<=i?d<i:d>i;1<=i?d++:d--){e=j(a[d],")","(",0,-1);if(-1===e)return"Template syntax error: unmatched '%(' starting at: "+a[d].substring(0,15);n=a[d].substring(0,e);b=a[d].substring(e);e=g.exec(b);if(null===e)return"Template syntax error: invalid type specifier starting at '"+b+"'";b=e[4];h[f++]=n;h[f++]=e[1]|0;h[f++]=e[2]|0;h[f++]=e[3];h[f++]=b}return h};a.cache={};return function(c,e){var d,f,b,i,g,h,j,k,p,m,q;d=a.cache[c];null==
d&&(d=a.cache[c]=a(c));h=[d[0]];i=1;f=d.length;b=1;for(q=f-5;b<=q;b+=5){k=d.slice(b,b+4+1||9E9);g=k[0];j=k[1];f=k[2];p=k[3];k=k[4];m=e[g];null==m&&(m="missing value: "+g);switch(p){case "d":h[i++]=""+parseInt(m,10);break;case "f":h[i++]=parseFloat(m).toFixed(f);break;case "s":h[i++]=""+m;break;default:h[i++]=""+m}0<j&&(h[i]=String.PadLeft(h[i],j));h[i++]=k}return h.join("")}}());return b.template.register_engine("js-eval",function(){(function(){function a(){a.__super__.constructor.apply(this,arguments)}
s(a,b.StateMachine);a.STATE_TABLE=[{enter:function(){this.data=[];return this.GO(1)}},{}];return a})();return function(a){return a}}())})(Bling)}).call(this);
(function(f){return f.plugin(function(){var g,h,e;e=function(a){var b,c,d,i;b=a.indexOf(":");if(0<b)return d=parseInt(a.slice(0,b),10),c=a.slice(b+1,b+1+d),i=a[b+1+d],a=a.slice(b+d+2),c=function(){switch(i){case "#":return Number(c);case "'":return""+c;case "!":return"true"===c;case "~":return null;case "]":return g(c);case "}":return h(c)}}(),[c,a]};g=function(a){var b,c;for(b=[];0<a.length;)a=e(a),c=a[0],a=a[1],b.push(c);return b};h=function(a){var b,c,d;for(b={};0<a.length;)d=e(a),c=d[0],a=d[1],
a=e(a),d=a[0],a=a[1],b[c]=d;return b};return{name:"TNET",$:{TNET:{stringify:function(a){var b,c,d;d=function(){switch(Object.Type(a)){case "number":return[""+a,"#"];case "string":return[a,"'"];case "function":return[""+a,"'"];case "boolean":return[""+!!a,"!"];case "null":return["","~"];case "undefined":return["","~"];case "array":return[function(){var b,d,e;e=[];b=0;for(d=a.length;b<d;b++)c=a[b],e.push(f.TNET.stringify(c));return e}().join(""),"]"];case "object":return[function(){var b;b=[];for(c in a)b.push(f.TNET.stringify(c)+
f.TNET.stringify(a[c]));return b}().join(""),"}"]}}();b=d[0];return(b.length|0)+":"+b+d[1]},parse:function(a){var b;return null!=(b=e(a))?b[0]:void 0}}}}})})(Bling);
(function(f){return f.plugin(function(){Dialog(selector,opts)(function(){var a,b;b=Object.Extend({autoOpen:!1,draggable:!0},b);a=f(selector).addClass("dialog");b.draggable&&a.draggable();b.autoOpen&&a.show().center();a.find("button.close, .close-button").bind("click touchstart",function(){a.hide();return!1});return a});Draggable(selector,opts)(function(){var a,b,c,e,g,d;d=Object.Extend({handleCSS:{}},d);d.handleCSS=Object.Extend({position:"absolute",top:"0px",left:"0px",width:"100%",height:"6px"},
d.handleCSS);a=f(selector);c=!1;e=g=0;b=f.synth("div.handle").defaultCss({background:"-webkit-gradient(linear, 50% 0%, 50% 100%, from(#eee), color-stop(0.25, #bbb), color-stop(0.3, #eee), color-stop(0.5, #eee), to(#bbb))",height:"6px","border-radius":"3px",cursor:"move"}.css(d.handleCSS.bind("mousedown, touchstart",function(a){c=!0;e||(e=a.pageX);g||(g=a.pageY);return!1})));f(document.bind("mousemove, touchmove",function(b){var d;if(c)return d=b.pageX-e,b=b.pageY-g,a.transform({translate:[d,b]},0).trigger("drag",
{dragObject:a}),!1})).bind("mouseup, touchend",function(){var e;if(c)return c=!1,e=b.position()[0],f(document.elementFromPoint(e.left,e.top-1).trigger("drop",{dropObject:a}))});return a.addClass("draggable").css({position:"relative","padding-top":a.css("padding-top").map(Number.AtLeast(parseInt(d.handleCSS.height,10))).px().first()}.append(b))});ProgressBar(selector,opts)(function(){var a,b,c,e,g;b=Object.Extend({change:Function.Empty,backgroundColor:"#fff",barColor:"rgba(0,128,0,0.5)",textColor:"white",
reset:!1},b);a=f(selector).addClass("progress-bar");g=0;b.reset&&(c=a.css("background").first(),e=a.css("color").first());return a.zap("updateProgress",function(d){for(;d>1;)d=d/100;g=d;d===1&&b.reset?a.css("background",c).css("color",e):a.css({background:"-webkit-gradient(linear, 0 0, "+parseInt(d*100)+"% 0, color-stop(0, "+b.barColor+"), color-stop(0.98, "+b.barColor+"), color-stop(1.0, "+b.backgroundColor+"))",color:b.textColor});if(Object.IsFunc(b.change))return b.change(g)})});Accordion(selector,
opts)(function(){var a,b,c;c=Object.Extend({exclusive:!1,sticky:!1},c);b=f(selector).addClass("accordion");a=function(a){var g,d,h,a=f(a).children().first().filter("*");if(2!==a.len())throw Exception("accordion row requires 2 elements, not "+a.len());h=a.eq(0).addClass("title");g=a.eq(1).addClass("body").hide();d=!1;return h.click(function(){c.exclusive&&b.find(".body").hide();if(d){if(c.sticky)return g.show().addClass("visible"),h.addClass("selected").trigger("select"),d=!0;g.hide().removeClass("visible");
h.removeClass("selected").trigger("deselect");return d=!1}g.show().addClass("visible");h.addClass("selected").trigger("select");return d=!0})};b.bind("DOMNodeInserted",function(c){var g;g=b.children().first().filter("*");c=f(c.target).parents().first();return a(c.intersect(g))});b.children().first().filter("*").map(a);return b});ViewStack(selector,opts)(function(){var a,b,c,e;b=f(selector).css({position:"relative",top:"0px",left:"0px"}.hide().map(f));a=0;b[a].show();b.next=function(){b[a].hide();
a=++a%nn;return b[a].show()};b.activate=function(c){b[a].hide();a=c;return b[c].show()};c=0;for(e=b.len();0<=e?c<e:c>e;0<=e?c++:c--)b[c].zap("_viewIndex",c.zap("activate",function(){return b.activate(this._viewIndex)}));return b});Tabs(selector,views)(function(){var a,b,c,e;c=f(selector);e=f(e).viewStack();b=c.len();for(a=0;0<=b?a<=b:a>=b;0<=b?a++:a--)c._tabIndex=a;f(c[0]).addClass("active");return c.click(function(){c.removeClass("active");e.activate(this._tabIndex);return f(this).addClass("active")})});
return{name:"UI",$:{UI:{Draggable:Draggable,ProgressBar:ProgressBar,ViewStack:ViewStack,Tabs:Tabs,Accordion:Accordion}},dialog:function(a){return Dialog(this,a)},progressBar:function(a){return ProgressBar(this,a)},viewStack:function(a){return ViewStack(this,a)},tabs:function(a){return Tabs(this,a)},accordion:function(a){return Accordion(this,a)},draggable:function(a){return Draggable(this,a)}}})})(Bling);

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
          throw new Error("invalid template engine: " + v + " not one of " + Object.Keys[engines]);
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
