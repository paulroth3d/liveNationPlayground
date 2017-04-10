/*
//Filename:grunt_src/lib/underscore_1_8_3.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
//-- underscorejs.1.8.3.js

//     Underscore.js 1.8.3
//     http://underscorejs.org
//     (c) 2009-2015 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
//     Underscore may be freely distributed under the MIT license.
(function(){function n(n){function t(t,r,e,u,i,o){for(;i>=0&&o>i;i+=n){var a=u?u[i]:i;e=r(e,t[a],a,t)}return e}return function(r,e,u,i){e=b(e,i,4);var o=!k(r)&&m.keys(r),a=(o||r).length,c=n>0?0:a-1;return arguments.length<3&&(u=r[o?o[c]:c],c+=n),t(r,e,u,o,c,a)}}function t(n){return function(t,r,e){r=x(r,e);for(var u=O(t),i=n>0?0:u-1;i>=0&&u>i;i+=n)if(r(t[i],i,t))return i;return-1}}function r(n,t,r){return function(e,u,i){var o=0,a=O(e);if("number"==typeof i)n>0?o=i>=0?i:Math.max(i+a,o):a=i>=0?Math.min(i+1,a):i+a+1;else if(r&&i&&a)return i=r(e,u),e[i]===u?i:-1;if(u!==u)return i=t(l.call(e,o,a),m.isNaN),i>=0?i+o:-1;for(i=n>0?o:a-1;i>=0&&a>i;i+=n)if(e[i]===u)return i;return-1}}function e(n,t){var r=I.length,e=n.constructor,u=m.isFunction(e)&&e.prototype||a,i="constructor";for(m.has(n,i)&&!m.contains(t,i)&&t.push(i);r--;)i=I[r],i in n&&n[i]!==u[i]&&!m.contains(t,i)&&t.push(i)}var u=this,i=u._,o=Array.prototype,a=Object.prototype,c=Function.prototype,f=o.push,l=o.slice,s=a.toString,p=a.hasOwnProperty,h=Array.isArray,v=Object.keys,g=c.bind,y=Object.create,d=function(){},m=function(n){return n instanceof m?n:this instanceof m?void(this._wrapped=n):new m(n)};"undefined"!=typeof exports?("undefined"!=typeof module&&module.exports&&(exports=module.exports=m),exports._=m):u._=m,m.VERSION="1.8.3";var b=function(n,t,r){if(t===void 0)return n;switch(null==r?3:r){case 1:return function(r){return n.call(t,r)};case 2:return function(r,e){return n.call(t,r,e)};case 3:return function(r,e,u){return n.call(t,r,e,u)};case 4:return function(r,e,u,i){return n.call(t,r,e,u,i)}}return function(){return n.apply(t,arguments)}},x=function(n,t,r){return null==n?m.identity:m.isFunction(n)?b(n,t,r):m.isObject(n)?m.matcher(n):m.property(n)};m.iteratee=function(n,t){return x(n,t,1/0)};var _=function(n,t){return function(r){var e=arguments.length;if(2>e||null==r)return r;for(var u=1;e>u;u++)for(var i=arguments[u],o=n(i),a=o.length,c=0;a>c;c++){var f=o[c];t&&r[f]!==void 0||(r[f]=i[f])}return r}},j=function(n){if(!m.isObject(n))return{};if(y)return y(n);d.prototype=n;var t=new d;return d.prototype=null,t},w=function(n){return function(t){return null==t?void 0:t[n]}},A=Math.pow(2,53)-1,O=w("length"),k=function(n){var t=O(n);return"number"==typeof t&&t>=0&&A>=t};m.each=m.forEach=function(n,t,r){t=b(t,r);var e,u;if(k(n))for(e=0,u=n.length;u>e;e++)t(n[e],e,n);else{var i=m.keys(n);for(e=0,u=i.length;u>e;e++)t(n[i[e]],i[e],n)}return n},m.map=m.collect=function(n,t,r){t=x(t,r);for(var e=!k(n)&&m.keys(n),u=(e||n).length,i=Array(u),o=0;u>o;o++){var a=e?e[o]:o;i[o]=t(n[a],a,n)}return i},m.reduce=m.foldl=m.inject=n(1),m.reduceRight=m.foldr=n(-1),m.find=m.detect=function(n,t,r){var e;return e=k(n)?m.findIndex(n,t,r):m.findKey(n,t,r),e!==void 0&&e!==-1?n[e]:void 0},m.filter=m.select=function(n,t,r){var e=[];return t=x(t,r),m.each(n,function(n,r,u){t(n,r,u)&&e.push(n)}),e},m.reject=function(n,t,r){return m.filter(n,m.negate(x(t)),r)},m.every=m.all=function(n,t,r){t=x(t,r);for(var e=!k(n)&&m.keys(n),u=(e||n).length,i=0;u>i;i++){var o=e?e[i]:i;if(!t(n[o],o,n))return!1}return!0},m.some=m.any=function(n,t,r){t=x(t,r);for(var e=!k(n)&&m.keys(n),u=(e||n).length,i=0;u>i;i++){var o=e?e[i]:i;if(t(n[o],o,n))return!0}return!1},m.contains=m.includes=m.include=function(n,t,r,e){return k(n)||(n=m.values(n)),("number"!=typeof r||e)&&(r=0),m.indexOf(n,t,r)>=0},m.invoke=function(n,t){var r=l.call(arguments,2),e=m.isFunction(t);return m.map(n,function(n){var u=e?t:n[t];return null==u?u:u.apply(n,r)})},m.pluck=function(n,t){return m.map(n,m.property(t))},m.where=function(n,t){return m.filter(n,m.matcher(t))},m.findWhere=function(n,t){return m.find(n,m.matcher(t))},m.max=function(n,t,r){var e,u,i=-1/0,o=-1/0;if(null==t&&null!=n){n=k(n)?n:m.values(n);for(var a=0,c=n.length;c>a;a++)e=n[a],e>i&&(i=e)}else t=x(t,r),m.each(n,function(n,r,e){u=t(n,r,e),(u>o||u===-1/0&&i===-1/0)&&(i=n,o=u)});return i},m.min=function(n,t,r){var e,u,i=1/0,o=1/0;if(null==t&&null!=n){n=k(n)?n:m.values(n);for(var a=0,c=n.length;c>a;a++)e=n[a],i>e&&(i=e)}else t=x(t,r),m.each(n,function(n,r,e){u=t(n,r,e),(o>u||1/0===u&&1/0===i)&&(i=n,o=u)});return i},m.shuffle=function(n){for(var t,r=k(n)?n:m.values(n),e=r.length,u=Array(e),i=0;e>i;i++)t=m.random(0,i),t!==i&&(u[i]=u[t]),u[t]=r[i];return u},m.sample=function(n,t,r){return null==t||r?(k(n)||(n=m.values(n)),n[m.random(n.length-1)]):m.shuffle(n).slice(0,Math.max(0,t))},m.sortBy=function(n,t,r){return t=x(t,r),m.pluck(m.map(n,function(n,r,e){return{value:n,index:r,criteria:t(n,r,e)}}).sort(function(n,t){var r=n.criteria,e=t.criteria;if(r!==e){if(r>e||r===void 0)return 1;if(e>r||e===void 0)return-1}return n.index-t.index}),"value")};var F=function(n){return function(t,r,e){var u={};return r=x(r,e),m.each(t,function(e,i){var o=r(e,i,t);n(u,e,o)}),u}};m.groupBy=F(function(n,t,r){m.has(n,r)?n[r].push(t):n[r]=[t]}),m.indexBy=F(function(n,t,r){n[r]=t}),m.countBy=F(function(n,t,r){m.has(n,r)?n[r]++:n[r]=1}),m.toArray=function(n){return n?m.isArray(n)?l.call(n):k(n)?m.map(n,m.identity):m.values(n):[]},m.size=function(n){return null==n?0:k(n)?n.length:m.keys(n).length},m.partition=function(n,t,r){t=x(t,r);var e=[],u=[];return m.each(n,function(n,r,i){(t(n,r,i)?e:u).push(n)}),[e,u]},m.first=m.head=m.take=function(n,t,r){return null==n?void 0:null==t||r?n[0]:m.initial(n,n.length-t)},m.initial=function(n,t,r){return l.call(n,0,Math.max(0,n.length-(null==t||r?1:t)))},m.last=function(n,t,r){return null==n?void 0:null==t||r?n[n.length-1]:m.rest(n,Math.max(0,n.length-t))},m.rest=m.tail=m.drop=function(n,t,r){return l.call(n,null==t||r?1:t)},m.compact=function(n){return m.filter(n,m.identity)};var S=function(n,t,r,e){for(var u=[],i=0,o=e||0,a=O(n);a>o;o++){var c=n[o];if(k(c)&&(m.isArray(c)||m.isArguments(c))){t||(c=S(c,t,r));var f=0,l=c.length;for(u.length+=l;l>f;)u[i++]=c[f++]}else r||(u[i++]=c)}return u};m.flatten=function(n,t){return S(n,t,!1)},m.without=function(n){return m.difference(n,l.call(arguments,1))},m.uniq=m.unique=function(n,t,r,e){m.isBoolean(t)||(e=r,r=t,t=!1),null!=r&&(r=x(r,e));for(var u=[],i=[],o=0,a=O(n);a>o;o++){var c=n[o],f=r?r(c,o,n):c;t?(o&&i===f||u.push(c),i=f):r?m.contains(i,f)||(i.push(f),u.push(c)):m.contains(u,c)||u.push(c)}return u},m.union=function(){return m.uniq(S(arguments,!0,!0))},m.intersection=function(n){for(var t=[],r=arguments.length,e=0,u=O(n);u>e;e++){var i=n[e];if(!m.contains(t,i)){for(var o=1;r>o&&m.contains(arguments[o],i);o++);o===r&&t.push(i)}}return t},m.difference=function(n){var t=S(arguments,!0,!0,1);return m.filter(n,function(n){return!m.contains(t,n)})},m.zip=function(){return m.unzip(arguments)},m.unzip=function(n){for(var t=n&&m.max(n,O).length||0,r=Array(t),e=0;t>e;e++)r[e]=m.pluck(n,e);return r},m.object=function(n,t){for(var r={},e=0,u=O(n);u>e;e++)t?r[n[e]]=t[e]:r[n[e][0]]=n[e][1];return r},m.findIndex=t(1),m.findLastIndex=t(-1),m.sortedIndex=function(n,t,r,e){r=x(r,e,1);for(var u=r(t),i=0,o=O(n);o>i;){var a=Math.floor((i+o)/2);r(n[a])<u?i=a+1:o=a}return i},m.indexOf=r(1,m.findIndex,m.sortedIndex),m.lastIndexOf=r(-1,m.findLastIndex),m.range=function(n,t,r){null==t&&(t=n||0,n=0),r=r||1;for(var e=Math.max(Math.ceil((t-n)/r),0),u=Array(e),i=0;e>i;i++,n+=r)u[i]=n;return u};var E=function(n,t,r,e,u){if(!(e instanceof t))return n.apply(r,u);var i=j(n.prototype),o=n.apply(i,u);return m.isObject(o)?o:i};m.bind=function(n,t){if(g&&n.bind===g)return g.apply(n,l.call(arguments,1));if(!m.isFunction(n))throw new TypeError("Bind must be called on a function");var r=l.call(arguments,2),e=function(){return E(n,e,t,this,r.concat(l.call(arguments)))};return e},m.partial=function(n){var t=l.call(arguments,1),r=function(){for(var e=0,u=t.length,i=Array(u),o=0;u>o;o++)i[o]=t[o]===m?arguments[e++]:t[o];for(;e<arguments.length;)i.push(arguments[e++]);return E(n,r,this,this,i)};return r},m.bindAll=function(n){var t,r,e=arguments.length;if(1>=e)throw new Error("bindAll must be passed function names");for(t=1;e>t;t++)r=arguments[t],n[r]=m.bind(n[r],n);return n},m.memoize=function(n,t){var r=function(e){var u=r.cache,i=""+(t?t.apply(this,arguments):e);return m.has(u,i)||(u[i]=n.apply(this,arguments)),u[i]};return r.cache={},r},m.delay=function(n,t){var r=l.call(arguments,2);return setTimeout(function(){return n.apply(null,r)},t)},m.defer=m.partial(m.delay,m,1),m.throttle=function(n,t,r){var e,u,i,o=null,a=0;r||(r={});var c=function(){a=r.leading===!1?0:m.now(),o=null,i=n.apply(e,u),o||(e=u=null)};return function(){var f=m.now();a||r.leading!==!1||(a=f);var l=t-(f-a);return e=this,u=arguments,0>=l||l>t?(o&&(clearTimeout(o),o=null),a=f,i=n.apply(e,u),o||(e=u=null)):o||r.trailing===!1||(o=setTimeout(c,l)),i}},m.debounce=function(n,t,r){var e,u,i,o,a,c=function(){var f=m.now()-o;t>f&&f>=0?e=setTimeout(c,t-f):(e=null,r||(a=n.apply(i,u),e||(i=u=null)))};return function(){i=this,u=arguments,o=m.now();var f=r&&!e;return e||(e=setTimeout(c,t)),f&&(a=n.apply(i,u),i=u=null),a}},m.wrap=function(n,t){return m.partial(t,n)},m.negate=function(n){return function(){return!n.apply(this,arguments)}},m.compose=function(){var n=arguments,t=n.length-1;return function(){for(var r=t,e=n[t].apply(this,arguments);r--;)e=n[r].call(this,e);return e}},m.after=function(n,t){return function(){return--n<1?t.apply(this,arguments):void 0}},m.before=function(n,t){var r;return function(){return--n>0&&(r=t.apply(this,arguments)),1>=n&&(t=null),r}},m.once=m.partial(m.before,2);var M=!{toString:null}.propertyIsEnumerable("toString"),I=["valueOf","isPrototypeOf","toString","propertyIsEnumerable","hasOwnProperty","toLocaleString"];m.keys=function(n){if(!m.isObject(n))return[];if(v)return v(n);var t=[];for(var r in n)m.has(n,r)&&t.push(r);return M&&e(n,t),t},m.allKeys=function(n){if(!m.isObject(n))return[];var t=[];for(var r in n)t.push(r);return M&&e(n,t),t},m.values=function(n){for(var t=m.keys(n),r=t.length,e=Array(r),u=0;r>u;u++)e[u]=n[t[u]];return e},m.mapObject=function(n,t,r){t=x(t,r);for(var e,u=m.keys(n),i=u.length,o={},a=0;i>a;a++)e=u[a],o[e]=t(n[e],e,n);return o},m.pairs=function(n){for(var t=m.keys(n),r=t.length,e=Array(r),u=0;r>u;u++)e[u]=[t[u],n[t[u]]];return e},m.invert=function(n){for(var t={},r=m.keys(n),e=0,u=r.length;u>e;e++)t[n[r[e]]]=r[e];return t},m.functions=m.methods=function(n){var t=[];for(var r in n)m.isFunction(n[r])&&t.push(r);return t.sort()},m.extend=_(m.allKeys),m.extendOwn=m.assign=_(m.keys),m.findKey=function(n,t,r){t=x(t,r);for(var e,u=m.keys(n),i=0,o=u.length;o>i;i++)if(e=u[i],t(n[e],e,n))return e},m.pick=function(n,t,r){var e,u,i={},o=n;if(null==o)return i;m.isFunction(t)?(u=m.allKeys(o),e=b(t,r)):(u=S(arguments,!1,!1,1),e=function(n,t,r){return t in r},o=Object(o));for(var a=0,c=u.length;c>a;a++){var f=u[a],l=o[f];e(l,f,o)&&(i[f]=l)}return i},m.omit=function(n,t,r){if(m.isFunction(t))t=m.negate(t);else{var e=m.map(S(arguments,!1,!1,1),String);t=function(n,t){return!m.contains(e,t)}}return m.pick(n,t,r)},m.defaults=_(m.allKeys,!0),m.create=function(n,t){var r=j(n);return t&&m.extendOwn(r,t),r},m.clone=function(n){return m.isObject(n)?m.isArray(n)?n.slice():m.extend({},n):n},m.tap=function(n,t){return t(n),n},m.isMatch=function(n,t){var r=m.keys(t),e=r.length;if(null==n)return!e;for(var u=Object(n),i=0;e>i;i++){var o=r[i];if(t[o]!==u[o]||!(o in u))return!1}return!0};var N=function(n,t,r,e){if(n===t)return 0!==n||1/n===1/t;if(null==n||null==t)return n===t;n instanceof m&&(n=n._wrapped),t instanceof m&&(t=t._wrapped);var u=s.call(n);if(u!==s.call(t))return!1;switch(u){case"[object RegExp]":case"[object String]":return""+n==""+t;case"[object Number]":return+n!==+n?+t!==+t:0===+n?1/+n===1/t:+n===+t;case"[object Date]":case"[object Boolean]":return+n===+t}var i="[object Array]"===u;if(!i){if("object"!=typeof n||"object"!=typeof t)return!1;var o=n.constructor,a=t.constructor;if(o!==a&&!(m.isFunction(o)&&o instanceof o&&m.isFunction(a)&&a instanceof a)&&"constructor"in n&&"constructor"in t)return!1}r=r||[],e=e||[];for(var c=r.length;c--;)if(r[c]===n)return e[c]===t;if(r.push(n),e.push(t),i){if(c=n.length,c!==t.length)return!1;for(;c--;)if(!N(n[c],t[c],r,e))return!1}else{var f,l=m.keys(n);if(c=l.length,m.keys(t).length!==c)return!1;for(;c--;)if(f=l[c],!m.has(t,f)||!N(n[f],t[f],r,e))return!1}return r.pop(),e.pop(),!0};m.isEqual=function(n,t){return N(n,t)},m.isEmpty=function(n){return null==n?!0:k(n)&&(m.isArray(n)||m.isString(n)||m.isArguments(n))?0===n.length:0===m.keys(n).length},m.isElement=function(n){return!(!n||1!==n.nodeType)},m.isArray=h||function(n){return"[object Array]"===s.call(n)},m.isObject=function(n){var t=typeof n;return"function"===t||"object"===t&&!!n},m.each(["Arguments","Function","String","Number","Date","RegExp","Error"],function(n){m["is"+n]=function(t){return s.call(t)==="[object "+n+"]"}}),m.isArguments(arguments)||(m.isArguments=function(n){return m.has(n,"callee")}),"function"!=typeof/./&&"object"!=typeof Int8Array&&(m.isFunction=function(n){return"function"==typeof n||!1}),m.isFinite=function(n){return isFinite(n)&&!isNaN(parseFloat(n))},m.isNaN=function(n){return m.isNumber(n)&&n!==+n},m.isBoolean=function(n){return n===!0||n===!1||"[object Boolean]"===s.call(n)},m.isNull=function(n){return null===n},m.isUndefined=function(n){return n===void 0},m.has=function(n,t){return null!=n&&p.call(n,t)},m.noConflict=function(){return u._=i,this},m.identity=function(n){return n},m.constant=function(n){return function(){return n}},m.noop=function(){},m.property=w,m.propertyOf=function(n){return null==n?function(){}:function(t){return n[t]}},m.matcher=m.matches=function(n){return n=m.extendOwn({},n),function(t){return m.isMatch(t,n)}},m.times=function(n,t,r){var e=Array(Math.max(0,n));t=b(t,r,1);for(var u=0;n>u;u++)e[u]=t(u);return e},m.random=function(n,t){return null==t&&(t=n,n=0),n+Math.floor(Math.random()*(t-n+1))},m.now=Date.now||function(){return(new Date).getTime()};var B={"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#x27;","`":"&#x60;"},T=m.invert(B),R=function(n){var t=function(t){return n[t]},r="(?:"+m.keys(n).join("|")+")",e=RegExp(r),u=RegExp(r,"g");return function(n){return n=null==n?"":""+n,e.test(n)?n.replace(u,t):n}};m.escape=R(B),m.unescape=R(T),m.result=function(n,t,r){var e=null==n?void 0:n[t];return e===void 0&&(e=r),m.isFunction(e)?e.call(n):e};var q=0;m.uniqueId=function(n){var t=++q+"";return n?n+t:t},m.templateSettings={evaluate:/<%([\s\S]+?)%>/g,interpolate:/<%=([\s\S]+?)%>/g,escape:/<%-([\s\S]+?)%>/g};var K=/(.)^/,z={"'":"'","\\":"\\","\r":"r","\n":"n","\u2028":"u2028","\u2029":"u2029"},D=/\\|'|\r|\n|\u2028|\u2029/g,L=function(n){return"\\"+z[n]};m.template=function(n,t,r){!t&&r&&(t=r),t=m.defaults({},t,m.templateSettings);var e=RegExp([(t.escape||K).source,(t.interpolate||K).source,(t.evaluate||K).source].join("|")+"|$","g"),u=0,i="__p+='";n.replace(e,function(t,r,e,o,a){return i+=n.slice(u,a).replace(D,L),u=a+t.length,r?i+="'+\n((__t=("+r+"))==null?'':_.escape(__t))+\n'":e?i+="'+\n((__t=("+e+"))==null?'':__t)+\n'":o&&(i+="';\n"+o+"\n__p+='"),t}),i+="';\n",t.variable||(i="with(obj||{}){\n"+i+"}\n"),i="var __t,__p='',__j=Array.prototype.join,"+"print=function(){__p+=__j.call(arguments,'');};\n"+i+"return __p;\n";try{var o=new Function(t.variable||"obj","_",i)}catch(a){throw a.source=i,a}var c=function(n){return o.call(this,n,m)},f=t.variable||"obj";return c.source="function("+f+"){\n"+i+"}",c},m.chain=function(n){var t=m(n);return t._chain=!0,t};var P=function(n,t){return n._chain?m(t).chain():t};m.mixin=function(n){m.each(m.functions(n),function(t){var r=m[t]=n[t];m.prototype[t]=function(){var n=[this._wrapped];return f.apply(n,arguments),P(this,r.apply(m,n))}})},m.mixin(m),m.each(["pop","push","reverse","shift","sort","splice","unshift"],function(n){var t=o[n];m.prototype[n]=function(){var r=this._wrapped;return t.apply(r,arguments),"shift"!==n&&"splice"!==n||0!==r.length||delete r[0],P(this,r)}}),m.each(["concat","join","slice"],function(n){var t=o[n];m.prototype[n]=function(){return P(this,t.apply(this._wrapped,arguments))}}),m.prototype.value=function(){return this._wrapped},m.prototype.valueOf=m.prototype.toJSON=m.prototype.value,m.prototype.toString=function(){return""+this._wrapped},"function"==typeof define&&define.amd&&define("underscore",[],function(){return m})}).call(this);
/*
//Filename:grunt_src/lib/GridBuddyHelperScripts.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
/**
 *  Common scripts that can be used by all GridbuddyCustomizations
 *  @author Paul Roth <proth@salesforce.com>
**/

