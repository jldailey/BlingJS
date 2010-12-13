var console=console||{};console.log=console.log||function(){};
function Bling(d,g){if(isBling(d))return d;g=g||document;var f=null;if(d==null)f=[];else if(typeof d==="number")f=Array(d);else if(d===window||isNode(d))f=[d];else if(typeof d==="string"){d=d.trimLeft();if(d[0]=="<")f=[Bling.HTML.parse(d)];else if(isBling(g))f=g.reduce(function(a,c){for(var e=c.querySelectorAll(d),h=0,i=e.length;h<i;h++)a.push(e[h]);return a},[]);else if(g.querySelectorAll!=undefined)try{f=g.querySelectorAll(d)}catch(b){throw Error("invalid selector: "+d,b);}else throw Error("invalid context: "+
g);}else f=d;f.__proto__=Bling.prototype;f.selector=d;f.context=g;return f}Bling.prototype=[];Bling.prototype.constructor=Bling;function isBling(d){return isType(d,Bling)}Bling.symbol="$";window[Bling.symbol]=Bling;function isType(d,g){return!d?g===d:typeof g==="string"?d.__proto__.constructor.name==g:d.__proto__.constructor===g}
function isSubtype(d,g){return d==null?d==g:d.__proto__==null?false:typeof g==="string"?d.__proto__.constructor.name==g:d.__proto__.constructor==g?true:isSubtype(d.__proto__,g)}function isString(d){return typeof d=="string"||isSubtype(d,String)}var isNumber=isFinite;function isFunc(d){return typeof d=="function"||isType(d,Function)}function isNode(d){return d?d.nodeType>0:false}function isFragment(d){return d?d.nodeType==11:false}
function isArray(d){return d?Function.ToString(d)=="[object Array]"||isSubtype(d,Array):false}function isObject(d){return typeof d=="object"}function hasValue(d){return d!=null}Object.Extend=function(d,g,f){for(var b in g)if(f&&d[b]!=undefined)for(var a in f)d[b][a]=g[b][a];else d[b]=g[b];return d};Object.Keys=function(d){var g=[],f=0,b=null;for(b in d)g[f++]=b;return g};
function boundmethod(d,g,f){function b(){return d.apply(g,f?f:arguments)}b.toString=function(){return"bound-method of "+g+"."+d.name+"(...) { [code] }"};return b}function tracemethod(d,g){function f(){console.log(g?g:d.name,Array.Slice(arguments,0));return d.apply(this,arguments)}f.toString=function(){return d.toString()};return f}var OtoS=Object.prototype.toString;Array.Slice=function(d,g,f){var b=[],a=0,c=d.length;f=f==undefined?c:f<0?c+f:f;for(g=g==undefined?0:g<0?c+g:g;g<f;)b[a++]=d[g++];return b};
Number.Px=function(d,g){return parseInt(d,10)+(g|0)+"px"};Object.Extend(String,{HtmlEscape:function(d){return d.replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/\t/g,"&nbsp;&nbsp;")},PadLeft:function(d,g,f){for(f=f||" ";d.length<g;)d=f+d;return d},Splice:function(){var d=arguments[0],g=arguments[1],f=arguments[2],b=Array.Slice(arguments,3).join("");return d.substring(0,g)+b+d.substring(f)}});
Object.Extend(Function,{Empty:function(){},NotNull:function(d){return d!=null},NotUndefined:function(d){return d!=undefined},IndexFound:function(d){return d>-1},ReduceAnd:function(d){return d&&this},UpperLimit:function(d){return function(g){return Math.min(d,g)}},LowerLimit:function(d){return function(g){return Math.max(d,g)}},ToString:function(d){return OtoS.apply(d)},Px:function(d){return function(){return Number.Px(this,d)}},PrettyPrint:function(){function d(i){var k=0,p=i.length,l=[],o=-1,j=-1,
n=null;if(!isString(i))if(isFunc(i.toString)){i=i.toString();p=i.length}else throw TypeError("invalid string argument to extract_quoted");for(;k<p;){o=i;j=k;n=o.indexOf('"',j);j=o.indexOf("'",j);if(n==-1)n=o.length;if(j==-1)j=o.length;n=n==j?[null,-1]:n<j?['"',n]:["'",j];o=n[1];if(o==-1){l.push(i.substring(k));break}l.push(i.substring(k,o));k=i;j=n[0];for(var q=k.indexOf(j,o+1);k.charAt(q-1)=="\\"&&q<k.length&&q>0;)q=k.indexOf(j,q+1);j=q;if(j==-1)throw Error("unmatched "+n[0]+" at "+o);l.push(i.substring(o,
j+1));k=j+1}return l}function g(i){for(var k=[],p=0,l=0,o=i.length,j=null,n=null;p<o;){j=n=i.substring(p);l=j.match(a);j=j.match(c);j=l==j?[-1,null]:l==null&&j!=null?[j.index,j[0]]:l!=null&&j==null?[l.index,l[0]]:j.index<l.index?[j.index,j[0]]:[l.index,l[0]];l=j[0];if(l>-1){k.push(n.substring(0,l));k.push(j[1]);p+=l+j[1].length}else{k.push(n);break}}return k}var f=/!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g,
b=/\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g,a=/\/\/.*?(?:\n|$)/,c=/\/\*(?:.|\n)*?\*\//,e=/\d+\.*\d*/g,h=/\$(?:\(|\.)/g;return function(i,k){if(isFunc(i))i=i.toString();if(!isString(i))throw TypeError("prettyPrint requires a function or string to format, not '"+typeof i+"'");if(Bling("style#pp-injected").length==
0){k=Object.Extend({opr:"#880",str:"#008",com:"#080",kwd:"#088",num:"#808",bln:"#800"},k);var p="code.pp .bln { font-size: 17px; } ",l;for(l in k)p+="code.pp ."+l+" { color: "+k[l]+"; }";Bling("head").append(Bling.synth("style#pp-injected").text(p))}return"<code class='pp'>"+Bling(g(i)).fold(function(o,j){return Bling(d(o)).fold(function(n,q){return n.replace(f,"<span class='opr'>$&</span>").replace(e,"<span class='num'>$&</span>").replace(b,"<span class='kwd'>$&</span>").replace(h,"<span class='bln'>$$</span>(").replace(/\t/g,
"&nbsp;&nbsp;")+(q?"<span class='str'>"+q+"</span>":"")}).join("")+(j?"<span class='com'>"+j+"</span>":"")}).join("")+"</code>"}}()});
Bling.addOps=function(){for(var d=0,g=arguments.length;d<g;d++){var f=arguments[d];if(isFunc(f))if(f.name==null)throw Error("cannot add an anonymous method directly (must have a name)");else if(f.name.charAt(0)==="$")Bling[f.name.substr(1)]=f;else Bling.prototype[f.name]=f;else if(isObject(f)){var b=Object.Keys(f),a=null,c=null;d=0;for(g=b.length;d<g;d++){a=b[d];c=f[a];if(a.charAt(0)==="$")Bling[a.substr(1)]=c;else Bling.prototype[a]=f[a]}}else throw Error("can only add an object or function, not:"+
typeof f);}};Bling.module=function(d,g){var f=g(),b=arguments.callee;Bling.addOps(f);b[d]=f;Bling.module.order.push(d)};Bling.module.order=[];
Bling.module("Core",function(){function d(b){var a;return function(){a=this[b];return isFunc(a)?boundmethod(a,this):a}}function g(b){var a=b.indexOf(".");return a>-1?this.zip(b.substr(0,a)).zip(b.substr(a+1)):this.map(d(b))}var f=new function(){this.queue=[];this.next=boundmethod(function(){this.queue.length>0&&this.queue.shift()()},this);this.schedule=function(b,a){if(isFunc(b)){var c=this.queue.length;b.order=a+(new Date).getTime();if(c==0||b.order>this.queue[c-1].order)this.queue[c]=b;else for(var e=
0;e<c;e++)this.queue[e].order>b.order&&this.queue.splice(e,0,b);setTimeout(this.next,a)}}};return{each:function(b){for(var a=-1,c=this.len(),e=null;++a<c;){e=this[a];b.call(e,e)}return this},map:function(b){var a=this.len(),c=Bling(a),e=0,h=null,i=true;c.context=this;for(c.selector=b;e<a;e++){h=this[e];if(i)try{c[e]=b.call(h,h)}catch(k){if(isType(k,TypeError)){i=false;e--}else c[e]=k}else try{c[e]=b(h)}catch(p){c[e]=p}}return c},reduce:function(b,a){if(!b)return this;var c=a,e=this;if(a==null){c=
this[0];e=this.skip(1)}e.each(function(){c=b.call(this,c,this)});return c},union:function(b){var a=Bling(),c=0,e=0,h=null;a.context=this.context;a.selector=this.selector;for(this.each(function(){a[c++]=this});h=b[e++];)a.contains(h)||(a[c++]=h);return a},intersect:function(b){var a=Bling(),c=0,e=0,h=this.length,i=b.length;a.context=this.context;a.selector=this.selector;if(isBling(b))for(;c<h;c++){if(b.contains(this[c]))a[a.length]=this[c]}else for(c=0;c<h;c++)for(;e<i;e++)if(this[c]==b[e])a[a.length]=
this[c];return a},distinct:function(){return this.union(this)},contains:function(b){return this.count(b)>0},count:function(b){if(b==undefined)return this.len();if(isObject(b)&&isNumber(b))b=Number(b);var a=0;this.each(function(){var c=this;if(isObject(c)&&isNumber(c))c=Number(c);c==b&&a++});return a},zip:function(){switch(arguments.length){case 0:return this;case 1:return g.call(this,arguments[0]);default:var b={},a=Bling(),c=arguments.length,e=this.length,h=0,i=0,k=null;for(h=0;h<c;h++)b[h]=g.call(this,
arguments[h]);for(h=0;h<e;h++){c={};for(k in b)c[k]=b[k].shift();a[i++]=c}return a}},zap:function(b,a){if(!b)return this;var c=b.indexOf(".");return c>-1?this.zip(b.substr(0,c)).zap(b.substr(c+1),a):isArray(a)?this.each(function(e){e[b]=a[++c]}):this.each(function(){this[b]=a})},take:function(b){b=Math.min(b|0,this.len());var a=Bling(b),c=-1;a.context=this.context;for(a.selector=this.selector;++c<b;)a[c]=this[c];return a},skip:function(b){b=Math.min(this.len(),Math.max(0,b|0));var a=Bling(b),c=0,
e=this.len()-b;a.context=this.context;for(a.selector=this.selector;c<e;c++)a[c]=this[c+b];return a},first:function(b){return b?this.take(b):this[0]},last:function(b){return b?this.skip(this.len()-b):this[this.length-1]},join:function(b){if(this.length==0)return"";return this.reduce(function(a){return a+b+this})},slice:function(b,a){var c=Bling(Array.Slice(this,b,a));c.context=this.context;c.selector=this.selector;return c},concat:function(b){for(var a=this.len()-1,c=-1,e=b.length;c<e;)this[++a]=b[++c];
return this},push:function(b){Array.prototype.push.call(this,b);return this},filter:function(b){var a=0,c=-1,e=this.length,h=Bling(e),i=null;h.context=this;for(h.selector=b;a<e;a++)if(i=this[a])if(isFunc(b)&&b.call(i,i)||isString(b)&&i.webkitMatchesSelector&&i.webkitMatchesSelector(b)||isType(b,"RegExp")&&b.test(i))h[++c]=i;return h},matches:function(b){if(isType(b,"RegExp"))return this.map(function(){return b.test(this)});return isString(b)&&this.webkitMatchesSelector?this.map(function(){return this.webkitMatchesSelector(b)}):
this.map(function(){return false})},weave:function(b){var a=b.length,c=this.length,e=Bling(2*Math.max(c,a));c=c-1;e.context=this.context;for(e.selector=this.selector;c>=0;c--)e[c*2+1]=this[c];for(;++c<a;)e[c*2]=b[c];return e},fold:function(b){var a=this.len(),c=0,e=Bling(Math.ceil(a/2)),h=0;e.context=this.context;e.selector=this.selector;for(h=0;h<a-1;h+=2)e[c++]=b.call(this,this[h],this[h+1]);if(a%2==1)e[c++]=b.call(this,this[a-1],undefined);return e},flatten:function(){var b=Bling(),a=this.len(),
c=null,e=0,h=0,i=0,k=0;b.context=this.context;for(b.selector=this.selector;h<a;h++){c=this[h];i=0;for(e=c.length;i<e;)b[k++]=c[i++]}return b},call:function(){return this.apply(null,arguments)},apply:function(b,a){return this.map(function(){if(isFunc(this))return this.apply(b,a);return this})},toString:function(){return Bling.symbol+"(["+this.map(function(){return this==undefined||this==window?"undefined":this==null?"null":this.toString().replace(/\[object (\w+)\]/,"$1")}).join(", ")+"])"},future:function(b,
a){a&&f.schedule(boundmethod(a,this),b);return this},log:function(b){b?console.log(b,this,this.length+" items"):console.log(this,this.length+" items");return this},len:function(){for(var b=this.length;b>-1&&this[--b]==undefined;);return b+1}}});
Bling.module("Html",function(){function d(a,c){a&&c&&a.parentNode.insertBefore(c,a)}function g(a){a=isNode(a)?a:isBling(a)?a.toFragment():isString(a)?Bling(a).toFragment():isFunc(a.toString)?Bling(a.toString()).toFragment():undefined;Bling.nextguid=Bling.nextguid||1;if(a&&a.guid==null)a.guid=Bling.nextguid++;return a}function f(a){for(var c=a.cloneNode(),e=0;e<a.childNodes.length;e++)c.appendChild(f(a.childNodes[e])).parentNode=c;return c}var b=null;return{$HTML:{parse:function(a){var c=document.createElement("body"),
e=document.createDocumentFragment();c.innerHTML=a;a=c.childNodes.length;if(a==1)return c.removeChild(c.childNodes[0]);for(var h=0;h<a;h++)e.appendChild(c.removeChild(c.childNodes[0]));return e},stringify:function(a){a=f(a);var c=document.createElement("div");c.appendChild(a);var e=c.innerHTML;c.removeChild(a);a.parentNode=null;return e},escape:function(a){b=b||Bling("<div>&nbsp;</div>").child(0);a=b.zap("data",a).zip("parentNode.innerHTML").first();b.zap("data","");return a}},$Color:{fromCss:function(a){a=
a||this;if(isString(a)){var c=document.createElement("div");c.style.display="none";c.style.color=a;Bling(document.body).append(c);a=window.getComputedStyle(c,null).getPropertyValue("color");Bling(c).remove();if(a){a=a.slice(a.indexOf("(")+1,a.indexOf(")")).split(", ");if(a.length==3)a[3]="1.0";return Bling(a).floats()}}},toCss:function(a){function c(e){e=e.map(Function.UpperLimit(255)).map(Function.LowerLimit(0));e[3]=Math.min(1,e[3]);return"rgba("+e.join(", ")+")"}a=a||this;return isBling(a[0])?
a.map(c):c(a)},invert:function(a){var c=Bling(4);if(isString(a))a=Bling.Color.fromCss(a);c[0]=255-a[0];c[1]=255-a[1];c[2]=255-a[2];c[3]=a[3];return c}},html:function(a){return a==undefined?this.zip("innerHTML"):isString(a)?this.zap("innerHTML",a):isBling(a)?this.html(a.toFragment()):isNode(a)?this.each(function(){for(this.replaceChild(this.childNodes[0],a);this.childNodes.length>1;)this.removeChild(this.childNodes[1])}):undefined},append:function(a){if(a==null)return this;a=g(a);var c=this.zip("appendChild");
c.take(1).call(a);c.skip(1).each(function(){this(f(a))});return this},appendTo:function(a){if(a==null)return this;Bling(a).append(this);return this},prepend:function(a){if(a==null)return this;a=g(a);this.take(1).each(function(){d(this.childNodes[0],a)});this.skip(1).each(function(){d(this.childNodes[0],f(a))});return this},prependTo:function(a){if(a==null)return this;Bling(a).prepend(this);return this},before:function(a){if(a==null)return this;a=g(a);this.take(1).each(function(){d(this,a)});this.skip(1).each(function(){d(this,
f(a))});return this},after:function(a){if(a==null)return this;a=g(a);this.take(1).each(function(){this.parentNode.insertBefore(a,this.nextSibling)});this.skip(1).each(function(){this.parentNode.insertBefore(f(a),this.nextSibling)});return this},wrap:function(a){a=g(a);if(isFragment(a))throw Error("cannot wrap something with a fragment");return this.map(function(c){if(isFragment(c))a.appendChild(c);else if(isNode(c)){var e=c.parentNode;if(e){var h=document.createElement("dummy");a.appendChild(e.replaceChild(h,
c));e.replaceChild(a,h)}else a.appendChild(c)}return c})},unwrap:function(){return this.each(function(){this.parentNode&&this.parentNode.parentNode&&this.parentNode.parentNode.replaceChild(this,this.parentNode)})},replace:function(a){a=g(a);var c=Bling(),e=-1;this.take(1).each(function(){if(this.parentNode){this.parentNode.replaceChild(a,this);c[++e]=a}});this.skip(1).each(function(){if(this.parentNode){var h=f(a);this.parentNode.replaceChild(h,this);c[++e]=h}});return c},attr:function(a,c){var e=
this.zip(c===undefined?"getAttribute":c===null?"removeAttribute":"setAttribute").call(a,c);return c?this:e},addClass:function(a){return this.removeClass(a).each(function(){var c=this.className.split(" ").filter(function(e){return e&&e!=""});c.push(a);this.className=c.join(" ")})},removeClass:function(a){var c=function(e){return e!=a};return this.each(function(){this.className=this.className.split(" ").filter(c).join(" ")})},toggleClass:function(a){function c(e){return e!=a}return this.each(function(e){var h=
e.className.split(" ");e.className=h.indexOf(a)>-1?h.filter(c).join(" "):h.push(a).join(" ")})},hasClass:function(a){return this.zip("className.split").call(" ").zip("indexOf").call(a).map(Function.IndexFound)},text:function(a){return a?this.zap("innerText",a):this.zip("innerText")},val:function(a){return a?this.zap("value",a):this.zip("value")},css:function(a,c){if(hasValue(c)||isObject(a)){var e=/^-webkit-/,h=this.zip("style.setProperty").map(function(){var k=this;return function(p,l){if(e.test(p)){k(p.replace(e,
"-moz-"),l);k(p.replace(e,"-o-"),l);k(p.replace(e,""),l)}k(p,l)}});if(isString(a))h.call(a,c);else for(var i in a)h.call(i,a[i]);return this}h=this.map(window.getComputedStyle).zip("getPropertyValue").call(a);return this.zip("style").zip(a).weave(h).fold(function(k,p){return k?k:p})},defaultCss:function(a,c){var e=this.selector,h="<style> ",i=Bling("head");if(isString(a))if(isString(c))h+=e+" { "+a+": "+c+" } ";else throw Error("defaultCss requires a value with a string key");else if(isObject(a)){h+=
e+" { ";for(var k in a)h+=k+": "+a[k];h+=" } "}h+="</style>";i.append(h)},rect:function(){return this.zip("getBoundingClientRect").call()},width:function(){return this.rect().zip("width")},height:function(a){return a==null?this.rect().zip("height"):this.css("height",a)},top:function(a){return a==null?this.rect().zip("top"):this.css("top",a)},left:function(a){return a==null?this.rect().zip("left"):this.css("left",a)},position:function(a,c){return a==null?this.rect():c==null?this.css("left",Number.Px(a)):
this.css({top:Number.Px(c),left:Number.Px(a)})},center:function(a){a=a||"viewport";var c=document.body.clientHeight/2,e=document.body.clientWidth/2;return this.each(function(){var h=Bling(this),i=h.height().floats().first(),k=h.width().floats().first();k=a=="viewport"||a=="horizontal"?document.body.scrollLeft+e-k/2:NaN;i=a=="viewport"||a=="vertical"?document.body.scrollTop+c-i/2:NaN;h.css({position:"absolute",left:isNumber(k)?k+"px":undefined,top:isNumber(i)?i+"px":undefined})})},trueColor:function(a,
c){a=a||"background-color";c=c||function(e){e[0]+=(this[0]-e[0])*this[3];e[1]+=(this[1]-e[1])*this[3];e[2]+=(this[2]-e[2])*this[3];e[3]=Math.min(1,e[3]+this[3]);return e};return this.parents().map(function(){return this.map(window.getComputedStyle).filter(hasValue).zip("getPropertyValue").call(a).filter(isString).map(Bling.Color.fromCss).reverse().reduce(c,Bling([0,0,0,0])).map(Bling.Color.toCss)})},child:function(a){return this.map(function(){return this.childNodes[a>=0?a:a+this.childNodes.length]})},
children:function(){return this.map(function(){return Bling(this.childNodes,this)})},parent:function(){return this.zip("parentNode")},parents:function(){return this.map(function(){for(var a=Bling(),c=-1,e=this;e=e.parentNode;)a[++c]=e;return a})},prev:function(){return this.map(function(){for(var a=Bling(),c=-1,e=this;e=e.previousSibling;)a[++c]=e;return a})},next:function(){return this.map(function(){for(var a=Bling(),c=-1,e=this;e=e.previousSibling;)a[++c]=e;return a})},remove:function(){return this.each(function(){this.parentNode&&
this.parentNode.removeChild(this)})},find:function(a){return this.filter("*").map(function(){return Bling(a,this)}).flatten()},clone:function(){return this.map(f)},toFragment:function(){if(this.length==1)return g(this[0]);var a=document.createDocumentFragment();this.map(g).map(boundmethod(a.appendChild,a));return a}}});
Bling.module("Math",function(){return{floats:function(){return this.map(function(){if(isBling(this))return this.floats();return parseFloat(this)})},ints:function(){return this.map(function(){if(isBling(this))return this.ints();return parseInt(this,10)})},px:function(d){d=d||0;return this.ints().map(Function.Px(d))},min:function(){return this.reduce(function(d){if(isBling(this))return this.min();return Math.min(this,d)})},max:function(){return this.reduce(function(d){if(isBling(this))return this.max();
return Math.max(this,d)})},average:function(){return this.sum()/this.length},sum:function(){return this.reduce(function(d){if(isBling(this))return d+this.sum();return d+this})},squares:function(){return this.map(function(){if(isBling(this))return this.squares();return this*this})},magnitude:function(){var d=this.map(function(){if(isBling(this))return this.magnitude();return parseFloat(this)});return Math.sqrt(d.squares().sum())},scale:function(d){return this.map(function(){if(isBling(this))return this.scale(d);
return d*this})},normalize:function(){return this.scale(1/this.magnitude())}}});
Bling.module("Event",function(){function d(f){eval("var f = function "+f+"(f) { // ."+f+"([f]) - trigger [or bind] the '"+f+"' event \nreturn isFunc(f) ? this.bind('"+f+"',f) : this.trigger('"+f+"', f ? f : {}) }");return eval("f")}setTimeout(function(){Bling.prototype.trigger!=null&&document.readyState=="complete"?Bling(document).trigger("ready"):setTimeout(arguments.callee,20)},0);var g=/, */;return{bind:function(f,b){var a=0,c=(f||"").split(g),e=c.length;return this.each(function(){for(;a<e;a++)this.addEventListener(c[a],
b)})},unbind:function(f,b){var a=0,c=(f||"").split(g),e=c.length;return this.each(function(){for(;a<e;a++)this.removeEventListener(c[a],b)})},once:function(f,b){for(var a=0,c=(f||"").split(g),e=c.length;a<e;a++)this.bind(c[a],function(h){b.call(this,h);this.unbind(h.type,arguments.callee)})},cycle:function(f){function b(){var k=0;return function(p){c[k].call(this,p);k=++k%i}}for(var a=0,c=Array.Slice(arguments,1,arguments.length),e=(f||"").split(g),h=e.length,i=c.length;a<h;)this.bind(e[a++],b());
return this},trigger:function(f,b){var a=undefined,c=0,e=(f||"").split(g),h=e.length,i=null;for(b=Object.Extend({bubbles:true,cancelable:true},b);c<h;c++){i=e[c];switch(i){case "click":case "mousemove":case "mousedown":case "mouseup":case "mouseover":case "mouseout":a=document.createEvent("MouseEvents");b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,button:0,relatedTarget:null},b);a.initMouseEvent(i,b.bubbles,b.cancelable,
window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.button,b.relatedTarget);break;case "blur":case "focus":case "reset":case "submit":case "abort":case "change":case "load":case "unload":a=document.createEvent("UIEvents");a.initUIEvent(i,b.bubbles,b.cancelable,window,1);break;case "touchstart":case "touchmove":case "touchend":case "touchcancel":a=document.createEvent("TouchEvents");b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,
altKey:false,shiftKey:false,metaKey:false,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},b);a.initTouchEvent(i,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.touches,b.targetTouches,b.changedTouches,b.scale,b.rotation);break;case "gesturestart":case "gestureend":case "gesturecancel":a=document.createEvent("GestureEvents");b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,
shiftKey:false,metaKey:false,target:null,scale:1,rotation:0},b);a.initGestureEvent(i,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.target,b.scale,b.rotation);break;default:a=document.createEvent("Events");a.initEvent(i,b.bubbles,b.cancelable)}a&&this.each(function(){this.dispatchEvent(a);a.result=a.returnValue=undefined})}return this},live:function(f,b){var a=this.selector,c=this.context;Bling(c).bind(f,function(h){Bling(a,
c).intersect(Bling(h.target).parents().first()).each(function(){h.target=this;b.call(this,h)})});var e=c.__livers__=c.__livers__||{};e[a]=e[a]||{};e[a][f]=e[a][f]||[];e[a][f].push(b)},die:function(f,b){var a=this.selector,c=this.context,e=Bling(c),h=c.__livers__;if(h==null)return this;h=c.__livers__[a][f];a=0;for(c=h.length;a<c;a++)if(b==undefined||b==h[a]){e.unbind(f,b);h.splice(a,1);c--;a--}},liveCycle:function(f){var b=0,a=Array.Slice(arguments,1,arguments.length);return this.live(f,function(c){a[b].call(this,
c);b=++b%a.length})},click:function(f){this.css("cursor").intersect(["auto",""]).len()>0&&this.css("cursor","pointer");return isFunc(f)?this.bind("click",f):this.trigger("click",f?f:{})},mousemove:d("mousemove"),mousedown:d("mousedown"),mouseup:d("mouseup"),mouseover:d("mouseover"),mouseout:d("mouseout"),blur:d("blur"),focus:d("focus"),load:d("load"),ready:d("ready"),unload:d("unload"),reset:d("reset"),submit:d("submit"),keyup:d("keyup"),keydown:d("keydown"),change:d("change"),abort:d("abort"),cut:d("cut"),
copy:d("copy"),paste:d("paste"),selection:d("selection"),drag:d("drag"),drop:d("drop"),orientationchange:d("orientationchange"),touchstart:d("touchstart"),touchmove:d("touchmove"),touchend:d("touchend"),touchcancel:d("touchcancel"),gesturestart:d("gesturestart"),gestureend:d("gestureend"),gesturecancel:d("gesturecancel")}});
Bling.module("Transform",function(){var d=/(?:scale|translate|rotate|scale3d|translateX|translateY|translateZ|translate3d|rotateX|rotateY|rotateZ|rotate3d)/;return{$duration:function(g){var f={slow:700,medium:500,normal:300,fast:100,instant:0,now:0}[g];return f?f:parseFloat(g)},transform:function(g,f,b){if(typeof f=="function"){b=f;f=undefined}f=f||"normal";var a=Bling.duration(f);f=[];var c=0,e=0,h=null,i="",k={};for(e in g)if(d.test(e)){h=g[e];if(h.join)h=h.join(", ");else if(h.toString)h=h.toString();
i+=" "+e+"("+h+")"}else k[e]=g[e];for(e in k)f[c++]=e;if(i)f[c++]="-webkit-transfrom";k["-webkit-transition-property"]=f.join(", ");k["-webkit-transition-duration"]=f.map(function(){return a+"ms"}).join(", ");if(i)k["-webkit-transform"]=i;this.css(k);return this.future(a,b)},hide:function(g){return this.each(function(){if(this.style){this._display=this.style.display=="none"?undefined:this.style.display;this.style.display="none"}}).future(50,g)},show:function(g){return this.each(function(){if(this.style){this.style.display=
this._display?this._display:"block";this._display=undefined}}).future(50,g)},toggle:function(g){this.weave(this.css("display")).fold(function(f,b){if(f=="none"){b.style.display=b._old_display?b._old_display:"block";b._old_display=undefined}else{b._old_display=f;b.style.display="none"}return b}).future(50,g)},fadeIn:function(g,f){return this.css("opacity","0.0").show(function(){this.transform({opacity:"1.0",translate3d:[0,0,0]},g,f)})},fadeOut:function(g,f,b,a){b=b||0;a=a||0;return this.each(function(c){Bling(c).transform({opacity:"0.0",
translate3d:[b,a,0]},g,function(){this.hide()})}).future(Bling.duration(g),f)},fadeLeft:function(g,f){return this.fadeOut(g,f,"-"+this.width().first(),0)},fadeRight:function(g,f){return this.fadeOut(g,f,this.width().first(),0)},fadeUp:function(g,f){return this.fadeOut(g,f,0,"-"+this.height().first())},fadeDown:function(g,f){return this.fadeOut(g,f,0,this.height().first())}}});
Bling.module("Http",function(){function d(f){var b=[],a=0;f=g.parse(g.stringify(f));for(var c in f)b[a++]=c+"="+escape(f[c]);return b.join("&")}var g=g||{};return{$http:function(f,b){var a=new XMLHttpRequest;if(isFunc(b))b={success:boundmethod(b,a)};b=Object.Extend({method:"GET",data:null,state:Function.Empty,success:Function.Empty,error:Function.Empty,async:true,withCredentials:false},b);b.state=boundmethod(b.state,a);b.success=boundmethod(b.success,a);b.error=boundmethod(b.error,a);if(b.data&&b.method==
"GET")f+="?"+d(b.data);else if(b.data&&b.method=="POST")b.data=d(b.data);a.open(b.method,f,b.async);a.withCredentials=b.withCredentials;a.onreadystatechange=function(){b.state&&b.state();if(a.readyState==4)a.status==200?b.success(a.responseText):b.error(a.status,a.statusText)};a.send(b.data);return Bling([a])},$post:function(f,b){if(isFunc(b))b={success:b};b=b||{};b.method="POST";return Bling.http(f,b)},$get:function(f,b){if(isFunc(b))b={success:b};b=b||{};b.method="GET";return Bling.http(f,b)}}});
Bling.module("Database",function(){function d(f,b){throw Error("sql error ["+b.code+"] "+b.message);}function g(f,b){if(!f)throw Error("assert failed: "+b);}return{$db:function(f,b,a,c){return Bling([window.openDatabase(f||"bling.db",b||"1.0",a||"bling database",c||1024)])},transaction:function(f){this.zip("transaction").call(f);return this},sql:function(f,b,a,c){if(f!=undefined){if(typeof b=="function"){c=a;a=b;b=undefined}b=b||[];a=a||Function.Empty;c=c||d;g(isType(this[0],"Database"),"can only call .sql() on a bling of Database");
return this.transaction(function(e){e.executeSql(f,b,a,c)})}}}});
Bling.module("Template",function(){function d(l){var o=[];l=l.split(/%[\(\/]/);var j=-1,n=1,q=l.length,r=null,t=j=null;for(o.push(l[0]);n<q;n++){a:{r=l[n];j=-1;t=1;if(j==null||j==-1)j=r.length;for(var u=0;u<j;u++){if(r.charAt(u)=="(")t+=1;else if(r.charAt(u)==")")t-=1;if(t==0){j=u;break a}}j=-1}if(j==-1)return"Template syntax error: unmatched '%(' in chunk starting at: "+l[n].substring(0,15);r=l[n].substring(0,j);j=l[n].substring(j);t=b.exec(j);if(t==null)return"Template syntax error: invalid type specifier starting at '"+
j+"'";j=t[4];o.push(r);o.push(t[1]|0);o.push(t[2]|0);o.push(t[3]);o.push(j)}return o}function g(l,o){for(var j=d.cache[l]||(d.cache[l]=d(l)),n=[j[0]],q=1,r=1,t=j.length;r<t-4;r+=5){var u=j[r],y=j[r+1],z=j[r+2],v=j[r+3],m=j[r+4],w=o[u];if(w==null)w="missing required value: "+u;switch(v){case "d":n[q++]=""+parseInt(w,10);break;case "f":n[q++]=parseFloat(w).toFixed(z);break;default:n[q++]=""+w}if(y>0)n[q]=String.PadLeft(n[q],y);n[q++]=m}return n.join("")}function f(l){function o(){var x=Bling.HTML.parse(y);
v?v.appendChild(x):w.push(x);y="";m=a}function j(){var x=document.createElement(n);x.id=q?q:null;x.className=r?r:null;for(var A in z)x.setAttribute(A,z[A]);v?v.appendChild(x):w.push(x);v=x;y=u=t=r=q=n="";z={};m=a}for(var n="",q="",r="",t="",u="",y="",z={},v=null,m=a,w=Bling([]),B=0,s=null;s=l.charAt(B++);)if(s=="+"&&m==a)v=v?v.parentNode:v;else if(s=="#"&&(m==a||m==e||m==h))m=c;else if(s=="."&&(m==a||m==c||m==h)){if(r.length>0)r+=" ";m=e}else if(s=="."&&r.length>0)r+=" ";else if(s=="["&&(m==a||m==
c||m==e||m==h))m=h;else if(s=="="&&m==h)m=i;else if(s=='"'&&m==a)m=k;else if(s=="'"&&m==a)m=p;else if(s=="]"&&(m==h||m==i)){z[t]=u;u=t="";m=a}else if(s=='"'&&m==k)o();else if(s=="'"&&m==p)o();else if((s==" "||s==",")&&m!=i&&m!=h&&n.length>0){j();if(s==",")v=null}else if(m==a)n+=s!=" "?s:"";else if(m==c)q+=s;else if(m==e)r+=s;else if(m==h)t+=s;else if(m==i)u+=s;else if(m==k||m==p)y+=s;else throw Error("Unknown input/state: '"+s+"'/"+m);n.length>0&&j();y.length>0&&o();return w}var b=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;
d.cache={};var a=1,c=2,e=3,h=4,i=5,k=6,p=7;return{$render:g,$synth:f,template:function(l){this.render=function(o){return g(this.map(Bling.HTML.stringify).join(""),Object.Extend(l,o))};return this.remove()},render:function(l){return g(this.map(Bling.HTML.stringify).join(""),l)},synth:function(l){return f(l).appendTo(this)}}});
