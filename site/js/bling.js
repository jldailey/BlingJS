(function(){var m,x,y,G,E,z,H,F,I,B,C,u=Array.prototype.slice,K=Object.prototype.hasOwnProperty,L=function(d,j){function h(){this.constructor=d}for(var b in j)if(K.call(j,b))d[b]=j[b];h.prototype=j.prototype;d.prototype=new h;d.__super__=j.prototype;return d},J=function(d,j){return function(){return d.apply(j,arguments)}};if(false in document)alert("This browser is not supported");else{B=console&&console.log?function(){var d;d=1<=arguments.length?u.call(arguments,0):[];return console.log.apply(console,
d)}:function(){var d;d=1<=arguments.length?u.call(arguments,0):[];return alert(d.join(", "))};y=Math.min;x=Math.max;G=Math.sqrt;E=Object.prototype.toString;z=/, */;H=/^\s+/;F=/\[object (\w+)\]/;m=function(d,j){var h;if(j==null)j=document;h=Object.Type(d);if(h==="node"||h==="window"||h==="function")h=[d];else if(h==="number")h=Array(d);else if(h==="string"){d=d.trimLeft();if(d[0]==="<")h=[m.HTML.parse(d)];else if(j.querySelectorAll)h=j.querySelectorAll(d);else throw Error("invalid context: "+j+" (type: "+
Object.Type(j)+")");}else if(h==="array"||h==="bling"||h==="nodelist")h=d;else if(h==="undefined"||h==="null")h=[];else throw Error("invalid selector: "+d+" (type: "+Object.Type(d)+")");h.constructor=m;h.__proto__=m.fn;h.selector=d;h.context=j;return h};C=null;m.__defineSetter__("symbol",function(d){C in window&&delete window[C];C=d;return window[d]=m});m.__defineGetter__("symbol",function(){return C});m.symbol="$";window.Bling=m;m.plugins=[];m.fn=[];Object.Keys=function(d,j){var h,b,g;if(j==null)j=
false;g=[];b=0;for(h in d)if(j||d.hasOwnProperty(h))g[b++]=h;return g};Object.Extend=function(d,j,h){var b,g,a;if(E.apply(h)==="[object Array]")for(b in h){if(j[h[b]]!==void 0)d[h[b]]=j[h[b]]}else{a=Object.Keys(j);h=0;for(g=a.length;h<g;h++){b=a[h];d[b]=j[b]}}return d};Object.Extend(Object,{Type:function(d){switch(true){case d===void 0:return"undefined";case d===null:return"null";case Object.IsString(d):return"string";case Object.IsType(d,m):return"bling";case Object.IsType(d,NodeList):return"nodelist";
case Object.IsArray(d):return"array";case Object.IsNumber(d):return"number";case Object.IsFragment(d):return"fragment";case Object.IsNode(d):return"node";case Object.IsFunc(d):return"function";case Object.IsType(d,"RegExp"):return"regexp";case Object.IsObject(d):return"setInterval"in d?"window":"object"}},IsType:function(d,j){return d===null?d===j:d.constructor===j?true:typeof j==="string"?d.constructor.name===j||E.apply(d).replace(F,"$1")===j:Object.IsType(d.__proto__,j)},IsString:function(d){return d!=
null&&(typeof d==="string"||Object.IsType(d,String))},IsNumber:function(d){return d!=null&&Object.IsType(d,Number)},IsFunc:function(d){return d!=null&&(typeof d==="function"||Object.IsType(d,Function))&&d.call!=null},IsNode:function(d){return d!=null&&d.nodeType>0},IsFragment:function(d){return d!=null&&d.nodeType===11},IsArray:function(d){return d!=null&&(Object.ToString(d)==="[object Array]"||Object.IsType(d,Array))},IsBling:function(d){return d!=null&&Object.IsType(d,m)},IsObject:function(d){return d!=
null&&typeof d==="object"},IsDefined:function(d){return d!=null},Unbox:function(d){if(d!=null&&Object.IsObject(d)){if(Object.IsString(d))return d.toString();if(Object.IsNumber(d))return Number(d)}return d},ToString:function(d){return E.apply(d)}});Object.Extend(Function,{Empty:function(){},Bound:function(d,j,h){var b;if(h==null)h=[];if("bind"in d){h.splice(0,0,j);b=d.bind.apply(d,h)}else b=function(){1<=arguments.length&&u.call(arguments,0);return d.apply(j,h)};b.toString=function(){return"bound-method of "+
j+"."+d.name};return b},Trace:function(d,j,h){var b;if(h==null)h=B;b=function(){var g;g=1<=arguments.length?u.call(arguments,0):[];h(""+(j||"")+(this.name||this)+"."+d.name+"(",g,")");return d.apply(this,g)};h("Function.Trace: "+(j||d.name)+" created.");b.toString=d.toString;return b},NotNull:function(d){return d!==null},IndexFound:function(d){return d>-1},ReduceAnd:function(d){return d&&this},UpperLimit:function(d){return function(j){return y(d,j)}},LowerLimit:function(d){return function(j){return x(d,
j)}},Px:function(d){return function(){return Number.Px(this,d)}}});Object.Extend(Array,{Coalesce:function(){var d,j,h,b;d=1<=arguments.length?u.call(arguments,0):[];if(Object.IsArray(d[0]))return Array.Coalesce.apply(Array,d[0]);else{h=0;for(b=d.length;h<b;h++){j=d[h];if(j!=null)return j}}},Extend:function(d,j){var h,b,g,a;b=d.length;g=0;for(a=j.length;g<a;g++){h=j[g];d[b++]=h}return d}});Object.Extend(Number,{Px:function(d,j){if(j==null)j=0;return d!=null&&parseInt(d,10)+(j|0)+"px"},AtLeast:function(d){return function(j){return x(parseFloat(j||
0),d)}},AtMost:function(d){return function(j){return y(parseFloat(j||0),d)}}});Object.Extend(String,{PadLeft:function(d,j,h){if(h==null)h=" ";for(;d.length<j;)d=h+d;return d},PadRight:function(d,j,h){if(h==null)h=" ";for(;d.length<j;)d+=h;return d},Splice:function(d,j,h,b){var g;g=d.length;h=h;if(h<0)h+=g;j=j;if(j<0)j+=g;return d.substring(0,j)+b+d.substring(h)},Checksum:function(d){var j,h,b;j=h=0;for(b=d.length;0<=b?j<b:j>b;0<=b?j+=1:j-=1)h+=d.charCodeAt(j);return h}});Object.Extend(Event,{Cancel:function(d){d.stopPropagation();
d.preventDefault();d.cancelBubble=true;return d.returnValue=false},Prevent:function(d){return d.preventDefault()},Stop:function(d){d.stopPropagation();return d.cancelBubble=true}});String.prototype.trimLeft=Array.Coalesce(String.prototype.trimLeft,function(){return this.replace(H,"")});String.prototype.split=Array.Coalesce(String.prototype.split,function(d){var j,h,b,g;j=[];for(h=g=0;(b=this.indexOf(d,h))>-1;){j[g++]=this.substring(h+1,b+1);h=b+1}return j});Array.prototype.join=Array.Coalesce(Array.prototype.join,
function(d){var j,h;j=this.length;if(j===0)return"";for(h=this[j-1];--j>0;)h=this[j-1]+d+h;return h});Element.prototype.matchesSelector=Array.Coalesce(Element.prototype.webkitMatchesSelector,Element.prototype.mozMatchesSelector,Element.prototype.matchesSelector);Element.prototype.toString=function(){var d;d=this.nodeName.toLowerCase();if(this.id!=null)d+="#"+this.id;else if(this.className!=null)d+="."+this.className.split(" ").join(".");return d};if(Element.prototype.cloneNode.length===0){I=Element.prototype.cloneNode;
Element.prototype.cloneNode=function(d){var j,h,b,g;if(d==null)d=false;j=I.call(this);if(d){g=this.childNodes;h=0;for(b=g.length;h<b;h++){d=g[h];j.appendChild(d.cloneNode(true))}}return j}}m.plugin=function(d){var j,h,b,g,a;h=d.call(m,m);j=function(f,c){return f[0]===m.symbol?m[f.substr(1)]=c:m.fn[f]=c};a=Object.Keys(h,true);b=0;for(g=a.length;b<g;b++){d=a[b];d!=="name"&&j(d,h[d])}m.plugins.push(h.name);return m.plugins[h.name]=h};m.plugin(function(){var d,j,h;d=new (function(){function b(){this.next=
J(function(){if(this.length>0)return this.shift()()},this);this.schedule=J(function(g,a){var f,c;if(!Object.IsFunc(g))throw Error("function expected, got: "+typeof g);c=this.length;g.order=a+(new Date).getTime();if(c===0||g.order>this[c-1].order)this[c]=g;else for(f=0;0<=c?f<c:f>c;0<=c?f+=1:f-=1)if(this[f].order>g.order){this.splice(f,0,g);break}return setTimeout(this.next,a)},this)}L(b,Array);return b}());j=function(b){return function(){var g;g=this[b];if(Object.IsFunc(g))return Function.Bound(g,
this);return g}};h=function(b){var g;g=b.indexOf(".");if(g>-1)return this.zip(b.substr(0,g)).zip(b.substr(g+1));return this.map(j(b))};return{name:"Core",querySelectorAll:function(b){return this.filter("*").reduce(function(g,a){return Array.Extend(g,a.querySelectorAll(b))},[])},eq:function(b){return m([this[b]])},each:function(b){var g,a,f;a=0;for(f=this.length;a<f;a++){g=this[a];b.call(g,g)}return this},map:function(b){var g,a,f,c;g=m();g.context=this;g.selector=["map",b];f=this.len();for(a=0;0<=
f?a<f:a>f;0<=f?a+=1:a-=1){c=this[a];try{g[a]=b.call(c,c)}catch(e){g[a]=e}}return g},reduce:function(b,g){var a,f;a=g;f=this;if(g==null){a=this[0];f=this.skip(1)}f.each(function(){return a=b.call(this,a,this)});return a},union:function(b,g){var a,f,c,e;c=m();a=f=0;c.context=[this,b];for(c.selector="union";e=this[f++];)c.contains(e,g)||(c[a++]=e);for(f=0;e=b[f++];)c.contains(e,g)||(c[a++]=e);return c},intersect:function(b){var g,a,f,c,e,i;i=m();f=0;c=this.len();e=Object.IsFunc(b.len)?b.len():b.length;
i.context=[this,b];i.selector="intersect";for(g=0;0<=c?g<c:g>c;0<=c?g+=1:g-=1)for(a=0;0<=e?a<e:a>e;0<=e?a+=1:a-=1)if(this[g]===b[a]){i[f++]=this[g];break}return i},distinct:function(b){return this.union(this,b)},contains:function(b,g){return this.count(b,g)>0},count:function(b,g){var a;if(b===void 0)return this.len();a=0;this.each(function(f){if(g&&f===b||!g&&f===b)return a++});return a},zip:function(){var b,g,a,f,c,e,i,k;b=1<=arguments.length?u.call(arguments,0):[];i=b.length;switch(i){case 0:return m();
case 1:return h.call(this,b[0]);default:e={};k=this.len();g=m();for(a=f=0;0<=i?a<i:a>i;0<=i?a+=1:a-=1)e[b[a]]=h.call(this,b[a]);for(a=0;0<=k?a<k:a>k;0<=k?a+=1:a-=1){b={};for(c in e)b[c]=e[c].shift();g[f++]=b}return g}},zap:function(b,g){var a;a=b.indexOf(".");return a>-1?this.zip(b.substr(0,a)).zap(b.substr(a+1),g):Object.IsArray(g)?this.each(function(){return this[b]=g[++a]}):this.each(function(){return this[b]=g})},take:function(b){var g,a;b=y(b|0,this.len());g=m();g.context=this;g.selector=["take",
b];for(a=0;0<=b?a<b:a>b;0<=b?a+=1:a-=1)g[a]=this[a];return g},skip:function(b){var g,a,f;b=y(this.len(),x(0,b|0));f=this.len()-b;g=m();g.context=this.context;g.selector=this.selector;for(a=0;0<=f?a<f:a>f;0<=f?a+=1:a-=1)g[a]=this[a+b];return g},first:function(b){if(b==null)b=1;return b===1?this[0]:this.take(b)},last:function(b){if(b==null)b=1;return b===1?this[this.len()-1]:this.skip(this.len()-b)},slice:function(b,g){var a,f,c;a=m();c=0;f=this.len();g!=null||(g=f);b!=null||(b=0);if(b<0)b+=f;if(g<
0)g+=f;a.context=this;a.selector="slice(#{start},#{end})";for(f=b;b<=g?f<g:f>g;b<=g?f+=1:f-=1)a[c++]=this[f];return a},concat:function(b){var g,a,f;g=this.len()-1;a=-1;for(f=Object.IsFunc(b.len)?b.len():b.length;a<f-1;)this[++g]=b[++a];return this},push:function(b){Array.prototype.push.call(this,b);return this},filter:function(b){var g,a,f,c,e,i;g=m();g.context=this;g.selector=b;c=0;switch(Object.Type(b)){case "string":a=function(k){return k.matchesSelector(b)};break;case "regexp":a=function(k){return b.test(k)};
break;case "function":a=b}e=0;for(i=this.length;e<i;e++){f=this[e];if(a.call(f,f))g[c++]=f}return g},test:function(b){return this.map(function(){return b.test(this)})},matches:function(b){return this.zip("matchesSelector").call(b)},weave:function(b){var g,a,f,c;f=b.len();a=this.len();g=m();g.context=[this,b];g.selector="weave";for(a=c=a-1;c<=0?a<=0:a>=0;c<=0?a+=1:a-=1)g[a*2+1]=this[a];for(a=0;0<=f?a<f:a>f;0<=f?a+=1:a-=1)g[a*2]=b[a];return g},fold:function(b){var g,a,f,c,e;c=this.len();f=0;g=m();g.context=
this;g.selector=["fold",b];a=0;for(e=c-1;0<=e?a<e:a>e;a+=2)g[f++]=b.call(this,this[a],this[a+1]);if(c%2===1)g[f++]=b.call(this,this[c-1],void 0);return g},flatten:function(){var b,g,a,f,c,e,i;b=m();i=this.len();e=0;b.context=this;b.selector="flatten";for(f=0;0<=i?f<i:f>i;0<=i?f+=1:f-=1){g=this[f];a=Object.IsFunc(g.len)?g.len():g.length;for(c=0;0<=a?c<a:c>a;0<=a?c+=1:c-=1)b[e++]=g[c]}return b},call:function(){return this.apply(null,arguments)},apply:function(b,g){return this.map(function(){return Object.IsFunc(this)?
this.apply(b,g):this})},toString:function(){return m.symbol+"(["+this.map(function(){switch(this){case void 0:return"undefined";case null:return"null";case window:return"window";default:return this.toString().replace(F,"$1")}}).join(", ")+"])"},delay:function(b,g){g&&d.schedule(Function.Bound(g,this),b);return this},log:function(b){var g;g=this.len();b?B(b,this,g+" items"):B(this,g+" items");return this},len:function(){var b;for(b=this.length;this[b]!==void 0;)b++;for(;b>-1&&this[b]===void 0;)b--;
return b+1}}});m.plugin(function(){var d,j,h,b,g;j=function(a,f){return a.parentNode.insertBefore(f,a)};d=function(a,f){return a.parentNode.insertBefore(f,a.nextSibling)};g=function(a){switch(Object.Type(a)){case "fragment":return a;case "node":return a;case "bling":return a.toFragment();case "string":return m(a).toFragment();case "function":return m(a.toString()).toFragment();default:throw Error("toNode called with invalid argument: "+a+" (type: "+Object.Type(a)+")");}};h=null;b=function(a){return function(){return window.getComputedStyle(this,
null).getPropertyValue(a)}};return{name:"Html",$HTML:{parse:function(a){var f,c,e,i;i=document.createElement("div");i.innerHTML=a;a=i.childNodes;e=a.length;if(e===1)return i.removeChild(a[0]);f=document.createDocumentFragment();for(c=0;0<=e?c<e:c>e;0<=e?c+=1:c-=1)f.appendChild(i.removeChild(a[0]));return f},stringify:function(a){var f,c;switch(Object.Type(a)){case "string":return a;case "node":a=a.cloneNode(true);f=document.createElement("div");f.appendChild(a);c=f.innerHTML;f.removeChild(a);delete a;
return c}},escape:function(a){h||(h=m("<div>&nbsp;</div>").child(0));a=h.zap("data",a).zip("parentNode.innerHTML").first();h.zap("data","");return a}},html:function(a){switch(Object.Type(a)){case "undefined":return this.zip("innerHTML");case "string":return this.zap("innerHTML",a);case "bling":return this.html(a.toFragment());case "node":return this.each(function(){var f;this.replaceChild(this.childNodes[0],a);for(f=[];this.childNodes.length>1;)f.push(this.removeChild(this.childNodes[1]));return f})}},
append:function(a){var f;a=g(a);f=this.zip("appendChild");f.take(1).call(a);f.skip(1).each(function(c){return c(a.cloneNode(true))});return this},appendTo:function(a){m(a).append(this);return this},prepend:function(a){if(a!=null){a=g(a);this.take(1).each(function(){return j(this.childNodes[0],a)});this.skip(1).each(function(){return j(this.childNodes[0],a.cloneNode(true))})}return this},prependTo:function(a){a!=null&&m(a).prepend(this);return this},before:function(a){if(a!=null){a=g(a);this.take(1).each(function(){return j(this,
a)});this.skip(1).each(function(){return j(this,a.cloneNode(true))})}return this},after:function(a){if(a!=null){a=g(a);this.take(1).each(function(){return d(this,a)});this.skip(1).each(function(){return d(this,a.cloneNode(true))})}return this},wrap:function(a){a=g(a);if(Object.IsFragment(a))throw Error("cannot wrap with a fragment");return this.map(function(f){var c,e;if(Object.IsFragment(f))a.appendChild(f);else if(Object.IsNode(f))if(e=f.parentNode){c=document.createElement("dummy");a.appendChild(e.replaceChild(c,
f));e.replaceChild(a,c)}else a.appendChild(f);return f})},unwrap:function(){return this.each(function(){if(this.parentNode&&this.parentNode.parentNode)return this.parentNode.parentNode.replaceChild(this,this.parentNode)})},replace:function(a){var f,c;a=g(a);f=m();c=0;this.take(1).each(function(){if(this.parentNode){this.parentNode.replaceChild(a,this);return f[c++]=a}});this.skip(1).each(function(){var e;if(this.parentNode){e=a.cloneNode(true);this.parentNode.replaceChild(e,this);return f[c++]=e}});
return f},attr:function(a,f){switch(f){case void 0:return this.zip("getAttribute").call(a,f);case null:return this.zip("removeAttribute").call(a,f);default:this.zip("setAttribute").call(a,f);return this}},addClass:function(a){return this.removeClass(a).each(function(){var f;f=this.className.split(" ").filter(function(c){return c!==""});f.push(a);return this.className=f.join(" ")})},removeClass:function(a){var f;f=function(c){return c!==a};return this.each(function(){return this.className=this.className.split(" ").filter(f).join(" ")})},
toggleClass:function(a){var f;f=function(c){return c!==a};return this.each(function(){var c;c=this.className.split(" ");if(c.indexOf(a)>-1)return this.className=c.filter(f).join(" ");else{c.push(a);return this.className=c.join(" ")}})},hasClass:function(a){return this.zip("className.split").call(" ").zip("indexOf").call(a).map(Function.IndexFound)},text:function(a){if(a!=null)return this.zap("textContent",a);return this.zip("textContent")},val:function(a){if(a!=null)return this.zap("value",a);return this.zip("value")},
css:function(a,f){var c,e,i,k;if(f!=null||Object.IsObject(a)){k=this.zip("style.setProperty");i=k.len();if(Object.IsObject(a))for(c in a)k.call(c,a[c],"");else if(Object.IsString(f))k.call(a,f,"");else if(Object.IsArray(f)){e=x(f.length,i);for(c=0;0<=e?c<e:c>e;0<=e?c+=1:c-=1)k[c%i](a,f[c%e],"")}return this}else{c=this.map(b(a));e=this.zip("style").zip(a);return e.weave(c).fold(function(n,l){return n||l})}},defaultCss:function(a,f){var c,e,i;e=this.selector;i="";if(Object.IsString(a))if(Object.IsString(f))i+=
""+e+" { "+a+": "+f+" } ";else throw Error("defaultCss requires a value with a string key");else if(Object.IsObject(a)){i+=""+e+" { ";for(c in a)i+=""+c+": "+a[c]+"; ";i+="} "}m.synth("style").text(i).appendTo("head");return this},empty:function(){return this.html("")},rect:function(){return this.zip("getBoundingClientRect").call()},width:function(a){if(a===null)return this.rect().zip("width");return this.css("width",a)},height:function(a){if(a===null)return this.rect().zip("height");return this.css("height",
a)},top:function(a){if(a===null)return this.rect().zip("top");return this.css("top",a)},left:function(a){if(a===null)return this.rect().zip("left");return this.css("left",a)},bottom:function(a){if(a===null)return this.rect().zip("bottom");return this.css("bottom",a)},right:function(a){if(a===null)return this.rect().zip("right");return this.css("right",a)},position:function(a,f){if(a===null)return this.rect();if(f===null)return this.css("left",Number.Px(a));return this.css({top:Number.Px(f),left:Number.Px(a)})},
center:function(a){var f,c,e;if(a==null)a="viewport";f=document.body;c=f.scrollTop+f.clientHeight/2;e=f.scrollLeft+f.clientWidth/2;return this.each(function(){var i,k,n;k=m(this);i=k.height().floats().first();n=k.width().floats().first();n=a==="viewport"||a==="horizontal"?e-n/2:NaN;i=a==="viewport"||a==="vertical"?c-i/2:NaN;return k.css({position:"absolute",left:Number.Px(n),top:Number.Px(i)})})},scrollToCenter:function(){document.body.scrollTop=this.zip("offsetTop")[0]-window.innerHeight/2;return this},
child:function(a){return this.zip("childNodes").map(function(){var f;f=a;if(f<0)f+=this.length;return this[f]})},children:function(){return this.map(function(){return m(this.childNodes,this)})},parent:function(){return this.zip("parentNode")},parents:function(){return this.map(function(){var a,f,c;a=m();f=0;for(c=this;c=c.parentNode;)a[f++]=c;return a})},prev:function(){return this.map(function(){var a,f,c;a=m();f=0;for(c=this;c=c.previousSibling;)a[f++]=c;return a})},next:function(){return this.map(function(){var a,
f,c;a=m();f=0;for(c=this;c=c.nextSibling;)a[f++]=c;return a})},remove:function(){return this.each(function(){if(this.parentNode)return this.parentNode.removeChild(this)})},find:function(a){return this.filter("*").map(function(){return m(a,this)}).flatten()},clone:function(a){if(a==null)a=true;return this.map(function(){return Object.IsNode(this)?this.cloneNode(a):null})},toFragment:function(){var a,f;if(this.len()>1){f=document.createDocumentFragment();a=Function.Bound(f.appendChild,f);this.map(g).map(a);
return f}return g(this[0])}}});m.plugin(function(){return{name:"Maths",floats:function(){return this.map(parseFloat)},ints:function(){return this.map(function(){return parseInt(this,10)})},px:function(d){if(d==null)d=0;return this.ints().map(Function.Px(d))},min:function(){return this.reduce(function(d){return y(this,d)})},max:function(){return this.reduce(function(d){return x(this,d)})},average:function(){return this.sum()/this.len()},sum:function(){return this.reduce(function(d){return d+this})},
squares:function(){return this.map(function(){return this*this})},magnitude:function(){return G(this.floats().squares().sum())},scale:function(d){return this.map(function(){return d*this})},normalize:function(){return this.scale(1/this.magnitude())}}});m.plugin(function(){var d,j,h,b,g,a,f;d=function(c){return function(e){if(e==null)e={};if(Object.IsFunc(e))return this.bind(c,e);return this.trigger(c,e)}};b=function(c,e,i,k,n){return m(e).bind(i,n).each(function(){var l;l=this.__alive__||(this.__alive__=
{});l=l[c]||(l[c]={});return(l[i]||(l[i]={}))[k]=n})};f=function(c,e,i,k){var n;n=m(e);return n.each(function(){var l;l=this.__alive__||(this.__alive__={});l=l[c]||(l[c]={});l=l[i]||(l[i]={});n.unbind(i,l[k]);return delete l[k]})};j=h=0;a=function(){if(!h++){m(document).trigger("ready").unbind("ready");typeof document.removeEventListener=="function"&&document.removeEventListener("DOMContentLoaded",a,false);return typeof window.removeEventListener=="function"?window.removeEventListener("load",a,false):
void 0}};if(!j++){typeof document.addEventListener=="function"&&document.addEventListener("DOMContentLoaded",a,false);typeof window.addEventListener=="function"&&window.addEventListener("load",a,false)}g={name:"Events",bind:function(c,e){var i,k;i=(c||"").split(z);k=function(n){var l;l=e.apply(this,arguments);l===false&&Event.Prevent(n);return l};return this.each(function(){var n,l,p,q;q=[];l=0;for(p=i.length;l<p;l++){n=i[l];q.push(this.addEventListener(n,k,false))}return q})},unbind:function(c,e){var i;
i=(c||"").split(z);return this.each(function(){var k,n,l,p;p=[];n=0;for(l=i.length;n<l;n++){k=i[n];p.push(this.removeEventListener(k,e,null))}return p})},once:function(c,e){var i,k,n,l,p;i=(c||"").split(z);p=[];n=0;for(l=i.length;n<l;n++){k=i[n];p.push(this.bind(k,function(q){e.call(this,q);return this.removeEventListener(q.type,arguments.callee,null)}))}return p},cycle:function(){var c,e,i,k,n,l,p;c=arguments[0];i=2<=arguments.length?u.call(arguments,1):[];c=(c||"").split(z);n=i.length;e=function(){var q;
q=0;return function(o){i[q].call(this,o);return q=++q%n}};l=0;for(p=c.length;l<p;l++){k=c[l];this.bind(k,e())}return this},trigger:function(c,e){var i,k,n,l,p;if(e==null)e={};n=(c||"").split(z);e=Object.Extend({bubbles:true,cancelable:true},e);l=0;for(p=n.length;l<p;l++){k=n[l];if(k==="click"||k==="mousemove"||k==="mousedown"||k==="mouseup"||k==="mouseover"||k==="mouseout"){i=document.createEvent("MouseEvents");e=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,
shiftKey:false,metaKey:false,button:0,relatedTarget:null},e);i.initMouseEvent(k,e.bubbles,e.cancelable,window,e.detail,e.screenX,e.screenY,e.clientX,e.clientY,e.ctrlKey,e.altKey,e.shiftKey,e.metaKey,e.button,e.relatedTarget)}else if(k==="blur"||k==="focus"||k==="reset"||k==="submit"||k==="abort"||k==="change"||k==="load"||k==="unload"){i=document.createEvent("UIEvents");i.initUIEvent(k,e.bubbles,e.cancelable,window,1)}else if(k==="touchstart"||k==="touchmove"||k==="touchend"||k==="touchcancel"){i=
document.createEvent("TouchEvents");e=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},e);i.initTouchEvent(k,e.bubbles,e.cancelable,window,e.detail,e.screenX,e.screenY,e.clientX,e.clientY,e.ctrlKey,e.altKey,e.shiftKey,e.metaKey,e.touches,e.targetTouches,e.changedTouches,e.scale,e.rotation)}else if(k==="gesturestart"||k==="gestureend"||k==="gesturecancel"){i=document.createEvent("GestureEvents");
e=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,target:null,scale:1,rotation:0},e);i.initGestureEvent(k,e.bubbles,e.cancelable,window,e.detail,e.screenX,e.screenY,e.clientX,e.clientY,e.ctrlKey,e.altKey,e.shiftKey,e.metaKey,e.target,e.scale,e.rotation)}else{i=document.createEvent("Events");i.initEvent(k,e.bubbles,e.cancelable);try{i=Object.Extend(i,e)}catch(q){}}if(i)try{this.each(function(){return this.dispatchEvent(i)})}catch(o){B("dispatchEvent error:",
o)}}return this},live:function(c,e){var i,k,n;k=this.selector;i=this.context;n=function(l){return m(k,i).intersect(m(l.target).parents().first().union(m(l.target))).each(function(){l.target=this;return e.call(this,l)})};m(i).bind(c,n);b(k,i,c,e,n);return this},die:function(c,e){var i,k;k=this.selector;i=this.context;k=f(k,i,c,e);m(i).unbind(c,k);return this},liveCycle:function(){var c,e,i;c=arguments[0];e=2<=arguments.length?u.call(arguments,1):[];i=0;return this.live(c,function(k){e[i].call(this,
k);return i=++i%e.length})},click:function(c){if(c==null)c={};this.css("cursor").intersect(["auto",""]).len()>0&&this.css("cursor","pointer");return Object.IsFunc(c)?this.bind("click",c):this.trigger("click",c)},ready:function(c){if(c==null)c={};return Object.IsFunc(c)?h?c.call(this):this.bind("ready",c):this.trigger("ready",c)}};["mousemove","mousedown","mouseup","mouseover","mouseout","blur","focus","load","unload","reset","submit","keyup","keydown","change","abort","cut","copy","paste","selection",
"drag","drop","orientationchange","touchstart","touchmove","touchend","touchcancel","gesturestart","gestureend","gesturecancel","hashchange"].forEach(function(c){return g[c]=d(c)});return g});m.plugin(function(){var d,j,h,b,g,a,f;j={slow:700,medium:500,normal:300,fast:100,instant:0,now:0};d=/(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/;h=document.createElement("div").style;if("WebkitTransform"in h){b="-webkit-transform";a="-webkit-transition-property";g="-webkit-transition-duration";
f="-webkit-transition-timing-function"}else if("MozTransform"in h){b="-moz-transform";a="-moz-transition-property";g="-moz-transition-duration";f="-moz-transition-timing-function"}else if("OTransform"in h){b="-o-transform";a="-o-transition-property";g="-o-transition-duration";f="-o-transition-timing-function"}delete h;return{name:"Transform",$duration:function(c){var e;e=j[c];if(e!=null)return e;return parseFloat(c)},transform:function(c,e,i,k){var n,l,p,q,o,r;if(Object.IsFunc(e)){k=e;i=e=null}else if(Object.IsFunc(i)){k=
i;i=null}if(e==null)e="normal";i||(i="ease");n=m.duration(e)+"ms";o=[];q=0;r="";e={};for(l in c)if(d.test(l)){p=c[l];if(p.join)p=m(p).px().join(", ");else if(p.toString)p=p.toString();r+=" "+l+"("+p+")"}else e[l]=c[l];for(l in e)o[q++]=l;if(r)o[q++]=b;e[a]=o.join(", ");e[g]=o.map(function(){return n}).join(", ");e[f]=o.map(function(){return i}).join(", ");if(r)e[b]=r;this.css(e);return this.delay(n,k)},hide:function(c){return this.each(function(){if(this.style){this._display="";if(this.style.display===
false)this._display=this.syle.display;return this.style.display="none"}}).trigger("hide").delay(50,c)},show:function(c){return this.each(function(){if(this.style){this.style.display=this._display;return delete this._display}}).trigger("show").delay(50,c)},toggle:function(c){return this.weave(this.css("display")).fold(function(e,i){if(e==="none"){i.style.display=i._display||"";delete i._display;m(i).trigger("show")}else{i._display=e;i.style.display="none";m(i).trigger("hide")}return i}).delay(50,c)},
fadeIn:function(c,e){return this.css("opacity","0.0").show(function(){return this.transform({opacity:"1.0",translate3d:[0,0,0]},c,e)})},fadeOut:function(c,e,i,k){if(i==null)i=0;if(k==null)k=0;return this.transform({opacity:"0.0",translate3d:[i,k,0]},c,function(){return this.hide(e)})},fadeLeft:function(c,e){return this.fadeOut(c,e,"-"+this.width().first(),0)},fadeRight:function(c,e){return this.fadeOut(c,e,this.width().first(),0)},fadeUp:function(c,e){return this.fadeOut(c,e,0,"-"+this.height().first())},
fadeDown:function(c,e){return this.fadeOut(c,e,0,this.height().first())}}});m.plugin(function(){var d;d=function(j){var h,b,g;g=[];b=0;j=JSON.parse(JSON.stringify(j));for(h in j)g[b++]=""+h+"="+escape(j[h]);return g.join("&")};return{name:"Http",$http:function(j,h){var b;if(h==null)h={};b=new XMLHttpRequest;if(Object.IsFunc(h))h={success:Function.Bound(h,b)};h=Object.Extend({method:"GET",data:null,state:Function.Empty,success:Function.Empty,error:Function.Empty,async:true,timeout:0,withCredentials:false,
followRedirects:false,asBlob:false},h);h.state=Function.Bound(h.state,b);h.success=Function.Bound(h.success,b);h.error=Function.Bound(h.error,b);if(h.data&&h.method==="GET")j+="?"+d(h.data);else if(h.data&&h.method==="POST")h.data=d(h.data);b.open(h.method,j,h.async);b.withCredentials=h.withCredentials;b.asBlob=h.asBlob;b.timeout=h.timeout;b.followRedirects=h.followRedirects;b.onreadystatechange=function(){h.state&&h.state();if(b.readyState===4)return b.status===200?h.success(b.responseText):h.error(b.status,
b.statusText)};b.send(h.data);return m([b])},$post:function(j,h){if(h==null)h={};if(Object.IsFunc(h))h={success:h};h.method="POST";return m.http(j,h)},$get:function(j,h){if(h==null)h={};if(Object.IsFunc(h))h={success:h};h.method="GET";return m.http(j,h)}}});m.plugin(function(){var d,j,h,b,g,a;h=function(f,c,e,i,k){var n,l;n=1;if(k===null||k===-1)k=f.length;for(l=i;i<=k?l<k:l>k;i<=k?l+=1:l-=1){if(f[l]===e)n+=1;else if(f[l]===c)n-=1;if(n===0)return l}return-1};a=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;
d=/%[\(\/]/;j=function(f){var c,e,i,k,n,l,p;f=f.split(d);n=f.length;p=[f[0]];for(e=i=1;1<=n?e<n:e>n;1<=n?e+=1:e-=1){c=h(f[e],")","(",0,-1);if(c===-1)return"Template syntax error: unmatched '%(' starting at: "+f[e].substring(0,15);k=f[e].substring(0,c);l=f[e].substring(c);c=a.exec(l);if(c===null)return"Template syntax error: invalid type specifier starting at '"+l+"'";l=c[4];p[i++]=k;p[i++]=c[1]|0;p[i++]=c[2]|0;p[i++]=c[3];p[i++]=l}return p};j.cache={};b=function(f,c){var e,i,k,n,l,p,q,o,r,s,t;e=j.cache[f];
if(e==null)e=j.cache[f]=j(f);p=[e[0]];n=1;i=e.length;k=1;for(t=i-4;1<=t?k<t:k>t;k+=5){l=e[k];q=e[k+1];i=e[k+2];r=e[k+3];o=e[k+4];s=c[l];if(s==null)s="missing value: "+l;switch(r){case "d":p[n++]=""+parseInt(s,10);break;case "f":p[n++]=parseFloat(s).toFixed(i);break;case "s":p[n++]=""+s;break;default:p[n++]=""+s}if(q>0)p[n]=String.PadLeft(p[n],q);p[n++]=o}return p.join("")};g=function(f){var c,e,i,k,n,l,p,q,o,r,s,t,A,D;r=null;A=D=c=k=q=t="";e={};o=1;s=m([]);p=0;s.selector=f;l=function(){var v;v=m.HTML.parse(A);
r?r.appendChild(v):s.push(v);A="";return o=1};for(n=function(){var v,w;w=document.createElement(t);w.id=q||null;w.className=k||null;for(v in e)w.setAttribute(v,e[v]);r?r.appendChild(w):s.push(w);r=w;A=D=c=k=q=t="";e={};return o=1};i=f[p++];)if(i==="+"&&o===1){if(r)r=r.parentNode}else if(i==="#"&&(o===1||o===3||o===4))o=2;else if(i==="."&&(o===1||o===2||o===4)){if(k.length>0)k+=" ";o=3}else if(i==="."&&k.length>0)k+=" ";else if(i==="["&&(o===1||o===2||o===3||o===4))o=4;else if(i==="="&&o===4)o=5;else if(i===
'"'&&o===1)o=6;else if(i==="'"&&o===1)o=7;else if(i==="]"&&(o===4||o===5)){e[c]=D;D=c="";o=1}else if(i==='"'&&o===6)l();else if(i==="'"&&o===7)l();else if((i===" "||i===",")&&o!==5&&o!==4&&t.length>0){n();if(i===",")r=null}else if(o===1){if(i!==" ")t+=i}else if(o===2)q+=i;else if(o===3)k+=i;else if(o===4)c+=i;else if(o===5)D+=i;else if(o===6||o===7)A+=i;else throw Error("Unknown input/state: '"+i+"'/"+o);t.length>0&&n();A.length>0&&l();return s};return{name:"Template",$render:b,$synth:g,template:function(f){this.render=
function(c){return b(this.map(m.HTML.stringify).join(""),Object.Extend(f,c))};return this.remove()},render:function(f){return b(this.map(m.HTML.stringify).join(""),f)},synth:function(f){return g(f).appendTo(this)}}})}}).call(this);
(function($) {

	Function.PrettyPrint = (function() {
		// in the closure scope:
		var operators = /!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g,
			operator_html = "<span class='opr'>$&</span>",
			keywords = /\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g,
			keyword_html = "<span class='kwd'>$&</span>",
			all_numbers = /\d+\.*\d*/g,
			number_html = "<span class='num'>$&</span>",
			bling_symbol = /\$(\(|\.)/g,
			bling_html = "<span class='bln'>$$</span>$1",
			tabs = /\t/g,
			tab_html = "&nbsp;&nbsp;",
			singleline_comment = /\/\/.*?(?:\n|$)/,
			multiline_comment = /\/\*(?:.|\n)*?\*\//
		function find_unescaped_quote(s, i, q) {
			var r = s.indexOf(q, i)
			while( s.charAt(r-1) === "\\" && r < s.length && r > 0)
				r = s.indexOf(q, r+1)
			return r
		}
		function find_first_quote(s, i) {
			var a = s.indexOf('"', i),
				b = s.indexOf("'", i)
			if( a === -1 ) a = s.length
			if( b === -1 ) b = s.length
			return a === b ? [null, -1]
				: a < b ? ['"', a]
				: ["'", b]
		}
		function extract_quoted(s) {
			var i = 0, n = s.length, ret = [],
				j = -1, k = -1, q = null
			if( ! Object.IsString(s) )
				if( ! Object.IsFunc(s.toString) )
					throw TypeError("invalid string argument to extract_quoted")
				else {
					s = s.toString()
					n = s.length
				}
			while( i < n ) {
				q = find_first_quote(s, i)
				j = q[1]
				if( j === -1 ) {
					ret.push(s.substring(i))
					break
				}
				ret.push(s.substring(i,j))
				k = find_unescaped_quote(s, j+1, q[0])
				if( k === -1 )
					throw Error("unmatched "+q[0]+" at "+j)
				ret.push(s.substring(j, k+1))
				i = k+1
			}
			return ret
		}
		function first_comment(s) {
			var a = s.match(singleline_comment),
				b = s.match(multiline_comment)
				return a === b ? [-1, null]
					: a == null && b != null ? [b.index, b[0]]
					: a != null && b == null ? [a.index, a[0]]
					: b.index < a.index ? [b.index, b[0]]
					: [a.index, a[0]]
		}
		function extract_comments(s) {
			var ret = [], i = 0, j = 0,
				n = s.length, q = null, ss = null
			while( i < n ) {
				ss = s.substring(i)
				q = first_comment(ss)
				j = q[0]
				if( j > -1 ) {
					ret.push(ss.substring(0,j))
					ret.push(q[1])
					i += j + q[1].length
				} else {
					ret.push(ss)
					break
				}
			}
			return ret
		}
		return function prettyPrint(js, colors) {
			if( Object.IsFunc(js) )
				js = js.toString()
			if( ! Object.IsString(js) )
				throw TypeError("prettyPrint requires a function or string to format, not '"+typeof(js)+"'")
			if( $("style#pp-injected").length === 0 ) {
				var i, css = "code.pp .bln { font-size: 17px; } "
				colors = Object.Extend({
					opr: "#880",
					str: "#008",
					com: "#080",
					kwd: "#088",
					num: "#808",
					bln: "#800"
				}, colors)
				for( i in colors )
					css += "code.pp ."+i+" { color: "+colors[i]+"; }"
				$("head").append($.synth("style#pp-injected").text(css))
			}
			return "<code class='pp'>"+
				// extract comments
				$(extract_comments(js))
					.fold(function(text, comment) {
						// extract quoted strings
						return $(extract_quoted(text))
							.fold(function(code, quoted) {
								// label number constants
								return (code
									// label operator symbols
									.replace(operators, operator_html)
									// label numbers
									.replace(all_numbers, number_html)
									// label keywords
									.replace(keywords, keyword_html)
									// label the bling operator
									.replace(bling_symbol, bling_html)
									// replace tabs with spaces
									.replace(tabs, tab_html)
								) +
								// label string constants
								(quoted ? "<span class='str'>"+quoted+"</span>" : "")
							})
							// collapse the strings
							.join('')
							// append the extracted comment
							+ (comment ? "<span class='com'>"+comment+"</span>" : "")
					})
					.join('')
			+ "</code>"
		}
	})()

	var example_re = /\s*[Ee]xample:\s*/,
		end_line = /\n/g,
		code_line = /(^|\n)\s*\&gt;\s/,
		blank_line = /^\s*$/,
		singleline_comment = /^\/\/ */,
		multiline_comment_open = /^\/\* */,
		multiline_comment_close = /\s*\*\/\s*$/,
		b_word = /\/(\w+)\//g,
		i_word = /_(\w+)_/g

	function getDescription(node) {
		// return a pair of [definition, description] strings
		var desc = node.find(".com").take(1).text().first();
		desc = desc ? desc
			.replace(singleline_comment,'')
			.replace(b_word, "<b>$1</b>")
			.replace(i_word, "<i>$1</i>")
			: "unknown - unknown"
		return desc.split(" - ")
	}
	function getExamples(node) {
		// return a list of [<p>, <pre>, <p>, <pre>, ...]
		var examples = node.find(".com").skip(1).html(),
			result = $([]), codeQueue = [], paraQueue = [],
			i = 0, j = 0, n = examples.length, example = null
			lines = null, line = null

		paraQueue.flush = function() {
			if( this.length > 0 ) {
				result.push($.synth("p").text(this.join("\n")))
				this.length = 0
			}
			return this.length == 0
		}

		codeQueue.flush = function() {
			if( this.length > 0 ) {
				result.push($.synth("pre")
					.html(Function.PrettyPrint(codeQueue.join('\n'))))
				this.length = 0
			}
			return this.length == 0
		}

		while( (example = examples[i++]) != null ) {
			if( example_re.test(example) ) {
				lines = example.split(end_line)
				j = 0
				while( (line = lines[j++]) != null ) {
					if( code_line.test(line) ) {
						codeQueue.push(line.replace(code_line, '$1'))
						paraQueue.flush()
					}
					else if ( ! blank_line.test(line) ) {
						paraQueue.push(line.replace(/\/\*/g,"").replace(/\*\//g,""))
						codeQueue.flush()
					} 
					else if( codeQueue.flush() ) { }
					else { paraQueue.flush() }
				}
			}
		}
		if( codeQueue.length > 0 )
			result.push($(Function.PrettyPrint(codeQueue.join('\n'))))
		if( paraQueue.length > 0 )
			result.push($("<p>").html(paraQueue.join('\n')))
		return result.flatten()
	}


	function walk(name, x, visit) {
		var keys = Object.Keys(x),
			i = 0, n = keys.length,
			key = null, val = null
		for(; i < n; i++) {
			key = keys[i]
			val = x[key]
			key = Object.IsNumber(key)
				? x[key].name
				: key[0] === '$' 
				? '$.' + key.substr(1) 
				: "" + name + "." + key
			if( Object.IsObject(val) ) // recurse
				arguments.callee(key, val, visit)
			else if( Object.IsFunc(val) )
				visit(key, val)
		}
	}

	$.plugin(function Doc() {
		return {
			$doc: {
				module: function (name, func_template) {
					// $.doc.module(name, template) - render docs into template
					var ret = $([])
					if( ! func_template )
						func_template = $.synth("li a[href=api:%(reference)s] '%(definition)s' + div '%(description)s' + div '%(examples)s'")
					walk("Bling.prototype", $.plugin.s[name], function visit(name, f) {
						var text = Function.PrettyPrint(f),
							nodes = $(text),
							examples = getExamples(nodes),
							description = getDescription(nodes),
							reference = name.replace("Bling.prototype.","").replace("Bling.",""),
							output = func_template.render({
								reference: reference,
								definition: description[0],
								description: description[1],
								examples: examples.map($.HTML.stringify).join("")
							})
						ret.push(output)
					})
					return ret
				}
			}
		}
	})


})(Bling)