//-- gridinfo where it is indexed by the Salesforce Field API Name.
gridInfoByField = {};
//-- gridInfo where it is indexed by the GridBuddy ID (i.e. v2)
gridInfoById = {};
//-- gridInfo of the child tables/rows under the main table
gridChildrenInfoMap = {};

/**
 *  Function that converts the gridInfoMap to populate the gridInfoByField
 *  and gridInfoById.
 *  @invariant gridInfoByField populated
 *  @invariant gridInfoById populated
**/
function convertGridInfoMap(){
	gridInfoByField = {};
	gridInfoById = {};
    gridChildrenInfoMap = {};
	
	//-- where is this p property from and why is there only that one property
	var originalMap = gridInfoMap;
	if( originalMap.hasOwnProperty( "p" )){
		originalMap = originalMap.p;
	}
	
	if( originalMap.metaColumns ){
		var metaColumn;
		for( var i = 0; i < originalMap.metaColumns.length; i++ ){
			metaColumn= originalMap.metaColumns[i];
			gridInfoByField[ metaColumn.fieldName ] = metaColumn;
			gridInfoById[ metaColumn.fieldId ] = metaColumn;
		}
	}

    getMetadataMapsForChildGrids();
}

/**
 *  Determines the metadata for a particular object within the gridInfoMap.
 *  <p>Appears to be a different way of calculating gridInfoMaps</p>
 *  @param objectName(String)
 *  @return (object:{ gridInfoByField, gridInfoById })
**/
function getMetadataMapsForObject(objectName){
	var originalMap = gridInfoMap;
	var objectMetaData;
	var returnObject = {gridInfoByField:{}, gridInfoById:{}};

	for(var k in originalMap){

		objectMetadata = originalMap[k];

		if(objectMetadata.hasOwnProperty('gridName') && objectMetadata.gridName == objectName){
			if( objectMetadata.metaColumns ){
				var metaColumn;
				for( var i = 0; i < objectMetadata.metaColumns.length; i++ ){
					metaColumn= objectMetadata.metaColumns[i];
					returnObject.gridInfoByField[ metaColumn.fieldName ] = metaColumn;
					returnObject.gridInfoById[ metaColumn.fieldId ] = metaColumn;
				}
			}
		}
	}

	return returnObject;
}

