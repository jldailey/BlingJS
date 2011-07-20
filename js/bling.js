(function(){var s,y,z,G,E,A,H,F,C,v=Array.prototype.slice,J=Object.prototype.hasOwnProperty,K=function(d,k){function j(){this.constructor=d}for(var i in k)if(J.call(k,i))d[i]=k[i];j.prototype=k.prototype;d.prototype=new j;d.__super__=k.prototype;return d},I=function(d,k){return function(){return d.apply(k,arguments)}};if(false in document)alert("This browser is not supported");else{C=console&&console.log?function(){var d;d=1<=arguments.length?v.call(arguments,0):[];return console.log.apply(console,
d)}:function(){var d;d=1<=arguments.length?v.call(arguments,0):[];return alert(d.join(", "))};z=Math.min;y=Math.max;G=Math.sqrt;E=Object.prototype.toString;A=/,* +/;H=/^\s+/;F=/\[object (\w+)\]/;s=function(d,k){var j;if(k==null)k=document;j=Object.Type(d);if(j==="node"||j==="window"||j==="function")j=[d];else if(j==="number")j=Array(d);else if(j==="string"){d=d.trimLeft();if(d[0]==="<")j=[s.HTML.parse(d)];else if(k.querySelectorAll)j=k.querySelectorAll(d);else throw Error("invalid context: "+k+" (type: "+
Object.Type(k)+")");}else if(j==="array"||j==="bling"||j==="nodelist")j=d;else if(j==="undefined"||j==="null")j=[];else throw Error("invalid selector: "+d+" (type: "+Object.Type(d)+")");j.constructor=s;j.__proto__=s.fn;j.selector=d;j.context=k;j.length=j.len();return j};s.fn=[];Object.Keys=function(d,k){var j,i,b;if(k==null)k=false;b=[];i=0;for(j in d)if(k||d.hasOwnProperty(j))b[i++]=j;return b};Object.Extend=function(d,k,j){var i,b,g;if(E.apply(j)==="[object Array]")for(i in j){if(k[j[i]]!==void 0)d[j[i]]=
k[j[i]]}else{g=Object.Keys(k);j=0;for(b=g.length;j<b;j++){i=g[j];d[i]=k[i]}}return d};Object.Extend(Object,{Type:function(d){var k;switch(true){case d===void 0:return"undefined";case d===null:return"null";case Object.IsString(d):return"string";case Object.IsType(d,s):return"bling";case Object.IsType(d,NodeList):return"nodelist";case Object.IsArray(d):return"array";case Object.IsNumber(d):return"number";case Object.IsFragment(d):return"fragment";case Object.IsNode(d):return"node";case Object.IsFunc(d):return"function";
case Object.IsType(d,"RegExp"):return"regexp";case (k=String(d))==="true"||k==="false":return"boolean";case Object.IsObject(d):return"setInterval"in d?"window":"object"}},IsType:function(d,k){return d===null?d===k:d.constructor===k?true:typeof k==="string"?d.constructor.name===k||E.apply(d).replace(F,"$1")===k:Object.IsType(d.__proto__,k)},IsString:function(d){return d!=null&&(typeof d==="string"||Object.IsType(d,String))},IsNumber:function(d){return d!=null&&Object.IsType(d,Number)},IsBoolean:function(d){return typeof d===
"boolean"},IsFunc:function(d){return d!=null&&(typeof d==="function"||Object.IsType(d,Function))&&d.call!=null},IsNode:function(d){return d!=null&&d.nodeType>0},IsFragment:function(d){return d!=null&&d.nodeType===11},IsArray:function(d){return d!=null&&(Object.ToString(d)==="[object Array]"||Object.IsType(d,Array))},IsBling:function(d){return d!=null&&Object.IsType(d,s)},IsObject:function(d){return d!=null&&typeof d==="object"},IsDefined:function(d){return d!=null},Unbox:function(d){if(d!=null&&Object.IsObject(d)){if(Object.IsString(d))return d.toString();
if(Object.IsNumber(d))return Number(d)}return d},ToString:function(d){return E.apply(d)}});Object.Extend(Function,{Empty:function(){},Bound:function(d,k,j){var i;if(j==null)j=[];if("bind"in d){j.splice(0,0,k);i=d.bind.apply(d,j)}else i=function(){1<=arguments.length&&v.call(arguments,0);return d.apply(k,j)};i.toString=function(){return"bound-method of "+k+"."+d.name};return i},Trace:function(d,k,j){var i;if(j==null)j=C;i=function(){var b;b=1<=arguments.length?v.call(arguments,0):[];j(""+(k||"")+(this.name||
this)+"."+d.name+"(",b,")");return d.apply(this,b)};j("Function.Trace: "+(k||d.name)+" created.");i.toString=d.toString;return i},NotNull:function(d){return d!==null},IndexFound:function(d){return d>-1},ReduceAnd:function(d){return d&&this},UpperLimit:function(d){return function(k){return z(d,k)}},LowerLimit:function(d){return function(k){return y(d,k)}},Px:function(d){return function(){return Number.Px(this,d)}}});Object.Extend(Array,{Coalesce:function(){var d,k,j,i;d=1<=arguments.length?v.call(arguments,
0):[];if(Object.IsArray(d[0]))return Array.Coalesce.apply(Array,d[0]);else{j=0;for(i=d.length;j<i;j++){k=d[j];if(k!=null)return k}}},Extend:function(d,k){var j,i,b,g;i=d.length;b=0;for(g=k.length;b<g;b++){j=k[b];d[i++]=j}return d}});Object.Extend(Number,{Px:function(d,k){if(k==null)k=0;return d!=null&&parseInt(d,10)+(k|0)+"px"},AtLeast:function(d){return function(k){return y(parseFloat(k||0),d)}},AtMost:function(d){return function(k){return z(parseFloat(k||0),d)}}});Object.Extend(String,{PadLeft:function(d,
k,j){if(j==null)j=" ";for(;d.length<k;)d=j+d;return d},PadRight:function(d,k,j){if(j==null)j=" ";for(;d.length<k;)d+=j;return d},Splice:function(d,k,j,i){var b;b=d.length;j=j;if(j<0)j+=b;k=k;if(k<0)k+=b;return d.substring(0,k)+i+d.substring(j)},Checksum:function(d){var k,j,i;k=j=0;for(i=d.length;0<=i?k<i:k>i;0<=i?k++:k--)j+=d.charCodeAt(k);return j}});Object.Extend(Event,{Cancel:function(d){d.stopPropagation();d.preventDefault();d.cancelBubble=true;return d.returnValue=false},Prevent:function(d){return d.preventDefault()},
Stop:function(d){d.stopPropagation();return d.cancelBubble=true}});(function(d){d.plugins=[];d.plugin=function(k){var j,i,b,g,a,f,c;try{g=k.call(d,d);b=k.name||g.name;if(!b)throw Error("plugin requires a 'name'");i=function(h,l){return h[0]===s.symbol?s[h.substr(1)]=l:s.fn[h]=l};c=Object.Keys(g,true);a=0;for(f=c.length;a<f;a++){j=c[a];j!=="name"&&i(j,g[j])}d.plugins.push(b);return d.plugins[b]=g}catch(e){return console.log("failed to load plugin",e)}};d.plugin(function(){var k;k=null;s.__defineSetter__("symbol",
function(j){k in window&&delete window[k];k=j;return window[j]=s});s.__defineGetter__("symbol",function(){return k});s.symbol="$";window.Bling=d=s;return{name:"Symbol"}});d.plugin(function(){var k,j;String.prototype.trimLeft=Array.Coalesce(String.prototype.trimLeft,function(){return this.replace(H,"")});String.prototype.split=Array.Coalesce(String.prototype.split,function(i){var b,g,a,f;b=[];for(g=f=0;(a=this.indexOf(i,g))>-1;){b[f++]=this.substring(g+1,a+1);g=a+1}return b});Array.prototype.join=
Array.Coalesce(Array.prototype.join,function(i){var b,g;b=this.length;if(b===0)return"";for(g=this[b-1];--b>0;)g=this[b-1]+i+g;return g});Element.prototype.matchesSelector=Array.Coalesce(Element.prototype.webkitMatchesSelector,Element.prototype.mozMatchesSelector,Element.prototype.matchesSelector);j=Element.prototype.toString;Element.prototype.toString=function(i){if(i){i=this.nodeName.toLowerCase();if(this.id!=null)i+="#"+this.id;else if(this.className!=null)i+="."+this.className.split(" ").join(".");
return i}else return j.apply(this)};if(Element.prototype.cloneNode.length===0){k=Element.prototype.cloneNode;Element.prototype.cloneNode=function(i){var b,g,a,f;if(i==null)i=false;b=k.call(this);if(i){f=this.childNodes;g=0;for(a=f.length;g<a;g++){i=f[g];b.appendChild(i.cloneNode(true))}}return b}}return{name:"Compat"}});d.plugin(function(){var k,j,i;k=new (function(){function b(){var g;g=I(function(){if(this.length>0)return this.shift()()},this);this.schedule=I(function(a,f){var c,e;if(!Object.IsFunc(a))throw Error("function expected, got: "+
typeof a);e=this.length;a.order=f+(new Date).getTime();if(e===0||a.order>this[e-1].order)this[e]=a;else for(c=0;0<=e?c<e:c>e;0<=e?c++:c--)if(this[c].order>a.order){this.splice(c,0,a);break}setTimeout(g,f);return this},this)}K(b,Array);return b}());j=function(b){return function(){var g;g=this[b];if(Object.IsFunc(g))return Function.Bound(g,this);return g}};i=function(b){var g;g=b.indexOf(".");if(g>-1)return this.zip(b.substr(0,g)).zip(b.substr(g+1));return this.map(j(b))};return{name:"Core",querySelectorAll:function(b){return this.filter("*").reduce(function(g,
a){return Array.Extend(g,a.querySelectorAll(b))},d())},eq:function(b){var g;g=d([this[b]]);g.context=this;return g.selector=["eq",b]},each:function(b){var g,a,f;a=0;for(f=this.length;a<f;a++){g=this[a];b.call(g,g)}return this},map:function(b){var g,a,f,c;g=d();g.context=this;g.selector=["map",b];f=this.len();for(a=0;0<=f?a<f:a>f;0<=f?a++:a--){c=this[a];try{g[a]=b.call(c,c)}catch(e){g[a]=e}}return g},reduce:function(b,g){var a,f;a=g;f=this;if(g==null){a=this[0];f=this.skip(1)}f.each(function(){return a=
b.call(this,a,this)});return a},union:function(b,g){var a,f,c,e;c=d();a=f=0;c.context=[this,b];for(c.selector="union";e=this[f++];)c.contains(e,g)||(c[a++]=e);for(f=0;e=b[f++];)c.contains(e,g)||(c[a++]=e);return c},intersect:function(b){var g,a,f,c,e,h;h=d();f=0;c=this.len();e=Object.IsFunc(b.len)?b.len():b.length;h.context=[this,b];h.selector="intersect";for(g=0;0<=c?g<c:g>c;0<=c?g++:g--)for(a=0;0<=e?a<e:a>e;0<=e?a++:a--)if(this[g]===b[a]){h[f++]=this[g];break}return h},distinct:function(b){return this.union(this,
b)},contains:function(b,g){var a,f,c;f=0;for(c=this.length;f<c;f++){a=this[f];if(g&&a===b||!g&&a===b)return true}return false},count:function(b,g){var a;if(b===void 0)return this.len();a=0;this.each(function(f){if(g&&f===b||!g&&f===b)return a++});return a},zip:function(){var b,g,a,f,c,e,h,l;b=1<=arguments.length?v.call(arguments,0):[];e=b.length;switch(e){case 0:return d();case 1:return i.call(this,b[0]);default:l={};h=this.len();c=d();for(g=a=0;0<=e?g<e:g>e;0<=e?g++:g--)l[b[g]]=i.call(this,b[g]);
for(g=0;0<=h?g<h:g>h;0<=h?g++:g--){b={};for(f in l)b[f]=l[f].shift();c[a++]=b}return c}},zap:function(b,g){var a;a=b.indexOf(".");return a>-1?this.zip(b.substr(0,a)).zap(b.substr(a+1),g):Object.IsArray(g)?this.each(function(){return this[b]=g[++a%g.length]}):this.each(function(){return this[b]=g})},zipzapmap:function(b,g){var a;a=this.zip(b);a=a.map(g);return this.zap(b,a)},take:function(b){var g,a;b=z(b|0,this.len());g=d();g.context=this;g.selector=["take",b];for(a=0;0<=b?a<b:a>b;0<=b?a++:a--)g[a]=
this[a];return g},skip:function(b){var g,a,f;if(b==null)b=0;b=z(this.len(),y(0,b|0));f=this.len()-b;g=d();g.context=this.context;g.selector=this.selector;for(a=0;0<=f?a<f:a>f;0<=f?a++:a--)g[a]=this[a+b];return g},first:function(b){if(b==null)b=1;return b===1?this[0]:this.take(b)},last:function(b){if(b==null)b=1;return b===1?this[this.len()-1]:this.skip(this.len()-b)},slice:function(b,g){var a,f,c;if(b==null)b=0;if(g==null)g=this.len();a=d();c=0;f=this.len();if(b<0)b+=f;if(g<0)g+=f;a.context=this;
a.selector=["slice",b,g];for(f=b;b<=g?f<g:f>g;b<=g?f++:f--)a[c++]=this[f];return a},concat:function(b){var g,a,f;g=this.len()-1;a=-1;for(f=Object.IsFunc(b.len)?b.len():b.length;a<f-1;)this[++g]=b[++a];return this},push:function(b){Array.prototype.push.call(this,b);return this},filter:function(b){var g,a,f,c,e,h;g=d();g.context=this;g.selector=b;c=0;switch(Object.Type(b)){case "string":a=function(l){return l.matchesSelector(b)};break;case "regexp":a=function(l){return b.test(l)};break;case "function":a=
b}e=0;for(h=this.length;e<h;e++){f=this[e];if(a.call(f,f))g[c++]=f}return g},test:function(b){return this.map(function(){return b.test(this)})},matches:function(b){return this.zip("matchesSelector").call(b)},weave:function(b){var g,a,f,c;f=b.len();a=this.len();g=d();g.context=[this,b];g.selector="weave";for(a=c=a-1;c<=0?a<=0:a>=0;c<=0?a++:a--)g[a*2+1]=this[a];for(a=0;0<=f?a<f:a>f;0<=f?a++:a--)g[a*2]=b[a];return g},fold:function(b){var g,a,f,c,e;c=this.len();f=0;g=d();g.context=this;g.selector=["fold",
b];a=0;for(e=c-1;0<=e?a<e:a>e;a+=2)g[f++]=b.call(this,this[a],this[a+1]);if(c%2===1)g[f++]=b.call(this,this[c-1],void 0);return g},flatten:function(){var b,g,a,f,c,e,h;b=d();h=this.len();e=0;b.context=this;b.selector="flatten";for(f=0;0<=h?f<h:f>h;0<=h?f++:f--){g=this[f];a=Object.IsFunc(g.len)?g.len():g.length;for(c=0;0<=a?c<a:c>a;0<=a?c++:c--)b[e++]=g[c]}return b},call:function(){return this.apply(null,arguments)},apply:function(b,g){return this.map(function(){return Object.IsFunc(this)?this.apply(b,
g):this})},toString:function(){return d.symbol+"(["+this.map(function(){switch(this){case void 0:return"undefined";case null:return"null";case window:return"window";default:return this.toString().replace(F,"$1")}}).join(", ")+"])"},delay:function(b,g){g&&k.schedule(Function.Bound(g,this),b);return this},log:function(b){var g;g=this.len();b?C(b,this,g+" items"):C(this,g+" items");return this},len:function(){var b;for(b=this.length;this[b]!==void 0;)b++;for(;b>-1&&this[b]===void 0;)b--;return b+1}}});
d.plugin(function(){var k,j,i,b,g;j=function(a,f){return a.parentNode.insertBefore(f,a)};k=function(a,f){return a.parentNode.insertBefore(f,a.nextSibling)};g=function(a){switch(Object.Type(a)){case "fragment":return a;case "node":return a;case "bling":return a.toFragment();case "string":return d(a).toFragment();case "function":return d(a.toString()).toFragment();default:throw Error("toNode called with invalid argument: "+a+" (type: "+Object.Type(a)+")");}};i=null;b=function(a){return function(){return window.getComputedStyle(this,
null).getPropertyValue(a)}};return{name:"Html",$HTML:{parse:function(a){var f,c,e,h;h=document.createElement("div");h.innerHTML=a;a=h.childNodes;e=a.length;if(e===1)return h.removeChild(a[0]);f=document.createDocumentFragment();for(c=0;0<=e?c<e:c>e;0<=e?c++:c--)f.appendChild(h.removeChild(a[0]));return f},stringify:function(a){var f,c;switch(Object.Type(a)){case "string":return a;case "node":a=a.cloneNode(true);f=document.createElement("div");f.appendChild(a);c=f.innerHTML;f.removeChild(a);delete a;
return c}},escape:function(a){i||(i=d("<div>&nbsp;</div>").child(0));a=i.zap("data",a).zip("parentNode.innerHTML").first();i.zap("data","");return a}},html:function(a){switch(Object.Type(a)){case "undefined":return this.zip("innerHTML");case "string":return this.zap("innerHTML",a);case "bling":return this.html(a.toFragment());case "node":return this.each(function(){var f;this.replaceChild(this.childNodes[0],a);for(f=[];this.childNodes.length>1;)f.push(this.removeChild(this.childNodes[1]));return f})}},
append:function(a){var f;a=g(a);f=this.zip("appendChild");f.take(1).call(a);f.skip(1).each(function(c){return c(a.cloneNode(true))});return this},appendTo:function(a){d(a).append(this);return this},prepend:function(a){if(a!=null){a=g(a);this.take(1).each(function(){return j(this.childNodes[0],a)});this.skip(1).each(function(){return j(this.childNodes[0],a.cloneNode(true))})}return this},prependTo:function(a){a!=null&&d(a).prepend(this);return this},before:function(a){if(a!=null){a=g(a);this.take(1).each(function(){return j(this,
a)});this.skip(1).each(function(){return j(this,a.cloneNode(true))})}return this},after:function(a){if(a!=null){a=g(a);this.take(1).each(function(){return k(this,a)});this.skip(1).each(function(){return k(this,a.cloneNode(true))})}return this},wrap:function(a){a=g(a);if(Object.IsFragment(a))throw Error("cannot wrap with a fragment");return this.map(function(f){var c,e;if(Object.IsFragment(f))a.appendChild(f);else if(Object.IsNode(f))if(e=f.parentNode){c=document.createElement("dummy");a.appendChild(e.replaceChild(c,
f));e.replaceChild(a,c)}else a.appendChild(f);return f})},unwrap:function(){return this.each(function(){if(this.parentNode&&this.parentNode.parentNode)return this.parentNode.parentNode.replaceChild(this,this.parentNode)})},replace:function(a){var f,c;a=g(a);f=d();c=0;this.take(1).each(function(){if(this.parentNode){this.parentNode.replaceChild(a,this);return f[c++]=a}});this.skip(1).each(function(){var e;if(this.parentNode){e=a.cloneNode(true);this.parentNode.replaceChild(e,this);return f[c++]=e}});
return f},attr:function(a,f){switch(f){case void 0:return this.zip("getAttribute").call(a,f);case null:return this.zip("removeAttribute").call(a,f);default:this.zip("setAttribute").call(a,f);return this}},addClass:function(a){return this.removeClass(a).each(function(){var f;f=this.className.split(" ").filter(function(c){return c!==""});f.push(a);return this.className=f.join(" ")})},removeClass:function(a){var f;f=function(c){return c!==a};return this.each(function(){return this.className=this.className.split(" ").filter(f).join(" ")})},
toggleClass:function(a){var f;f=function(c){return c!==a};return this.each(function(){var c;c=this.className.split(" ");if(c.indexOf(a)>-1)return this.className=c.filter(f).join(" ");else{c.push(a);return this.className=c.join(" ")}})},hasClass:function(a){return this.zip("className.split").call(" ").zip("indexOf").call(a).map(Function.IndexFound)},text:function(a){if(a!=null)return this.zap("textContent",a);return this.zip("textContent")},val:function(a){if(a!=null)return this.zap("value",a);return this.zip("value")},
css:function(a,f){var c,e,h,l;if(f!=null||Object.IsObject(a)){l=this.zip("style.setProperty");h=l.len();if(Object.IsObject(a))for(c in a)l.call(c,a[c],"");else if(Object.IsString(f))l.call(a,f,"");else if(Object.IsArray(f)){e=y(f.length,h);for(c=0;0<=e?c<e:c>e;0<=e?c++:c--)l[c%h](a,f[c%e],"")}return this}else{c=this.map(b(a));e=this.zip("style").zip(a);return e.weave(c).fold(function(n,m){return n||m})}},defaultCss:function(a,f){var c,e,h;e=this.selector;h="";if(Object.IsString(a))if(Object.IsString(f))h+=
""+e+" { "+a+": "+f+" } ";else throw Error("defaultCss requires a value with a string key");else if(Object.IsObject(a)){h+=""+e+" { ";for(c in a)h+=""+c+": "+a[c]+"; ";h+="} "}d.synth("style").text(h).appendTo("head");return this},empty:function(){return this.html("")},rect:function(){return this.zip("getBoundingClientRect").call()},width:function(a){if(a===null)return this.rect().zip("width");return this.css("width",a)},height:function(a){if(a===null)return this.rect().zip("height");return this.css("height",
a)},top:function(a){if(a===null)return this.rect().zip("top");return this.css("top",a)},left:function(a){if(a===null)return this.rect().zip("left");return this.css("left",a)},bottom:function(a){if(a===null)return this.rect().zip("bottom");return this.css("bottom",a)},right:function(a){if(a===null)return this.rect().zip("right");return this.css("right",a)},position:function(a,f){if(a===null)return this.rect();if(f===null)return this.css("left",Number.Px(a));return this.css({top:Number.Px(f),left:Number.Px(a)})},
center:function(a){var f,c,e;if(a==null)a="viewport";f=document.body;c=f.scrollTop+f.clientHeight/2;e=f.scrollLeft+f.clientWidth/2;return this.each(function(){var h,l,n;l=d(this);h=l.height().floats().first();n=l.width().floats().first();n=a==="viewport"||a==="horizontal"?e-n/2:NaN;h=a==="viewport"||a==="vertical"?c-h/2:NaN;return l.css({position:"absolute",left:Number.Px(n),top:Number.Px(h)})})},scrollToCenter:function(){document.body.scrollTop=this.zip("offsetTop")[0]-window.innerHeight/2;return this},
child:function(a){return this.zip("childNodes").map(function(){var f;f=a;if(f<0)f+=this.length;return this[f]})},children:function(){return this.map(function(){return d(this.childNodes,this)})},parent:function(){return this.zip("parentNode")},parents:function(){return this.map(function(){var a,f,c;a=d();f=0;for(c=this;c=c.parentNode;)a[f++]=c;return a})},prev:function(){return this.map(function(){var a,f,c;a=d();f=0;for(c=this;c=c.previousSibling;)a[f++]=c;return a})},next:function(){return this.map(function(){var a,
f,c;a=d();f=0;for(c=this;c=c.nextSibling;)a[f++]=c;return a})},remove:function(){return this.each(function(){if(this.parentNode)return this.parentNode.removeChild(this)})},find:function(a){return this.filter("*").map(function(){return d(a,this)}).flatten()},clone:function(a){if(a==null)a=true;return this.map(function(){return Object.IsNode(this)?this.cloneNode(a):null})},toFragment:function(){var a,f;if(this.len()>1){f=document.createDocumentFragment();a=Function.Bound(f.appendChild,f);this.map(g).map(a);
return f}return g(this[0])}}});d.plugin(function(){return{name:"Maths",floats:function(){return this.map(parseFloat)},ints:function(){return this.map(function(){return parseInt(this,10)})},px:function(k){if(k==null)k=0;return this.ints().map(Function.Px(k))},min:function(){return this.reduce(function(k){return z(this,k)})},max:function(){return this.reduce(function(k){return y(this,k)})},average:function(){return this.sum()/this.len()},sum:function(){return this.reduce(function(k){return k+this})},
squares:function(){return this.map(function(){return this*this})},magnitude:function(){return G(this.floats().squares().sum())},scale:function(k){return this.map(function(){return k*this})},normalize:function(){return this.scale(1/this.magnitude())}}});d.plugin(function(){var k,j,i,b,g,a,f;k=function(c){return function(e){if(e==null)e={};if(Object.IsFunc(e))return this.bind(c,e);return this.trigger(c,e)}};b=function(c,e,h,l,n){return d(e).bind(h,n).each(function(){var m;m=this.__alive__||(this.__alive__=
{});m=m[c]||(m[c]={});return(m[h]||(m[h]={}))[l]=n})};f=function(c,e,h,l){var n;n=d(e);return n.each(function(){var m;m=this.__alive__||(this.__alive__={});m=m[c]||(m[c]={});m=m[h]||(m[h]={});n.unbind(h,m[l]);return delete m[l]})};j=i=0;a=function(){if(!i++){d(document).trigger("ready").unbind("ready");typeof document.removeEventListener==="function"&&document.removeEventListener("DOMContentLoaded",a,false);return typeof window.removeEventListener==="function"?window.removeEventListener("load",a,
false):void 0}};if(!j++){typeof document.addEventListener==="function"&&document.addEventListener("DOMContentLoaded",a,false);typeof window.addEventListener==="function"&&window.addEventListener("load",a,false)}g={name:"Events",bind:function(c,e){var h,l;h=(c||"").split(A);l=function(n){g=e.apply(this,arguments);g===false&&Event.Prevent(n);return g};return this.each(function(){var n,m,p,q;q=[];m=0;for(p=h.length;m<p;m++){n=h[m];q.push(this.addEventListener(n,l,false))}return q})},unbind:function(c,
e){var h;h=(c||"").split(A);return this.each(function(){var l,n,m,p;p=[];n=0;for(m=h.length;n<m;n++){l=h[n];p.push(this.removeEventListener(l,e,null))}return p})},once:function(c,e){var h,l,n,m,p;h=(c||"").split(A);p=[];n=0;for(m=h.length;n<m;n++){l=h[n];p.push(this.bind(l,function(q){e.call(this,q);return this.removeEventListener(q.type,arguments.callee,null)}))}return p},cycle:function(){var c,e,h,l,n,m,p;c=arguments[0];h=2<=arguments.length?v.call(arguments,1):[];c=(c||"").split(A);n=h.length;
e=function(){var q;q=0;return function(o){h[q].call(this,o);return q=++q%n}};m=0;for(p=c.length;m<p;m++){l=c[m];this.bind(l,e())}return this},trigger:function(c,e){var h,l,n,m,p;if(e==null)e={};n=(c||"").split(A);e=Object.Extend({bubbles:true,cancelable:true},e);m=0;for(p=n.length;m<p;m++){l=n[m];if(l==="click"||l==="mousemove"||l==="mousedown"||l==="mouseup"||l==="mouseover"||l==="mouseout"){h=document.createEvent("MouseEvents");e=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,
altKey:false,shiftKey:false,metaKey:false,button:0,relatedTarget:null},e);h.initMouseEvent(l,e.bubbles,e.cancelable,window,e.detail,e.screenX,e.screenY,e.clientX,e.clientY,e.ctrlKey,e.altKey,e.shiftKey,e.metaKey,e.button,e.relatedTarget)}else if(l==="blur"||l==="focus"||l==="reset"||l==="submit"||l==="abort"||l==="change"||l==="load"||l==="unload"){h=document.createEvent("UIEvents");h.initUIEvent(l,e.bubbles,e.cancelable,window,1)}else if(l==="touchstart"||l==="touchmove"||l==="touchend"||l==="touchcancel"){h=
document.createEvent("TouchEvents");e=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},e);h.initTouchEvent(l,e.bubbles,e.cancelable,window,e.detail,e.screenX,e.screenY,e.clientX,e.clientY,e.ctrlKey,e.altKey,e.shiftKey,e.metaKey,e.touches,e.targetTouches,e.changedTouches,e.scale,e.rotation)}else if(l==="gesturestart"||l==="gestureend"||l==="gesturecancel"){h=document.createEvent("GestureEvents");
e=Object.Extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,target:null,scale:1,rotation:0},e);h.initGestureEvent(l,e.bubbles,e.cancelable,window,e.detail,e.screenX,e.screenY,e.clientX,e.clientY,e.ctrlKey,e.altKey,e.shiftKey,e.metaKey,e.target,e.scale,e.rotation)}else{h=document.createEvent("Events");h.initEvent(l,e.bubbles,e.cancelable);try{h=Object.Extend(h,e)}catch(q){}}if(h)try{this.each(function(){return this.dispatchEvent(h)})}catch(o){C("dispatchEvent error:",
o)}}return this},live:function(c,e){var h,l;l=this.selector;h=this.context;b(l,h,c,e,function(n){return d(l,h).intersect(d(n.target).parents().first().union(d(n.target))).each(function(){n.target=this;return e.call(this,n)})});return this},die:function(c,e){var h,l;l=this.selector;h=this.context;l=f(l,h,c,e);d(h).unbind(c,l);return this},liveCycle:function(){var c,e,h;c=arguments[0];e=2<=arguments.length?v.call(arguments,1):[];h=0;return this.live(c,function(l){e[h].call(this,l);return h=++h%e.length})},
click:function(c){if(c==null)c={};this.css("cursor").intersect(["auto",""]).len()>0&&this.css("cursor","pointer");return Object.IsFunc(c)?this.bind("click",c):this.trigger("click",c)},ready:function(c){if(c==null)c={};return Object.IsFunc(c)?i?c.call(this):this.bind("ready",c):this.trigger("ready",c)}};["mousemove","mousedown","mouseup","mouseover","mouseout","blur","focus","load","unload","reset","submit","keyup","keydown","change","abort","cut","copy","paste","selection","drag","drop","orientationchange",
"touchstart","touchmove","touchend","touchcancel","gesturestart","gestureend","gesturecancel","hashchange"].forEach(function(c){return g[c]=k(c)});return g});d.plugin(function(){var k,j,i,b,g,a,f;j={slow:700,medium:500,normal:300,fast:100,instant:0,now:0};k=/(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/;i=document.createElement("div").style;if("WebkitTransform"in i){b="-webkit-transform";a="-webkit-transition-property";g="-webkit-transition-duration";f="-webkit-transition-timing-function"}else if("MozTransform"in
i){b="-moz-transform";a="-moz-transition-property";g="-moz-transition-duration";f="-moz-transition-timing-function"}else if("OTransform"in i){b="-o-transform";a="-o-transition-property";g="-o-transition-duration";f="-o-transition-timing-function"}delete i;return{name:"Transform",$duration:function(c){var e;e=j[c];if(e!=null)return e;return parseFloat(c)},transform:function(c,e,h,l){var n,m,p,q,o,r;if(Object.IsFunc(e)){l=e;h=e=null}else if(Object.IsFunc(h)){l=h;h=null}if(e==null)e="normal";h||(h="ease");
n=d.duration(e)+"ms";o=[];q=0;r="";e={};for(m in c)if(k.test(m)){p=c[m];if(p.join)p=d(p).px().join(", ");else if(p.toString)p=p.toString();r+=" "+m+"("+p+")"}else e[m]=c[m];for(m in e)o[q++]=m;if(r)o[q++]=b;e[a]=o.join(", ");e[g]=o.map(function(){return n}).join(", ");e[f]=o.map(function(){return h}).join(", ");if(r)e[b]=r;this.css(e);return this.delay(n,l)},hide:function(c){return this.each(function(){if(this.style){this._display="";if(this.style.display===false)this._display=this.syle.display;return this.style.display=
"none"}}).trigger("hide").delay(50,c)},show:function(c){return this.each(function(){if(this.style){this.style.display=this._display;return delete this._display}}).trigger("show").delay(50,c)},toggle:function(c){return this.weave(this.css("display")).fold(function(e,h){if(e==="none"){h.style.display=h._display||"";delete h._display;d(h).trigger("show")}else{h._display=e;h.style.display="none";d(h).trigger("hide")}return h}).delay(50,c)},fadeIn:function(c,e){return this.css("opacity","0.0").show(function(){return this.transform({opacity:"1.0",
translate3d:[0,0,0]},c,e)})},fadeOut:function(c,e,h,l){if(h==null)h=0;if(l==null)l=0;return this.transform({opacity:"0.0",translate3d:[h,l,0]},c,function(){return this.hide(e)})},fadeLeft:function(c,e){return this.fadeOut(c,e,"-"+this.width().first(),0)},fadeRight:function(c,e){return this.fadeOut(c,e,this.width().first(),0)},fadeUp:function(c,e){return this.fadeOut(c,e,0,"-"+this.height().first())},fadeDown:function(c,e){return this.fadeOut(c,e,0,this.height().first())}}});d.plugin(function(){var k;
k=function(j){var i,b,g;g=[];b=0;j=JSON.parse(JSON.stringify(j));for(i in j)g[b++]=""+i+"="+escape(j[i]);return g.join("&")};return{name:"Http",$http:function(j,i){var b;if(i==null)i={};b=new XMLHttpRequest;if(Object.IsFunc(i))i={success:Function.Bound(i,b)};i=Object.Extend({method:"GET",data:null,state:Function.Empty,success:Function.Empty,error:Function.Empty,async:true,timeout:0,withCredentials:false,followRedirects:false,asBlob:false},i);i.state=Function.Bound(i.state,b);i.success=Function.Bound(i.success,
b);i.error=Function.Bound(i.error,b);if(i.data&&i.method==="GET")j+="?"+k(i.data);else if(i.data&&i.method==="POST")i.data=k(i.data);b.open(i.method,j,i.async);b.withCredentials=i.withCredentials;b.asBlob=i.asBlob;b.timeout=i.timeout;b.followRedirects=i.followRedirects;b.onreadystatechange=function(){i.state&&i.state();if(b.readyState===4)return b.status===200?i.success(b.responseText):i.error(b.status,b.statusText)};b.send(i.data);return d([b])},$post:function(j,i){if(i==null)i={};if(Object.IsFunc(i))i=
{success:i};i.method="POST";return d.http(j,i)},$get:function(j,i){if(i==null)i={};if(Object.IsFunc(i))i={success:i};i.method="GET";return d.http(j,i)}}});d.plugin(function(){var k,j,i,b,g,a;i=function(f,c,e,h,l){var n,m;n=1;if(l===null||l===-1)l=f.length;for(m=h;h<=l?m<l:m>l;h<=l?m++:m--){if(f[m]===e)n+=1;else if(f[m]===c)n-=1;if(n===0)return m}return-1};a=/([0-9#0+-]*)\.*([0-9#+-]*)([diouxXeEfFgGcrsqm])((?:.|\n)*)/;k=/%[\(\/]/;j=function(f){var c,e,h,l,n,m,p;f=f.split(k);n=f.length;p=[f[0]];for(e=
h=1;1<=n?e<n:e>n;1<=n?e++:e--){c=i(f[e],")","(",0,-1);if(c===-1)return"Template syntax error: unmatched '%(' starting at: "+f[e].substring(0,15);l=f[e].substring(0,c);m=f[e].substring(c);c=a.exec(m);if(c===null)return"Template syntax error: invalid type specifier starting at '"+m+"'";m=c[4];p[h++]=l;p[h++]=c[1]|0;p[h++]=c[2]|0;p[h++]=c[3];p[h++]=m}return p};j.cache={};b=function(f,c){var e,h,l,n,m,p,q,o,r,t,u;e=j.cache[f];if(e==null)e=j.cache[f]=j(f);p=[e[0]];n=1;h=e.length;l=1;for(u=h-4;1<=u?l<u:
l>u;l+=5){m=e[l];q=e[l+1];h=e[l+2];r=e[l+3];o=e[l+4];t=c[m];if(t==null)t="missing value: "+m;switch(r){case "d":p[n++]=""+parseInt(t,10);break;case "f":p[n++]=parseFloat(t).toFixed(h);break;case "s":p[n++]=""+t;break;default:p[n++]=""+t}if(q>0)p[n]=String.PadLeft(p[n],q);p[n++]=o}return p.join("")};g=function(f){var c,e,h,l,n,m,p,q,o,r,t,u,B,D;r=null;B=D=c=l=q=u="";e={};o=1;t=d([]);p=0;t.selector=f;m=function(){var w;w=d.HTML.parse(B);r?r.appendChild(w):t.push(w);B="";return o=1};for(n=function(){var w,
x;x=document.createElement(u);x.id=q||null;x.className=l||null;for(w in e)x.setAttribute(w,e[w]);r?r.appendChild(x):t.push(x);r=x;B=D=c=l=q=u="";e={};return o=1};h=f[p++];)if(h==="+"&&o===1){if(r)r=r.parentNode}else if(h==="#"&&(o===1||o===3||o===4))o=2;else if(h==="."&&(o===1||o===2||o===4)){if(l.length>0)l+=" ";o=3}else if(h==="."&&l.length>0)l+=" ";else if(h==="["&&(o===1||o===2||o===3||o===4))o=4;else if(h==="="&&o===4)o=5;else if(h==='"'&&o===1)o=6;else if(h==="'"&&o===1)o=7;else if(h==="]"&&
(o===4||o===5)){e[c]=D;D=c="";o=1}else if(h==='"'&&o===6)m();else if(h==="'"&&o===7)m();else if((h===" "||h===",")&&o!==5&&o!==4&&u.length>0){n();if(h===",")r=null}else if(o===1){if(h!==" ")u+=h}else if(o===2)q+=h;else if(o===3)l+=h;else if(o===4)c+=h;else if(o===5)D+=h;else if(o===6||o===7)B+=h;else throw Error("Unknown input/state: '"+h+"'/"+o);u.length>0&&n();B.length>0&&m();return t};return{name:"Template",$render:b,$synth:g,template:function(f){this.render=function(c){return b(this.map(d.HTML.stringify).join(""),
Object.Extend(f,c))};return this.remove()},render:function(f){return b(this.map(d.HTML.stringify).join(""),f)},synth:function(f){return g(f).appendTo(this)}}});return d.plugin(function(){var k,j,i;i=function(b){var g,a,f,c;g=b.indexOf(":");if(g>0){f=parseInt(b.slice(0,g),10);a=b.slice(g+1,g+1+f);c=b[g+1+f];b=b.slice(g+f+2);a=function(){switch(c){case "#":return Number(a);case "'":return String(a);case "!":return a==="true";case "~":return null;case "]":return k(a);case "}":return j(a)}}();return[a,
b]}};k=function(b){var g,a;for(g=[];b.length>0;){b=i(b);a=b[0];b=b[1];g.push(a)}return g};j=function(b){var g,a,f;for(g={};b.length>0;){f=i(b);a=f[0];b=f[1];b=i(b);f=b[0];b=b[1];g[a]=f}return g};return{name:"TNET",$TNET:{stringify:function(b){var g,a,f;f=function(){switch(Object.Type(b)){case "number":return[String(b),"#"];case "string":return[b,"'"];case "function":return[String(b),"'"];case "boolean":return[String(!!b),"!"];case "null":return["","~"];case "undefined":return["","~"];case "array":return[function(){var c,
e,h;h=[];c=0;for(e=b.length;c<e;c++){a=b[c];h.push(d.TNET.stringify(a))}return h}().join(""),"]"];case "object":return[function(){var c;c=[];for(a in b)c.push(d.TNET.stringify(a)+d.TNET.stringify(b[a]));return c}().join(""),"}"]}}();g=f[0];return(g.length|0)+":"+g+f[1]},parse:function(b){var g;return(g=i(b))!=null?g[0]:void 0}}}})})(s)}}).call(this);
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

