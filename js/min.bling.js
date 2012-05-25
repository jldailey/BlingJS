(function(){var a,b,f,c,d,i,e;var g=Array.prototype.slice,h=Object.prototype.hasOwnProperty,j=Array.prototype.indexOf||function(n){for(var m=0,k=this.length;m<k;m++){if(h.call(this,m)&&this[m]===n){return m}}return -1};d=function(){var k;k=1<=arguments.length?g.call(arguments,0):[];try{return console.log.apply(console,k)}catch(l){}return alert(k.join(", "))};if((e=Object.keys)==null){Object.keys=function(n){var m,l;l=[];for(m in n){l.push(m)}return l}}if(typeof extend==="undefined"||extend===null){extend=function(n,l){var p,o,q,m,r;if(!l){return n}r=Object.keys(l);for(q=0,m=r.length;q<m;q++){p=r[q];o=l[p];if(o!=null){n[p]=o}}return n}}b=function(m,k,l){return Object.defineProperty(m,k,extend({configurable:true,enumerable:true},l))};c=function(k,l){if(!(l!=null)){return k===l||k==="null"||k==="undefined"}else{return l.constructor===k||l.constructor.name===k||Object.prototype.toString.apply(l)===("[object "+k+"]")||c(k,l.__proto__)}};f=function(k,l){if(typeof k==="function"){l.constructor=k;k=k.prototype}l.__proto__=k;return l};i=(function(){var o,l,p,k,n,m;l={};o={name:"unknown",match:function(q){return true}};k=[];n=function(q,r){if(!(q in l)){k.unshift(q)}return l[r.name=q]=o!==r?f(o,r):r};m=function(s,t){var r,u,q;if(typeof s==="string"){if((u=l[s])==null){l[s]=n(s,{})}return l[s]=extend(l[s],t)}else{if(typeof s==="object"){q=[];for(r in s){q.push(m(r,s[r]))}return q}}};p=function(t){var r,s,q,u;for(s=0,q=k.length;s<q;s++){r=k[s];if((u=l[r])!=null?u.match.call(t,t):void 0){return l[r]}}};n("unknown",o);n("object",{match:function(){return typeof this==="object"}});n("error",{match:function(){return c("Error",this)}});n("regexp",{match:function(){return c("RegExp",this)}});n("string",{match:function(){return typeof this==="string"||c(String,this)}});n("number",{match:function(){return c(Number,this)}});n("bool",{match:function(){var q;return typeof this==="boolean"||((q=String(this))==="true"||q==="false")}});n("array",{match:function(){return(typeof Array.isArray==="function"?Array.isArray(this):void 0)||c(Array,this)}});n("function",{match:function(){return typeof this==="function"}});n("global",{match:function(){return typeof this==="object"&&"setInterval" in this}});n("undefined",{match:function(q){return q===void 0}});n("null",{match:function(q){return q===null}});return extend((function(q){return p(q).name}),{register:n,lookup:p,extend:m,is:function(q,r){var s;return(s=l[q])!=null?s.match.call(r,r):void 0}})})();a=(function(){var l,k,m;function n(o,p){if(p==null){p=document||{}}return f(n,extend(i.lookup(o).array(o,p),{selector:o,context:p}))}n.plugin=function(s,q){var p,r;var t=this;if(!(q!=null)){q=s;s={}}if("depends" in s){return this.depends(s.depends,function(){return t.plugin({provides:s.provides},q)})}try{if((r=q!=null?q.call(this,this):void 0)){extend(this,r!=null?r.$:void 0);["$","name"].forEach(function(u){return delete r[u]});extend(this.prototype,r);for(p in r){this[p]||(this[p]=function(){var u;u=1<=arguments.length?g.call(arguments,0):[];return t.prototype[p].apply($(u[0]),u.slice(1))})}if(s.provides!=null){this.provide(s.provides)}}}catch(o){d("failed to load plugin: "+this.name+" '"+o.message+"'");throw o}return this};m=[];l={};k=function(o){return((typeof o)==="string"?o.split(","):o).filter(function(p){return !(p in l)})};n.depends=function(o,p){if((o=k(o)).length===0){p()}else{m.push(function(r){var q;return((q=o.indexOf(r))>-1?o.splice(q,1):void 0)&&o.length===0&&p})}return p};n.provide=function(q){var t,p,r,s,o,u;console.log("provide("+q+")");u=k(q);for(s=0,o=u.length;s<o;s++){r=u[s];l[r]=p=0;while(p<m.length){if((t=m[p](r))){m.splice(p,1);t()}else{p++}}}return null};n.provides=function(o,p){return function(){var q,s;q=1<=arguments.length?g.call(arguments,0):[];s=p.apply(null,q);n.provide(o);return s}};i.extend({unknown:{array:function(p){return[p]}},"null":{array:function(p){return[]}},undefined:{array:function(p){return[]}},array:{array:function(p){return p}},number:{array:function(p){return n.extend(new Array(p),{length:0})}}});i.register("bling",{match:function(p){return c(n,p)},array:function(p){return p},hash:function(p){return p.map(n.hash).sum()},string:function(p){return n.symbol+"(["+p.map(n.toString).join(", ")+"])"}});return n})();a.prototype=[];(function(k){k.plugin({provides:"type"},function(){return{$:{inherit:f,extend:extend,isType:c,type:i,is:i.is,isSimple:function(l){var m;return(m=i(l))==="string"||m==="number"||m==="bool"},isEmpty:function(l){return l===""||l===null||l===(void 0)}}}});k.plugin({provides:"symbol"},function(){var l,m,n;n=null;l={};(m=typeof window!=="undefined"&&window!==null?window:global).Bling=a;b(k,"symbol",{set:function(o){m[n]=l[n];l[n=o]=m[o];return m[o]=a},get:function(){return n}});return{$:{symbol:"$"}}});k.plugin(function(){var p,o,n,m,l;(o=String.prototype).trimLeft||(o.trimLeft=function(){return this.replace(/^\s+/,"")});(n=String.prototype).split||(n.split=function(s){var q,t,r;q=[];t=0;while((r=this.indexOf(s,t))>-1){q.push(this.substring(t,r));t=r+1}return q});(m=String.prototype).lastIndexOf||(m.lastIndexOf=function(t,u,r){var q;if(r==null){r=-1}q=-1;while((r=t.indexOf(u,r+1))>-1){q=r}return q});(l=Array.prototype).join||(l.join=function(q){var t,r;if(q==null){q=""}t=this.length;if(t===0){return""}r=this[t-1];while(--t>0){r=this[t-1]+q+r}return r});if(typeof Event!=="undefined"&&Event!==null){Event.prototype.preventAll=function(){this.preventDefault();this.stopPropagation();return this.cancelBubble=true}}if(typeof Element!=="undefined"&&Element!==null){Element.prototype.matchesSelector=Element.prototype.webkitMatchesSelector||Element.prototype.mozMatchesSelector||Element.prototype.matchesSelector;if(Element.prototype.cloneNode.length===0){p=Element.prototype.cloneNode;Element.prototype.cloneNode=function(r){var s,v,t,q,u;if(r==null){r=false}v=p.call(this);if(r){u=this.childNodes;for(t=0,q=u.length;t<q;t++){s=u[t];v.appendChild(s.cloneNode(true))}}return v}}}return{}});k.plugin({depends:"function",provides:"delay"},function(){return{$:{delay:(function(){var l;l=k.extend([],(function(){var m;m=function(){if(this.length){return this.shift()()}};return{add:function(p,r){var o,q;p.order=r+k.now;for(o=0,q=this.length;0<=q?o<q:o>q;0<=q?o++:o--){if(this[o].order>p.order){this.splice(o,0,p);break}}setTimeout(m,r);return this},cancel:function(o){var n,p;for(n=0,p=this.length;0<=p?n<p:n>p;0<=p?n++:n--){if(this[n]===o){this.splice(n,1);break}}return this}}})());return function(o,m){if(k.is("function",m)){l.add(m,o)}return{cancel:function(){return l.cancel(m)}}}})()},delay:function(o,l,m){if(m==null){m=this}return k.delay(o,k.bound(m,l))}}});k.plugin({provides:"core"},function(){var l;b(k,"now",{get:function(){return +(new Date)}});l=function(m,n){while(m<0){m+=n.length}return Math.min(m,n.length)};return{$:{log:d,assert:function(o,n){if(n==null){n=""}if(!o){throw new Error("assertion failed: "+n)}},coalesce:function(){var m;m=1<=arguments.length?g.call(arguments,0):[];return k(m).coalesce()}},eq:function(m){return k([this[l(m,this)]])},each:function(p){var n,o,m;for(o=0,m=this.length;o<m;o++){n=this[o];p.call(n,n)}return this},map:function(n){var m;return k((function(){var q,p,o;o=[];for(q=0,p=this.length;q<p;q++){m=this[q];o.push(n.call(m,m))}return o}).call(this))},reduce:function(r,o){var p,m,q,n;p=this;if(!(o!=null)){o=this[0];p=this.skip(1)}for(q=0,n=p.length;q<n;q++){m=p[q];o=r.call(m,o,m)}return o},union:function(o,q){var r,n,t,s,p,m;if(q==null){q=true}r=k();for(t=0,p=this.length;t<p;t++){n=this[t];if(!r.contains(n,q)){r.push(n)}}for(s=0,m=o.length;s<m;s++){n=o[s];if(!r.contains(n,q)){r.push(n)}}return r},distinct:function(m){if(m==null){m=true}return this.union(this,m)},intersect:function(n){var m;return k((function(){var q,p,o;o=[];for(q=0,p=this.length;q<p;q++){m=this[q];if(j.call(n,m)>=0){o.push(m)}}return o}).call(this))},contains:function(o,m){var n;if(m==null){m=true}return((function(){var r,q,p;p=[];for(r=0,q=this.length;r<q;r++){n=this[r];p.push((m&&n===o)||(!m&&n===o))}return p}).call(this)).reduce((function(q,p){return q||p}),false)},count:function(o,m){var n;if(m==null){m=true}return k((function(){var r,q,p;p=[];for(r=0,q=this.length;r<q;r++){n=this[r];if((o===void 0)||(m&&n===o)||(!m&&n===o)){p.push(1)}}return p}).call(this)).sum()},coalesce:function(){var n,o,m,p;for(o=0,m=this.length;o<m;o++){n=this[o];if((p=k.type(n))==="array"||p==="bling"){n=k(n).coalesce()}if(n!=null){return n}}return null},swap:function(n,m){var o;n=l(n,this);m=l(m,this);if(n!==m){o=[this[m],this[n]],this[n]=o[0],this[m]=o[1]}return this},shuffle:function(){var m;m=this.length-1;while(m>=0){this.swap(--m,Math.floor(Math.random()*m))}return this},select:(function(){var n,m;n=function(o){return function(){var p;if(k.is("function",p=this[o])){return k.bound(this,p)}else{return p}}};return m=function(q){var o;if((o=q.indexOf("."))>-1){return this.select(q.substr(0,o)).select(q.substr(o+1))}else{return this.map(n(q))}}})(),or:function(m){var n,o;for(n=0,o=this.length;0<=o?n<o:n>o;0<=o?n++:n--){this[n]||(this[n]=m)}return this},zap:function(r,m){var q,o,n;o=r.lastIndexOf(".");if(o>0){q=r.substr(0,o);n=r.substr(o+1);this.select(q).zap(n,m);return this}switch(k.type(m)){case"array":case"bling":this.each(function(){return this[r]=m[++o%m.length]});break;case"function":this.zap(r,this.select(r).map(m));break;default:this.each(function(){return this[r]=m})}return this},take:function(p){var m,o;if(p==null){p=1}m=Math.min(p,this.length);return k((function(){var n;n=[];for(o=0;0<=m?o<m:o>m;0<=m?o++:o--){n.push(this[o])}return n}).call(this))},skip:function(p){var m,o;if(p==null){p=0}o=Math.max(0,p|0);return k((function(){var q,n;n=[];for(m=o,q=this.length;o<=q?m<q:m>q;o<=q?m++:m--){n.push(this[m])}return n}).call(this))},first:function(m){if(m==null){m=1}if(m===1){return this[0]}else{return this.take(m)}},last:function(m){if(m==null){m=1}if(m===1){return this[this.length-1]}else{return this.skip(this.length-m)}},slice:function(o,m){var n;if(o==null){o=0}if(m==null){m=this.length}o=l(o,this);m=l(m,this);return k((function(){var p;p=[];for(n=o;o<=m?n<m:n>m;o<=m?n++:n--){p.push(this[n])}return p}).call(this))},extend:function(m){var o,p,n;for(p=0,n=m.length;p<n;p++){o=m[p];this.push(o)}return this},push:function(m){Array.prototype.push.call(this,m);return this},filter:function(n){var m;m=(function(){switch(k.type(n)){case"string":return function(o){return o.matchesSelector(n)};case"regexp":return function(o){return n.test(o)};case"function":return n;default:throw new Error("unsupported type passed to filter: "+(k.type(n)))}})();return k(Array.prototype.filter.call(this,m))},matches:function(m){return this.select("matchesSelector").call(m)},querySelectorAll:function(m){return this.filter("*").reduce(function(n,o){return n.extend(o.querySelectorAll(m))},k())},weave:function(m){var q,n,p,o;q=k();for(n=p=this.length-1;p<=0?n<=0:n>=0;p<=0?n++:n--){q[(n*2)+1]=this[n]}for(n=0,o=m.length;0<=o?n<o:n>o;0<=o?n++:n--){q[n*2]=m[n]}return q},fold:function(p){var m,o,q;q=this.length;m=k((function(){var r,n;n=[];for(o=0,r=q-1;o<r;o+=2){n.push(p.call(this,this[o],this[o+1]))}return n}).call(this));if((q%2)===1){m.push(p.call(this,this[q-1],void 0))}return m},flatten:function(){var n,q,p,s,r,o,m;n=k();for(s=0,o=this.length;s<o;s++){q=this[s];for(r=0,m=q.length;r<m;r++){p=q[r];n.push(p)}}return n},call:function(){return this.apply(null,arguments)},apply:function(n,m){return this.map(function(){if(k.is("function",this)){return this.apply(n,m)}else{return this}})},log:function(m){if(m){k.log(m,this,this.length+" items")}else{k.log(this,this.length+" items")}return this},toArray:function(){this.__proto__=Array.prototype;return this}}});k.plugin({provides:"math"},function(){return{$:{range:function(o,l,n){var m;if(n==null){n=1}if(l<o&&n>0){n*=-1}return k((function(){var q,p;p=[];for(m=0,q=Math.ceil((l-o)/n);0<=q?m<q:m>q;0<=q?m++:m--){p.push(o+(m*n))}return p})())},zeros:function(m){var l;return k((function(){var n;n=[];for(l=0;0<=m?l<m:l>m;0<=m?l++:l--){n.push(0)}return n})())},ones:function(m){var l;return k((function(){var n;n=[];for(l=0;0<=m?l<m:l>m;0<=m?l++:l--){n.push(1)}return n})())}},floats:function(){return this.map(parseFloat)},ints:function(){return this.map(function(){return parseInt(this,10)})},px:function(l){return this.ints().map(function(){return k.px(this,l)})},min:function(){return this.reduce(function(l){return Math.min(this,l)})},max:function(){return this.reduce(function(l){return Math.max(this,l)})},mean:function(){return this.sum()/this.length},sum:function(){return this.reduce(function(l){return l+this})},squares:function(){return this.map(function(){return this*this})},magnitude:function(){return Math.sqrt(this.floats().squares().sum())},scale:function(l){return this.map(function(){return l*this})},add:function(m){var l;switch(k.type(m)){case"number":return this.map(function(){return m+this});case"bling":case"array":return k((function(){var o,n;n=[];for(l=0,o=Math.min(this.length,m.length)-1;0<=o?l<o:l>o;0<=o?l++:l--){n.push(this[l]+m[l])}return n}).call(this))}},normalize:function(){return this.scale(1/this.magnitude())}}});k.plugin({depends:"function",provides:"string"},function(){k.type.extend({unknown:{string:function(l){var m;return(m=typeof l.toString==="function"?l.toString():void 0)!=null?m:String(l)}},"null":{string:function(){return"null"}},undefined:{string:function(){return"undefined"}},string:{string:k.identity},array:{string:function(m){var l;return"["+((function(){var p,o,n;n=[];for(p=0,o=m.length;p<o;p++){l=m[p];n.push(k.toString(l))}return n})()).join(",")+"]"}},object:{string:function(n){var m,l;return"{"+((function(){var p,o;o=[];for(l=0,p=n.length;l<p;l++){m=n[l];o.push(""+m+":"+(k.toString(l)))}return o})()).join(", ")+"}"}},number:{string:function(l){switch(true){case l.precision!=null:return l.toPrecision(l.precision);case l.fixed!=null:return l.toFixed(l.fixed);default:return String(l)}}}});return{$:{toString:function(l){return k.type.lookup(l).string(l)},px:function(l,m){if(m==null){m=0}return(l!=null)&&(parseInt(l,10)+(m|0))+"px"},capitalize:function(l){return(l.split(" ").map(function(m){return m[0].toUpperCase()+m.substring(1).toLowerCase()})).join(" ")},dashize:function(m){var p,n,l,o;l="";for(n=0,o=(m!=null?m.length:void 0)|0;0<=o?n<o:n>o;0<=o?n++:n--){p=m.charCodeAt(n);if((91>p&&p>64)){p+=32;l+="-"}l+=String.fromCharCode(p)}return l},camelize:function(l){var m;l.split("-");while((m=l!=null?l.indexOf("-"):void 0)>-1){l=k.stringSplice(l,m,m+2,l[m+1].toUpperCase())}return l},padLeft:function(l,o,m){if(m==null){m=" "}while(l.length<o){l=m+l}return l},padRight:function(l,o,m){if(m==null){m=" "}while(l.length<o){l=l+m}return l},stringCount:function(p,l,o,q){var m;if(o==null){o=0}if(q==null){q=0}if((m=p.indexOf(l,o))>o-1){return k.count(p,l,m+1,q+1)}else{return q}},stringSplice:function(p,o,m,t){var l,r,q;r=p.length;l=m;if(l<0){l+=r}q=o;if(q<0){q+=r}return p.substring(0,q)+t+p.substring(l)},checksum:function(o){var m,l,n,p;m=1;l=0;for(n=0,p=o.length;0<=p?n<p:n>p;0<=p?n++:n--){m=(m+o.charCodeAt(n))%65521;l=(l+m)%65521}return(l<<16)|m},stringBuilder:function(){var l;var m=this;if(k.is("window",this)){return new k.stringBuilder()}l=[];this.length=0;this.append=function(n){l.push(n);return m.length+=(n!=null?n.toString().length:void 0)|0};this.prepend=function(n){l.splice(0,0,n);return m.length+=(n!=null?n.toString().length:void 0)|0};this.clear=function(){var n;n=m.toString();l=[];m.length=0;return n};this.toString=function(){return l.join("")};return this}},toString:function(){return k.toString(this)}}});k.plugin({provides:"function",depends:"hash"},function(){return{$:{identity:function(l){return l},not:function(l){return function(){var m;m=1<=arguments.length?g.call(arguments,0):[];return !l.apply(this,m)}},compose:function(m,l){return function(n){var o;return m.call(o,(o=l.call(n,n)))}},and:function(m,l){return function(n){return l.call(n,n)&&m.call(n,n)}},once:function(l,m){if(m==null){m=1}l.n=m;return function(){var n;n=1<=arguments.length?g.call(arguments,0):[];if(l.n-->0){return l.apply(this,n)}}},bound:function(m,o,l){var n;if(l==null){l=[]}if(k.is("function",o.bind)){l.splice(0,0,m);n=o.bind.apply(o,l)}else{n=function(){var p;p=1<=arguments.length?g.call(arguments,0):[];return o.apply(m,l(l.length?void 0:p))}}return k.extend(n,{toString:function(){return"bound-method of "+m+"."+o.name}})},memoize:function(m){var l;l={};return function(){var o,n,p;o=1<=arguments.length?g.call(arguments,0):[];return(p=l[n=k.hash(o)])!=null?p:l[n]=m.apply(this,o)}}}}});k.plugin({provides:"trace",depends:"function,type"},function(){k.type.extend({unknown:{trace:k.identity},object:{trace:function(r,p,n){var m,q,l,s;s=Object.keys(r);for(q=0,l=s.length;q<l;q++){m=s[q];r[m]=k.trace(r[m],""+p+"."+m,n)}return r}},array:{trace:function(p,m,l){var n,q;for(n=0,q=p.length;0<=q?n<q:n>q;0<=q?n++:n--){p[n]=k.trace(p[n],""+m+"["+n+"]",l)}return p}},"function":{trace:function(o,m,l){var n;n=function(){var p;p=1<=arguments.length?g.call(arguments,0):[];l(""+(this.name||k.type(this))+"."+(m||o.name)+"(",p,")");return o.apply(this,p)};l("Trace: "+(m||o.name)+" created.");n.toString=o.toString;return n}}});return{$:{trace:function(n,m,l){return k.type.lookup(n).trace(n,m,l)}},trace:function(m,l){return this.map(function(){return k.trace(this,m,l)})}}});k.plugin({provides:"hash",depends:"type"},function(){k.type.extend({unknown:{hash:function(l){return k.checksum(k.toString(l))}},object:{hash:function(m){var l;return((function(){var n;n=[];for(l in m){n.push(k.hash(m[l]))}return n})())+k.hash(Object.keys(m))}},array:{hash:function(m){var l;return((function(){var p,o,n;n=[];for(p=0,o=x.length;p<o;p++){l=x[p];n.push(k.hash(l))}return n})()).reduce(function(o,n){return o+n})}},bool:{hash:function(l){return parseInt(l?1:void 0)}}});return{$:{hash:function(l){return k.type.lookup(l).hash(l)}},hash:function(){return k.hash(this)}}});k.plugin({provides:"pubsub"},function(){var m,l,o,n;o={};m=function(){var q,t,s,r,p,u;t=arguments[0],q=2<=arguments.length?g.call(arguments,1):[];u=(o[t]||(o[t]=[]));for(r=0,p=u.length;r<p;r++){s=u[r];s.apply(null,q)}return this};l=function(q,p){(o[q]||(o[q]=[])).push(p);return p};n=function(s,r){var p,q;if(!(r!=null)){return o[s]=[]}else{p=(o[s]||(o[s]=[]));if((q=p.indexOf(r))>-1){return p.splice(q,q)}}};return{$:{publish:m,subscribe:l,unsubscribe:n}}});k.plugin({provides:"throttle",depends:"core"},function(){return{$:{throttle:function(m,o,l){if(o==null){o=250}if(l==null){l=0}return function(){var n,p;n=1<=arguments.length?g.call(arguments,0):[];p=k.now-l;if(p>o){l+=p;return m.apply(this,n)}return null}},debounce:function(m,o,l){if(o==null){o=250}if(l==null){l=0}return function(){var n,p;n=1<=arguments.length?g.call(arguments,0):[];l+=(p=k.now-l);return m.apply(this,n(p>o?void 0:null))}}}}});k.plugin({provides:"EventEmitter"},function(){var l;return{$:{EventEmitter:l=(function(){function m(){this.__event={}}m.prototype.addListener=function(p,o){var n;((n=this.__event)[p]||(n[p]=[])).push(o);return this.emit("newListener",p,o)};m.prototype.on=function(o,n){return this.addListener(o,n)};m.prototype.once=function(p,n){var o;return this.addListener(p,(o=function(){var q;q=1<=arguments.length?g.call(arguments,0):[];this.removeListener(o);return n.apply(null,q)}))};m.prototype.removeListener=function(q,p){var n,o;if((n=((o=this.__event)[q]||(o[q]=[])).indexOf(p))>-1){return this.__event[q].splice(n,1)}};m.prototype.removeAllListeners=function(n){return this.__event[n]=[]};m.prototype.setMaxListeners=function(o){};m.prototype.listeners=function(n){return this.__event[n]};m.prototype.emit=function(){var o,s,r,p,q,n,t;s=arguments[0],o=2<=arguments.length?g.call(arguments,1):[];t=((p=this.__event)[s]||(p[s]=[]));for(q=0,n=t.length;q<n;q++){r=t[q];r.apply(this,o)}return null};return m})()}}});if((typeof window!=="undefined"&&window!==null?window:global).document!=null){k.plugin({depends:"function",provides:"dom"},function(){var r,o,n,m,p,q,l;k.type.register("nodelist",{match:function(s){return(s!=null)&&k.isType("NodeList",s)},hash:function(t){var s;return k((function(){var w,v,u;u=[];for(w=0,v=x.length;w<v;w++){s=x[w];u.push(k.hash(s))}return u})()).sum()},array:k.identity,string:function(s){return"{nodelist:"+k(s).select("nodeName").join(",")+"}"},node:function(s){return k(s).toFragment()}});k.type.register("node",{match:function(s){return(s!=null?s.nodeType:void 0)>0},hash:function(s){return k.checksum(s.nodeName)+k.hash(s.attributes)+k.checksum(s.innerHTML)},string:function(s){return s.toString()},node:k.identity});k.type.register("fragment",{match:function(s){return(s!=null?s.nodeType:void 0)===11},hash:function(t){var s;return k((function(){var w,v,y,u;y=t.childNodes;u=[];for(w=0,v=y.length;w<v;w++){s=y[w];u.push(k.hash(s))}return u})()).sum()},string:function(s){return s.toString()},node:k.identity});k.type.register("html",{match:function(u){var t;return typeof u==="string"&&(t=u.trimLeft())[0]==="<"&&t[t.length-1]===">"},node:function(t){var s;return k.type.lookup(s=a.HTML.parse(t)).node(s)},array:function(t,u){var s;return k.type.lookup(s=a.HTML.parse(t)).array(s,u)}});k.type.extend({unknown:{node:function(){return null}},bling:{node:function(s){return s.toFragment()}},string:{node:function(s){return k(s).toFragment()},array:function(s,t){return typeof t.querySelectorAll==="function"?t.querySelectorAll(s):void 0}},"function":{node:function(s){return k(s.toString()).toFragment()}}});q=function(s){var t;if(!(s.parentNode!=null)){t=document.createDocumentFragment();t.appendChild(s)}return s};o=function(t,s){return q(t).parentNode.insertBefore(s,t)};r=function(t,s){return q(t).parentNode.insertBefore(s,t.nextSibling)};l=function(s){return k.type.lookup(s).node(s)};m=null;n=function(s){return function(){return window.getComputedStyle(this,null).getPropertyValue(s)}};p=function(s){return function(t){if(t!=null){return this.css(s,t)}else{return this.rect().select(s)}}};return{$:{HTML:{parse:function(t){var w,v,s,y,u;(u=document.createElement("div")).innerHTML=t;if(y=(w=u.childNodes).length===1){return u.removeChild(w[0])}v=document.createDocumentFragment();for(s=0;0<=y?s<y:s>y;0<=y?s++:s--){v.appendChild(u.removeChild(w[0]))}return v},stringify:function(u){var t,s;switch(k.type(u)){case"string":case"html":return u;case"node":case"fragment":t=document.createElement("div");t.appendChild((u=u.cloneNode(true)));s=t.innerHTML;t.removeChild(u);return s;default:return"HTML.stringify of unknown type: "+k.type(u)}},escape:function(t){var s;m||(m=k("<div>&nbsp;</div>").child(0));s=m.zap("data",t).select("parentNode.innerHTML").first();m.zap("data","");return s}}},html:function(s){switch(k.type(s)){case"undefined":case"null":return this.select("innerHTML");case"string":return this.zap("innerHTML",s);case"bling":return this.html(s.toFragment());case"node":return this.each(function(){var t;this.replaceChild(this.childNodes[0],s);t=[];while(this.childNodes.length>1){t.push(this.removeChild(this.childNodes[1]))}return t})}},append:function(s){s=l(s);return this.each(function(){return this.appendChild(s.cloneNode(true))})},appendTo:function(s){var u,t;u=this.map(function(){return this.cloneNode(true)});t=0;k(s).each(function(){return this.appendChild(u[t++])});return u},prepend:function(s){if(s!=null){s=l(s);this.take(1).each(function(){return o(this.childNodes[0],s)});this.skip(1).each(function(){return o(this.childNodes[0],s.cloneNode(true))})}return this},prependTo:function(s){if(s!=null){k(s).prepend(this)}return this},before:function(s){if(s!=null){s=l(s);this.take(1).each(function(){return o(this,s)});this.skip(1).each(function(){return o(this,s.cloneNode(true))})}return this},after:function(s){if(s!=null){s=l(s);this.take(1).each(function(){return r(this,s)});this.skip(1).each(function(){return r(this,s.cloneNode(true))})}return this},wrap:function(s){s=l(s);if(k.is("fragment",s)){throw new Error("cannot wrap with a fragment")}return this.each(function(v){var t,u;switch(k.type(v)){case"fragment":return s.appendChild(v);case"node":u=v.parentNode;if(!u){return s.appendChild(v)}else{t=document.createElement("dummy");s.appendChild(u.replaceChild(t,v));return u.replaceChild(s,t)}}})},unwrap:function(){return this.each(function(){if(this.parentNode&&this.parentNode.parentNode){return this.parentNode.parentNode.replaceChild(this,this.parentNode)}else{if(this.parentNode){return this.parentNode.removeChild(this)}}})},replace:function(u){var s,t;u=l(u);s=k();t=0;this.take(1).each(function(){var v;if((v=this.parentNode)!=null){v.replaceChild(u,this)}return s[t++]=u});this.skip(1).each(function(){var w,v;w=u.cloneNode(true);if((v=this.parentNode)!=null){v.replaceChild(w,this)}return s[t++]=w});return s},attr:function(s,t){switch(t){case void 0:return this.select("getAttribute").call(s,t);case null:return this.select("removeAttribute").call(s,t);default:this.select("setAttribute").call(s,t);return this}},data:function(t,s){t="data-"+(k.dashize(t));return this.attr(t,s)},addClass:function(s){return this.removeClass(s).each(function(){var t;t=this.className.split(" ").filter(function(u){return u!==""});t.push(s);return this.className=t.join(" ")})},removeClass:function(s){var t;t=function(u){return u!==s};return this.each(function(){var v,u;v=(u=this.className)!=null?u.split(" ").filter(t).join(" "):void 0;if(v.length===0){return this.removeAttribute("class")}})},toggleClass:function(s){var t;t=function(u){return u!==s};return this.each(function(){var w,u,v;u=this.className.split(" ");v=k.not(k.isEmpty);if(u.indexOf(s)>-1){v=k.and(t,v)}else{u.push(s)}w=u.filter(v).join(" ");this.className=w;if(w.length===0){return this.removeAttribute("class")}})},hasClass:function(s){return this.select("className.split").call(" ").select("indexOf").call(s).map(function(t){return t>-1})},text:function(s){if(s!=null){return this.zap("textContent",s)}return this.select("textContent")},val:function(s){if(s!=null){return this.zap("value",s)}return this.select("value")},css:function(y,B){var A,z,s,C,t,w,u;if((B!=null)||k.is("object",y)){w=this.select("style.setProperty");if(k.is("object",y)){for(z in y){w.call(z,y[z],"")}}else{if(k.is("string",B)){w.call(y,B,"")}else{if(k.is("array",B)){for(z=0,u=s=Math.max(B.length,C=w.len());0<=u?z<u:z>u;0<=u?z++:z--){w[z%C](y,B[z%s],"")}}}}return this}else{A=this.map(n(y));t=this.select("style").select(y);return t.weave(A).fold(function(v,D){return v||D})}},defaultCss:function(t,s){var u,y,w;y=this.selector;w="";if(k.is("string",t)){if(k.is("string",s)){w+=""+y+" { "+t+": "+s+" } "}else{throw Error("defaultCss requires a value with a string key")}}else{if(k.is("object",t)){for(u in t+"} "){w+=(""+y+" { ")+(""+u+": "+t[u]+"; ")}}}k("<style></style>").text(w).appendTo("head");return this},rect:function(){return this.select("getBoundingClientRect").call()},width:p("width"),height:p("height"),top:p("top"),left:p("left"),bottom:p("bottom"),right:p("right"),position:function(t,s){switch(true){case !(t!=null):return this.rect();case !(s!=null):return this.css("left",k.px(t));default:return this.css({top:k.px(s),left:k.px(t)})}},scrollToCenter:function(){document.body.scrollTop=this[0].offsetTop-(window.innerHeight/2);return this},child:function(s){return this.select("childNodes").map(function(){return this[s<0?s+this.length:s]})},parents:function(){return this.map(function(){var s;s=this;return k((function(){var t;t=[];while(s=s!=null?s.parentNode:void 0){t.push(s)}return t})())})},prev:function(){return this.map(function(){var s;s=this;return k((function(){var t;t=[];while(s=s!=null?s.previousSibling:void 0){t.push(s)}return t})())})},next:function(){return this.map(function(){var s;s=this;return k((function(){var t;t=[];while(s=s!=null?s.nextSibling:void 0){t.push(s)}return t})())})},remove:function(){return this.each(function(){var s;return(s=this.parentNode)!=null?s.removeChild(this):void 0})},find:function(s){return this.filter("*").map(function(){return k(s,this)}).flatten()},clone:function(s){if(s==null){s=true}return this.map(function(){if(k.is("node",this)){return this.cloneNode(s)}})},toFragment:function(){var s;if(this.length>1){s=document.createDocumentFragment();this.map(l).map(k.bound(s,s.appendChild));return s}return l(this[0])}}})}k.plugin({depends:"dom"},function(){var p,l,n,t,q,o,s,r,m;p=", ";n={slow:700,medium:500,normal:300,fast:100,instant:0,now:0};l=/(?:scale(?:3d)*|translate(?:[XYZ]|3d)*|rotate(?:[XYZ]|3d)*)/;m=30;t=document.createElement("div").style;q="transform";s="transition-property";o="transition-duration";r="transition-timing-function";if("WebkitTransform" in t){q="-webkit-transform";s="-webkit-transition-property";o="-webkit-transition-duration";r="-webkit-transition-timing-function"}else{if("MozTransform" in t){q="-moz-transform";s="-moz-transition-property";o="-moz-transition-duration";r="-moz-transition-timing-function"}else{if("OTransform" in t){q="-o-transform";s="-o-transition-property";o="-o-transition-duration";r="-o-transition-timing-function"}}}return{$:{duration:function(u){var v;v=n[u];if(v!=null){return v}return parseFloat(u)}},transform:function(A,u,z,C){var y,v,w,D,B,E;if(k.is("function",u)){C=u;u=z=null}else{if(k.is("function",z)){C=z;z=null}}if(u==null){u="normal"}z||(z="ease");v=k.duration(u)+"ms";B=[];E="";y={};for(w in A){if(l.test(w)){D=A[w];if(D.join){D=k(D).px().join(p)}else{if(D.toString){D=D.toString()}}E+=" "+w+"("+D+")"}else{y[w]=A[w]}}for(w in y){B.push(w)}if(E){B.push(q)}y[s]=B.join(p);y[o]=B.map(function(){return v}).join(p);y[r]=B.map(function(){return z}).join(p);if(E){y[q]=E}this.css(y);return this.delay(v,C)},hide:function(u){return this.each(function(){if(this.style){this._display="";if(this.style.display===!"none"){this._display=this.syle.display}return this.style.display="none"}}).trigger("hide".delay(m,u))},show:function(u){return this.each(function(){if(this.style){this.style.display=this._display;return delete this._display}}).trigger("show".delay(m,u))},toggle:function(u){return this.weave(this.css("display")).fold(function(w,v){if(w==="none"){v.style.display=v._display||"";delete v._display;k(v).trigger("show")}else{v._display=w;v.style.display="none";k(v).trigger("hide")}return v}).delay(m,u)},fadeIn:function(u,v){return this.css("opacity","0.0").show(function(){return this.transform({opacity:"1.0",translate3d:[0,0,0]},u,v)})},fadeOut:function(v,z,u,w){if(u==null){u=0}if(w==null){w=0}return this.transform({opacity:"0.0",translate3d:[u,w,0]},v,function(){return this.hide(z)})},fadeLeft:function(u,v){return this.fadeOut(u,v,"-"+this.width().first(),0)},fadeRight:function(u,v){return this.fadeOut(u,v,this.width().first(),0)},fadeUp:function(u,v){return this.fadeOut(u,v,0,"-"+this.height().first())},fadeDown:function(u,v){return this.fadeOut(u,v,0,this.height().first())}}});k.plugin({depends:"dom"},function(){var l;l=function(n){var m,p;p=JSON.parse(JSON.stringify(n));return((function(){var o;o=[];for(m in p){o.push(""+m+"="+(escape(p[m])))}return o})()).join("&")};k.type.register("http",{match:function(m){return k.isType("XMLHttpRequest",m)},array:function(m){return[m]}});return{$:{http:function(m,n){var o;if(n==null){n={}}o=new XMLHttpRequest();if(k.is("function",n)){n={success:k.bound(o,n)}}n=k.extend({method:"GET",data:null,state:k.identity,success:k.identity,error:k.identity,async:true,asBlob:false,timeout:0,followRedirects:false,withCredentials:false},n);n.state=k.bound(o,n.state);n.success=k.bound(o,n.success);n.error=k.bound(o,n.error);if(n.data&&n.method==="GET"){m+="?"+l(n.data)}else{if(n.data&&n.method==="POST"){n.data=l(n.data)}}o.open(n.method,m,n.async);o=k.extend(o,{asBlob:n.asBlob,timeout:n.timeout,followRedirects:n.followRedirects,withCredentials:n.withCredentials,onreadystatechange:function(){if(typeof n.state==="function"){n.state()}if(o.readyState===4){if(o.status===200){return n.success(o.responseText)}else{return n.error(o.status,o.statusText)}}}});o.send(n.data);return k(o)},post:function(m,n){if(n==null){n={}}if(k.is("function",n)){n={success:n}}n.method="POST";return k.http(m,n)},get:function(m,n){if(n==null){n={}}if(k.is("function",n)){n={success:n}}n.method="GET";return k.http(m,n)}}}});k.plugin({depends:"dom,function,core",provides:"event"},function(){var n,s,l,o,q,m,r,p;n=/,* +/;o=["mousemove","mousedown","mouseup","mouseover","mouseout","blur","focus","load","unload","reset","submit","keyup","keydown","change","abort","cut","copy","paste","selection","drag","drop","orientationchange","touchstart","touchmove","touchend","touchcancel","gesturestart","gestureend","gesturecancel","hashchange"];l=function(t){return function(u){return this.bind(t,u)(k.is("function",u)?void 0:this.trigger(t,u))}};q=function(t,v,u,y,w){return k(v).bind(u,w).each(function(){var A,z;return((A=((z=(this.__alive__||(this.__alive__={})))[t]||(z[t]={})))[u]||(A[u]={}))[y]=w})};p=function(t,u,y,w){var v;v=k(u);return v.each(function(){var A,z,B;A=(this.__alive__||(this.__alive__={}));z=(A[t]||(A[t]={}));B=(z[y]||(z[y]={}));v.unbind(y,B[w]);return delete B[w]})};r=k.once(function(){k(document).trigger("ready").unbind("ready");if(typeof document.removeEventListener==="function"){document.removeEventListener("DOMContentLoaded",r,false)}return typeof window.removeEventListener==="function"?window.removeEventListener("load",r,false):void 0});s=k.once(function(){if(typeof document.addEventListener==="function"){document.addEventListener("DOMContentLoaded",r,false)}return typeof window.addEventListener==="function"?window.addEventListener("load",r,false):void 0});s();m={bind:function(v,u){var w,t;w=(v||"").split(n);t=function(y){m=u.apply(this,arguments);if(m===false){y.preventAll()}return m};return this.each(function(){var A,B,z,y;y=[];for(B=0,z=w.length;B<z;B++){A=w[B];y.push(this.addEventListener(A,t,false))}return y})},unbind:function(u,t){var v;v=(u||"").split(n);return this.each(function(){var z,A,y,w;w=[];for(A=0,y=v.length;A<y;A++){z=v[A];w.push(this.removeEventListener(z,t,null))}return w})},once:function(z,y){var A,v,w,u,t;A=(z||"").split(n);t=[];for(w=0,u=A.length;w<u;w++){v=A[w];t.push(this.bind(v,function(B){y.call(this,B);return this.removeEventListener(B.type,arguments.callee,null)}))}return t},cycle:function(){var B,A,z,u,v,y,w,t;z=arguments[0],u=2<=arguments.length?g.call(arguments,1):[];B=(z||"").split(n);y=u.length;A=function(C){if(C==null){C=-1}return function(D){return u[C=++C%y].call(this,D)}};for(w=0,t=B.length;w<t;w++){v=B[w];this.bind(v,A())}return this},trigger:function(u,v){var A,w,z,t,B;if(v==null){v={}}v=k.extend({bubbles:true,cancelable:true},v);B=(u||"").split(n);for(z=0,t=B.length;z<t;z++){w=B[z];if(w==="click"||w==="mousemove"||w==="mousedown"||w==="mouseup"||w==="mouseover"||w==="mouseout"){A=document.createEvent("MouseEvents");v=k.extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,button:0,relatedTarget:null},v);A.initMouseEvent(w,v.bubbles,v.cancelable,window,v.detail,v.screenX,v.screenY,v.clientX,v.clientY,v.ctrlKey,v.altKey,v.shiftKey,v.metaKey,v.button,v.relatedTarget)}else{if(w==="blur"||w==="focus"||w==="reset"||w==="submit"||w==="abort"||w==="change"||w==="load"||w==="unload"){A=document.createEvent("UIEvents");A.initUIEvent(w,v.bubbles,v.cancelable,window,1)}else{if(w==="touchstart"||w==="touchmove"||w==="touchend"||w==="touchcancel"){A=document.createEvent("TouchEvents");v=k.extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,touches:[],targetTouches:[],changedTouches:[],scale:1,rotation:0},v);A.initTouchEvent(w,v.bubbles,v.cancelable,window,v.detail,v.screenX,v.screenY,v.clientX,v.clientY,v.ctrlKey,v.altKey,v.shiftKey,v.metaKey,v.touches,v.targetTouches,v.changedTouches,v.scale,v.rotation)}else{if(w==="gesturestart"||w==="gestureend"||w==="gesturecancel"){A=document.createEvent("GestureEvents");v=k.extend({detail:1,screenX:0,screenY:0,clientX:0,clientY:0,ctrlKey:false,altKey:false,shiftKey:false,metaKey:false,target:null,scale:1,rotation:0},v);A.initGestureEvent(w,v.bubbles,v.cancelable,window,v.detail,v.screenX,v.screenY,v.clientX,v.clientY,v.ctrlKey,v.altKey,v.shiftKey,v.metaKey,v.target,v.scale,v.rotation)}else{A=document.createEvent("Events");A.initEvent(w,v.bubbles,v.cancelable);try{A=k.extend(A,v)}catch(y){}}}}}if(!A){continue}else{try{this.each(function(){return this.dispatchEvent(A)})}catch(y){d("dispatchEvent error:",y)}}}return this},live:function(y,w){var u,v,t;t=this.selector;u=this.context;v=function(z){return k(t,u).intersect(k(z.target).parents().first().union(k(z.target))).each(function(){return w.call(z.target=this,z)})};q(t,u,y,w,v);return this},die:function(u,t){k(this.context).unbind(u,p(this.selector,this.context,u,t));return this},liveCycle:function(){var w,t,u,v;w=arguments[0],t=2<=arguments.length?g.call(arguments,1):[];u=-1;v=t.length;return this.live(w,function(y){return t[u=++u%v].call(this,y)})},click:function(t){var u;if(t==null){t={}}if((u=this.css("cursor"))==="auto"||u===""){this.css("cursor","pointer")}if(k.is("function",t)){return this.bind("click",t)}else{return this.trigger("click",t)}},ready:function(t){if(r.n<=0){return t.call(this)}return this.bind("ready",t)}};o.forEach(function(t){return m[t]=l(t)});return m});return k.plugin({depends:"dom",provides:"lazy"},function(){var l;l=function(m,n){return k("head").append(k.extend(document.createElement(m),n))};return{$:{script:function(m){return l("script",{src:m})},style:function(m){return l("link",{href:m,rel:"stylesheet"})}}}})})(a)}).call(this);