function getMetadataMapsForChildGrids(){
    var originalMap = gridInfoMap.p;
    var objectMetaData;
    var returnObject = {gridInfoByField:{}, gridInfoById:{}};

    if (originalMap.allChildInfos != null) {
        for( var k = 0; k < originalMap.allChildInfos.length; k++ ){

            objectMetadata = originalMap.allChildInfos[k];

            if(objectMetadata.hasOwnProperty('gridName')){
                if( objectMetadata.metaColumns ){
                    var metaColumn;
                    for( var i = 0; i < objectMetadata.metaColumns.length; i++ ){
                        metaColumn= objectMetadata.metaColumns[i];
                        returnObject.gridInfoByField[ metaColumn.fieldName ] = metaColumn;
                        returnObject.gridInfoById[ metaColumn.fieldId ] = metaColumn;
                    }
                }

                gridChildrenInfoMap[objectMetadata.gridApiName] = returnObject;
            }
        }
    }
}

/**
 *  Creates a selector for a row given by a specific salesforce id.
 *  @param salesForceId (String) - salesforce record id
 *  @param String - selector - ex: tr#a0qR0000001iEeYIAU
 *  @example: jq( "#gbMainTable").find( createRowSelector( "a0qR0000001iEeYIAU" )).createFieldSelector( gridInfoByField.RecordTypeId.fieldName ))
**/
function createRowSelector( salesForceId ){
	return( "tr#" + salesForceId );
}

/**
 *  Creates a selector for a field in a gridBuddy grid
 *  for a given salesforce field api name.
 *  @param fieldApi (String) - like RateType__c
 *  @param metadataObject (Object)
 *  @return String - i.e td[name=v2]
**/
function createFieldSelector( fieldApi, metadataObject ){

	var source = metadataObject||window;
	if( !source.gridInfoByField ){
		throw( "convertGridInfoMap() has not been called and metadataObject is missing or unexpected format" );
	} else if( !source.gridInfoByField.hasOwnProperty( fieldApi )){
		throw( "Field[" + fieldApi + "] is not defined in the gridInfoByField" );
	}
	
	//-- :input not included as it seems not necessary
	//-- remember to use evt.target.value to get values on selects.
	return( "td[name=" + source.gridInfoByField[fieldApi].fieldId + "]" );
}

