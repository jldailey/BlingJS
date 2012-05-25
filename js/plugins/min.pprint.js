(function(){(function(a){return a.plugin(function(){var v,k,l,m,n,f,o,b,c,e,h,p,s,g,q,r,i,u,d,j,t;q=/!==|!=|!|\#|\%|\%=|\&|\&\&|\&\&=|&=|\*|\*=|\+|\+=|-|-=|->|\.{1,3}|\/|\/=|:|::|;|<<=|<<|<=|<|===|==|=|>>>=|>>=|>=|>>>|>>|>|\?|@|\[|\]|}|{|\^|\^=|\^\^|\^\^=|\|=|\|\|=|\|\||\||~/g;g="<span class='opr'>$&</span>";h=/\b[Ff]unction\b|\bvar\b|\.prototype\b|\.__proto__\b|\bString\b|\bArray\b|\bNumber\b|\bObject\b|\bbreak\b|\bcase\b|\bcontinue\b|\bdelete\b|\bdo\b|\bif\b|\belse\b|\bfinally\b|\binstanceof\b|\breturn\b|\bthrow\b|\btry\b|\btypeof\b|\btrue\b|\bfalse\b/g;e="<span class='kwd'>$&</span>";v=/\d+\.*\d*/g;s="<span class='num'>$&</span>";l=/\$(\(|\.)/g;k="<span class='bln'>$$</span>$1";t=/\t/g;j="&nbsp;&nbsp;";i=/\/\/.*?(?:\n|$)/;p=/\/\*(?:.|\n)*?\*\//;n=function(w){if(w){return"<span class='com'>"+w+"</span>"}else{return""}};r=function(w){if(w){return"<span class='str'>"+w+"</span>"}else{return""}};o=function(z,y){var x,w;x=z.indexOf('"',y);w=z.indexOf("'",y);if(x===-1){x=z.length}if(w===-1){w=z.length}if(x===w){return[null,-1]}if(x<w){return['"',x]}return["'",w]};m=function(x,w,z){var y;y=x.indexOf(z,w);while(x.charAt(y-1)==="\\"&&(0<y&&y<x.length)){y=x.indexOf(z,y+1)}return y};d=function(A){var z,y,w,C,B,x;z=0;C=A.length;x=[];if(!Object.IsString(A)){if(!Object.IsFunction(A.toString)){throw TypeError("invalid string argument to split_quoted")}else{A=A.toString();C=A.length}}while(z<C){B=o(A,z);y=B[1];if(y===-1){x.push(A.substring(z));break}x.push(A.substring(z,y));w=m(A,y+1,B[0]);if(w===-1){throw Error("unclosed quote: "+B[0]+" starting at "+y)}x.push(A.substring(y,w+1));z=w+1}return x};f=function(y){var x,w;x=y.match(i);w=y.match(p);if(x===w){return[-1,null]}if(x===null&&w!==null){return[w.index,w[0]]}if(x!==null&&w===null){return[x.index,x[0]]}if(w.index<x.index){return[w.index,w[0]]}return[x.index,x[0]]};u=function(A){var z,x,C,B,w,y;w=[];z=0;C=A.length;while(z<C){y=A.substring(z);B=f(y);x=B[0];if(x>-1){w.push(y.substring(0,x));w.push(B[1]);z+=x+B[1].length}else{w.push(y);break}}return w};b=function(x,w){return x.replace(q,g).replace(v,s).replace(h,e).replace(l,k).replace(t,j)+r(w)};c=function(w,x){return a(d(w)).fold(b).join("")+n(x)};return{name:"PrettyPrint",$:{prettyPrint:function(A,x){var w,z,y;if(Object.IsFunction(A)){A=A.toString()}if(!Object.IsString(A)){throw TypeError("prettyPrint requires a function or string to format, not '"+Object.Type(A)+"'")}if(a("style#prettyPrint").length===0){z="code.pp .bln { font-size: 17px; } ";x=Object.Extend({opr:"#880",str:"#008",com:"#080",kwd:"#088",num:"#808",bln:"#800"},x);for(w in x){z+="code.pp ."+w+" { color: "+x[w]+"; } "}a.synth("style#prettyPrint").text(z).appendTo("head")}return y="<code class='pp'>"+(a(u(A)).fold(c).join(""))+"</code>"}}}})})(Bling)}).call(this);