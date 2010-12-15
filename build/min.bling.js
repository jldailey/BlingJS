function Bling(e,g){if(isBling(e))return e;g=g||document;var h=null;if(e==null)h=[];else if(typeof e==="number")h=Array(e);else if(e===window||isNode(e))h=[e];else if(typeof e==="string"){e=e.trimLeft();if(e[0]==="<")h=[Bling.HTML.parse(e)];else if(isBling(g))h=g.reduce(function(c,a){for(var b=a.querySelectorAll(e),d=0,f=b.length;d<f;d++)c.push(b[d]);return c},[]);else if(g.querySelectorAll)try{h=g.querySelectorAll(e)}catch(i){throw Error("invalid selector: "+e,i);}else throw Error("invalid context: "+
g);}else h=e;h.__proto__=Bling.prototype;h.selector=e;h.context=g;return h}Bling.prototype=[];Bling.prototype.constructor=Bling;function isBling(e){return isType(e,Bling)}Bling.symbol="$";window[Bling.symbol]=Bling;function isType(e,g){return!e?g===e:typeof g==="string"?e.__proto__.constructor.name===g:e.__proto__.constructor===g}
function isSubtype(e,g){return e==null?e===g:e.__proto__==null?false:typeof g==="string"?e.__proto__.constructor.name==g:e.__proto__.constructor===g?true:isSubtype(e.__proto__,g)}function isString(e){return typeof e==="string"||isSubtype(e,String)}var isNumber=isFinite;function isFunc(e){return typeof e==="function"||isType(e,Function)}function isNode(e){return e?e.nodeType>0:false}function isFragment(e){return e?e.nodeType===11:false}
function isArray(e){return e?Function.ToString(e)==="[object Array]"||isSubtype(e,Array):false}function isObject(e){return typeof e==="object"}function hasValue(e){return e!=null}Object.Extend=function(e,g,h){var i;if(isArray(h))for(i in h)e[h[i]]=g[h[i]]!=void 0?g[h[i]]:e[h[i]];else for(i in h=Object.Keys(g))e[h[i]]=g[h[i]];return e};Object.Keys=function(e,g){var h=[],i=0,c=null;for(c in e)if(g||e.hasOwnProperty(c))h[i++]=c;return h};
function boundmethod(e,g,h){function i(){return e.apply(g,h?h:arguments)}i.toString=function(){return"bound-method of "+g+"."+e.name+"(...) { [code] }"};return i}function tracemethod(e,g){function h(){console.log(g?g:e.name,Array.Slice(arguments,0));return e.apply(this,arguments)}h.toString=function(){return e.toString()};console.log("tracemethod:",g?g:e.name,"created");return h}
Object.Extend(Function,{Empty:function(){},NotNull:function(e){return e!=null},IndexFound:function(e){return e>-1},ReduceAnd:function(e){return e&&this},UpperLimit:function(e){return function(g){return Math.min(e,g)}},LowerLimit:function(e){return function(g){return Math.max(e,g)}},ToString:function(e){return Object.prototype.toString.apply(e)},Px:function(e){return function(){return Number.Px(this,e)}}});var console=console||{};console.log=console.log||Function.Empty;
Array.Slice=function(e,g,h){var i=[],c=0,a=e.length;h=h==null?a:h<0?a+h:h;for(g=g==null?0:g<0?a+g:g;g<h;)i[c++]=e[g++];return i};Number.Px=function(e,g){return parseInt(e,10)+(g|0)+"px"};Object.Extend(String,{PadLeft:function(e,g,h){for(h=h||" ";e.length<g;)e=h+e;return e},PadRight:function(e,g,h){for(h=h||" ";e.length<g;)e+=h;return e},Splice:function(){var e=arguments[0],g=arguments[1],h=arguments[2],i=Array.Slice(arguments,3).join("");return e.substring(0,g)+i+e.substring(h)}});
Bling.plugin=function(e){var g=e.call(Bling,Bling),h=Object.Keys(g,true),i,c,a=arguments.callee.s=arguments.callee.s||[];for(i in h){c=h[i];if(c.charAt(0)==="$")Bling[c.substr(1)]=g[c];else Bling.prototype[c]=g[c]}a.push(e.name);a[e.name]=g};
(function(e){e.plugin(function(){function g(c){var a;return function(){a=this[c];return isFunc(a)?boundmethod(a,this):a}}function h(c){var a=c.indexOf(".");return a>-1?this.zip(c.substr(0,a)).zip(c.substr(a+1)):this.map(g(c))}var i=new function(){this.queue=[];this.next=boundmethod(function(){this.queue.length>0&&this.queue.shift()()},this);this.schedule=function(c,a){if(isFunc(c)){var b=this.queue.length;c.order=a+(new Date).getTime();if(b===0||c.order>this.queue[b-1].order)this.queue[b]=c;else for(var d=
0;d<b;d++)this.queue[d].order>c.order&&this.queue.splice(d,0,c);setTimeout(this.next,a)}}};return{each:function(c){for(var a=-1,b=this.len(),d=null;++a<b;){d=this[a];c.call(d,d)}return this},map:function(c){var a=this.len(),b=e(a),d=0,f=null,j=true;b.context=this;for(b.selector=c;d<a;d++){f=this[d];if(j)try{b[d]=c.call(f,f)}catch(k){if(isType(k,TypeError)){j=false;d--}else b[d]=k}else try{b[d]=c(f)}catch(q){b[d]=q}}return b},reduce:function(c,a){if(!c)return this;var b=a,d=this;if(a==null){b=this[0];
d=this.skip(1)}d.each(function(){b=c.call(this,b,this)});return b},union:function(c){var a=e(),b=0,d=0,f=null;a.context=this.context;a.selector=this.selector;for(this.each(function(){a[b++]=this});f=c[d++];)a.contains(f)||(a[b++]=f);return a},intersect:function(c){var a=e(),b=0,d=0,f=this.length,j=c.length;a.context=this.context;for(a.selector=this.selector;b<f;b++)for(d=0;d<j;d++)if(this[b]===c[d]){a[a.length]=this[b];break}return a},distinct:function(){return this.union(this)},contains:function(c){return this.count(c)>
0},count:function(c,a){if(c===void 0)return this.len();var b=0;this.each(function(d){if(a&&d===c||!a&&d==c)b++});return b},zip:function(){switch(arguments.length){case 0:return this;case 1:return h.call(this,arguments[0]);default:var c={},a=e(),b=arguments.length,d=this.length,f=0,j=0,k=null;for(f=0;f<b;f++)c[f]=h.call(this,arguments[f]);for(f=0;f<d;f++){b={};for(k in c)b[k]=c[k].shift();a[j++]=b}return a}},zap:function(c,a){if(!c)return this;var b=c.indexOf(".");return b>-1?this.zip(c.substr(0,b)).zap(c.substr(b+
1),a):isArray(a)?this.each(function(d){d[c]=a[++b]}):this.each(function(){this[c]=a})},take:function(c){c=Math.min(c|0,this.len());var a=e(c),b=-1;a.context=this.context;for(a.selector=this.selector;++b<c;)a[b]=this[b];return a},skip:function(c){c=Math.min(this.len(),Math.max(0,c|0));var a=e(c),b=0,d=this.len()-c;a.context=this.context;for(a.selector=this.selector;b<d;b++)a[b]=this[b+c];return a},first:function(c){return c?this.take(c):this[0]},last:function(c){return c?this.skip(this.len()-c):this[this.length-
1]},join:function(c){if(this.length===0)return"";return this.reduce(function(a){return a+c+this})},slice:function(c,a){var b=e(Array.Slice(this,c,a));b.context=this.context;b.selector=this.selector;return b},concat:function(c){for(var a=this.len()-1,b=-1,d=c.length;b<d;)this[++a]=c[++b];return this},push:function(c){Array.prototype.push.call(this,c);return this},filter:function(c){var a=0,b=-1,d=this.length,f=e(d),j=null;f.context=this;for(f.selector=c;a<d;a++)if(j=this[a])if(isFunc(c)&&c.call(j,
j)||isString(c)&&j.webkitMatchesSelector&&j.webkitMatchesSelector(c)||isType(c,"RegExp")&&c.test(j))f[++b]=j;return f},matches:function(c){if(isType(c,"RegExp"))return this.map(function(){return c.test(this)});return isString(c)&&this.webkitMatchesSelector?this.map(function(){return this.webkitMatchesSelector(c)}):this.map(function(){return false})},weave:function(c){var a=c.length,b=this.length,d=e(2*Math.max(b,a));b=b-1;d.context=this.context;for(d.selector=this.selector;b>=0;b--)d[b*2+1]=this[b];
for(;++b<a;)d[b*2]=c[b];return d},fold:function(c){var a=this.len(),b=0,d=e(Math.ceil(a/2)),f=0;d.context=this.context;d.selector=this.selector;for(f=0;f<a-1;f+=2)d[b++]=c.call(this,this[f],this[f+1]);if(a%2===1)d[b++]=c.call(this,this[a-1],undefined);return d},flatten:function(){var c=e(),a=this.len(),b=null,d=0,f=0,j=0,k=0;c.context=this.context;for(c.selector=this.selector;f<a;f++){b=this[f];j=0;for(d=b.length;j<d;)c[k++]=b[j++]}return c},call:function(){return this.apply(null,arguments)},apply:function(c,
a){return this.map(function(){if(isFunc(this))return this.apply(c,a);return this})},toString:function(){return e.symbol+"(["+this.map(function(){return this===undefined||this===window?"undefined":this===null?"null":this.toString().replace(/\[object (\w+)\]/,"$1")}).join(", ")+"])"},future:function(c,a){a&&i.schedule(boundmethod(a,this),c);return this},log:function(c){c?console.log(c,this,this.length+" items"):console.log(this,this.length+" items");return this},len:function(){for(var c=this.length;c>
-1&&this[--c]===undefined;);return c+1}}});e.plugin(function(){function g(a,b){a&&b&&a.parentNode.insertBefore(b,a)}function h(a){a=isNode(a)?a:isBling(a)?a.toFragment():isString(a)?e(a).toFragment():isFunc(a.toString)?e(a.toString()).toFragment():undefined;e.nextguid=e.nextguid||1;if(a&&a.guid==null)a.guid=e.nextguid++;return a}function i(a){for(var b=a.cloneNode(),d=0;d<a.childNodes.length;d++)b.appendChild(i(a.childNodes[d])).parentNode=b;return b}var c=null;return{$HTML:{parse:function(a){var b=
document.createElement("body"),d=document.createDocumentFragment();b.innerHTML=a;a=b.childNodes.length;if(a===1)return b.removeChild(b.childNodes[0]);for(var f=0;f<a;f++)d.appendChild(b.removeChild(b.childNodes[0]));return d},stringify:function(a){a=i(a);var b=document.createElement("div");b.appendChild(a);var d=b.innerHTML;b.removeChild(a);a.parentNode=null;return d},escape:function(a){c=c||e("<div>&nbsp;</div>").child(0);a=c.zap("data",a).zip("parentNode.innerHTML").first();c.zap("data","");return a}},
$Color:{fromCss:function(a){a=a||this;if(isString(a)){var b=document.createElement("div");b.style.display="none";b.style.color=a;e(document.body).append(b);a=window.getComputedStyle(b,null).getPropertyValue("color");e(b).remove();if(a){a=a.slice(a.indexOf("(")+1,a.indexOf(")")).split(", ");if(a.length===3)a[3]="1.0";return e(a).floats()}}},toCss:function(a){function b(d){d=d.map(Function.UpperLimit(255)).map(Function.LowerLimit(0));d[3]=Math.min(1,d[3]);return"rgba("+d.join(", ")+")"}a=a||this;return isBling(a[0])?
a.map(b):b(a)},invert:function(a){var b=e(4);if(isString(a))a=e.Color.fromCss(a);b[0]=255-a[0];b[1]=255-a[1];b[2]=255-a[2];b[3]=a[3];return b}},html:function(a){return a===undefined?this.zip("innerHTML"):isString(a)?this.zap("innerHTML",a):isBling(a)?this.html(a.toFragment()):isNode(a)?this.each(function(){for(this.replaceChild(this.childNodes[0],a);this.childNodes.length>1;)this.removeChild(this.childNodes[1])}):undefined},append:function(a){if(a==null)return this;a=h(a);var b=this.zip("appendChild");
b.take(1).call(a);b.skip(1).each(function(){this(i(a))});return this},appendTo:function(a){if(a==null)return this;e(a).append(this);return this},prepend:function(a){if(a==null)return this;a=h(a);this.take(1).each(function(){g(this.childNodes[0],a)});this.skip(1).each(function(){g(this.childNodes[0],i(a))});return this},prependTo:function(a){if(a==null)return this;e(a).prepend(this);return this},before:function(a){if(a==null)return this;a=h(a);this.take(1).each(function(){g(this,a)});this.skip(1).each(function(){g(this,
i(a))});return this},after:function(a){if(a==null)return this;a=h(a);this.take(1).each(function(){this.parentNode.insertBefore(a,this.nextSibling)});this.skip(1).each(function(){this.parentNode.insertBefore(i(a),this.nextSibling)});return this},wrap:function(a){a=h(a);if(isFragment(a))throw Error("cannot wrap something with a fragment");return this.map(function(b){if(isFragment(b))a.appendChild(b);else if(isNode(b)){var d=b.parentNode;if(d){var f=document.createElement("dummy");a.appendChild(d.replaceChild(f,
b));d.replaceChild(a,f)}else a.appendChild(b)}return b})},unwrap:function(){return this.each(function(){this.parentNode&&this.parentNode.parentNode&&this.parentNode.parentNode.replaceChild(this,this.parentNode)})},replace:function(a){a=h(a);var b=e(),d=-1;this.take(1).each(function(){if(this.parentNode){this.parentNode.replaceChild(a,this);b[++d]=a}});this.skip(1).each(function(){if(this.parentNode){var f=i(a);this.parentNode.replaceChild(f,this);b[++d]=f}});return b},attr:function(a,b){var d=this.zip(b===
undefined?"getAttribute":b===null?"removeAttribute":"setAttribute").call(a,b);return b?this:d},addClass:function(a){return this.removeClass(a).each(function(){var b=this.className.split(" ").filter(function(d){return d&&d!=""});b.push(a);this.className=b.join(" ")})},removeClass:function(a){var b=function(d){return d!=a};return this.each(function(){this.className=this.className.split(" ").filter(b).join(" ")})},toggleClass:function(a){function b(d){return d!=a}return this.each(function(d){var f=d.className.split(" ");
if(f.indexOf(a)>-1)d.className=f.filter(b).join(" ");else{f.push(a);d.className=f.join(" ")}})},hasClass:function(a){return this.zip("className.split").call(" ").zip("indexOf").call(a).map(Function.IndexFound)},text:function(a){return a?this.zap("innerText",a):this.zip("innerText")},val:function(a){return a?this.zap("value",a):this.zip("value")},css:function(a,b){if(hasValue(b)||isObject(a)){var d=this.zip("style.setProperty");if(isString(a))d.call(a,b);else for(var f in a)d.call(f,a[f]);return this}d=
this.map(window.getComputedStyle).zip("getPropertyValue").call(a);return this.zip("style").zip(a).weave(d).fold(function(j,k){return j?j:k})},defaultCss:function(a,b){var d=this.selector,f="<style> ",j=e("head");if(isString(a))if(isString(b))f+=d+" { "+a+": "+b+" } ";else throw Error("defaultCss requires a value with a string key");else if(isObject(a)){f+=d+" { ";for(var k in a)f+=k+": "+a[k];f+=" } "}f+="</style>";j.append(f)},rect:function(){return this.zip("getBoundingClientRect").call()},width:function(){return this.rect().zip("width")},
height:function(a){return a==null?this.rect().zip("height"):this.css("height",a)},top:function(a){return a==null?this.rect().zip("top"):this.css("top",a)},left:function(a){return a==null?this.rect().zip("left"):this.css("left",a)},position:function(a,b){return a==null?this.rect():b==null?this.css("left",Number.Px(a)):this.css({top:Number.Px(b),left:Number.Px(a)})},center:function(a){a=a||"viewport";var b=document.body.clientHeight/2,d=document.body.clientWidth/2;return this.each(function(){var f=
e(this),j=f.height().floats().first(),k=f.width().floats().first();k=a==="viewport"||a==="horizontal"?document.body.scrollLeft+d-k/2:NaN;j=a==="viewport"||a==="vertical"?document.body.scrollTop+b-j/2:NaN;f.css({position:"absolute",left:isNumber(k)?k+"px":undefined,top:isNumber(j)?j+"px":undefined})})},trueColor:function(a,b){a=a||"background-color";b=b||function(d){d[0]+=(this[0]-d[0])*this[3];d[1]+=(this[1]-d[1])*this[3];d[2]+=(this[2]-d[2])*this[3];d[3]=Math.min(1,d[3]+this[3]);return d};return this.parents().map(function(){return this.map(window.getComputedStyle).filter(hasValue).zip("getPropertyValue").call(a).filter(isString).map(e.Color.fromCss).reverse().reduce(b,
e([0,0,0,0])).map(e.Color.toCss)})},child:function(a){return this.map(function(){return this.childNodes[a>=0?a:a+this.childNodes.length]})},children:function(){return this.map(function(){return e(this.childNodes,this)})},parent:function(){return this.zip("parentNode")},parents:function(){return this.map(function(){for(var a=e(),b=-1,d=this;d=d.parentNode;)a[++b]=d;return a})},prev:function(){return this.map(function(){for(var a=e(),b=-1,d=this;d=d.previousSibling;)a[++b]=d;return a})},next:function(){return this.map(function(){for(var a=
e(),b=-1,d=this;d=d.previousSibling;)a[++b]=d;return a})},remove:function(){return this.each(function(){this.parentNode&&this.parentNode.removeChild(this)})},find:function(a){return this.filter("*").map(function(){return e(a,this)}).flatten()},clone:function(){return this.map(i)},toFragment:function(){if(this.length===1)return h(this[0]);var a=document.createDocumentFragment();this.map(h).map(boundmethod(a.appendChild,a));return a}}});e.plugin(function g(){return{floats:function(){return this.map(function(){if(isBling(this))return this.floats();
return parseFloat(this)})},ints:function(){return this.map(function(){if(isBling(this))return this.ints();return parseInt(this,10)})},px:function(h){h=h||0;return this.ints().map(Function.Px(h))},min:function(){return this.reduce(function(h){if(isBling(this))return this.min();return g.min(this,h)})},max:function(){return this.reduce(function(h){if(isBling(this))return this.max();return g.max(this,h)})},average:function(){return this.sum()/this.length},sum:function(){return this.reduce(function(h){if(isBling(this))return h+
this.sum();return h+this})},squares:function(){return this.map(function(){if(isBling(this))return this.squares();return this*this})},magnitude:function(){var h=this.map(function(){if(isBling(this))return this.magnitude();return parseFloat(this)});return g.sqrt(h.squares().sum())},scale:function(h){return this.map(function(){if(isBling(this))return this.scale(h);return h*this})},normalize:function(){return this.scale(1/this.magnitude())}}});e.plugin(function(){function g(a){eval("var f = function "+
a+"(f) { // ."+a+"([f]) - trigger [or bind] the '"+a+"' event \nreturn isFunc(f) ? this.bind('"+a+"',f) : this.trigger('"+a+"', f ? f : {}) }");return eval("f")}function h(a,b,d,f,j){e(b).bind(d,j).each(function(){var k=this.__alive__=this.__alive__||{};k=k[a]=k[a]||{};(k[d]=k[d]||{})[f]=j})}function i(a,b,d,f){var j=e(b);j.each(function(){var k=this.__alive__=this.__alive__||{};k=k[a]=k[a]||{};k=k[d]=k[d]||{};j.unbind(d,k[f]);delete k[f]})}setTimeout(function(){e.prototype.trigger!=null&&document.readyState===
"complete"?e(document).trigger("ready"):setTimeout(arguments.callee,20)},0);var c=/, */;return{bind:function(a,b){var d=0,f=(a||"").split(c),j=f.length;return this.each(function(){for(;d<j;d++)this.addEventListener(f[d],b)})},unbind:function(a,b){var d=0,f=(a||"").split(c),j=f.length;return this.each(function(){for(;d<j;d++)this.removeEventListener(f[d],b)})},once:function(a,b){for(var d=0,f=(a||"").split(c),j=f.length;d<j;d++)this.bind(f[d],function(k){b.call(this,k);this.unbind(k.type,arguments.callee)})},
cycle:function(a){function b(){var n=0;return function(s){f[n].call(this,s);n=++n%q}}for(var d=0,f=Array.Slice(arguments,1,arguments.length),j=(a||"").split(c),k=j.length,q=f.length;d<k;)this.bind(j[d++],b());return this},trigger:function(a,b){var d,f=0,j=(a||"").split(c),k=j.length,q=null;for(b=Object.Extend({bubbles:true,cancelable:true},b);f<k;f++){q=j[f];switch(q){case "click":case "mousemove":case "mousedown":case "mouseup":case "mouseover":case "mouseout":d=document.createEvent("MouseEvents");
b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,button:0,relatedTarget:null},b);d.initMouseEvent(q,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.button,b.relatedTarget);break;case "blur":case "focus":case "reset":case "submit":case "abort":case "change":case "load":case "unload":d=document.createEvent("UIEvents");d.initUIEvent(q,b.bubbles,b.cancelable,
window,1);break;case "touchstart":case "touchmove":case "touchend":case "touchcancel":d=document.createEvent("TouchEvents");b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},b);d.initTouchEvent(q,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.touches,b.targetTouches,b.changedTouches,b.scale,
b.rotation);break;case "gesturestart":case "gestureend":case "gesturecancel":d=document.createEvent("GestureEvents");b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,target:null,scale:1,rotation:0},b);d.initGestureEvent(q,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.target,b.scale,b.rotation);break;default:d=document.createEvent("Events");d.initEvent(q,
b.bubbles,b.cancelable)}d&&this.each(function(){this.dispatchEvent(d);delete d.result;delete d.returnValue})}return this},live:function(a,b){function d(k){e(f,j).intersect(e(k.target).parents().first().union(e(k.target))).each(function(){k.target=this;b.call(this,k)})}var f=this.selector,j=this.context;e(j).bind(a,d);h(f,j,a,b,d);return this},die:function(a,b){var d=this.context,f=i(this.selector,d,a,b);e(d).unbind(a,f);return this},liveCycle:function(a){var b=0,d=Array.Slice(arguments,1,arguments.length);
return this.live(a,function(f){d[b].call(this,f);b=++b%d.length})},click:function(a){this.css("cursor").intersect(["auto",""]).len()>0&&this.css("cursor","pointer");return isFunc(a)?this.bind("click",a):this.trigger("click",a?a:{})},mousemove:g("mousemove"),mousedown:g("mousedown"),mouseup:g("mouseup"),mouseover:g("mouseover"),mouseout:g("mouseout"),blur:g("blur"),focus:g("focus"),load:g("load"),ready:g("ready"),unload:g("unload"),reset:g("reset"),submit:g("submit"),keyup:g("keyup"),keydown:g("keydown"),
change:g("change"),abort:g("abort"),cut:g("cut"),copy:g("copy"),paste:g("paste"),selection:g("selection"),drag:g("drag"),drop:g("drop"),orientationchange:g("orientationchange"),touchstart:g("touchstart"),touchmove:g("touchmove"),touchend:g("touchend"),touchcancel:g("touchcancel"),gesturestart:g("gesturestart"),gestureend:g("gestureend"),gesturecancel:g("gesturecancel")}});e.plugin(function(){var g=/(?:scale|translate|rotate|scale3d|translateX|translateY|translateZ|translate3d|rotateX|rotateY|rotateZ|rotate3d)/,
h={slow:700,medium:500,normal:300,fast:100,instant:0,now:0};return{$duration:function(i){return h[i]||parseFloat(i)},transform:function(i,c,a){if(isFunc(c)){a=c;c=null}c=c||"normal";var b=e.duration(c);c=[];var d=0,f=0,j=null,k="",q={};for(f in i)if(g.test(f)){j=i[f];if(j.join)j=j.join(", ");else if(j.toString)j=j.toString();k+=" "+f+"("+j+")"}else q[f]=i[f];for(f in q)c[d++]=f;if(k)c[d++]="-webkit-transfrom";q["-webkit-transition-property"]=c.join(", ");q["-webkit-transition-duration"]=c.map(function(){return b+
"ms"}).join(", ");if(k)q["-webkit-transform"]=k;this.css(q);return this.future(b,a)},hide:function(i){return this.each(function(){if(this.style){this._display=this.style.display==="none"?"":this.style.display;this.style.display="none"}}).future(50,i)},show:function(i){return this.each(function(){if(this.style){this.style.display=this._display;delete this._display}}).future(50,i)},toggle:function(i){this.weave(this.css("display")).fold(function(c,a){if(c==="none"){a.style.display=a._old_display?a._old_display:
"block";delete a._old_display}else{a._old_display=c;a.style.display="none"}return a}).future(50,i)},fadeIn:function(i,c){return this.css("opacity","0.0").show(function(){this.transform({opacity:"1.0",translate3d:[0,0,0]},i,c)})},fadeOut:function(i,c,a,b){a=a||0;b=b||0;return this.each(function(d){e(d).transform({opacity:"0.0",translate3d:[a,b,0]},i,function(){this.hide()})}).future(e.duration(i),c)},fadeLeft:function(i,c){return this.fadeOut(i,c,"-"+this.width().first(),0)},fadeRight:function(i,c){return this.fadeOut(i,
c,this.width().first(),0)},fadeUp:function(i,c){return this.fadeOut(i,c,0,"-"+this.height().first())},fadeDown:function(i,c){return this.fadeOut(i,c,0,this.height().first())}}});e.plugin(function(){function g(i){var c=[],a=0;i=h.parse(h.stringify(i));for(var b in i)c[a++]=b+"="+escape(i[b]);return c.join("&")}var h=h||{};return{$http:function(i,c){var a=new XMLHttpRequest;if(isFunc(c))c={success:boundmethod(c,a)};c=Object.Extend({method:"GET",data:null,state:Function.Empty,success:Function.Empty,
error:Function.Empty,async:true,withCredentials:false},c);c.state=boundmethod(c.state,a);c.success=boundmethod(c.success,a);c.error=boundmethod(c.error,a);if(c.data&&c.method==="GET")i+="?"+g(c.data);else if(c.data&&c.method==="POST")c.data=g(c.data);a.open(c.method,i,c.async);a.withCredentials=c.withCredentials;a.onreadystatechange=function(){c.state&&c.state();if(a.readyState===4)a.status===200?c.success(a.responseText):c.error(a.status,a.statusText)};a.send(c.data);return e([a])},$post:function(i,
c){if(isFunc(c))c={success:c};c=c||{};c.method="POST";return e.http(i,c)},$get:function(i,c){if(isFunc(c))c={success:c};c=c||{};c.method="GET";return e.http(i,c)}}});e.plugin(function(){function g(a,b){throw Error("sql error ["+b.code+"] "+b.message);}function h(a,b){if(!a)throw Error("assert failed: "+b);}function i(a,b,d,f){if(a==null)return null;if(isFunc(b)){f=d;d=b;b=null}b=b||[];d=d||Function.Empty;f=f||g;h(isType(this[0],"Database"),"can only call .sql() on a bling of Database");return this.transaction(function(j){j.executeSql(a,
b,d,f)})}function c(a){this.zip("transaction").call(a);return this}return{$db:function(a,b,d,f){a=e([window.openDatabase(a||"bling.db",b||"1.0",d||"bling database",f||1024)]);a.transaction=c;a.execute=i;return a}}});e.plugin(function(){function g(n){var s=[];n=n.split(/%[\(\/]/);var m=-1,r=1,u=n.length,o=null,t=m=null;for(s.push(n[0]);r<u;r++){a:{o=n[r];m=-1;t=1;if(m==null||m===-1)m=o.length;for(var v=0;v<m;v++){if(o.charAt(v)==="(")t+=1;else if(o.charAt(v)===")")t-=1;if(t===0){m=v;break a}}m=-1}if(m===
-1)return"Template syntax error: unmatched '%(' in chunk starting at: "+n[r].substring(0,15);o=n[r].substring(0,m);m=n[r].substring(m);t=c.exec(m);if(t===null)return"Template syntax error: invalid type specifier starting at '"+m+"'";m=t[4];s.push(o);s.push(t[1]|0);s.push(t[2]|0);s.push(t[3]);s.push(m)}return s}function h(n,s){for(var m=g.cache[n]||(g.cache[n]=g(n)),r=[m[0]],u=1,o=1,t=m.length;o<t-4;o+=5){var v=m[o],z=m[o+1],A=m[o+2],w=m[o+3],l=m[o+4],x=s[v];if(x==null)x="missing required value: "+
v;switch(w){case "d":r[u++]=""+parseInt(x,10);break;case "f":r[u++]=parseFloat(x).toFixed(A);break;default:r[u++]=""+x}if(z>0)r[u]=String.PadLeft(r[u],z);r[u++]=l}return r.join("")}function i(n){function s(){var y=e.HTML.parse(z);w?w.appendChild(y):x.push(y);z="";l=a}function m(){var y=document.createElement(r);y.id=u?u:null;y.className=o?o:null;for(var B in A)y.setAttribute(B,A[B]);w?w.appendChild(y):x.push(y);w=y;z=v=t=o=u=r="";A={};l=a}for(var r="",u="",o="",t="",v="",z="",A={},w=null,l=a,x=e([]),
C=0,p=null;p=n.charAt(C++);)if(p==="+"&&l===a)w=w?w.parentNode:w;else if(p==="#"&&(l===a||l===d||l===f))l=b;else if(p==="."&&(l===a||l===b||l===f)){if(o.length>0)o+=" ";l=d}else if(p==="."&&o.length>0)o+=" ";else if(p==="["&&(l===a||l===b||l===d||l===f))l=f;else if(p==="="&&l===f)l=j;else if(p==='"'&&l===a)l=k;else if(p==="'"&&l===a)l=q;else if(p==="]"&&(l===f||l===j)){A[t]=v;v=t="";l=a}else if(p==='"'&&l===k)s();else if(p==="'"&&l===q)s();else if((p===" "||p===",")&&l!==j&&l!==f&&r.length>0){m();
if(p==",")w=null}else if(l===a)r+=p!=" "?p:"";else if(l===b)u+=p;else if(l===d)o+=p;else if(l===f)t+=p;else if(l===j)v+=p;else if(l===k||l===q)z+=p;else throw Error("Unknown input/state: '"+p+"'/"+l);r.length>0&&m();z.length>0&&s();return x}var c=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;g.cache={};var a=1,b=2,d=3,f=4,j=5,k=6,q=7;return{$render:h,$synth:i,template:function(n){this.render=function(s){return h(this.map(e.HTML.stringify).join(""),Object.Extend(n,s))};return this.remove()},
render:function(n){return h(this.map(e.HTML.stringify).join(""),n)},synth:function(n){return i(n).appendTo(this)}}})})(Bling);