/**
 *  Creates a selector for a field input in a gridBuddy grid
 *  for a given salesforce field api name.
 *  @param fieldApi (String) - like RateType__c
 *  @param metadataObject (Object)
 *  @return String - i.e td[name=v2] :input
**/
function createFieldInputSelector( fieldApi , metadataObject){
	return( createFieldSelector( fieldApi, metadataObject ) + " :input" );
}

/**
 *  Finds a given row by a salesForceId
 *  @param salesForceId (String)
 *  @return (el) - jquery results for that row
 *  @example: jq( createFieldSelector( "BaseAmount__c" ), findRowById( "a0qR0000001iEeYIAU" ));
**/
function findRowById( salesForceId){
	//-- does not appear necessary - and may give some options in the future if we leave off gbTable
	//return( jq( "#gbMainTable " + createRowSelector( salesForceId )));
	return( jq( createRowSelector( salesForceId )));
}

/**
 *  Creates a URL for a given apex page.
 *  @param pageName (String)
 *  @return (String)
 *  @example
 *  getAjaxResponderURL( "LNE_GridBuddyCalculationAPI" ); //https://lne--dev0--c.cs2.visual.force.com/apex/LNE_GridBuddyCalculationAPI 
**/
function createApexURL( pageName ){
  var currentLocation = window.location.href;
  var ajaxURL = currentLocation.replace( 'gblite.', 'c.' );
  ajaxURL = ajaxURL.substring(0, ajaxURL.toLowerCase().indexOf('/apex/' )) + '/apex/' + pageName;
  return( ajaxURL );
}

/**
 *  Sanitize numbers.
 *  @param numStr (can include thousands position)
 *  @return cleanedString
**/
function sanitizeNumber( numStr ){
	if( !numStr ){
		return( numStr );
	} else {
		return(numStr.replace( /[^-.0-9]/g, '' ));
	}
}

/**
 *  Formats numbers
 *  @param num
 *  @return (string) - i.e 85,814.00
**/
function formatNumber( num ){
	try {
		var result = num.toLocaleString(  "en-US", { style: 'currency', currency: 'USD' }).replace('$', '');
		return( result );
	} catch( err ){
		console.log( 'unable to format number[' + num + ']' );
		return( num );
	}
}

/**
 *  Gets a value from a gridbuddy input
 *  @param row (Element) - jQuery element of the row to select within
 *  @param fieldAPI (String) - api name of the field to ask for
**/
function getInputValue( row, fieldAPI ){
	if( !gridInfoByField.hasOwnProperty( fieldAPI )){
		throw( "gridInfoByField[" + fieldAPI + "] does not exist" );
	}
	var el = jq( row ).find( createFieldInputSelector( fieldAPI ) );
	if( !el || el.length < 1 ){
		//-- @TODO: investigate further - this happens if there is a select that hasn't been used yet... (facepalm)
		return( jq( row ).find( createFieldSelector( fieldAPI ) + " div" ).text() );
	} else {
		return( el.val() );
	}
}

/**
 *  Gets the ID of the current record being used.
 *  <p>In this case its the id of the event</p>
 **/
function getCurrentRecordId() {
    return (window.location.href.match(/[&?]fpv=([^&?]+)[&?]/)[1]);
}

/**
 *  Gets the ID of the current record being used on grids
 *  that use the "fpv" param with a combined ID+stage type.
 *  This function looks for a separate param with just the record ID.
 *  <p>In this case its the id of the event</p>
 **/
function getParentRecordId() {
    return (window.location.href.match(/[&?]parentid=([^&?]+)($|[&?])/)[1]);
}

/**
 *  Converts a % string to a decimal (i.e. "44" to "0.44")
 *  @param percentStr
 *  @return float as a string
 **/
function percentToFloat(percentStr) {
    var newVal = parseFloat(percentStr, 10);
    if (!isNaN(newVal)) {
        return ((newVal / 100.0).toFixed(4));
    } else {
        //-- could not parse percentStr
        return (percentStr);
    }
}

/**
 *  Converts a Decimal string to a percentage
 *  @see percentToFloat
 *  @param floatStr
 *  @return percent as String
 **/
function floatToPercent(floatAmt) {
    if (!isNaN(floatAmt)) {
        return (floatAmt * 100.0);
    } else {
        //-- could not parse percentStr
        return (floatAmt);
    }
}

/**
 *  Marks whether the table is ready (true) or not (false)
 *  @param isReady - whether the table is ready and change events can dispatch
 **/
function markTableReady(isReady) {
    jq("#gbMainTable").attr("isReady", isReady);
}

/**
 *  Determines whether the table is ready
 *  @return boolean - whether the table was marked ready (true) or not (false)
 **/
function isTableReady() {
    var isReady = jq("#gbMainTable").attr("isReady");
    return (isReady === "true");
}

/**
*   Handle when user has unsaved changes and this grid looses focus
*   Receive messages from parent VF containing page
**/
function gridSpecificHandleFocusLoss(mode) {
    console.log('gridSpecificHandleFocusLoss Fires - v2');
    var gridName = window.gridNameForUDF || null;
    var receiveMode = mode;

    if (gridName.indexOf('-') > -1) {
        gridName = gridName.replace(/-/g,'');
    }

    window.addEventListener("message", receiveMessage, false);

    function receiveMessage(event) {
        console.log('gridSpecificHandleFocusLoss receiveMessage mode ' + receiveMode);
        var msg = {
            'changes': 'false',
            'gridName': gridName,
            'requestedAction': event.data.action,
            'hasRows': 'false'
        };

        if (!gridName) {
            return false;
        }

        var origin = event.origin || event.originalEvent.origin; // For Chrome, the origin property is in the event.originalEvent object.
        if (origin.indexOf('visual.force.com') === -1) {
            return false;
        } else {
            var $changedCells = jq('#gbMainTable').find('td.mod');
            var $newRows = jq('#gbMainTable').find('tr.nr');

            if ($changedCells.length > 0 || $newRows.length > 0) {
                msg.changes = 'true';
            } else {
                msg.changes = 'false';
            }

            var $noDataCol = jq('#gbMainTable').find('td.noDataCol');
            var $cell1 = jq('#gbMainTable').find('td[name="v0"]');
            if ($cell1.length == 0 || $noDataCol.length > 0) {
                msg.hasRows = 'false';
            } else {
                msg.hasRows = 'true';
            }

            if (event.data.action === 'report' || event.data.action === 'reportForVisibility'
            ) {
                console.log('received report / reportForVisibility');
                if (receiveMode !== 'nutter') {
                    console.log('receiveMode not nutter ' + receiveMode);
                    event.source.postMessage(msg, event.origin);
                }
            } else if (event.data.action === 'reportForNutSave') {
                event.source.postMessage(msg, event.origin);
            } else if (event.data.action === 'save') {
                //-- check again to be sure
                if ($changedCells.length > 0 || $newRows.length > 0) {
                    if (jq('body').find('input[type="submit"].saveBtn:not(.none)')) {
                        jq('body').find('input[type="submit"].saveBtn:not(.none)').click();
                    } else {
                        console.log('Cannot find save button');
                    }
                }
            } else if (event.data.action === 'refresh') {
                 if ($changedCells.length === 0) {
                    if (jq('body').find('input[type="submit"].refreshBtn:not(.none)')) {
                        jq('body').find('input[type="submit"].refreshBtn:not(.none)').click();
                    } else {
                        console.log('Cannot find save button');
                    }
                }               
            }
        }
    }
}

function gridSpecificNotifySavedSuccessful() {
    var msg = {};    
    var $pageMessage = jq('.msgDetail');    
    if ($pageMessage) {
        var text = $pageMessage.text() || ''; 
    }
    var u = new URLSearchParams(window.location.search);
    var auraId = u.get('auraId') || null;
        
    msg = {
        auraId: auraId,
        requestedAction: 'savedNotification',
        src: window.location.href
    };

    if (text.indexOf('Save success') === 0) {
        parent.postMessage(msg, '*');
    }
}

function gridStateMessagingController(mode) {
  gridSpecificHandleFocusLoss(mode);
  jq(document).ready(function() {
    gridSpecificNotifySavedSuccessful();
  });
}

/**
* Sets up resizing events
**/
(function() {

    var u = new URLSearchParams(window.location.search);
    var nom = (u.get('gname') || '').replace(/[^a-z]/gi, '').toLowerCase();

    function resizeNow() {
      // to check for new elements created by the new button.
      // timeout isnt best approach but not much else to go off of
      setTimeout(function() {
        jq('.createNew, .deleteItem, .minus, .icon-arrow, .rfIcon').on('click', resizeNow);
      }, 100);

      var height = jq('.gbAppPage').outerHeight() + (jq(this).hasClass('rfIcon') ? 150 : 40);
      // post message to parent
      parent.postMessage({
        resize: height,
        id: nom
      }, '*');
    }

    // to force it to run after other ready scripts
    setTimeout(resizeNow, 100);

})();


