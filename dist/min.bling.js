(function(){var g,q,r,C,y,v,D,A,x,z,G=Object.prototype.hasOwnProperty,E=function(a,d){function b(){this.constructor=a}for(var e in d)G.call(d,e)&&(a[e]=d[e]);b.prototype=d.prototype;a.prototype=new b;a.__super__=d.prototype;return a},w=Array.prototype.slice,F=function(a,d){return function(){return a.apply(d,arguments)}};(Array.prototype.indexOf||function(a){for(var d=0,b=this.length;d<b;d++)if(this[d]===a)return d;return-1}).call(document,!1)>=0&&alert("This browser is not supported");v=/, */;D=/^\s+/;
A=/\[object (\w+)\]/;r=Math.min;q=Math.max;C=Math.sqrt;y=Object.prototype.toString;x=console.log;z="string";Array.prototype.extend=function(a){var d,b,e,i;b=this.length;e=0;for(i=a.length;e<i;e++)d=a[e],this[b++]=d;return this};g=function(){function a(d,b){b==null&&(b=document);this.selector=d;this.context=b;if(this===window)return new a(d,b);if(d!=null)if(Object.IsNode(d||d===window))this[0]=d;else if(typeof d===z)if(d=String.TrimLeft(d),d[0]==="<")this[0]=a.HTML.parse(d);else if(b.querySelectorAll)this.extend(b.querySelectorAll(d));
else if(Object.IsBling(b))this.extend(b.reduce(function(e,a){return e.extend(typeof a.querySelectorAll=="function"?a.querySelectorAll(d):void 0)},[]));else throw Error("invalid context: "+b+" (type: "+typeof b+")");else if("length"in d)this.extend(d);else throw Error("invalid selector: "+d+" (type: "+typeof d+")");}E(a,Array);a.symbol="$";a.plugins=[];return a}();window.$=window.Bling=g;Object.Keys=function(a,d){var b,e,i;i=[];e=0;for(b in a)if(d||a.hasOwnProperty(b))i[e++]=b;return i};Object.Extend=
function(a,d,b){var e;if(y.apply(b)==="[object Array]")for(e in b)d[b[e]]!==void 0&&(a[b[e]]=d[b[e]]);else for(e in b=Object.Keys(d))a[b[e]]=d[b[e]];return a};Object.Extend(Object,{IsType:function(a,d){return a===null?a===d:a.__proto__===null?!1:a.__proto__.constructor===d?!0:typeof d===z?a.constructor.name===d||y.apply(a).replace(A,"$1")===d:Object.IsType(a.__proto__,d)},Type:function(a){switch(!0){case Object.IsString(a):return"string";case Object.IsNumber(a):return"number";case Object.IsFragment(a):return"fragment";
case Object.IsNode(a):return"node";case Object.IsFunc(a):return"function";case Object.IsArray(a):return"array";case Object.IsBling(a):return"bling";case Object.IsType(a,"RegExp"):return"regexp";case Object.IsObject(a):return"object"}},IsString:function(a){return a!=null&&(typeof a===z||Object.IsType(a,String))},IsNumber:isFinite,IsFunc:function(a){return a!=null&&(typeof a==="function"||Object.IsType(a,Function))&&a.call!=null},IsNode:function(a){return a!=null&&a.nodeType>0},IsFragment:function(a){return a!=
null&&a.nodeType===11},IsArray:function(a){return a!=null&&(Object.ToString(a)==="[object Array]"||Object.IsType(a,Array))},IsBling:function(a){return a!=null&&Object.IsType(a,g)},IsObject:function(a){return a!=null&&typeof a==="object"},IsDefined:function(a){return a!=null},Unbox:function(a){if(a!=null&&Object.IsObject(a)){if(Object.IsString(a))return a.toString();if(Object.IsNumber(a))return Number(a)}return a},ToString:function(a){return y.apply(a)}});Object.Extend(Function,{Empty:function(){},
Bound:function(a,d,b){var e;b==null&&(b=[]);"bind"in a?(b.splice(0,0,d),e=a.bind.apply(a,b)):e=function(){1<=arguments.length&&w.call(arguments,0);return a.apply(d,b)};e.toString=function(){return"bound-method of "+d+"."+a.name};return e},Trace:function(a,d,b){var e;b==null&&(b=x);e=function(){var e;e=1<=arguments.length?w.call(arguments,0):[];b(""+(d||"")+(this.name||this)+"."+a.name+"(",e,")");return a.apply(this,e)};b("Function.Trace: "+(d||a.name)+" created.");e.toString=a.toString;return e},
NotNull:function(a){return a!==null},IndexFound:function(a){return a>-1},ReduceAnd:function(a){return a&&this},UpperLimit:function(a){return function(d){return r(a,d)}},LowerLimit:function(a){return function(d){return q(a,d)}},Px:function(a){return function(){return Number.Px(this,a)}}});Object.Extend(Array,{Coalesce:function(){var a,d,b,e;a=1<=arguments.length?w.call(arguments,0):[];if(Object.IsArray(a[0]))return Array.Coalesce.apply(Array,a[0]);else{b=0;for(e=a.length;b<e;b++)if(d=a[b],d!=null)return d}}});
Object.Extend(Number,{Px:function(a,d){d==null&&(d=0);return a!=null&&parseInt(a,10)+(d|0)+"px"},AtLeast:function(a){return function(d){return q(parseFloat(d||0),a)}},AtMost:function(a){return function(d){return r(parseFloat(d||0),a)}}});Object.Extend(String,{PadLeft:function(a,d,b){for(b==null&&(b=" ");a.length<d;)a=b+a;return a},PadRight:function(a,d,b){for(b==null&&(b=" ");a.length<d;)a+=b;return a},Splice:function(a,d,b,e){var i;i=a.length;b<0&&(b+=i);d<0&&(d+=i);return a.substring(0,d)+e+a.substring(b)}});
Object.Extend(Event,{Cancel:function(a){a.stopPropagation();a.preventDefault();a.cancelBubble=!0;return a.returnValue=!1},Prevent:function(a){return a.preventDefault()},Stop:function(a){a.stopPropagation();return a.cancelBubble=!0}});String.prototype.trimLeft=Array.Coalesce(String.prototype.trimLeft,function(){return this.replace(D,"")});String.prototype.split=Array.Coalesce(String.prototype.split,function(a){var d,b,e,i;d=[];for(b=i=0;(e=this.indexOf(a,b))>-1;)d[i++]=this.substring(b+1,e+1),b=e+
1;return d});Array.prototype.join=Array.Coalesce(Array.prototype.join,function(a){var d,b;d=this.length;if(d===0)return"";for(b=this[d-1];--d>0;)b=this[d-1]+a+b;return b});Element.prototype.matchesSelector=Array.Coalesce(Element.prototype.webkitMatchesSelector,Element.prototype.mozMatchesSelector,Element.prototype.matchesSelector);Element.prototype.toString=function(a){a==null&&(a=!1);return a?(a=this.nodeName.toLowerCase(),this.id!=null?a+="#"+this.id:this.className!=null&&(a+="."+this.className.split(" ").join(".")),
a):Element.prototype.toString.apply(this)};if(Element.prototype.cloneNode.length===0)Element.prototype.cloneNode=function(a){var d,b,e,i,c;a==null&&(a=!1);b=this.cloneNode();if(a){c=this.childNodes;e=0;for(i=c.length;e<i;e++)d=c[e],b.appendChild(d.cloneNode(a))}return b};g.plugin=function(a){var d,b,e,i,c;b=a.call(g,g);d=function(c,f){return c[0]===g.symbol?g[c.substr(1)]=f:g.prototype[c]=f};c=Object.Keys(b,!0);e=0;for(i=c.length;e<i;e++)a=c[e],a!=="name"&&d(a,b[a]);g.plugins.push(b.name);return g.plugins[b.name]=
b};g.plugin(function(){var a,d,b;a=new (function(){function e(){this.next=F(function(){if(this.length>0)return this.shift()()},this);this.schedule=F(function(e,c){var a,f;if(!Object.IsFunc(e))throw Error("function expected, got: "+typeof e);f=this.length;e.order=c+(new Date).getTime();if(f===0||e.order>this[f-1].order)this[f]=e;else for(a=0;0<=f?a<f:a>f;0<=f?a+=1:a-=1)if(this[a].order>e.order){this.splice(a,0,e);break}return setTimeout(this.next,c)},this)}E(e,Array);return e}());d=function(e){return function(){var a;
a=this[e];if(Object.IsFunc(a))return Function.Bound(a,this);return a}};b=function(e){var a;a=e.indexOf(".");if(a>-1)return this.zip(e.substr(0,a)).zip(e.substr(a+1));return this.map(d(e))};return{name:"Core",eq:function(e){return g([this[e]])},each:function(e){var a,c,h;c=0;for(h=this.length;c<h;c++)a=this[c],e.call(a,a);return this},map:function(a){var b,c,h,f;b=g();b.context=this;b.selector=["map",a];h=this.len();for(c=0;0<=h?c<h:c>h;0<=h?c+=1:c-=1){f=this[c];try{b[c]=a.call(f,f)}catch(k){b[c]=
k}}return b},reduce:function(a,b){var c,h;c=b;b==null&&(c=this[0],h=this.skip(1));h.each(function(){return c=a.call(this,c,this)});return c},union:function(a,b){var c,h,f,k;f=g();c=h=0;f.context=[this,a];for(f.selector="union";k=this[h++];)f.contains(k,b)||(f[c++]=k);for(h=0;k=a[h++];)f.contains(k,b)||(f[c++]=k);return f},intersect:function(a){var b,c,h,f,k,j;j=g();h=0;f=this.len();k=Object.IsFunc(a.len)?a.len():a.length;j.context=[this,a];j.selector="intersect";for(b=0;0<=f?b<f:b>f;0<=f?b+=1:b-=
1)for(c=0;0<=k?c<k:c>k;0<=k?c+=1:c-=1)if(this[b]===a[c]){j[h++]=this[b];break}return j},distinct:function(a){return this.union(this,a)},contains:function(a,b){return this.count(a,b)>0},count:function(a,b){var c;if(a===void 0)return this.len();c=0;this.each(function(h){if(b&&h===a||!b&&h===a)return c++});return c},zip:function(){var a,d,c,h,f,k,j,u;a=1<=arguments.length?w.call(arguments,0):[];j=a.length;switch(j){case 0:return g();case 1:return b.call(this,a[0]);default:k={};u=this.len();d=g();for(c=
h=0;0<=j?c<j:c>j;0<=j?c+=1:c-=1)k[a[c]]=b.call(this,a[c]);for(c=0;0<=u?c<u:c>u;0<=u?c+=1:c-=1){a={};for(f in k)a[f]=k[f].shift();d[h++]=a}return d}},zap:function(a,b){var c;c=a.indexOf(".");return c>-1?this.zip(a.substr(0,c)).zap(a.substr(c+1),b):Object.IsArray(b)?this.each(function(){return this[a]=b[++c]}):this.each(function(){return this[a]=b})},take:function(a){var b,c;a=r(a|0,this.len());b=g();b.context=this;b.selector=["take",a];for(c=0;0<=a?c<a:c>a;0<=a?c+=1:c-=1)b[c]=this[c];return b},skip:function(a){var b,
c,h;a=r(this.len(),q(0,a|0));h=this.len()-a;b=g();b.context=this.context;b.selector=this.selector;for(c=0;0<=h?c<h:c>h;0<=h?c+=1:c-=1)b[c]=this[c+a];return b},first:function(a){a==null&&(a=1);return this.take(a)},last:function(a){a==null&&(a=1);return this.skip(this.len()-a)},slice:function(a,b){var c;c=g(this.slice(a,b));c.context=this;c.selector="slice(#{start},#{end})";return c},concat:function(a){var b,c,h;b=this.len()-1;c=-1;for(h=Object.IsFunc(a.len)?a.len():a.length;c<h-1;)this[++b]=a[++c];
return this},push:function(a){Array.prototype.push.call(this,a);return this},filter:function(a){var b,c,h,f,k,j;j=this.len();b=g();b.context=this;b.selector=a;k=0;switch(Object.Type(a)){case "string":c=function(c){return typeof f.matchesSelector=="function"?f.matchesSelector(c):void 0};break;case "regexp":c=function(c){return a.test(c)};break;case "function":c=a}for(h=0;0<=j?h<j:h>j;0<=j?h+=1:h-=1)f=this[h],c.call(f,f)&&(b[k++]=f);return b},test:function(a){return this.map(function(){return a.test(this)})},
matches:function(a){return this.zip("matchesSelector").call(a)},weave:function(a){var b,c,h,f;h=a.len();c=this.len();b=g();b.context=[this,a];b.selector="weave";for(c=f=c-1;f<=0?c<=0:c>=0;f<=0?c+=1:c-=1)b[c*2+1]=this[c];for(c=0;0<=h?c<h:c>h;0<=h?c+=1:c-=1)b[c*2]=a[c];return b},fold:function(a){var b,c,h,f,k;f=this.len();h=0;b=g();b.context=this;b.selector=["fold",a];c=0;for(k=f-1;0<=k?c<k:c>k;c+=2)b[h++]=a.call(this,this[c],this[c+1]);f%2===1&&(b[h++]=a.call(this,this[f-1],void 0));return b},flatten:function(){var a,
b,c,h,f,k,j;a=g();j=this.len();k=0;a.context=this;a.selector="flatten";for(h=0;0<=j?h<j:h>j;0<=j?h+=1:h-=1){b=this[h];c=Object.IsFunc(b.len)?b.len():b.length;for(f=0;0<=c?f<c:f>c;0<=c?f+=1:f-=1)a[k++]=b[f]}return a},call:function(){return this.apply(null,arguments)},apply:function(a,b){return this.map(function(){return Object.IsFunc(this)?this.apply(a,b):this})},toString:function(){return g.symbol+"(["+this.map(function(){switch(this){case void 0:return"undefined";case null:return"null";case window:return"window";
default:return this.toString().replace(A,"$1")}}).join(", ")+"])"},delay:function(b,d){d&&a.schedule(Function.Bound(d,this),b);return this},log:function(a){var b;b=this.len();a?x(a,this,b+" items"):x(this,b+" items");return this},len:function(){var a;for(a=this.length;this[a]!==void 0;)a++;for(;a>-1&&this[a]===void 0;)a--;return a+1}}});g.plugin(function(){var a,d,b,e,i;d=function(a,b){return a.parentNode.insertBefore(b,a)};a=function(a,b){return a.parentNode.insertBefore(b,a.nextSibling)};i=function(a){switch(Object.Type(a)){case "node":return a;
case "bling":return a.toFragment();case "string":return g(a).toFragment();case "function":return g(a.toString()).toFragment()}};b=null;e=function(a){return function(){return window.getComputedStyle(this,null).getPropertyValue(a)}};return{name:"Html",$HTML:{parse:function(a){var b,f,k,j;j=document.createElement("div");j.innerHTML=a;a=j.childNodes;k=a.length;if(k===1)return j.removeChild(a[0]);b=document.createDocumentFragment();for(f=0;0<=k?f<k:f>k;0<=k?f+=1:f-=1)b.appendChild(j.removeChild(a[0]));
return b},stringify:function(a){var b,f;a=a.cloneNode(!0);b=document.createElement("div");b.appendChild(a);f=b.innerHTML;b.removeChild(a);try{a.parentNode=null}catch(k){}return f},escape:function(a){b||(b=g("<div>&nbsp;</div>").child(1));a=b.zap("data",a).zip("parentNode.innerHTML").first();b.zap("data","");return a}},html:function(a){switch(Object.Type(a)){case "undefined":return this.zip("innerHTML");case "string":return this.zap("innerHTML",a);case "bling":return this.html(a.toFragment());case "node":return this.each(function(){var b;
this.replaceChild(this.childNodes[0],a);for(b=[];this.childNodes.length>1;)b.push(this.removeChild(this.childNodes[1]));return b})}},append:function(a){var b;a!=null&&(a=i(a),b=this.zip("appendChild"),b.take(1).call(a),b.skip(1).each(function(b){return b(a.cloneNode(!0))}));return this},appendTo:function(a){a!=null&&g(a).append(this);return this},prepend:function(a){a!=null&&(a=i(a),this.take(1).each(function(){return d(this.childNodes[0],a)}),this.skip(1).each(function(){return d(this.childNodes[0],
a.cloneNode(!0))}));return this},prependTo:function(a){a!=null&&g(a).prepend(this);return this},before:function(a){a!=null&&(a=i(a),this.take(1).each(function(){return d(this,a)}),this.skip(1).each(function(){return d(this,a.cloneNode(!0))}));return this},after:function(b){b!=null&&(b=i(b),this.take(1).each(function(){return a(this,b)}),this.skip(1).each(function(){return a(this,b.cloneNode(!0))}));return this},wrap:function(a){a=i(a);if(Object.IsFragment(a))throw Error("cannot wrap with a fragment");
return this.map(function(b){var f,k;if(Object.IsFragment(b))a.appendChild(b);else if(Object.IsNode(b))(k=b.parentNode)?(f=document.createElement("dummy"),a.appendChild(k.replaceChild(f,b)),k.replaceChild(a,f)):a.appendChild(b);return b})},unwrap:function(){return this.each(function(){if(this.parentNode&&this.parentNode.parentNode)return this.parentNode.parentNode.replaceChild(this,this.parentNode)})},replace:function(a){var b,f;a=i(a);b=g();f=0;this.take(1).each(function(){if(this.parentNode)return this.parentNode.replaceChild(a,
this),b[f++]=a});this.skip(1).each(function(){var k;if(this.parentNode)return k=a.cloneNode(!0),this.parentNode.replaceChild(k,this),b[f++]=k});return b},attr:function(a,b){switch(b){case void 0:return this.zip("getAttribute").call(a,b);case null:return this.zip("removeAttribute").call(a,b);default:return this.zip("setAttribute").call(a,b),this}},addClass:function(a){return this.removeClass(a).each(function(){var b;b=this.className.split(" ").filter(function(a){return a!==""});b.push(a);return this.className=
b.join(" ")})},removeClass:function(a){var b;b=function(b){return b!==a};return this.each(function(){return this.className=this.className.split(" ").filter(b).join(" ")})},toggleClass:function(a){var b;b=function(b){return b!==a};return this.each(function(){var f;f=this.className.split(" ");return f.indexOf(a)>-1?this.className=f.filter(b).join(" "):(f.push(a),this.className=f.join(" "))})},hasClass:function(a){return this.zip("className.split").call(" ").zip("indexOf").call(a).map(Function.IndexFound)},
text:function(a){if(a===null)return this.zip("textContent");return this.zap("textContent",a)},val:function(a){if(a===null)return this.zip("value");return this.zap("value",a)},css:function(a,b){var f,k,j,d;if(b!=null||Object.IsObject(a)){d=this.zip("style.setProperty");j=d.len();if(Object.IsObject(a))for(f in a)d.call(f,a[f],"");else if(Object.IsString(b))d.call(a,b,"");else if(Object.IsArray(b)){k=q(b.length,j);for(f=0;0<=k?f<k:f>k;0<=k?f+=1:f-=1)d[f%j](a,b[f%k],"")}return this}else return f=this.map(e(a)),
k=this.zip("style").zip(a),k.weave(f).fold(function(a,b){return a||b})},defaultCss:function(a,b){var f,k,j;k=this.selector;j="";if(Object.IsString(a))if(Object.IsString(b))j+=""+k+" { "+a+": "+b+" } ";else throw Error("defaultCss requires a value with a string key");else if(Object.IsObject(a)){j+=""+k+" { ";for(f in a)j+=""+f+": "+a[f]+"; ";j+="} "}g.synth("style").text(j).appendTo("head");return this},empty:function(){return this.html("")},rect:function(){return this.zip("getBoundingClientRect").call()},
width:function(a){if(a===null)return this.rect().zip("width");return this.css("width",a)},height:function(a){if(a===null)return this.rect().zip("height");return this.css("height",a)},top:function(a){if(a===null)return this.rect().zip("top");return this.css("top",a)},left:function(a){if(a===null)return this.rect().zip("left");return this.css("left",a)},bottom:function(a){if(a===null)return this.rect().zip("bottom");return this.css("bottom",a)},right:function(a){if(a===null)return this.rect().zip("right");
return this.css("right",a)},position:function(a,b){if(a===null)return this.rect();if(b===null)return this.css("left",Number.Px(a));return this.css({top:Number.Px(b),left:Number.Px(a)})},center:function(a){var b,f,k;a==null&&(a="viewport");b=document.body;f=b.scrollTop+b.clientHeight/2;k=b.scrollLeft+b.clientWidth/2;return this.each(function(){var b,d,e;d=g(this);b=d.height().floats().first();e=d.width().floats().first();e=a==="viewport"||a==="horizontal"?k-e/2:NaN;b=a==="viewport"||a==="vertical"?
f-b/2:NaN;return d.css({position:"absolute",left:Number.Px(e),top:Number.Px(b)})})},scrollToCenter:function(){document.body.scrollTop=this.zip("offsetTop")[0]-window.innerHeight/2;return this},child:function(){return this.map(function(){return null})},children:function(){return this.map(function(){return g(this.childNodes,this)})},parent:function(){return this.zip("parentNode")},parents:function(){return this.map(function(){var a,b,f;a=g();b=0;for(f=this;f=f.parentNode;)a[b++]=f;return a})},prev:function(){return this.map(function(){var a,
b,f;a=g();b=0;for(f=this;f=f.previousSibling;)a[b++]=f;return a})},next:function(){return this.map(function(){var a,b,f;a=g();b=0;for(f=this;f=f.nextSibling;)a[b++]=f;return a})},remove:function(){return this.each(function(){if(this.parentNode)return this.parentNode.removeChild(this)})},find:function(a){return this.filter("*").map(function(){return g(a,this).flatten()})},clone:function(a){a==null&&(a=!0);return this.map(function(){return Object.IsNode(this)?this.cloneNode(a):null})},toFragment:function(){var a;
if(this.len()>1)return a=document.createDocumentFragment(),this.map(i).map(Function.Bound(a.appendChild,a)),a;return i(this[0])}}});g.plugin(function(){return{name:"Maths",floats:function(){return this.map(parseFloat)},ints:function(){return this.map(function(){return parseInt(this,10)})},px:function(a){a==null&&(a=0);return this.ints().map(Function.Px(a))},min:function(){return this.reduce(function(a){return r(this,a)})},max:function(){return this.reduce(function(a){return q(this,a)})},average:function(){return this.sum()/
this.len()},sum:function(){return this.reduce(function(a){return a+this})},squares:function(){return this.map(function(){return this*this})},magnitude:function(){return C(this.floats().squares().sum())},scale:function(a){return this.map(function(){return a*this})},normalize:function(){return this.scale(1/this.magnitude())}}});g.plugin(function(){var a,d,b,e,i,c,h;a=function(a){return function(b){b==null&&(b={});if(Object.IsFunc(b))return this.bind(a,b);return this.trigger(a,b)}};e=function(a,b,j,
c,d){return g(b).bind(j,d).each(function(){var b;b=this.__alive__||(this.__alive__={});b=b[a]||(b[a]={});return(b[j]||(b[j]={}))[c]=d})};h=function(a,b,j,d){var c;c=g(b);return c.each(function(){var b;b=this.__alive__||(this.__alive__={});b=b[a]||(b[a]={});b=b[j]||(b[j]={});c.unbind(j,b[d]);return delete b[d]})};d=b=0;c=function(){if(!b++)return g(document).trigger("ready").unbind("ready"),typeof document.removeEventListener=="function"&&document.removeEventListener("DOMContentLoaded",c,!1),typeof window.removeEventListener==
"function"?window.removeEventListener("load",c,!1):void 0};d++||(typeof document.addEventListener=="function"&&document.addEventListener("DOMContentLoaded",c,!1),typeof window.addEventListener=="function"&&window.addEventListener("load",c,!1));i={name:"Events",bind:function(a,b){var j,c;j=(a||"").split(v);c=function(a){var f;f=b.apply(this,arguments);f===!1&&Event.Prevent(a);return f};return this.each(function(){var a,b,f,k;k=[];b=0;for(f=j.length;b<f;b++)a=j[b],k.push(this.addEventListener(a,c,!1));
return k})},unbind:function(a,b){var c;c=(a||"").split(v);return this.each(function(){var a,f,d,e;e=[];f=0;for(d=c.length;f<d;f++)a=c[f],e.push(this.removeEventListener(a,b,null));return e})},once:function(a,b){var c,d,e,h,g;c=(a||"").split(v);g=[];e=0;for(h=c.length;e<h;e++)d=c[e],g.push(this.bind(d,function(a){b.call(this,a);return this.removeEventListener(a.type,arguments.callee,null)}));return g},cycle:function(){var a,b,c,d,e,h,g;a=arguments[0];c=2<=arguments.length?w.call(arguments,1):[];a=
(a||"").split(v);e=c.length;b=function(){var a;a=0;return function(b){c[a].call(this,b);return a=++a%e}};h=0;for(g=a.length;h<g;h++)d=a[h],this.bind(d,b());return this},trigger:function(a,b){var c,d,e,h,g;e=(a||"").split(v);b=Object.Extend({bubbles:!0,cancelable:!0},b);h=0;for(g=e.length;h<g;h++){d=e[h];if(d==="click"||d==="mousemove"||d==="mousedown"||d==="mouseup"||d==="mouseover"||d==="mouseout")c=document.createEvent("MouseEvents"),b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,
ctrlKey:!1,altKey:!1,shiftKey:!1,metaKey:!1,button:0,relatedTarget:null},b),c.initMouseEvent(d,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.button,b.relatedTarget);else if(d==="blur"||d==="focus"||d==="reset"||d==="submit"||d==="abort"||d==="change"||d==="load"||d==="unload")c=document.createEvent("UIEvents"),c.initUIEvent(d,b.bubbles,b.cancelable,window,1);else if(d==="touchstart"||d==="touchmove"||d==="touchend"||d==="touchcancel")c=
document.createEvent("TouchEvents"),b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:!1,altKey:!1,shiftKey:!1,metaKey:!1,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},b),c.initTouchEvent(d,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.touches,b.targetTouches,b.changedTouches,b.scale,b.rotation);else if(d==="gesturestart"||d==="gestureend"||d==="gesturecancel")c=document.createEvent("GestureEvents"),
b=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:!1,altKey:!1,shiftKey:!1,metaKey:!1,target:null,scale:1,rotation:0},b),c.initGestureEvent(d,b.bubbles,b.cancelable,window,b.detail,b.screenX,b.screenY,b.clientX,b.clientY,b.ctrlKey,b.altKey,b.shiftKey,b.metaKey,b.target,b.scale,b.rotation);else{c=document.createEvent("Events");c.initEvent(d,b.bubbles,b.cancelable);try{c=Object.Extend(c,b)}catch(i){}}if(c)try{this.each(function(){return this.dispatchEvent(c)})}catch(l){x("dispatchEvent error:",
l)}}return this},live:function(a,b){var d,c,h;c=this.selector;d=this.context;h=function(a){return g(c,d).intersect(g(a.target).parents().first().union(g(a.target))).each(function(){a.target=this;return b.call(this,a)})};g(d).bind(a,h);e(c,d,a,b,h);return this},die:function(a,b){var d,c;c=this.selector;d=this.context;c=h(c,d,a,b);g(d).unbind(a,c);return this},liveCycle:function(){var a,b,d;a=arguments[0];b=2<=arguments.length?w.call(arguments,1):[];d=0;return this.live(a,function(a){b[d].call(this,
a);return d=++d%b.length})},click:function(a){a==null&&(a={});this.css("cursor").intersect(["auto",""]).len()>0&&this.css("cursor","pointer");return Object.IsFunc(a)?this.bind("click",a):this.trigger("click",a)},ready:function(a){a==null&&(a={});return Object.IsFunc(a)?b?a.call(this):this.bind("ready",a):this.trigger("ready",a)}};["mousemove","mousedown","mouseup","mouseover","mouseout","blur","focus","load","unload","reset","submit","keyup","keydown","change","abort","cut","copy","paste","selection",
"drag","drop","orientationchange","touchstart","touchmove","touchend","touchcancel","gesturestart","gestureend","gesturecancel","hashchange"].forEach(function(b){return i[b]=a(b)});return i});g.plugin(function(){var a,d,b,e,i,c,h;d={slow:700,medium:500,normal:300,fast:100,instant:0,now:0};a=/(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/;b=document.createElement("div").style;"WebkitTransform"in b?(e="-webkit-transform",c="-webkit-transition-property",i="-webkit-transition-duration",
h="-webkit-transition-timing-function"):"MozTransform"in b?(e="-moz-transform",c="-moz-transition-property",i="-moz-transition-duration",h="-moz-transition-timing-function"):"OTransform"in b&&(e="-o-transform",c="-o-transition-property",i="-o-transition-duration",h="-o-transition-timing-function");delete b;return{name:"Transform",$duration:function(a){var b;b=d[a];if(b!=null)return b;return parseFloat(a)},transform:function(b,d,j,u){var B,n,m,s,l,o;Object.IsFunc(d)?(u=d,j=d=null):Object.IsFunc(j)&&
(u=j,j=null);d==null&&(d="normal");j||(j="ease");B=g.duration(d)+"ms";l=[];s=0;o="";d={};for(n in b)a.test(n)?(m=b[n],m.join?m=g(m).px().join(", "):m.toString&&(m=m.toString()),o+=" "+n+"("+m+")"):d[n]=b[n];for(n in d)l[s++]=n;o&&(l[s++]=e);d[c]=l.join(", ");d[i]=l.map(function(){return B}).join(", ");d[h]=l.map(function(){return j}).join(", ");o&&(d[e]=o);this.css(d);return this.delay(B,u)},hide:function(a){return this.each(function(){if(this.style){this._display="";if(this.style.display===!1)this._display=
this.syle.display;return this.style.display="none"}}).trigger("hide").delay(50,a)},show:function(a){return this.each(function(){if(this.style)return this.style.display=this._display,delete this._display}).trigger("show").delay(50,a)},toggle:function(a){return this.weave(this.css("display")).fold(function(a,b){a==="none"?(b.style.display=b._display||"",delete b._display,g(b).trigger("show")):(b._display=a,b.style.display="none",g(b).trigger("hide"));return b}).delay(50,a)},fadeIn:function(a,b){return this.css("opacity",
"0.0").show(function(){return this.transform({opacity:"1.0",translate3d:[0,0,0]},a,b)})},fadeOut:function(a,b,d,c){d==null&&(d=0);c==null&&(c=0);return this.transform({opacity:"0.0",translate3d:[d,c,0]},a,function(){return this.hide(b)})},fadeLeft:function(a,b){return this.fadeOut(a,b,"-"+this.width().first(),0)},fadeRight:function(a,b){return this.fadeOut(a,b,this.width().first(),0)},fadeUp:function(a,b){return this.fadeOut(a,b,0,"-"+this.height().first())},fadeDown:function(a,b){return this.fadeOut(a,
b,0,this.height().first())}}});g.plugin(function(){var a;a=function(a){var b,e,g;g=[];e=0;a=JSON.parse(JSON.stringify(a));for(b in a)g[e++]=""+b+"="+escape(a[b]);return g.join("&")};return{name:"Http",$http:function(d,b){var e;b==null&&(b={});e=new XMLHttpRequest;Object.IsFunc(b)&&(b={success:Function.Bound(b,e)});b=Object.Extend({method:"GET",data:null,state:Function.Empty,success:Function.Empty,error:Function.Empty,async:!0,timeout:0,withCredentials:!1,followRedirects:!1,asBlob:!1},b);b.state=Function.Bound(b.state,
e);b.success=Function.Bound(b.success,e);b.error=Function.Bound(b.error,e);if(b.data&&b.method==="GET")d+="?"+a(b.data);else if(b.data&&b.method==="POST")b.data=a(b.data);e.open(b.method,d,b.async);e.withCredentials=b.withCredentials;e.asBlob=b.asBlob;e.timeout=b.timeout;e.followRedirects=b.followRedirects;e.onreadystatechange=function(){b.state&&b.state();if(e.readyState===4)return e.status===200?b.success(e.responseText):b.error(e.status,e.statusText)};e.send(b.data);return g([e])},$post:function(a,
b){b==null&&(b={});Object.IsFunc(b)&&(b={success:b});b.method="POST";return g.http(a,b)},$get:function(a,b){b==null&&(b={});Object.IsFunc(b)&&(b={success:b});b.method="GET";return g.http(a,b)}}});g.plugin(function(){var a,d,b,e,i,c;b=function(a,b,d,c,e){var g,i;g=1;if(e===null||e===-1)e=a.length;for(i=c;c<=e?i<e:i>e;c<=e?i+=1:i-=1)if(a[i]===d?g+=1:a[i]===b&&(g-=1),g===0)return i;return-1};c=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;a=/%[\(\/]/;d=function(d){var f,e,j,g,i,n,m;d=
d.split(a);i=d.length;m=[d[0]];for(e=j=1;1<=i?e<i:e>i;1<=i?e+=1:e-=1){f=b(d[e],")","(",0,-1);if(f===-1)return"Template syntax error: unmatched '%(' starting at: "+d[e].substring(0,15);g=d[e].substring(0,f);n=d[e].substring(f);f=c.exec(n);if(f===null)return"Template syntax error: invalid type specifier starting at '"+n+"'";n=f[4];m[j++]=g;m[j++]=f[1]|0;m[j++]=f[2]|0;m[j++]=f[3];m[j++]=n}return m};d.cache={};e=function(a,b){var c,e,g,i,n,m,s,l,o,p,t;c=d.cache[a];c==null&&(c=d.cache[a]=d(a));m=[c[0]];
i=1;e=c.length;g=1;for(t=e-4;1<=t?g<t:g>t;g+=5){n=c[g];s=c[g+1];e=c[g+2];o=c[g+3];l=c[g+4];p=b[n];p==null&&(p="missing value: "+n);switch(o){case "d":m[i++]=""+parseInt(p,10);break;case "f":m[i++]=parseFloat(p).toFixed(e);break;case "s":m[i++]=""+p;break;default:m[i++]=""+p}s>0&&(m[i]=String.PadLeft(m[i],s));m[i++]=l}return m.join("")};i=function(a){var b,d,c,e,i,n,m,s,l,o,p,t,q,r;o=null;q=r=b=e=s=t="";d={};l=1;p=g([]);m=0;p.selector=a;p.context=document;n=function(){var a;a=g.HTML.parse(q);o?o.appendChild(a):
p.push(a);q="";return l=1};for(i=function(){var a,c;c=document.createElement(t);c.id=s||null;c.className=e||null;for(a in d)c.setAttribute(a,d[a]);o?o.appendChild(c):p.push(c);o=c;q=r=b=e=s=t="";d={};return l=1};c=a[m++];)if(c==="+"&&l===1){if(o)o=o.parentNode}else if(c==="#"&&(l===1||l===3||l===4))l=2;else if(c==="."&&(l===1||l===2||l===4))e.length>0&&(e+=" "),l=3;else if(c==="."&&e.length>0)e+=" ";else if(c==="["&&(l===1||l===2||l===3||l===4))l=4;else if(c==="="&&l===4)l=5;else if(c==='"'&&l===
1)l=6;else if(c==="'"&&l===1)l=7;else if(c==="]"&&(l===4||l===5))d[b]=r,r=b="",l=1;else if(c==='"'&&l===6)n();else if(c==="'"&&l===7)n();else if((c===" "||c===",")&&l!==5&&l!==4&&t.length>0)i(),c===","&&(o=null);else if(l===1)c!==" "&&(t+=c);else if(l===2)s+=c;else if(l===3)e+=c;else if(l===4)b+=c;else if(l===5)r+=c;else if(l===6||l===7)q+=c;else throw Error("Unknown input/state: '"+c+"'/"+l);t.length>0&&i();q.length>0&&n();return p};return{name:"Template",$render:e,$synth:i,template:function(a){this.render=
function(b){return e(this.map(g.HTML.stringify).join(""),Object.Extend(a,b))};return this.remove()},render:function(a){return e(this.map(g.HTML.stringify).join(""),a)},synth:function(a){return i(a).appendTo(this)}}})}).call(this);
