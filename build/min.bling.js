function Bling(e,k){if(Object.IsBling(e))return e;k=k||document;var i=null;if(e==null)i=[];else if(typeof e==="number")i=Array(e);else if(e===window||Object.IsNode(e))i=[e];else if(typeof e==="string"){e=e.trimLeft();if(e[0]==="<")i=[Bling.HTML.parse(e)];else if(k.querySelectorAll)try{i=k.querySelectorAll(e)}catch(n){throw Error("invalid selector: "+e,n);}else if(Object.IsBling(k))i=k.reduce(function(l,B){for(var E=B.querySelectorAll(e),F=0,I=E.length;F<I;F++)l.push(E[F]);return l},[]);else throw Error("invalid context: "+
k);}else i=e;i.__proto__=Bling.fn;i.selector=e;i.context=k;return i}Bling.fn=[];Bling.fn.constructor=Bling;Bling.symbol="$";window[Bling.symbol]=Bling;Object.Keys=function(e,k){var i=[],n=0,l=null;for(l in e)if(k||e.hasOwnProperty(l))i[n++]=l;return i};Object.Extend=function(e,k,i){var n;if(Object.prototype.toString.apply(i)=="[object Array]")for(n in i)e[i[n]]=k[i[n]]!=void 0?k[i[n]]:e[i[n]];else for(n in i=Object.Keys(k))e[i[n]]=k[i[n]];return e};
Object.Extend(Object,{Values:function(e,k){var i=Object.Keys(e,k),n={},l=0,B=null;for(l in i){B=i[l];n[e[B]]=B}return n},IsType:function(e,k){return e==null?e===k:e.__proto__==null?false:e.__proto__.constructor===k?true:typeof k==="string"?e.__proto__.constructor.name===k:Object.IsType(e.__proto__,k)},IsString:function(e){return typeof e==="string"||Object.IsType(e,String)},IsNumber:isFinite,IsFunc:function(e){return typeof e==="function"||Object.IsType(e,Function)},IsNode:function(e){return e?e.nodeType>
0:false},IsFragment:function(e){return e?e.nodeType===11:false},IsArray:function(e){return e?Function.ToString(e)==="[object Array]"||Object.IsType(e,Array):false},IsBling:function(e){return Object.IsType(e,Bling)},IsObject:function(e){return typeof e==="object"},HasValue:function(e){return e!=null},Unbox:function(e){if(Object.IsObject(e))switch(true){case Object.IsString(e):return e.toString();case Object.IsNumber(e):return Number(e)}return e}});
Object.Extend(Function,{Empty:function(){},Bound:function(e,k,i){i=i||[];i.splice(0,0,k);i=e.bind.apply(e,i);i.toString=function(){return"bound-method of "+k+"."+e.name};return i},Trace:function(e,k){var i=function(){console.log(k?k:""+(this.name?this.name:this),"."+e.name+"(",Array.Slice(arguments,0),")");return e.apply(this,arguments)};i.toString=function(){return e.toString()};console.log("Function.Trace:",k?k:e.name,"created");return i},NotNull:function(e){return e!=null},IndexFound:function(e){return e>
-1},ReduceAnd:function(e){return e&&this},UpperLimit:function(e){return function(k){return Math.min(e,k)}},LowerLimit:function(e){return function(k){return Math.max(e,k)}},ToString:function(e){return Object.prototype.toString.apply(e)},Px:function(e){return function(){return Number.Px(this,e)}}});Object.Extend(Array,{Slice:function(e,k,i){var n=[],l=0,B=e.length;i=i==null?B:i<0?B+i:i;for(k=k==null?0:k<0?B+k:k;k<i;)n[l++]=e[k++];return n}});
Object.Extend(Number,function(){var e=Math.max,k=Math.min;return{Px:function(i,n){return parseInt(i,10)+(n|0)+"px"},AtLeast:function(i){return function(n){return e(parseFloat(n||0),i)}},AtMost:function(i){return function(n){return k(parseFloat(n||0),i)}}}}());
Object.Extend(String,{PadLeft:function(e,k,i){for(i=i||" ";e.length<k;)e=i+e;return e},PadRight:function(e,k,i){for(i=i||" ";e.length<k;)e+=i;return e},Splice:function(e,k,i,n){var l=e.length;i=i==null?l:i<0?l+i:i;return e.substring(0,k==null?0:k<0?l+k:k)+n+e.substring(i)}});
Object.Extend(Event,{Prevent:function(e){e.stopPropagation();e.preventDefault();e.cancelBubble=true;e.returnValue=false},Stop:function(e){e.preventDefault();e.cancelBubble=true},Cancel:function(e){e.stopPropagation();e.returnValue=false}});
(function(e){var k=", ",i=/, */,n=" ",l="",B=/\[object (\w+)\]/,E=Math.min,F=Math.max,I=Math.ceil,K=Math.sqrt;e.plugin=function(j){var p=j.call(e,e),g=Object.Keys(p,true),c,b,a=arguments.callee.s=arguments.callee.s||[];for(c in g){b=g[c];if(b.charAt(0)==="$")e[b.substr(1)]=p[b];else e.fn[b]=p[b]}a.push(j.name);a[j.name]=p};e.plugin(function(){function j(c){var b;return function(){b=this[c];return Object.IsFunc(b)?Function.Bound(b,this):b}}function p(c){var b=c.indexOf(".");return b>-1?this.zip(c.substr(0,
b)).zip(c.substr(b+1)):this.map(j(c))}var g=new function(){this.queue=[];this.next=Function.Bound(function(){this.queue.length>0&&this.queue.shift()()},this);this.schedule=function(c,b){if(Object.IsFunc(c)){var a=this.queue.length;c.order=b+(new Date).getTime();if(a===0||c.order>this.queue[a-1].order)this.queue[a]=c;else{for(var d=false,f=0;f<a;f++)if(this.queue[f].order>c.order){this.queue.splice(f,0,c);d=true;break}d||this.queue.push(c)}setTimeout(this.next,b)}}};return{eq:function(c){return e([this[c]])},
each:function(c){for(var b=-1,a=this.length,d=null;++b<a;){d=this[b];c.call(d,d)}return this},map:function(c){var b=this.len(),a=e(b),d=0,f=null;a.context=this;for(a.selector=c;d<b;d++){f=this[d];try{a[d]=c.call(f,f)}catch(h){a[d]=h}}return a},reduce:function(c,b){if(!c)return this;var a=b,d=this;if(b==null){a=this[0];d=this.skip(1)}d.each(function(){a=c.call(this,a,this)});return a},union:function(c,b){var a=e(),d,f,h=d=f=0;a.context=this.context;for(a.selector=this.selector;h=this[f++];)a.contains(h,
b)||(a[d++]=h);for(f=0;h=c[f++];)a.contains(h,b)||(a[d++]=h);return a},intersect:function(c){var b=e(),a=0,d=0,f=this.length,h=c.length;b.context=this.context;for(b.selector=this.selector;a<f;a++)for(d=0;d<h;d++)if(this[a]===c[d]){b[b.length]=this[a];break}return b},distinct:function(c){return this.union(this,c)},contains:function(c,b){return this.count(c,b)>0},count:function(c,b){if(c===void 0)return this.len();var a=0;this.each(function(d){if(b&&d===c||!b&&d==c)a++});return a},zip:function(){switch(arguments.length){case 0:return this;
case 1:return p.call(this,arguments[0]);default:for(var c={},b=e(),a=arguments.length,d=this.length,f=0,h=0,m=null;f<a;f++)c[arguments[f]]=p.call(this,arguments[f]);for(f=0;f<d;f++){a={};for(m in c)a[m]=c[m].shift();b[h++]=a}return b}},zap:function(c,b){if(!c)return this;var a=c.indexOf(".");return a>-1?this.zip(c.substr(0,a)).zap(c.substr(a+1),b):Object.IsArray(b)?this.each(function(d){d[c]=b[++a]}):this.each(function(){this[c]=b})},take:function(c){c=E(c|0,this.len());var b=e(c),a=-1;b.context=
this.context;for(b.selector=this.selector;++a<c;)b[a]=this[a];return b},skip:function(c){c=E(this.len(),F(0,c|0));var b=0,a=this.len()-c,d=e(a);d.context=this.context;for(d.selector=this.selector;b<a;b++)d[b]=this[b+c];return d},first:function(c){return c?this.take(c):this[0]},last:function(c){return c?this.skip(this.len()-c):this[this.length-1]},join:function(c){if(this.length===0)return l;return this.reduce(function(b){return b+c+this})},slice:function(c,b){var a=e(Array.Slice(this,c,b));a.context=
this.context;a.selector=this.selector;return a},concat:function(c){for(var b=this.len()-1,a=-1,d=c.length;a<d-1;)this[++b]=c[++a];return this},push:function(c){Array.prototype.push.call(this,c);return this},filter:function(c){var b=0,a=-1,d=this.length,f=e(),h=null;f.context=this;for(f.selector=c;b<d;b++)if(h=this[b])if(Object.IsFunc(c)&&c.call(h,h)||Object.IsString(c)&&h.webkitMatchesSelector&&h.webkitMatchesSelector(c)||Object.IsType(c,"RegExp")&&c.test(h))f[++a]=h;return f},matches:function(c){if(Object.IsType(c,
"RegExp"))return this.map(function(){return c.test(this)});return Object.IsString(c)?this.zip("webkitMatchesSelector").call(c):this.map(function(){})},weave:function(c){var b=c.length,a=this.length,d=e(2*F(a,b));a=a-1;d.context=this.context;for(d.selector=this.selector;a>=0;a--)d[a*2+1]=this[a];for(;++a<b;)d[a*2]=c[a];return d},fold:function(c){var b=this.len(),a=0,d=e(I(b/2)),f=0;d.context=this.context;d.selector=this.selector;for(f=0;f<b-1;f+=2)d[a++]=c.call(this,this[f],this[f+1]);if(b%2===1)d[a++]=
c.call(this,this[b-1],undefined);return d},flatten:function(){var c=e(),b=this.len(),a=null,d=0,f=0,h=0,m=0;c.context=this.context;for(c.selector=this.selector;f<b;f++){a=this[f];h=0;for(d=a.length;h<d;)c[m++]=a[h++]}return c},call:function(){return this.apply(null,arguments)},apply:function(c,b){return this.map(function(){if(Object.IsFunc(this))return this.apply(c,b);return this})},toString:function(){return e.symbol+"(["+this.map(function(){return this===undefined||this===window?"undefined":this===
null?"null":this.toString().replace(B,"$1")}).join(k)+"])"},future:function(c,b){b&&g.schedule(Function.Bound(b,this),c);return this},log:function(c){c?console.log(c,this,this.length+" items"):console.log(this,this.length+" items");return this},len:function(){for(var c=this.length;c>-1&&this[--c]===undefined;);return c+1}}});e.plugin(function(){function j(a,d){a&&d&&a.parentNode.insertBefore(d,a)}function p(a){return Object.IsNode(a)?a:Object.IsBling(a)?a.toFragment():Object.IsString(a)?e(a).toFragment():
Object.IsFunc(a.toString)?e(a.toString()).toFragment():undefined}function g(a){for(var d=a.cloneNode(),f=0,h=a.childNodes.length;f<h;f++)d.appendChild(g(a.childNodes[f]));return d}function c(a){return function(){window.getComputedStyle(this,null).getPropertyValue(a)}}var b=null;return{$HTML:{parse:function(a){var d=document.createElement("html"),f=document.createDocumentFragment();d.innerHTML=a;a=d.childNodes[1];d=a.childNodes;var h=d.length;if(h===1)return a.removeChild(d[0]);for(var m=0;m<h;m++)f.appendChild(a.removeChild(d[0]));
return f},stringify:function(a){a=g(a);var d=document.createElement("div");d.appendChild(a);var f=d.innerHTML;d.removeChild(a);a.parentNode=null;return f},escape:function(a){b=b||e("<div>&nbsp;</div>").child(0);a=b.zap("data",a).zip("parentNode.innerHTML").first();b.zap("data",l);return a}},$Color:{fromCss:function(a){a=a||this;if(Object.IsString(a)){var d=document.createElement("div");d.style.display="none";d.style.color=a;a=e(d).appendTo(document.body);d=window.getComputedStyle(d,null).getPropertyValue("color");
a.remove();if(d){d=d.slice(d.indexOf("(")+1,d.indexOf(")")).split(i);if(d.length===3)d[3]="1.0";return e(d).floats()}}},toCss:function(a){function d(f){f=f.map(Function.UpperLimit(255)).map(Function.LowerLimit(0));f[3]=E(1,f[3]);return"rgba("+f.join(k)+")"}a=a||this;return Object.IsBling(a[0])?a.map(d):d(a)},invert:function(a){var d=e(4);if(Object.IsString(a))a=e.Color.fromCss(a);d[0]=255-a[0];d[1]=255-a[1];d[2]=255-a[2];d[3]=a[3];return d}},html:function(a){return a===undefined?this.zip("innerHTML"):
Object.IsString(a)?this.zap("innerHTML",a):Object.IsBling(a)?this.html(a.toFragment()):Object.IsNode(a)?this.each(function(){for(this.replaceChild(this.childNodes[0],a);this.childNodes.length>1;)this.removeChild(this.childNodes[1])}):undefined},append:function(a){if(a==null)return this;a=p(a);var d=this.zip("appendChild");d.take(1).call(a);d.skip(1).each(function(){this(g(a))});return this},appendTo:function(a){if(a==null)return this;e(a).append(this);return this},prepend:function(a){if(a==null)return this;
a=p(a);this.take(1).each(function(){j(this.childNodes[0],a)});this.skip(1).each(function(){j(this.childNodes[0],g(a))});return this},prependTo:function(a){if(a==null)return this;e(a).prepend(this);return this},before:function(a){if(a==null)return this;a=p(a);this.take(1).each(function(){j(this,a)});this.skip(1).each(function(){j(this,g(a))});return this},after:function(a){if(a==null)return this;a=p(a);this.take(1).each(function(){this.parentNode.insertBefore(a,this.nextSibling)});this.skip(1).each(function(){this.parentNode.insertBefore(g(a),
this.nextSibling)});return this},wrap:function(a){a=p(a);if(Object.IsFragment(a))throw Error("cannot wrap something with a fragment");return this.map(function(d){if(Object.IsFragment(d))a.appendChild(d);else if(Object.IsNode(d)){var f=d.parentNode;if(f){var h=document.createElement("dummy");a.appendChild(f.replaceChild(h,d));f.replaceChild(a,h)}else a.appendChild(d)}return d})},unwrap:function(){return this.each(function(){this.parentNode&&this.parentNode.parentNode&&this.parentNode.parentNode.replaceChild(this,
this.parentNode)})},replace:function(a){a=p(a);var d=e(),f=-1;this.take(1).each(function(){if(this.parentNode){this.parentNode.replaceChild(a,this);d[++f]=a}});this.skip(1).each(function(){if(this.parentNode){var h=g(a);this.parentNode.replaceChild(h,this);d[++f]=h}});return d},attr:function(a,d){var f=this.zip(d===undefined?"getAttribute":d===null?"removeAttribute":"setAttribute").call(a,d);return d?this:f},addClass:function(a){return this.removeClass(a).each(function(){var d=this.className.split(n).filter(function(f){return f&&
f!=l});d.push(a);this.className=d.join(n)})},removeClass:function(a){var d=function(f){return f!=a};return this.each(function(){this.className=this.className.split(n).filter(d).join(n)})},toggleClass:function(a){function d(f){return f!=a}return this.each(function(f){var h=f.className.split(n);if(h.indexOf(a)>-1)f.className=h.filter(d).join(n);else{h.push(a);f.className=h.join(n)}})},hasClass:function(a){return this.zip("className.split").call(n).zip("indexOf").call(a).map(Function.IndexFound)},text:function(a){return a?
this.zap("textContent",a):this.zip("textContent")},val:function(a){return a?this.zap("value",a):this.zip("value")},css:function(a,d){if(Object.HasValue(d)||Object.IsObject(a)){var f=this.zip("style.setProperty"),h=0,m=0,u=f.length;if(Object.IsString(a))f.call(a,d);else if(Object.IsArray(d))for(m=F(d.length,u);h<m;h++)f[h%u](d[h%m]);else if(Object.IsObject(a))for(h in a)f.call(h,a[h]);return this}f=this.map(c(a));return this.zip("style").zip(a).weave(f).fold(function(q,w){return q?q:w})},defaultCss:function(a,
d){var f=this.selector,h=l;if(Object.IsString(a))if(Object.IsString(d))h+=f+" { "+a+": "+d+" } ";else throw Error("defaultCss requires a value with a string key");else if(Object.IsObject(a)){h+=f+" { ";for(var m in a)h+=m+": "+a[m]+"; ";h+="} "}e.synth("style").text(h).appendTo("head");return this},empty:function(){return this.html(l)},rect:function(){return this.zip("getBoundingClientRect").call()},width:function(a){return a==null?this.rect().zip("width"):this.css("width",a)},height:function(a){return a==
null?this.rect().zip("height"):this.css("height",a)},top:function(a){return a==null?this.rect().zip("top"):this.css("top",a)},left:function(a){return a==null?this.rect().zip("left"):this.css("left",a)},bottom:function(a){return a==null?this.rect().zip("bottom"):this.css("bottom",a)},right:function(a){return a==null?this.rect().zip("right"):this.css("right",a)},position:function(a,d){return a==null?this.rect():d==null?this.css("left",Number.Px(a)):this.css({top:Number.Px(d),left:Number.Px(a)})},center:function(a){a=
a||"viewport";var d=document.body.scrollLeft+document.body.clientHeight/2,f=document.body.scrollTop+document.body.clientWidth/2;return this.each(function(){var h=e(this),m=h.height().floats().first(),u=h.width().floats().first();u=a==="viewport"||a==="horizontal"?f-u/2:NaN;m=a==="viewport"||a==="vertical"?d-m/2:NaN;h.css({position:"absolute",left:Object.IsNumber(u)?u+"px":undefined,top:Object.IsNumber(m)?m+"px":undefined})})},trueColor:function(a,d){a=a||"background-color";d=d||function(f){f[0]+=
(this[0]-f[0])*this[3];f[1]+=(this[1]-f[1])*this[3];f[2]+=(this[2]-f[2])*this[3];f[3]=E(1,f[3]+this[3]);return f};return this.parents().map(function(){return this.map(window.getComputedStyle).filter(Object.HasValue).zip("getPropertyValue").call(a).filter(Object.IsString).map(e.Color.fromCss).reverse().reduce(d,e([0,0,0,0])).map(e.Color.toCss)})},child:function(a){return this.map(function(){return this.childNodes[a>=0?a:a+this.childNodes.length]})},children:function(){return this.map(function(){return e(this.childNodes,
this)})},parent:function(){return this.zip("parentNode")},parents:function(){return this.map(function(){for(var a=e(),d=-1,f=this;f=f.parentNode;)a[++d]=f;return a})},prev:function(){return this.map(function(){for(var a=e(),d=-1,f=this;f=f.previousSibling;)a[++d]=f;return a})},next:function(){return this.map(function(){for(var a=e(),d=-1,f=this;f=f.nextSibling;)a[++d]=f;return a})},remove:function(){return this.each(function(){this.parentNode&&this.parentNode.removeChild(this)})},find:function(a){return this.filter("*").map(function(){return e(a,
this)}).flatten()},clone:function(){return this.map(g)},toFragment:function(){if(this.length===1)return p(this[0]);var a=document.createDocumentFragment();this.map(p).map(Function.Bound(a.appendChild,a));return a}}});e.plugin(function(){return{floats:function(){return this.map(function(){if(Object.IsBling(this))return this.floats();return parseFloat(this)})},ints:function(){return this.map(function(){if(Object.IsBling(this))return this.ints();return parseInt(this,10)})},px:function(j){j=j||0;return this.ints().map(Function.Px(j))},
min:function(){return this.reduce(function(j){if(Object.IsBling(this))return this.min();return E(this,j)})},max:function(){return this.reduce(function(j){if(Object.IsBling(this))return this.max();return F(this,j)})},average:function(){return this.sum()/this.length},sum:function(){return this.reduce(function(j){if(Object.IsBling(this))return j+this.sum();return j+this})},squares:function(){return this.map(function(){if(Object.IsBling(this))return this.squares();return this*this})},magnitude:function(){var j=
this.map(function(){if(Object.IsBling(this))return this.magnitude();return parseFloat(this)});return K(j.squares().sum())},scale:function(j){return this.map(function(){if(Object.IsBling(this))return this.scale(j);return j*this})},normalize:function(){return this.scale(1/this.magnitude())}}});e.plugin(function(){function j(c){eval("var g = function "+c+"(f) { // ."+c+"([f]) - trigger [or bind] the '"+c+"' event \nreturn Object.IsFunc(f) ? this.bind('"+c+"',f) : this.trigger('"+c+"', f ? f : {}) }");
return eval("g")}function p(c,b,a,d,f){e(b).bind(a,f).each(function(){var h=this.__alive__=this.__alive__||{};h=h[c]=h[c]||{};(h[a]=h[a]||{})[d]=f})}function g(c,b,a,d){var f=e(b);f.each(function(){var h=this.__alive__=this.__alive__||{};h=h[c]=h[c]||{};h=h[a]=h[a]||{};f.unbind(a,h[d]);delete h[d]})}setTimeout(function(){e.fn.trigger!=null&&document.readyState==="complete"?e(document).trigger("ready"):setTimeout(arguments.callee,20)},0);return{bind:function(c,b){var a=0,d=(c||l).split(i),f=d.length;
return this.each(function(){for(;a<f;a++)this.addEventListener(d[a],b)})},unbind:function(c,b){var a=0,d=(c||l).split(i),f=d.length;return this.each(function(){for(;a<f;a++)this.removeEventListener(d[a],b)})},once:function(c,b){for(var a=0,d=(c||l).split(i),f=d.length;a<f;a++)this.bind(d[a],function(h){b.call(this,h);this.unbind(h.type,arguments.callee)})},cycle:function(c){function b(){var u=0;return function(q){d[u].call(this,q);u=++u%m}}for(var a=0,d=Array.Slice(arguments,1,arguments.length),f=
(c||l).split(i),h=f.length,m=d.length;a<h;)this.bind(f[a++],b());return this},trigger:function(c,b){var a,d=0,f=(c||l).split(i),h=f.length,m=null;for(b=Object.Extend({bubbles:true,cancelable:true},b);d<h;d++){m=f[d];switch(m){case "click":case "mousemove":case "mousedown":case "mouseup":case "mouseover":case "mouseout":a=document.createEvent("MouseEvents");b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,button:0,relatedTarget:null},
b);a.initMouseEvent(m,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.button,b.relatedTarget);break;case "blur":case "focus":case "reset":case "submit":case "abort":case "change":case "load":case "unload":a=document.createEvent("UIEvents");a.initUIEvent(m,b.bubbles,b.cancelable,window,1);break;case "touchstart":case "touchmove":case "touchend":case "touchcancel":a=document.createEvent("TouchEvents");b=Object.Extend({detail:1,
screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},b);a.initTouchEvent(m,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.touches,b.targetTouches,b.changedTouches,b.scale,b.rotation);break;case "gesturestart":case "gestureend":case "gesturecancel":a=document.createEvent("GestureEvents");b=Object.Extend({detail:1,screenX:0,
screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,target:null,scale:1,rotation:0},b);a.initGestureEvent(m,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.target,b.scale,b.rotation);break;default:a=document.createEvent("Events");a.initEvent(m,b.bubbles,b.cancelable);a=Object.Extend(a,b)}a&&this.each(function(){this.dispatchEvent(a);delete a.result;delete a.returnValue})}return this},live:function(c,
b){function a(h){e(d,f).intersect(e(h.target).parents().first().union(e(h.target))).each(function(){h.target=this;b.call(this,h)})}var d=this.selector,f=this.context;e(f).bind(c,a);p(d,f,c,b,a);return this},die:function(c,b){var a=this.context,d=g(this.selector,a,c,b);e(a).unbind(c,d);return this},liveCycle:function(c){var b=0,a=Array.Slice(arguments,1,arguments.length);return this.live(c,function(d){a[b].call(this,d);b=++b%a.length})},click:function(c){this.css("cursor").intersect(["auto",l]).len()>
0&&this.css("cursor","pointer");return Object.IsFunc(c)?this.bind("click",c):this.trigger("click",c?c:{})},mousemove:j("mousemove"),mousedown:j("mousedown"),mouseup:j("mouseup"),mouseover:j("mouseover"),mouseout:j("mouseout"),blur:j("blur"),focus:j("focus"),load:j("load"),ready:j("ready"),unload:j("unload"),reset:j("reset"),submit:j("submit"),keyup:j("keyup"),keydown:j("keydown"),change:j("change"),abort:j("abort"),cut:j("cut"),copy:j("copy"),paste:j("paste"),selection:j("selection"),drag:j("drag"),
drop:j("drop"),orientationchange:j("orientationchange"),touchstart:j("touchstart"),touchmove:j("touchmove"),touchend:j("touchend"),touchcancel:j("touchcancel"),gesturestart:j("gesturestart"),gestureend:j("gestureend"),gesturecancel:j("gesturecancel")}});e.plugin(function(){var j=/(?:scale|translate|rotate|scale3d|translate[XYZ]|translate3d|rotate[XYZ]|rotate3d)/,p={slow:700,medium:500,normal:300,fast:100,instant:0,now:0};return{$duration:function(g){return p[g]||parseFloat(g)},transform:function(g,
c,b,a){if(Object.IsFunc(c)){a=c;b=c=null}else if(Object.IsFunc(b)){a=b;b=null}c=Object.HasValue(c)?c:"normal";b=b||"ease";var d=e.duration(c);c=[];var f=0,h=0,m=null,u=l,q={};for(h in g)if(j.test(h)){m=g[h];if(m.join)m=e(m).px().join(k);else if(m.toString)m=m.toString();u+=n+h+"("+m+")"}else q[h]=g[h];for(h in q)c[f++]=h;if(u)c[f++]="-webkit-transform";q["-webkit-transition-property"]=c.join(k);q["-webkit-transition-duration"]=c.map(function(){return d+"ms"}).join(k);q["-webkit-transition-timing-function"]=
c.map(function(){return b}).join(k);if(u)q["-webkit-transform"]=u;this.css(q);return this.future(d,a)},hide:function(g){return this.each(function(){if(this.style){this._display=this.style.display==="none"?l:this.style.display;this.style.display="none"}}).trigger("hide").future(50,g)},show:function(g){return this.each(function(){if(this.style){this.style.display=this._display;delete this._display}}).trigger("show").future(50,g)},visible:function(){var g,c=g=null;return this.parents().map(function(b){for(var a=
-1,d=b.length;++a<d;){var f=e(b[a]);if(f[0]===document){c=c||document;g=g||document}else{if(f.css("overflow-x").first()=="hidden")c=f;if(f.css("overflow-y").first()=="hidden")g=f;if(c&&g)break}}return e([c,g])})},toggle:function(g){this.weave(this.css("display")).fold(function(c,b){if(c==="none"){b.style.display=b._display||l;delete b._display;e(b).trigger("show")}else{b._display=c;b.style.display="none";e(b).trigger("hide")}return b}).future(50,g)},fadeIn:function(g,c){return this.css("opacity",
"0.0").show(function(){this.transform({opacity:"1.0",translate3d:[0,0,0]},g,function(){this.trigger("show");c&&c.apply(this)})})},fadeOut:function(g,c,b,a){b=b||0;a=a||0;return this.each(function(d){e(d).transform({opacity:"0.0",translate3d:[b,a,0]},g,function(){this.hide()})}).future(e.duration(g),c)},fadeLeft:function(g,c){return this.fadeOut(g,c,"-"+this.width().first(),0)},fadeRight:function(g,c){return this.fadeOut(g,c,this.width().first(),0)},fadeUp:function(g,c){return this.fadeOut(g,c,0,"-"+
this.height().first())},fadeDown:function(g,c){return this.fadeOut(g,c,0,this.height().first())}}});e.plugin(function(){function j(p){var g=[],c=0;p=JSON.parse(JSON.stringify(p));for(var b in p)g[c++]=b+"="+escape(p[b]);return g.join("&")}return{$http:function(p,g){var c=new XMLHttpRequest;if(Object.IsFunc(g))g={success:Function.Bound(g,c)};g=Object.Extend({method:"GET",data:null,state:Function.Empty,success:Function.Empty,error:Function.Empty,async:true,timeout:0,withCredentials:false,followRedirects:false,
asBlob:false},g);g.state=Function.Bound(g.state,c);g.success=Function.Bound(g.success,c);g.error=Function.Bound(g.error,c);if(g.data&&g.method==="GET")p+="?"+j(g.data);else if(g.data&&g.method==="POST")g.data=j(g.data);c.open(g.method,p,g.async);c.withCredentials=g.withCredentials;c.asBlob=g.asBlob;c.timeout=g.timeout;c.followRedirects=g.followRedirects;c.onreadystatechange=function(){g.state&&g.state();if(c.readyState===4)c.status===200?g.success(c.responseText):g.error(c.status,c.statusText)};c.send(g.data);
return e([c])},$post:function(p,g){if(Object.IsFunc(g))g={success:g};g=g||{};g.method="POST";return e.http(p,g)},$get:function(p,g){if(Object.IsFunc(g))g={success:g};g=g||{};g.method="GET";return e.http(p,g)}}});e.plugin(function(){function j(b,a){throw Error("sql error ["+a.code+"] "+a.message);}function p(b,a){if(!b)throw Error("assert failed: "+a);}function g(b,a,d,f){if(b==null)return null;if(Object.IsFunc(a)){f=d;d=a;a=null}a=a||[];d=d||Function.Empty;f=f||j;p(Object.IsType(this[0],"Database"),
"can only call .sql() on a bling of Database");return this.transaction(function(h){h.executeSql(b,a,d,f)})}function c(b){this.zip("transaction").call(b);return this}return{$db:function(b,a,d,f){b=e([window.openDatabase(b||"bling.db",a||"1.0",d||"bling database",f||1024)]);b.transaction=c;b.execute=g;return b}}});e.plugin(function(){function j(q){var w=[];q=q.split(/%[\(\/]/);var r=-1,v=1,y=q.length,s=null,x=r=null;for(w.push(q[0]);v<y;v++){a:{s=q[v];r=-1;x=1;if(r==null||r===-1)r=s.length;for(var z=
0;z<r;z++){if(s.charAt(z)==="(")x+=1;else if(s.charAt(z)===")")x-=1;if(x===0){r=z;break a}}r=-1}if(r===-1)return"Template syntax error: unmatched '%(' in chunk starting at: "+q[v].substring(0,15);s=q[v].substring(0,r);r=q[v].substring(r);x=c.exec(r);if(x===null)return"Template syntax error: invalid type specifier starting at '"+r+"'";r=x[4];w.push(s);w.push(x[1]|0);w.push(x[2]|0);w.push(x[3]);w.push(r)}return w}function p(q,w){for(var r=j.cache[q]||(j.cache[q]=j(q)),v=[r[0]],y=1,s=1,x=r.length;s<
x-4;s+=5){var z=r[s],G=r[s+1],H=r[s+2],A=r[s+3],o=r[s+4],C=w[z];if(C==null)C="missing required value: "+z;switch(A){case "d":v[y++]=l+parseInt(C,10);break;case "f":v[y++]=parseFloat(C).toFixed(H);break;default:v[y++]=l+C}if(G>0)v[y]=String.PadLeft(v[y],G);v[y++]=o}return v.join(l)}function g(q){function w(){var D=e.HTML.parse(G);A?A.appendChild(D):C.push(D);G=l;o=b}function r(){var D=document.createElement(v);D.id=y?y:null;D.className=s?s:null;for(var J in H)D.setAttribute(J,H[J]);A?A.appendChild(D):
C.push(D);A=D;G=z=x=s=y=v=l;H={};o=b}var v=l,y=l,s=l,x=l,z=l,G=l,H={},A=null,o=b,C=e([]),L=0,t=null;C.selector=q;for(C.context=document;t=q.charAt(L++);)if(t==="+"&&o===b)A=A?A.parentNode:A;else if(t==="#"&&(o===b||o===d||o===f))o=a;else if(t==="."&&(o===b||o===a||o===f)){if(s.length>0)s+=n;o=d}else if(t==="."&&s.length>0)s+=n;else if(t==="["&&(o===b||o===a||o===d||o===f))o=f;else if(t==="="&&o===f)o=h;else if(t==='"'&&o===b)o=m;else if(t==="'"&&o===b)o=u;else if(t==="]"&&(o===f||o===h)){H[x]=z;z=
x=l;o=b}else if(t==='"'&&o===m)w();else if(t==="'"&&o===u)w();else if((t===n||t===",")&&o!==h&&o!==f&&v.length>0){r();if(t==",")A=null}else if(o===b)v+=t!=n?t:l;else if(o===a)y+=t;else if(o===d)s+=t;else if(o===f)x+=t;else if(o===h)z+=t;else if(o===m||o===u)G+=t;else throw Error("Unknown input/state: '"+t+"'/"+o);v.length>0&&r();G.length>0&&w();return C}var c=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;j.cache={};var b=1,a=2,d=3,f=4,h=5,m=6,u=7;return{$render:p,$synth:g,template:function(q){this.render=
function(w){return p(this.map(e.HTML.stringify).join(l),Object.Extend(q,w))};return this.remove()},render:function(q){return p(this.map(e.HTML.stringify).join(l),q)},synth:function(q){return g(q).appendTo(this)}}})})(Bling);