/*
//Filename:grunt_src/ancillaryrevenuedatacards.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
var GBConditionalFields = (function(window, document, jq) {

    // Data Cards config #1
    // set how many primary fields there are in each object
    // the key is the object Id ( p, 1, 2, 3, 4) and the value is the number of primary fields you want to show on load
    var noOfFieldsToShow = {
        p: 4,
        1: 4
    };

    // Data Cards config #2
    // set how many fields you want to show in a row in a data card
    var elementsInARow = 4;

    // assumptions:
    // 1. required fields (fieldToShow) are set up as secondary fields
    // 2. condition fields (governingField) are primary fields
    // 3. condition field and required field are on the same object

    // Conditionally required fields use case #1
    // Make a field required when we change another field to a specific value. If we don't need this, declare as an empty object.
    var requiredFields = {
        //Opportunity: [
        //    {
        //        governingField: 'StageName',
        //        value: ['Closed Won', 'Closed Lost'],
        //        fieldToShow: ['Reason_Won_Lost__c']
        //    }
        //]
    };

    // Conditionally required fields use case #2
    // Make a field required when we when a validation rule is tripped. If we don't need this, declare as an empty object.
    var validatonRequiredFields = {
        //Opportunity: ['Lost_Reason__c']
    };

    /**
    *  DON'T CHANGE ANYTHING BELOW THIS LINE
    **/

    var secondaryFields = {};
    var numberOfrequiredForCreateFields = {};
    var requiredFieldsToHide = [];

    var cssRules = [
        {ruleName: '#gbMainTable .lastCol .showDataCard .ui-icon', ruleDef: 'background-image: url(images/ui-icons_888888_256x240.png);'},
        {ruleName: '#gbMainTable .dataCard .cardItem', ruleDef: 'width:' + (100 / elementsInARow) + '%;'},
        {ruleName: '#gbMainTable .dataCardCell .gbInfoIcon', ruleDef: 'background:transparent url("images/ic_info.png") no-repeat scroll 0 0; margin-left:4px; position:relative; top:2px; height:13px; width:13px; background-size:13px; display:inline-block; cursor:pointer;'}
    ];

    var mobileCssRules = [
        {ruleName: '#gbMainTable .lastCol .showDataCard',ruleDef: 'padding: 4px !important;zoom: 150%;'},
        {ruleName: '#gbMainTable .dataCard .cardItem',ruleDef: 'padding: 0 !important;'},
        {ruleName: 'body,html',ruleDef: 'width:100% !important; /* reset SFDC body widths */'},
        {ruleName: '#gbMainTable',ruleDef: 'width: 99%; margin-left: 1%;'},
        {ruleName: '#parentHeaderTable',ruleDef: 'margin-left: 1%; margin-top: 10px; margin-bottom: 10px; width: 99%;'},
        {ruleName: '#gbMainTable .cardItem nobr',ruleDef: 'display:inline-block; vertical-align:middle;'},
        {ruleName: '#gbMainTable .cardItem input[type="checkbox"]',ruleDef: 'vertical-align:top;'},
        {ruleName: '#gbMainTable .dataCard .cardItem label',ruleDef: 'width:200px !important; padding-left:3px; padding-bottom: 4px; display:block !important;'},
        {ruleName: '#gbMainTable .dataCard .cardTable',ruleDef: 'margin-bottom: 20px !important;'},
        {ruleName: '#gbMainTable .dataCard .conditionalFieldsHeader',ruleDef: 'height: 17px; margin-bottom: 9px !important'},
        {ruleName: '#gbMainTable .dataCard .conditionalFieldsHeader span',ruleDef: 'left: -124px !important;'}
    ];

    // count editable cols, we need to account for these on the parent when we expand the data card
    var noOfEditableRelCols = 0;
    for (var i = 1; i <= 4; i++) {
        if (gridInfoMap[i] == undefined) {
            break;
        }
        if(gridInfoMap[i].isConcatenatedView == true){
            noOfEditableRelCols++
        }
    }

    function init() {
    	debugger;

        var headerClass = '',
            sectionSelector = '';

        for(var k in gridInfoMap){
            for (var i=noOfFieldsToShow[k]; i < gridInfoMap[k].metaColumns.length; i++) {
                if(secondaryFields[k] == undefined){
                    secondaryFields[k] = [];
                }
                // don't add fields that are required on create. they should show up in the top col
                if(gridInfoMap[k].metaColumns[i].requiredForCreate == false){
                    secondaryFields[k].push(gridInfoMap[k].metaColumns[i].fieldId);
                }else{
                    if(numberOfrequiredForCreateFields[k] == undefined){
                        numberOfrequiredForCreateFields[k] = 1;
                    }else{
                        numberOfrequiredForCreateFields[k] ++;
                    }
                }
            }

            // hide secondary fields
            if(secondaryFields[k] != undefined && secondaryFields[k].length > 0){
                for (var j=0; j<secondaryFields[k].length; j++) {
                    if(k == 'p'){
                        headerClass = '.gradientHeader';
                        sectionSelector = mainTableJqueryId + ' > tbody >';
                    }else{
                        headerClass = '.childHeaderRow';
                        sectionSelector = '.childTable[name="c' + k + '"]';
                    }

                    jq(headerClass + ' td[name="' + secondaryFields[k][j] + '"]').remove(); // remove column headers to avoid them being copied to frozen header
                    jq(sectionSelector + ' .summaryRow td[name="' + secondaryFields[k][j] + '"]').remove(); // remove summary cells
                    jq(sectionSelector + ' .groupByRow td[name="' + secondaryFields[k][j] + '"]').remove(); // remove group by cells
                    cssRules.push({ruleName: sectionSelector + ' tr > td[name="' + secondaryFields[k][j] + '"]',ruleDef: 'display: none;'});
                }
                jq(sectionSelector + ' .dr .lastCol').append('<span class="showDataCard"><span class="ui-icon ui-icon-plusthick"></span></span>');
            }
        }

        jq(mainTableJqueryId).on('click', '.showDataCard', showDataCard);

        setupEvents(secondaryFields);
        addRulesToStyleSheet(cssRules);
        if(isInMobileView){
            addRulesToStyleSheet(mobileCssRules);
        }

        if(Object.keys(requiredFields).length > 0){
            initConditionalFields();
        }

        if(Object.keys(validatonRequiredFields).length > 0){
            initValidationConditionalFields();
        }

    }

    function initConditionalFields(){
        var gridInfo,
            fieldToWatch,
            requiredData;

        for(var k in requiredFields){
            gridInfo = GBGridInfoHelper.getGridInfoByFullObjectName(k);

            if(gridInfo == null){
                continue;
            }

            for (var i = 0; i < requiredFields[k].length; i++) {
                fieldToWatch = requiredFields[k][i].governingField;
                requiredData = requiredFields[k][i];
                watchForRequiredField(gridInfo, fieldToWatch, requiredData);
                requiredFieldsToHide = requiredFieldsToHide.concat(requiredData.fieldToShow);
            }
        }
    }

    // hide ValidationConditionalFields also
    function initValidationConditionalFields(){
        for(var k in validatonRequiredFields){
            requiredFieldsToHide = requiredFieldsToHide.concat(validatonRequiredFields[k]);
        }

        jq('body').on('click', '.saveBtn', removeOriginalValidationRequiredFields);

        // check if we need to parse validation error messages
        if(errorRecs.length > 0){
            handleValidationError();
        }

    }

    // before save, we have to remove the original ValidationRequiredFields from the grid, otherwise they'd trip our required validation
    function removeOriginalValidationRequiredFields(){
        var sectionSelector,
            gridInfo,
            metaCol;

        for(var k in validatonRequiredFields){
            gridInfo = GBGridInfoHelper.getGridInfoByFullObjectName(k);

            if(gridInfo == null){
                continue;
            }

            for(var i = 0; i < validatonRequiredFields[k].length; i++) {
                metaCol = getMetaColByFieldName(gridInfo, validatonRequiredFields[k][i]);
                sectionSelector = (gridInfo.gridId == 'p')?mainTableJqueryId + ' > tbody >':'.childTable[name="' + pGridInfo.objId + '"]';
                jq(sectionSelector + ' .dr td[name="'+metaCol.fieldId+'"]').remove();
            }

        }
    }

    function handleValidationError(){
        var element;

        for(var i = 0; i < errorRecs.length; i++) {
            jq('#'+errorRecs[i]+' > .lastCol .showDataCard').click(); // expand data card
            element = jq('#'+errorRecs[i]);

            // after the data card has been expanded
            setTimeout(function(element){
                var dataCard = element.next('.dataCard'),
                    gridInfo,
                    metaCol,
                    reqField,
                    reqInput;

                // show required header
                dataCard.find('.conditionalFieldsHeader').show();

                // show required field(s)
                for(var k in validatonRequiredFields){
                    gridInfo = GBGridInfoHelper.getGridInfoByFullObjectName(k);

                    for (var i = 0; i < validatonRequiredFields[k].length; i++) {
                        metaCol = getMetaColByFieldName(gridInfo, validatonRequiredFields[k][i]);
                        reqField = dataCard.find('.cardItem[name="'+metaCol.fieldId+'"]').show();
                        reqInput = reqField.find('select, input, textarea');
                        reqInput.after('<span class="gbInfoIcon tooltip"></span>');
                        reqField.find('.gbInfoIcon').tooltipster({content:'Please fill out required field'});

                        // add required styling
                        if(reqInput.val() == ''){
                            reqInput.addClass('gbrq').on('blur, change',function(){
                                var elem = jq(this);
                                if(elem.val() != ''){
                                    elem.removeClass('gbrq'); // remove required styling
                                }
                            });
                        }
                        blinkDataCard(reqField);
                    }
                }

            },0, element);
        }
    }

    // when the value changes to on a watched field, show the conditional fields if appropriate
    function watchForRequiredField(pGridInfo, pFieldToWatch, pRequiredData){
        var sectionSelector = (pGridInfo.gridId == 'p')?mainTableJqueryId + ' > tbody >':'.childTable[name="' + pGridInfo.objId + '"]';
        var metaCol = getMetaColByFieldName(pGridInfo, pFieldToWatch);

        jq('body').on('change',sectionSelector + ' .dr [name="'+metaCol.fieldId+'"]', function(){
            var changedField = jq(this);
            var value = changedField.find('select, input, textarea').val();
            var thisRow = changedField.closest('tr');

            if(pRequiredData.value.indexOf(value) != -1){
                // show required field
                if(!thisRow.hasClass('dataCardExpanded')){
                    thisRow.find('.showDataCard').click(); // expand data card
                }

                // after the data card has been expanded
                setTimeout(function(){
                    var dataCard = thisRow.next('.dataCard'),
                        metaCol,
                        reqField,
                        reqInput;

                    // show required header
                    dataCard.find('.conditionalFieldsHeader').show();

                    // show required field(s)
                    for (var i = 0; i < pRequiredData.fieldToShow.length; i++) {
                        metaCol = getMetaColByFieldName(pGridInfo, pRequiredData.fieldToShow[i]);
                        //reqField = dataCard.find('.cardItem[name="'+metaCol.fieldId+'"]').css('display','table-cell');
                        reqField = dataCard.find('.cardItem[name="'+metaCol.fieldId+'"]').show();
                        reqInput = reqField.find('select, input, textarea');

                        // add required styling
                        if(reqInput.val() == ''){
                            reqInput.addClass('gbrq').on('blur',function(){
                                var elem = jq(this);
                                if(elem.val() != ''){
                                    elem.removeClass('gbrq'); // remove required styling
                                }
                            });
                        }
                        blinkDataCard(reqField);
                    }

                },0);
            }else{
                // hide required field
                setTimeout(function(){
                    var dataCard = thisRow.next('.dataCard'),
                        metaCol,
                        reqField;

                    for (var i = 0; i < pRequiredData.fieldToShow.length; i++) {
                        metaCol = getMetaColByFieldName(pGridInfo, pRequiredData.fieldToShow[i]);
                        reqField = dataCard.find('.cardItem[name="'+metaCol.fieldId+'"]').hide();
                    }

                    // hide required header
                    if(dataCard.find('.hiddenRequiredTable .cardItem:visible').length == 0){
                        dataCard.find('.conditionalFieldsHeader').hide();
                    }

                },0);
            }

        });
    }

    function blinkDataCard(elem){
        elem.addClass('highlight');
        setTimeout(function(){
            elem.removeClass('highlight');
        },300);
    }

    function showDataCard(){
        var button = jq(this).find('.ui-icon'),
            thisRow = button.closest('tr'),
            dataCard = thisRow.next('.dataCard'),
            isInitialized = dataCard.length != 0,
            dataCardHtml,
            newDataCard,
            rowClasses = thisRow[0].className,
            gridInfo = getGridInfo(button),
            isNewRow = thisRow.hasClass('nr'),
            colspan = noOfFieldsToShow[gridInfo.gridId] + 1;

        if(isNewRow && numberOfrequiredForCreateFields[gridInfo.gridId] != undefined){
            // when it's a new row, we have to account for the not configured required fields
            colspan += numberOfrequiredForCreateFields[gridInfo.gridId];
        }

        if(gridInfo.gridId == 'p' && noOfEditableRelCols > 0){
            colspan += noOfEditableRelCols; // account for editable related cols on the parent
        }

        button.toggleClass('expanded');

        if(button.hasClass('expanded')){
            button.addClass('ui-icon-minusthick').removeClass('ui-icon-plusthick');
            thisRow.addClass('dataCardExpanded');
            dataCard.addClass('dataCardExpanded');

            // expand
            if(!isInitialized){
                // init and insert row
                dataCardHtml = getDataCardHtml(thisRow, gridInfo);
                thisRow.after('<tr id="'+thisRow.attr('id')+'" class="' + rowClasses + ' dataCard dataCardExpanded"><td class="firstCol"></td><td class="dataCardCell" colspan="'+ colspan +'">'+dataCardHtml+'</td></tr>')
                newDataCard = jq('#'+thisRow.attr('id')+'.dataCard');
                addAutocompleteToLookupFields(newDataCard, false);
                initTextAreas(newDataCard);
                initPicklists(newDataCard);
                newDataCard.addClass('highlightRow');

                newDataCard.find('input, textarea').css('width', ''); // remove enforced width from draggable resize columns
            }else{
                // already initialized, just show row
                dataCard.show();
            }

            correctColspan(thisRow.closest('tbody'), gridInfo.gridId);

            GBMixpanel.track('Show Data Card', {
                'Source': 'Button'
            });

        }else{
            button.addClass('ui-icon-plusthick').removeClass('ui-icon-minusthick');
            thisRow.removeClass('dataCardExpanded');
            dataCard.removeClass('dataCardExpanded');
            // collapse
            dataCard.hide();
        }
    }

    function getDataCardHtml(row, gridInfo){
        var htmlArr = ['<div class="cardTable">'],
            cell,
            fieldId,
            fieldData,
            isThereRequired = false,
            requiredHiddenHtmlArr = [],
            isRowOpen,
            rowFieldIndex = 0;

        for (var i=0; i<secondaryFields[gridInfo.gridId].length; i++) {
            fieldId = secondaryFields[gridInfo.gridId][i];
            fieldData = gridInfoMap[gridInfo.gridId].getMetaColByFieldId(fieldId);
            cell = row.find('td[name="'+fieldId+'"]');

            if(cell.length == 0){
                continue;
            }

            // if it's a required field, add it to the markup later
            if(requiredFieldsToHide.indexOf(fieldData.fieldName) != -1){
                isThereRequired = true;
                requiredHiddenHtmlArr.push('<div class="cardItem ' + cell[0].className + ' creq" name="'+fieldId+'">');
                requiredHiddenHtmlArr.push('<label>' + fieldData.fieldLabel + '</label>');
                requiredHiddenHtmlArr.push(cell.html());
                requiredHiddenHtmlArr.push('</div>');

            }else{
                if(rowFieldIndex%elementsInARow == 0){
                    htmlArr.push('<div class="cardRow">'); // start cardRow div
                    isRowOpen = true;
                }

                htmlArr.push('<div class="cardItem ' + cell[0].className + '" name="'+fieldId+'">');
                htmlArr.push('<label>' + fieldData.fieldLabel + '</label>');
                htmlArr.push(cell.html());
                htmlArr.push('</div>');

                if(rowFieldIndex%elementsInARow == elementsInARow-1){
                    htmlArr.push('</div>'); // close cardRow div after every 5th card or at the end
                    isRowOpen = false;
                }
                rowFieldIndex++;
            }
        }

        if(isRowOpen == true){
            htmlArr.push('</div>'); // close cardRow div
        }
        htmlArr.push('</div>'); // close cardTable

        // if there's a required hidden field, add it in a separate row at the bottom of the data card
        if(isThereRequired){
            htmlArr.push('<div class="conditionalFieldsHeader"><span>Required Fields</span></div>'); // open row
            htmlArr.push('<div class="cardTable hiddenRequiredTable"><div class="cardRow ">'); // open row
            htmlArr = htmlArr.concat(requiredHiddenHtmlArr);
            htmlArr.push('</div>'); // close cardRow div
            htmlArr.push('</div>'); // close cardTable
        }

        return htmlArr.join('');
    }

    function setupEvents(){

        jq(mainTableJqueryId).on('change', 'input.rtf', function(e) {
            GBRowHelper.updateRecordTypePicklists(jq(this).closest('td'), false);
        });

    }

    function handleNewRow(newRow){
        // find new row
        var childTable = newRow.closest('.childTable'),
            id = '';

        if(childTable.length == 0){
            // it's the parent object
            id = 'p';
        }else{
            id = childTable.attr('name').charAt(1);
        }

        correctColspan(newRow.closest('tbody'), id);

        // append expand button if we need to
        if(secondaryFields[id] != undefined && secondaryFields[id].length > 0){
            newRow.find('.lastCol').append('<span class="showDataCard"><span class="ui-icon ui-icon-plusthick"></span></span>');
        }

    }

    // make sure dataCard colspans are still accurate due to not configured required fields
    function correctColspan(section, gridId){
        var newRows = section.find('>tr.nr');

        if(numberOfrequiredForCreateFields[gridId] != undefined){
            if(newRows.length != 0){
                // if there’s a new row in the section and if there are hidden required columns
                var numberOfCols = newRows.first().find('td:visible').length;
                section.find('>tr.dataCard .dataCardCell').attr('colspan', numberOfCols-1)
            }
        }
    }

    function initTextAreas(dataCard){
        var originalRow = dataCard.prev('.dr');

        // we have to copy the values from the textareas in the dataCard to their hidden counterparts. This is because they're saved in a specific way
        jq(mainTableJqueryId).on('blur', '#'+dataCard.attr('id')+'.dataCard textarea', function(e) {
            originalRow.find('td[name="'+jq(this).closest('.cardItem').attr('name')+'"] textarea').val(jq(this).val());
        });

    }

    function initPicklists(dataCard){
        dataCard.find('.cardItem.pl').each(function(item){
            setupPicklistBehavior(null, jq(this), false);
        });
    }

    return {
        init: init,
        handleNewRow: handleNewRow
    }

})(window, document, jq); // end GBConditionalFields

jq(document).ready(function() {GBConditionalFields.init()});








/**
**  OVERRIDES
**/

// override getMetaCol function to accommodate data cards
function getMetaCol(pJqueryElem, pGridInfo) {
    var cellName = pJqueryElem.parents('td').attr('name');
    if(cellName == undefined){
        cellName = pJqueryElem.closest('.cardItem').attr('name');
    }
    var metaCol = getMetaColByCellName(cellName, pGridInfo);
    return metaCol;
}

// override updateModifiedDataMap function to accommodate data cards
function updateModifiedDataMap(pJqueryElem, pGridInfo) {
    // the value of this element changed
    // get the element's row id and put it in the modified map
    var dataRow = pJqueryElem.parents('tr'),
        rowId = dataRow.attr('id'),
        isNewData = dataRow.hasClass('nr'),
        dataMap = (isNewData ? newData : modData),
        rowData = dataMap[rowId],
        metaCol = getMetaCol(pJqueryElem, pGridInfo),
        cellId = metaCol.fieldId,
        inputVal;

    // only proceed if rowData is empty or has exaclty one property: 'cl'. This happens when cloning a record
    if (rowData == null || (Object.keys(rowData).length == 1 && rowData.cl)) {
        dataMap[rowId] = dataMap[rowId] ? dataMap[rowId] : new Object();
        rowData = dataMap[rowId];
        // set the object name
        rowData['nm'] = pGridInfo.fullyQualifiedObjectName;

        if (isNewData) {
            newDataSize++;

            if (pGridInfo.objId != 'p') {
                // this is a child row, get the parent row's id
                var childContainerRow = dataRow.parents('tr.cr'),
                // looking for parent row which is a row adjacent to the child container row
                    prevRow = childContainerRow.prev(),
                    parentRowId;

                if (childContainerRow.length == 1) {
                    var ctr = 0;

                    // FIXME use the row name to find the parent
                    while (prevRow.hasClass('cr')) {
                        prevRow = prevRow.prev();
                        ctr++;

                        // safety exit
                        if (ctr > 4) {
                            break;
                        }
                    }

                    if (prevRow.hasClass('dr')) {
                        parentRowId = prevRow.attr('id');
                        if (GBUnrelated.isChildUnrelated(pGridInfo)) {
                            parentRowId = GBUnrelated.getParentIdentifierForChildData(pGridInfo,
                                parentRowId,
                                prevRow);
                        }
                        rowData['pId'] = parentRowId;
                    }
                }else{
                    parentRowId = dataRow.closest('#relatedColumnWidget').attr('data-parent-id');
                    rowData['pId'] = parentRowId;
                }
            }
        } else {
            modDataSize++;
        }
    }

    if (pGridInfo.objId == 'p' && GBUnrelated.fieldIsCrossRefForeignKey(metaCol.fieldName)) {
        // the field updated is for the parent object, and it is a cross ref FK field
        GBUnrelated.updateUnrelatedChildData(dataRow, metaCol.fieldName);
    }

    if (pJqueryElem.is(':checkbox')) {
        // make sure boolean is in string format for json object
        inputVal = (pJqueryElem.is(':checked') == true)+"";

    } else {
        // scrub value
        inputVal = scrubFieldValue(pJqueryElem, pGridInfo, isNewData);

        // if it's a lookup for whoId add the whoId object name to the map
        if (metaCol.isWhoIdField()) {
            var whoIdObjectName = pJqueryElem.parents('div.ui-widget').find('select.wId').val();
            rowData['whoId'] = whoIdObjectName;
        } else if (metaCol.isWhoOrWhatIdField()) {
            var whatIdObjectName = pJqueryElem.parents('div.ui-widget').find('select.wId').val();
            rowData['whatId'] = whatIdObjectName;
        }
    }

    if (inputVal == null) {
        inputVal = '';
    }

    // for new records only, if there's an empty value it means the user entered a value to begin with and then removed it
    // instead of setting the value on the sobject to empty, remove it from the map so the default value gets applied on create
    // ISSUE WITH RECORD TYPE - can't be empty on create, can't remove on edit
    if (isNewData==true && inputVal == '' && metaCol.defaultedOnCreate==true) {
        delete rowData[cellId];
    } else {
        rowData[cellId] = inputVal;
    }
}

function setupHighlightForMouseoverAction() {
    // highlight a data record (highlighting was removed
    // from the mass update widget because of an issue in IE9)
    var rowSelector = mainTableJqueryId+' tr.dr:not(.nd)';

    jq('div.gbPage').on('mouseover', rowSelector, function() {
        jq('tr[id="' + jq(this).attr('id') + '"]').addClass('highlightRow');
    });

    jq('div.gbPage').on('mouseleave', rowSelector, function() {
        jq('tr[id="' + jq(this).attr('id') + '"]').removeClass('highlightRow');
    });
}

// remember fields and data the user changed
function registerValueChange(e, jQueryElem, isMassUpdate, excludePicklistValidation, excludeUnrelatedUpdates, skipFlatView) {
    var gridInfo = getGridInfo(jQueryElem),
        metaCol = getMetaCol(jQueryElem, gridInfo),
        isNewRow = jQueryElem.parents('tr.dr:first').hasClass('nr'),
        isUnrelatedRow = jQueryElem.closest('tr').hasClass('ur'),
        dependentInfo = dependentPickListInfo[metaCol.fieldName],
        isFlatViewUpdate = (jq('#relatedColumnWidget:visible').length > 0) && !skipFlatView;

    // make parameters default
    excludeUnrelatedUpdates = excludeUnrelatedUpdates || false;

    updateModifiedDataMap(jQueryElem, gridInfo);
    validateField(jQueryElem, gridInfo, isNewRow);

    if (isNewRow==false) {
        var dataCell = jQueryElem.parents('td:first');

        if(dataCell.hasClass('dataCardCell')){
            dataCell = jQueryElem.closest('.cardItem');
        }

        if (dataCell.hasClass('mod')==false) {
            dataCell.addClass('mod');
        }
    }

    //on mass update don't override the values that were selected in the mass update widget
    if(dependentInfo && (!isMassUpdate || (isMassUpdate && jQueryElem.val() == ""))){
        updateDependentPickLists(jQueryElem, dependentInfo, metaCol, gridInfo);
    }

    // validate after the dependent field logic in case any of the dependent fields are required
    validateRemainingRequiredRowFields(jQueryElem, gridInfo, isNewRow, excludePicklistValidation);

    // if child record is unrelated, update all duplicates
    if (isUnrelatedRow && !excludeUnrelatedUpdates) {
        GBRowHelper.updateRecords(e, jQueryElem, gridInfo, metaCol, true);
    }

    // if the flat view related records widget is open, update between the widget and the related section
    if(isFlatViewUpdate){
        GBRowHelper.updateRecords(e, jQueryElem, gridInfo, metaCol, false);
    }

    // update the summary value if this field has one
    if (metaCol.summaryType && metaCol.summaryType != '') {
        GBSummary.updateSummaryValue(jQueryElem);
    }

    // update chart
    if (GBHelpers.isChartValid()) {
        GBCharts.gridChart.updateChart(modData, newData);
    }

    // update the color code
    GBColorCode.updateColor(jQueryElem, metaCol, gridInfo);

}

/**
 * Adds the given css rules to the gb-jq style sheet.
 * @param pNewRules an array of objects, example:
 * 		  [{ruleName: 'table.mainTable > tbody > tr > td[name="v3"]',
 *			ruleDef: 'min-width: 750px;'},
 * 		   {ruleName: 'table.mainTable > tbody > tr > td[name="v3"] input',
 *			ruleDef: 'width: 740px;'},
 * 		   {ruleName: 'table.childTable[name="c2"] tr td[name="v4"] textarea',
 * 			ruleDef: 'width: 590px;'},
 * 		   ...]
 */
function addRulesToStyleSheet(pNewRules) {
    var gbStyleSheet,
        ruleName,
        ruleDef;

    for (var y=0; y < document.styleSheets.length; y++) {
        if (document.styleSheets[y].href && document.styleSheets[y].href.indexOf('gb-jq') > 0) {
            gbStyleSheet = document.styleSheets[y];
            break;
        }
    }

    if(!gbStyleSheet){
        return;
    }

    // loop through the new rules and add them to the style sheet
    for (var k=0; k < pNewRules.length; k++) {
        ruleName = pNewRules[k].ruleName;
        ruleDef = pNewRules[k].ruleDef;

        if (gbStyleSheet.addRule) {
            // IE
            gbStyleSheet.addRule(ruleName, ruleDef, 0);
        } else {
            // others
            gbStyleSheet.insertRule(ruleName+' { '+ruleDef+' }', 0);
        }
    }
}

GBColorCode.updateColor = function(element, metaCol, gridInfo){
    var colorCodeValue,
        isColored = false,
        value,
        cell = element.closest('.cardItem'),
        objectDotFieldName = '',
        fullyQualifiedObjectNameParts = gridInfo.fullyQualifiedObjectName.split(':'),
        valueProps;

    if(cell.length == 0){
        cell = element.closest('td');
    }

    if(fullyQualifiedObjectNameParts.length == 1){
        objectDotFieldName = gridInfo.fullyQualifiedObjectName + ':' + metaCol.fieldName; // if it's a parent object
    }else{
        objectDotFieldName = fullyQualifiedObjectNameParts[0] + ':' + metaCol.fieldName + ':' + fullyQualifiedObjectNameParts[1]; // if it's a related object
    }

    // find the applicable rules based on the objectDotFieldName
    // parent field example: "Account:Industry"
    // related field example: "Opportunity:Amount:AccountId"
    // unrelated field example: "Opportunity:Amount:unrelated"
    // junction parent field example: "Asset:Quantity:unrelated-AssetId-Case"
    var applicableRules = colorCodingRulesJson.filter(function(obj) {
        if (obj.governingField == objectDotFieldName) {
            // related object or parent
            return true;
        }else if(obj.governingField.split(':').length == 3 && // governing field is syntactically correct
            obj.governingField.split(':')[2].indexOf('unrelated') != -1 && // last token (relation) of governingField contains "unrelated"
            objectDotFieldName.split(':')[0].indexOf(obj.governingField.split(':')[0]) != -1 && // first token (object) of objectDotFieldName containts the first token of governingField. If it's truly unrelated, they'll be the same. If it's junction parent, one will just contain part of the other
            obj.governingField.split(':')[1] == objectDotFieldName.split(':')[1]){ // second token (field) of governingField and objectDotFieldName are the same
            // unrelated object: last element of governing field should be 'unrelated' and the first and second element of the objectDotFieldnames should match
            return true;
        }
    });

    for (var i = 0; i < applicableRules.length; i++) {
        // convert color code value from string to something that we can compare
        colorCodeValue = this.convertValue(applicableRules[i].value, metaCol.colDataType, applicableRules[i].value);

        // update color coding on change
        //value = (cell.hasClass('pl') && !cell.hasClass('plOn')) ? cell.find('.plTxt').text() : cell.find('input, select').val();
        valueProps = this.getCleanValue(cell, metaCol.colDataType);
        value = valueProps['cleanValue'];

        if (!value && metaCol.isNumeric()) {
            // reset/don't highlight this field, it's numeric but the value is blank
            // blank numeric values should not be treated like 0 values
            isColored = false;

        } else {
            // convert value from string to something that we can compare
            value = this.convertValue(value, metaCol.colDataType, applicableRules[i].value);

            isColored = this.evaluateValueForColorCode(applicableRules[i].operator, value, colorCodeValue, metaCol.colDataType);
        }

        this.applyColor(cell, applicableRules[i], isColored);
    }
};

function insertNewRow(pDataTable, originalRow) {
    var htmlArr = [],
        gridInfo = getGridInfoByName(pDataTable.attr('name')),
        metaCols = gridInfo.metaColumns,
        firstDataRow = getFirstDataRow(pDataTable),
        firstRowId = (firstDataRow==null || firstDataRow.length==0 ? '' : firstDataRow.attr('id')) || '',
        isParentTable = pDataTable.hasClass('mainTable')==true,
        headerRow = (isParentTable ? pDataTable.find('tr.gradientHeader') : pDataTable.find('tr.childHeaderRow')),
        newCellValue = '',
        metaCol,
        newRow,
        cellClass,
        cellClasses,
        cellProps,
        requiredCols = [], // could contain hidden, required columns and/or required for create columns
        firstDataRowExists = (firstRowId.length == 0 || isNaN(firstRowId)==true);

    // make sure the data table is displayed
    showGridTable(pDataTable);

    if (firstDataRowExists) {
        // this is the first new record for this table
        // add the new required field columns to the header and adjust the columns for the rest of the rows

        if (firstDataRow.hasClass('nd')) {
            // no data found row
            firstDataRow.addClass('none');
        }

        var colHtml = '',
            newColsAdded = 0;

        // show required columns in new rows only if it's not a clone. if it's a clone, we'll take care of it on the back-end
        if (!originalRow) {
            for (var i=0, len=gridInfo.metaColumns.length; i < len; i++) {
                metaCol = gridInfo.metaColumns[i];
                if (metaCol.requiredForCreate == true || metaCol.showHiddenColumnOnCreate(gridInfo)) {
                    // insert the new columns before the last column
                    headerRow.find('td.lastCol').before('<td class="nc">'+metaCol.fieldLabelForDisplay()+'</td>');

                    // add new column to the summary row if applicable
                    headerRow.first().next('.summaryRow').find('td.lastCol').before('<td class="nc"></td>');

                    if (isParentTable) {
                        // add new column to each group by header row
                        jq('.groupByRow').find('td.lastCol').before('<td class="nc"></td>');
                    }

                    newColsAdded++;
                }
            }
        }

        // if there's no select (checkbox) column, add an empty column for the minus button for new records
        // TODO this check may no longer be necessary, since the checkbox column should always be displayed now, confirm
        if (headerRow.find('input.selectAllChk').length == 0) {
            headerRow.find('td:first').before('<td class="minusCol nc">&nbsp;</td>');
            pDataTable.children('tbody').children('tr.dr').children('td:first-child').before('<td class="nc">&nbsp;</td>');
            newColsAdded++;
        }

        // readjust all the data rows in this table
        if (newColsAdded > 0) {
            // set the new colspan on the last column based on how many required columns are added for the new row
            pDataTable.children('tbody').children('tr.dr:not(.nr)').find('td.lastCol').attr('colspan', newColsAdded+1).addClass('bl');

            // readjust the data rows in child tables
            if (isParentTable) {
                var allChildObjectSections = jq('td.crDataContainer');
                if (allChildObjectSections.length > 0) {
                    var origColspan = allChildObjectSections.first().attr('colspan') * 1;
                    allChildObjectSections.attr('colspan', origColspan + newColsAdded);
                }
            }
        }
    }

    // use the current new row id
    htmlArr.push('<tr id="'+currentNewRowId+'" name="r'+currentNewRowId+'" class="dr nr">');

    // decrement the row id
    currentNewRowId--;

    // first column is for the delete icon
    htmlArr.push('<td class="chk firstCol"><span class="minus">&nbsp;</span></td>');

    for (var c=0, len=metaCols.length; c < len; c++) {
        metaCol = metaCols[c];
        if (!metaCol.isHidden && !metaCol.requiredForCreate) {
            _buildRowDataCells(metaCol);
        } else if (metaCol.showHiddenColumnOnCreate(gridInfo) || (metaCol.requiredForCreate && !originalRow)) {
            // only require the metaCol if it's not a clone
            requiredCols.push(metaCol);
        }
    }

    // insert an empty cell before the required columns if this is a new parent row and a concatenated view child is on the grid
    htmlArr.push(GBRowHelper.getFlatViewColDataHtml(gridInfo, null));

    for (var d=0, len=requiredCols.length; d<len; d++) {
        metaCol = requiredCols[d];
        _buildRowDataCells(metaCol);
    }

    function _buildRowDataCells(metaCol) {
        cellProps = getCellProperties(metaCol, newCellValue, null, gridInfo, false);
        cellClasses = getCellClassForContent(metaCol, newCellValue, cellProps.readOnly);
        cellClass = (cellClasses.length > 0 ? 'class="'+cellClasses+'"' : '');
        htmlArr.push('<td name="'+metaCol.fieldId+'" '+cellClass+'>'+cellProps.cellHtml+'</td>');
    }

    htmlArr.push(
        GBRowHelper.getLastColHtml(gridInfo, true)
        + '</tr>'
    );

    // insert row
    if(originalRow){
        if(originalRow.next('.cr').length > 0){
            // user is cloning a parent row on a multi-object grid
            // if the record has one or more child record section as adjecent following siblings,
            // find the last child section tr and insert the cloned record after it
            newRow = jq(htmlArr.join('')).insertAfter(originalRow.nextUntil(':not(.cr)').last());
        }else{
            // user is cloning a child row or any record on a single object grid
            newRow = jq(htmlArr.join('')).insertAfter(originalRow);
        }

    }else{
        // user is creating a new record
        newRow = jq(htmlArr.join('')).insertBefore(firstDataRow);
    }

    // set all the element events
    setEventsForNewRow(newRow);

    // if this is a parent row show the new child object sections
    if (isParentTable) {
        GBActions.addNewRelatedObjects(newRow);
    }

    /* TODO when mass updates are supported for new records
     // display the extra required columns for this object
     toggleRequiredFieldsForCreatesInMassUpdatesWidget(gridInfo, true);
     */

    if (firstDataRowExists) {
        // init summary row if applicable when creating the first new row, but only after we added the first data row
        GBSummary.initSummaryRow();
    }

    // reinitialize draggable resize columns on the new row if they've been already initialized
    GBDraggableResizeColumns.reinitOnNewRow();

    GBConditionalFields.handleNewRow(newRow);

    return newRow; // clone uses the returned newRow object
}