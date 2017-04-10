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
//Filename:grunt_src/bonushelpers.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
//-- your info goes here:bonushelpers
//-- to deploy run: grunt deployGridBuddyResource:bonushelpers


function lneBonusHelp(fieldInfo) {
    this.anyBonusRecs = [];
    this.$branch = '';
    this.$container = '';
    this.$currentRow = '';
    this.currentRunLogs = [];
    this.errorMsgs = [];
    this.fieldInfo = fieldInfo;
    this.lneBonusHelperLogs = [];
    this.map = {};
    this.newValues = [];
    this.numberRowsAdded = 0;
    this.relatedBonusRecs = []; 
    this.retroDealType = '';
    this.retroBonusRecs = [];
    this.$rows = '';
    this.showingError = false;

    this.boot();
}

lneBonusHelp.prototype = {
    boot: function() {
        var bh = this;
        var fieldDetail = {};
        var fieldInfo = bh.fieldInfo;
        var $buttonBar, cannotSaveMarkup;

        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Boot Start ' + fieldInfo.humanGridName + ' @@@@@@@@@@@@');

        var rowFieldChangeHandler = function(e) {

            try{
                var $branch, $currentRow, $label, $rowsParent;

                /**
                *   Make sure we know what type of bonus was changed.
                *   The inputs all get change handlers so we need to not process any mismatching bonus types.
                *   A single instance of bonusHelpers will process any Artist Retro bonuses, another instance any Artist Deal bonuses etc
                *
                */
                $currentRow = jq(e.target).closest('tr.dr');
                $rowsParent = $currentRow.closest('div.childData');
                $branch = $currentRow.closest('.branch');
                if ($branch.length === 0) {
                    $branch = $rowsParent.closest('.branch');
                    console.log('RESET $branch to ' );
                    console.log($branch);
                }
                //-- save $branch for when we append any error message markup later on
                bh.$branch = $branch;
                bh.currentRunLogs.push('closest branch');
                bh.currentRunLogs.push($branch);
                $label = $branch.find('.createNew[title="' + fieldInfo.tableNewRowLabel + '"]').first();
                bh.currentRunLogs.push('label');
                bh.currentRunLogs.push($label);

                bh.errorMsgs = [];

                var currentGridTitle = $branch.find('.toggleData:first').find('span').get(1).innerText;

                //-- Make sure we don't try and deal with something we are not supposed to
                //if (!$label || $label.attr('title') !== fieldInfo.tableNewRowLabel ) {
                 if (!currentGridTitle || currentGridTitle.indexOf(fieldInfo.humanGridName) == -1 ) {
                    bh.currentRunLogs.push('%%%%%%%%%%%%%%%%% rowFieldChangeHandler ' + fieldInfo.humanGridName + ' EXIT');
                    bh.currentRunLogs.push('Bonus helpers cannot determine current table to handle input changes. This will break overlap checks etc');
                    return false;
                } else {
                    bh.currentRunLogs.push('%%%%%%%%%%%%%%%%% rowFieldChangeHandler ' + fieldInfo.humanGridName + ' proceeeding!');
                    bh.currentRunLogs.push('$$$$$$$$$$$$$$$$$$ Change bonus detail ' + fieldInfo.humanGridName + ' $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
                    bh.currentRunLogs.push(e.target);
                    bh.prepOp('edit', e);

                    bh.checkStartRangeNotBlank();
                    bh.checkRange();
                    bh.checkHighestEndPoint();
                }
            }catch(e){
                console.log('there is a bug in rowFieldChangeHandler located in bonushelpers.js');
            }
        }
        
        //-- may or may not be displayed if in error
        $buttonBar = jq('div.gridBtns.top');
        cannotSaveMarkup = '<div id="fe-cannot-save" class="fe-cannot-save hide">Please correct errors below to save.</div>';
        if (!jq('#fe-cannot-save').hasClass('hide')) {
            $buttonBar.append(cannotSaveMarkup);
        }


        jq('body #gbMainTable').on('click', '.createNew[title="' + fieldInfo.tableNewRowLabel + '"]', function(e){ 
            bh.currentRunLogs.push('$$$$$$$$$$$$$$$$$$ New bonus detail ' + fieldInfo.humanGridName + ' $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
            bh.prepOp('new', e);
            bh.newBonusDetailPrefill();
        });

        jq('body #gbMainTable').on('change', 'input', function(e) {
            rowFieldChangeHandler(e);
        });

        if (bh.fieldInfo.uniqueness === 'copromoter' || bh.fieldInfo.uniqueness === 'artistdeal') {
            //-- Changing the Type can change if the end range should be blank or not
            //-- so try and catch it early
            jq('tbody td[name="v1"]').on('change', 'select', function(e) {
                rowFieldChangeHandler(e);
            });
        }

        $saveButton = jq('body .gridBtns').find('.saveBtn:not(.none)').first();

        $saveButton.on('click' , function(e) {
            var errorBoxSel = '.fe-injected-validation-' + bh.fieldInfo.shortGridName;

            if (bh.errorMsgs.length > 0) {
                e.preventDefault();
                e.stopPropagation();
                var $nosave = jq('body').find('#fe-cannot-save').first();
                $nosave.removeClass('hide');
                $nosave.addClass('show');
                bh.showingError = true;

                //-- When the validation runs again it will handle show/hide in bh.stopSave
                //-- for the first run we show it here as this will run after
                jq(errorBoxSel).removeClass('hide').addClass('show');
            } else {
                jq('#fe-cannot-save').removeClass('show').addClass('hide');
                bh.showingError = false;
            }
        });
    },
    compareContinuous: function(startArr,endArr){
          var isContinuous = [];
          var len = endArr.length;
          var isReversed; 

          //Don't check when new record is created and default is 0 and the reverse case 
          if(len <3 && startArr[0] != 0 || len <3 && startArr[0] < startArr[1] ){
            if(startArr[0] > startArr[1]){
                isReversed = true; 
              } else {
                isReversed = false; 
              }

          }else if(len >= 3 && startArr[0] != 0 || startArr[1] != 0 ){
                if( startArr[0] > startArr[1] && startArr[1] > startArr[2]) {
                isReversed = true; 
              } else {
                isReversed = false; 
              }
          }
          //The reverse messes up sometimes, check this 
          if(isReversed == false){
            var startArr = startArr.reverse();
            var endArr = endArr.reverse(); 
          }
            //If there's only 2 rows 
            if(len == 2){
                if (endArr[len-1] + 1 == startArr[0]){
                  isContinuous.push("true");
                }else{
                   isContinuous.push("false");
                }
            }
              
              //When there's 3 or more fields 
            if(len >2){
                for(var i=0; i<len; i++ ){
                    if(i+1 < len){
                        //check start & end points and special condition for the last null case 
                        if(startArr[i] == endArr[i+1] +1 || endArr[i+1] == null && i+1 == len-1){
                            isContinuous.push("true");
                        }else{
                            isContinuous.push("false");
                        }
                    }
                 
                }
            }
          
          
          if(isContinuous.indexOf("false") >= 0){
              return false; 
          }else{
              return true;
          }
    },
    prepOp: function(op, e) {
        var bh = this;
        if (this.fieldInfo.uniqueness) {
            bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ prepOp Start ' + this.fieldInfo.humanGridName + ' @@@@@@@@@@@@');
        } else {
            bh.currentRunLogs.push('$$$$$$$$$$$$$$ Warning! Cannot determine fieldInfo uniqueness - will cause later issues $$$$$$$$$$$$$$$$$$$');
        }

        var $branch, $con, $masterTable;
        var targetRow = jq(e.target).closest('tr.dr');
        //-- targetRow used to establish if row has focus later
        bh.targetRow = targetRow;

        if (op === 'new') {
            $container = jq(e.target).closest('.crDataContainer');
            $rowsParent = $container.find('div.childData');
            bh.$rows = $rowsParent.find('tr.dr:not(.none)');
            bh.$currentRow = bh.$rows[0];
            bh.$rowsParent = $rowsParent;
            bh.popBonusRecordsArray();
            bh.popRelatedBonusRecordsArray();
        } else if (op === 'edit') {
            $container = jq(e.target).closest('tr.dr');
            bh.$currentRow = $container;
            $rowsParent = $container.closest('div.childData');
            bh.$rows = $rowsParent.find('tr.dr:not(.none)');
            bh.$rowsParent = $rowsParent;
            bh.popBonusRecordsArray();
            bh.popRelatedBonusRecordsArray();    
        }

        if (bh.fieldInfo.uniqueness === 'artistretro' && op === 'edit') {
            //-- the deal type for artistretro is on the parent table (deal not bonus)
            $branch = bh.$currentRow.closest('.branch').first();
            $con = $branch.closest('tr').first();
            $masterTable = $con.prev('tr').first();
            bh.retroDealType = $masterTable.find('td[name="v8"] select').val();
            if (!bh.retroDealType) {
                bh.retroDealType = $masterTable.find('td[name="v8"] .plTxt').text();
            }

            bh.currentRunLogs.push('## bh.retroDealType is ' + bh.retroDealType);
        }

    },
    getCurrentRec: function(sub) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' getCurrentRec');
        var $cells = jq(bh.$currentRow).find('td');
        var currentRec = bh.popBonusRecordsObj($cells);
        if (bh.fieldInfo.uniqueness !== 'artistretro' && !currentRec.BonusBase__c) {
            // current row empty, use last entered
            $cells = jq(bh.$rows[1]).find('td');
            currentRec = bh.popBonusRecordsObj($cells);
        }

        currentRec = bh.filterOutCommas(currentRec);
        return currentRec;
    },
    checkStartRangeNotBlank: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkStartRangeNotBlank');

        var currentRec = bh.getCurrentRec();
        if (currentRec.rangeStart == '') {
            if (bh.errorMsgs.indexOf('startBlank') < 0) {
                bh.errorMsgs.push('startBlank');
            }
        } else {
            if (bh.errorMsgs.indexOf('startBlank') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('startBlank'), 1);
            }                
        }

        bh.checkError();
    },
    checkRange: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkRange');

        var amended = {};
        var anyBonusRecs = [];
        var $cells;
        var currentRec = bh.getCurrentRec();
        var endPoints = [];
        var highestEnd;
        var highestStart;
        var overlapEnd = false;
        var overlapStart = false;
        var related = bh.relatedBonusRecs;
        var startPoints = [];
        var results = [];

        for (var i = 0; i < related.length; i++) {
            if (related[i].rangeStart) {
                startPoints.push(parseInt(related[i].rangeStart));
            } else {
                startPoints.push(null);  
            }
            if (related[i].rangeEnd) {
                endPoints.push(parseInt(related[i].rangeEnd));
            } else {
                endPoints.push(null);
            }
        }


        if (startPoints) {
            highestStart = Math.max.apply(Math, startPoints) || null;
        }
        if (endPoints) {
            highestEnd = Math.max.apply(Math, endPoints) || null;
        }
        

        //Logic for looking at overlapping points 
        for (var i = 1; i < related.length; i++) {
            //-- only compare different rows
            bh.currentRunLogs.push('Standard range check!');
            //-- standard range check
            bh.currentRunLogs.push('related[i].rangeStart ' + related[i].rangeStart);
            bh.currentRunLogs.push('related[i].rangeEnd ' + related[i].rangeEnd);
            bh.currentRunLogs.push('currentRec.rangeStart ' + currentRec.rangeStart);
            bh.currentRunLogs.push('currentRec.rangeEnd ' + currentRec.rangeEnd);

            //check for overlap but remove check for when end is "" so it does the logic correctly 
            if (related[i].rangeStart && related[i].rangeEnd && i!= related.length -1 && currentRec.rangeEnd !="") {
                overlapStart = !bh.numberInRange(related[i].rangeStart, related[i].rangeEnd, currentRec.rangeStart);
                overlapEnd = !bh.numberInRange(related[i].rangeStart, related[i].rangeEnd, currentRec.rangeEnd);
                bh.currentRunLogs.push('overlapStart ' + overlapStart);
                bh.currentRunLogs.push('overlapEnd ' + overlapEnd);

                if (overlapStart || overlapEnd) {
                    results.push('true');
                } else {
                    results.push('false');
                }
            }
            //Check overlap when there's a blank end 
            else if(currentRec.rangeEnd == ""){
                //bh.compareContinuous(startPoints, endPoints)
                if(related[i].rangeStart == currentRec.rangeStart){
                     overlapStart = !bh.numberInRange(related[i-1].rangeStart, related[i-1].rangeEnd, currentRec.rangeStart);
                }else{
                     overlapStart = !bh.numberInRange(related[i].rangeStart, related[i].rangeEnd, currentRec.rangeStart);
                }
                 if(overlapStart){
                    results.push('true')
                 }else{
                    results.push('false');
                 }
            }
        }

        bh.currentRunLogs.push('results of overlap test');
        bh.currentRunLogs.push(results);

        if (results.length === 0) {
            bh.currentRunLogs.push('no results of overlap tests');
            bh.currentRunLogs.push('bh.relatedBonusRecs');
            bh.currentRunLogs.push(bh.relatedBonusRecs);
        }

        if (results.indexOf('true') >= 0) {
            overlap = true;
        } else {
            overlap = false;
        }

        if (overlap) {
            if (bh.errorMsgs.indexOf('overlap') < 0) {
                bh.errorMsgs.push('overlap');
            }
        } else {
            if (bh.errorMsgs.indexOf('overlap') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('overlap'), 1);
            }                
        }

        //Check if it's continous 
        var secondHighestEndPoint;
      
        
        if(startPoints.length > 1){

                if(startPoints && endPoints){
                    if(!bh.compareContinuous(startPoints, endPoints)){
                        if (bh.errorMsgs.indexOf('mustbeContinuous') < 0) {
                            bh.errorMsgs.push('mustbeContinuous');
                        }
                    }else{
                        if (bh.errorMsgs.indexOf('mustbeContinuous') >= 0) {
                            bh.errorMsgs.splice(bh.errorMsgs.indexOf('mustbeContinuous'), 1);
                        }
                    }
                }
                
        }
    
        if (parseInt(currentRec.rangeStart) && parseInt(currentRec.rangeEnd)) {
            if (parseInt(currentRec.rangeStart) > parseInt(currentRec.rangeEnd)) {
                if (bh.errorMsgs.indexOf('endIsLessThanStart') < 0) {
                    bh.errorMsgs.push('endIsLessThanStart');
                }
            } else {
                if (bh.errorMsgs.indexOf('endIsLessThanStart') >= 0) {
                    bh.errorMsgs.splice(bh.errorMsgs.indexOf('endIsLessThanStart'), 1);
                }
            }

            if (currentRec.rangeStart && highestStart && 
                    parseInt(currentRec.rangeStart) < highestStart && 
                    parseInt(currentRec.rangeEnd) > highestEnd 
                ) 
            {
                if (bh.errorMsgs.indexOf('highestEndNotHighestStart') < 0) {
                    bh.errorMsgs.push('highestEndNotHighestStart');
                }
            } else {
                if (bh.errorMsgs.indexOf('highestEndNotHighestStart') >= 0) {
                    bh.errorMsgs.splice(bh.errorMsgs.indexOf('highestEndNotHighestStart'), 1);
                }
            }
        }

        if (!currentRec.rangeEnd || currentRec.rangeEnd.length === 0) {
            bh.currentRunLogs.push('REMOVE FALSE POSITIVE endIsLessThanStart highestEndNotHighestStart');
            //-- if field now blank remove false positive
            if (bh.errorMsgs.indexOf('endIsLessThanStart') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('endIsLessThanStart'), 1);
            }
            if (bh.errorMsgs.indexOf('highestEndNotHighestStart') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('highestEndNotHighestStart'), 1);
            }  
        } else {
            bh.currentRunLogs.push('OTHER ROWS WITH A HIGHER START AND BLANK END?');
            bh.currentRunLogs.push(currentRec);
            bh.currentRunLogs.push(currentRec.rangeEnd);
            bh.currentRunLogs.push('currentRec.rangeEnd.length ' + currentRec.rangeEnd.length);
            //-- Are there other records that have a higher start point and blank end?
            //-- TODO: If the validator ran on every other row when you change one input this would be redundant...
            //--        although more intensive? 
            for (var r = 0; r < related.length; r++) {
                if (related[r].rangeEnd.length === 0) {
                    if (related[r].rangeStart > currentRec.rangeStart) {
                        if (bh.errorMsgs.indexOf('highestEndNotHighestStart') >= 0) {
                            bh.errorMsgs.splice(bh.errorMsgs.indexOf('highestEndNotHighestStart'), 1);
                        }  
                    }
                }
            }
        }

        bh.checkError();
    },
    numberInComflict: function(list){
        var inConflict = false; 
        for(var i=0; i< list.length; i++){
            if(list[i]){
                if(i == list.length){
                    return; 
                }
                if(list[i] > list[i+1] ){
                    inConflict = true;
                }
            }
        }

        return isConflict; 
    },
    secondMaxInArray: function(arr){ 
        var filteredList = [];

        arr.forEach(function(n){
          console.log(parseInt(n));
          var num = parseInt(n);
          if(isNaN(num)){
            
          }else{
            filteredList.push(num);
          }
        })

        var listArr = filteredList;

        var max = Math.max.apply(null, listArr);
        listArr.splice(arr.indexOf(max), 1); 
        return Math.max.apply(null, listArr); 
    },
    numberInRange: function(relatedStart, relatedEnd, newStart) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' numberInRange');
        return parseInt(relatedStart) <= parseInt(newStart) && parseInt(newStart) >= parseInt(relatedEnd);
    },
    filterOutCommas: function(amended) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' filterOutCommas');

        if (amended.rangeStart && amended.rangeStart.indexOf(',') >= 0) {
            amended.rangeStart = amended.rangeStart.replace(/,/g,'');
        } 

        if (amended.rangeEnd && amended.rangeEnd.indexOf(',') >= 0) {
            amended.rangeEnd =  amended.rangeEnd.replace(/,/g,'');
        } 
        
        return amended;            
    },
    checkHighestEndPoint: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkHighestEndPoint');

        var amended = {};
        var errorMsgs = [];
        var highestStart, tmp;
        var bonusRec = {};
        var related = bh.relatedBonusRecs;
        var startPoints = [];

        //--    When a Retro-type Bonus is defined, if the record with the highest Begin Point 
        //--        (and same Bonus Base, Type, and Apply To values) 
        //--    has a defined End Point, then the user is prompted and prevented from saving
        for (var ii = 0; ii < related.length; ii++) {
            if (parseInt(related[ii].rangeStart)) {
                startPoints.push(parseInt(related[ii].rangeStart));
            }
        }

        if (startPoints.length > 0) {
            highestStart = Math.max.apply(Math, startPoints);
        } else {
            highestStart = 0;
        }

        if (highestStart) {
            tmp = startPoints.indexOf(highestStart);
            bonusRec = related[tmp];
        } else {
            bonusRec = bh.getCurrentRec();
        }

        if (bonusRec && 
                (bonusRec.Type__c === 'Retro' && bh.fieldInfo.uniqueness === 'copromoter') ||
                (bonusRec.Type__c === 'Retro' && bh.fieldInfo.uniqueness === 'artistdeal') ||
                (bh.fieldInfo.uniqueness === 'artistretro')
                //(bh.retroDealType === 'Retro Gross Deal' || bh.retroDealType === 'Retro Net Deal' && bh.fieldInfo.uniqueness === 'artistretro') 
            ) 
        {
            

            if (bonusRec && bonusRec.rangeEnd) {
                bh.currentRunLogs.push(bonusRec.rangeEnd);
                bh.currentRunLogs.push(parseInt(bonusRec.rangeEnd));
            }

            //-- check it has no end point entered
            if (bonusRec && bonusRec.rangeEnd && parseInt(bonusRec.rangeEnd) > 0) {
                bh.currentRunLogs.push('bonusRec.rangeEnd is ' + bonusRec.rangeEnd);
                if (bh.errorMsgs.indexOf('endNotBlank') < 0) {
                    bh.errorMsgs.push('endNotBlank');
                    bh.currentRunLogs.push('adding endNotBlank error');
                }
            } else {
                bh.currentRunLogs.push('bonusRec.rangeEnd cannot be deteremined');
                if (bh.errorMsgs.indexOf('endNotBlank') >= 0) {
                    bh.errorMsgs.splice(bh.errorMsgs.indexOf('endNotBlank'), 1);
                    bh.currentRunLogs.push('removed endNotBlank error');
                }
            }
        } 

        bh.checkForMultipleBlankEndPoints();

    },
    countInArray: function(dataset,search){
        var count = dataset.reduce(function(n, val) {
              return n + (val === search);
        }, 0);
        return count; 
    },
    checkForMultipleBlankEndPoints: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkForMultipleBlankEndPoints');

        var amended = {};
        var currentRec = bh.getCurrentRec();
        var errorMsgs = [];
        var highestStart, tmp;
        var bonusRec = {};
        var endPoints = [];
        var related = bh.relatedBonusRecs;
        var startPoints = [];

        for (var ii = 0; ii < related.length; ii++) {
            if (parseInt(related[ii].rangeStart)) {
                startPoints.push(parseInt(related[ii].rangeStart));
            }
            if (related[ii].rangeEnd && parseInt(related[ii].rangeEnd)) {
                endPoints.push(parseInt(related[ii].rangeEnd));
            } else if (related[ii] && related[ii].rangeEnd === '') {
                bh.currentRunLogs.push('IS BLANK!');
                endPoints.push('blank');
            }
        }

       

        if (endPoints.indexOf('blank') >= 0 && !currentRec.rangeEnd) {
            //Only push end not there message when its there's more than 1 blank Cont for artist retro and artistdeal && type =retro
            if (bh.fieldInfo.uniqueness == 'artistretro' || bh.fieldInfo.uniqueness == 'artistdeal' || bh.fieldInfo.uniqueness == 'copromoter' && (related[0].Type__c== "Retro" || related[0].Type__c== "Step Up" ) ){
                var blankCount = bh.countInArray(endPoints,"blank");
                if(blankCount >= 2){
                    bh.errorMsgs.push('endMultipleBlanks');
                } 
            }else if(bh.errorMsgs.indexOf('endMultipleBlanks') === -1 ){
                bh.errorMsgs.push('endMultipleBlanks');
            }
        } else {
            if (bh.errorMsgs.indexOf('endMultipleBlanks') >= 0) {
                bh.currentRunLogs.push('found endMultipleBlanks in errorMsgs removing it');
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('endMultipleBlanks'), 1);
            }
        }

        if (!currentRec.rangeEnd && bh.errorMsgs.indexOf('endMultipleBlanks') === -1) {
            if (bh.errorMsgs.indexOf('endNotBlank') >= 0) {
                bh.errorMsgs.splice(bh.errorMsgs.indexOf('endNotBlank'), 1);
            }
        }

        bh.currentRunLogs.push('at end of checkForMultipleBlankEndPoints bh.errorMsgs is');
        bh.currentRunLogs.push(bh.errorMsgs);

        bh.checkError(); 
    },
    newBonusDetailPrefill: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' newBonusDetailPrefill');
        var fieldDetail = bh.fieldInfo.fields;
        var $cells, newValues;

        for (var i = 0; i < bh.$rows.length; i++){
            c = i + 1;

            $cells = jq(bh.$rows[i]).find('td');

            if (i === 1) {
                newValues = bh.popNewValuesArray($cells);
                //--filter out empty row
                //-- make sure starting point is 0
                if (newValues[0] && newValues[1] && !newValues[parseInt(fieldDetail.rangeStart.order)]) {
                    newValues[parseInt(fieldDetail.rangeStart.order)] = 0;
                }
            }
        }

        if (newValues) {
            $cells = jq(bh.$rows[0]).find('td');
            bh.updateMarkupDefaultValues($cells, newValues);
        } else {
            bh.currentRunLogs.push('newValues not set');
        }
    },
    popBonusRecordsArray: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' popBonusRecordsArray');
        var $cells, obj;
        bh.anyBonusRecs = [];

        for (var i = 0; i < bh.$rows.length; i++) {
            $cells = jq(bh.$rows[i]).find('td');
            obj = bh.popBonusRecordsObj($cells);
            obj = bh.filterOutCommas(obj);
            bh.anyBonusRecs.push(obj);                
            obj = {};
        }
    },
    popRelatedBonusRecordsArray: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' popRelatedBonusRecordsArray');

        var anyBonusRecs = [];
        var $cells;
        var currentRec = bh.getCurrentRec();
        var focus;
        var rec;
        var related = [];
        var $rows;
        var uniqueness = bh.fieldInfo.uniqueness;

        $rows = bh.$rowsParent.find('tr.dr:not(.none)');

        for (var ii = 0; ii < $rows.length; ii++) {
            //populated anyBonus recs 
            $cells = jq($rows[ii]).find('td');
            rec = bh.popBonusRecordsObj($cells);
            anyBonusRecs.push(rec);
        }

        for (var i = 0; i < anyBonusRecs.length; i++) {
            rec = bh.filterOutCommas(anyBonusRecs[i]);
            anyBonusRecs[i] = rec;

            bh.currentRunLogs.push('anyBonusRecs loop i ' + i);
            //-- same uniqueness as new entry? 
            //-- push to array
            if (uniqueness === 'copromoter') {
                if (currentRec.BonusBase__c == anyBonusRecs[i].BonusBase__c && 
                        currentRec.Type__c == anyBonusRecs[i].Type__c) 
                {
                    related.push(anyBonusRecs[i]);
                }
            } else if (uniqueness === 'artistdeal') {
                if (currentRec.BonusBase__c == anyBonusRecs[i].BonusBase__c && 
                        currentRec.Type__c == anyBonusRecs[i].Type__c &&
                        currentRec.ApplyTo__c == anyBonusRecs[i].ApplyTo__c ) 
                {
                    related.push(anyBonusRecs[i]);
                }
            } else if (uniqueness === 'artistretro') {
                related.push(anyBonusRecs[i]);
            }
        }


        bh.relatedBonusRecs = related;
        bh.currentRunLogs.push('bh.relatedBonusRecs set to at exit of popRelatedBonusRecordsArray');
        bh.currentRunLogs.push(bh.relatedBonusRecs);
    }, 
    updateMarkupDefaultValues: function($cells, newValues) {
        //Updates the properties of the dropdowns on prefill 
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' updateMarkupDefaultValues');
        var fieldInfo = bh.fieldInfo.fields;
        var highestStart, highestStartIndex, index, int, newStart, startPoints;
        highestStart = 0;
        int = 0;
        startPoints = [];

        for (var prop in fieldInfo) {
            if (fieldInfo.hasOwnProperty(prop)) {
                fieldDetail = fieldInfo[prop];
                index = parseInt(fieldDetail.order);

                if (newValues[index] !== null && newValues[index] !== '-' && fieldDetail.prepop === 'true') {
                    if (fieldDetail.type === 'drop') {
                        if (jq($cells[0]).find('.icon-ellipses').length > 0) {
                            jq($cells[parseInt(fieldDetail.order)]).change();
                            jq($cells[parseInt(fieldDetail.order)]).find('select').val(newValues[index]);
                            jq($cells[parseInt(fieldDetail.order)]).change();
                        } else {
                            jq($cells[parseInt(fieldDetail.order)]).find('select').val(newValues[index]);
                            jq($cells[parseInt(fieldDetail.order)]).find('select').change();
                        }
                    } else {
                        jq($cells[parseInt(fieldDetail.order)]).find('input').val(newValues[index]);
                        jq($cells[parseInt(fieldDetail.order)]).find('input').change();
                    }
                }
            }
        }

        if (fieldInfo.rangeStart.prepop === 'calc') {
            bh.currentRunLogs.push('CALC');
            bh.currentRunLogs.push(bh.relatedBonusRecs);
            //-- if new record has other rows with same base + type, find max start of that
            for (var ii = 0; ii < bh.relatedBonusRecs.length; ii++) {
                int = parseInt(bh.relatedBonusRecs[ii].rangeStart);
                startPoints.push(int);
            }
            
            if (startPoints.length > 0) {
                highestStart = Math.max.apply(Math, startPoints.filter(function(n) { return !isNaN(n); }));
            } else {
                highestStart = startPoints[0] || null;
            }

            highestStart = highestStart ? highestStart : 0;
            bh.currentRunLogs.push('highestStart is ' + highestStart);
            
            for (ii = 0; ii < bh.relatedBonusRecs.length; ii++) {
                if (parseInt(bh.relatedBonusRecs[ii].rangeStart) === parseInt(highestStart)) {
                    if (parseInt(bh.relatedBonusRecs[ii].rangeEnd)) {
                        newStart = parseInt(bh.relatedBonusRecs[ii].rangeEnd) + 1;
                        jq($cells[parseInt(fieldInfo.rangeStart.order)]).find('input').val(newStart);
                        jq($cells[parseInt(fieldInfo.rangeStart.order)]).find('input').change();
                    } 
                }
            }
        }
    },
    extractFromMarkup: function($cells) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' extractFromMarkup');
        var bonusRec = {};
        var fieldInfo = bh.fieldInfo.fields;
        var fieldOrder;
        var value;

        for (var prop in fieldInfo) {
            if (fieldInfo.hasOwnProperty(prop)) {
                fieldDetail = fieldInfo[prop];
                fieldOrder = fieldDetail.order;

                if (fieldDetail.type === 'drop') {
                    if (jq($cells[0]).find('.icon-ellipses').length > 0) {
                        value = jq($cells[parseInt(fieldOrder)]).find('.plTxt').text();
                        if (!value) {
                            bh.currentRunLogs.push('DID NOT FIND VALUE IN PLTXT TRYING SELECT');
                            value = jq($cells[parseInt(fieldOrder)]).find('select').val();
                        }
                    } else {
                        value = jq($cells[parseInt(fieldOrder)]).find('select').val();
                    }
                } else {
                    value = jq($cells[parseInt(fieldOrder)]).find('input').val();
                }

                bonusRec[prop] = value;
            }
        }

        return bonusRec;
    },
    popBonusRecordsObj: function($cells) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' popBonusRecordsObj');
        var bonusRec = bh.extractFromMarkup($cells);
        return bonusRec;
    },
    popNewValuesArray: function($cells) {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' popNewValuesArray');
        var bonusRec = {};
        var fieldInfo = bh.fieldInfo.fields;
        var index = 0;
        var length = 0;
        var newValues;
        
        for (var prop in fieldInfo) {
            if (fieldInfo.hasOwnProperty(prop)) {
                length++;
            }
        }
        newValues = new Array(length + 1);
        newValues[0] = '-';

        bonusRec = bh.extractFromMarkup($cells);
        
        for (var prop in bonusRec) {
            if (bonusRec.hasOwnProperty(prop)) {
                index = fieldInfo[prop].order;
                newValues[parseInt(index)] = bonusRec[prop];
            }
        }
        return newValues;
    },
    checkError: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' checkError');

        if (bh.errorMsgs.length > 0) {
            bh.stopSave();
        } else {
            bh.allowSave();
        }
    },
    stopSave: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' stopSave');

        var shortGridName = bh.fieldInfo.shortGridName;
        var errorMsgs = bh.errorMsgs;
        var errorBoxSel = '.fe-injected-validation-' + shortGridName;
        var markup = '';
        var parent, pWithStyle, save;
        
        //jq(bh.$currentRow).attr('style','border: solid 2px red;');

        //-- now using bh.$branch
        //parent = jq('#gbMainTable').find('.crDataContainer').first();
        
        jq(errorBoxSel).remove();

        //-- Main error container
        markup += '<div class="fe-injected-validation fe-injected-validation-' + shortGridName +' hide"> ';
        markup += '<p>Please correct the following issues in the <span style="font-weight: 800;">';
        markup += bh.fieldInfo.humanGridName + '</span> grid to allow saving of your work.</p>';
        
        //-- Add individual errors
        pWithStyle = '<p class="error">';
        for (var i = 0; i < errorMsgs.length; i++) {

            if (errorMsgs[i] === 'endIsLessThanStart') {
                markup += pWithStyle + 'End point less than start point' + '</p>';
            }
            if (errorMsgs[i] === 'overlap') {
                markup += pWithStyle + 'Overlapping start and end points' + '</p>';
            }
            if (errorMsgs[i] === 'endNotBlank') {
                if (shortGridName == 'retro') {
                    markup += pWithStyle + 'Highest tier of the retro deal must have a blank Ending Range so the max is met' + '</p>';
                } else {
                    markup += pWithStyle + 'Highest tier of the bonus must have a blank End Point so the max is met' + '</p>'; 
                }
            }
            if (errorMsgs[i] === 'endMultipleBlanks') {
                markup += pWithStyle + 'Please ensure only the highest tier of the bonus has a blank End Point ';
                markup += '</p>';
            }
            if (errorMsgs[i] === 'startBlank') {
                markup += pWithStyle + 'Each start point must be entered' + '</p>';
            }
            if (errorMsgs[i] === 'startAndEndMatch') {
                markup += pWithStyle + 'The start and end range cannot match' + '</p>';
            }
            if (errorMsgs[i] === 'highestEndNotHighestStart') {
                markup += pWithStyle + 'Only the tier with the highest start range can have the highest end range' + '</p>';
            }
            if (errorMsgs[i] === 'mustbeContinuous') {
                markup += pWithStyle + 'Start Range must be continous from previous Ending Range' + '</p>';
            }
        }

        //-- CLose main error container
        markup += '<input class="fe-injected-validation-' +  shortGridName + '-anchor" style="display: none;" /></div>';

        //-- Add to page
        //--         jq(parent).append(jq(markup));
        bh.$branch.append(jq(markup));
        
        //-- Add error marking to save
        jq('body .gridBtns').find('.saveBtn:not(.none)').first().attr('style','border: 2px solid red;');
        bh.prepLogs();

        if (bh.showingError) {
            jq(errorBoxSel).removeClass('hide').addClass('show');
        }
    },
    allowSave: function() {
        var bh = this;
        bh.currentRunLogs.push('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  ' + this.fieldInfo.humanGridName + ' allowSave');
        bh.errorMsgs = [];
        var shortGridName = bh.fieldInfo.shortGridName;
        var errorBoxSel = '.fe-injected-validation-' + shortGridName;

        for (var i = 0; i < bh.$rows.length; i++) {
            jq(bh.$rows[i]).attr('style','border: none;');
        }

        jq(errorBoxSel).remove();
        jq('#fe-cannot-save').removeClass('show').addClass('hide');
        jq('body .gridBtns').find('.saveBtn:not(.none)').first().attr('style','border: none;');
        bh.showingError = false;
        bh.prepLogs();
    },
    prepLogs: function() {
        var bh = this;
        bh.lneBonusHelperLogs.push('OP START ' + new Date().toString());
        for (var i = 0; i < bh.currentRunLogs.length; i++) {
            bh.lneBonusHelperLogs.push(bh.currentRunLogs[i]);
            console.log(bh.currentRunLogs[i]);
        }
        bh.currentRunLogs = [];
    }
};



/*
//Filename:grunt_src/copromoterHelpers.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
/**
 *  Common copromoter scripts for primary and secondary grids.
 *  @author John Casimiro <jcasimiro@salesforce.com>
**/

/**
 *  Finds the Live Nation row and disables all inputs in that row.
 *  <p>Called on document.ready</p>
 **/
function makeLiveNationRowReadOnly() {
	console.log('makeLiveNationRowReadOnly enter');
	var rows = jq("#gbMainTable").find(".dr");
	var foundLNRow = false;
	for (var i = 0; i < rows.length; i++) {
		jq(rows[i]).find('input').each(function() {
			if (this.value == 'Live Nation') {
				// color tds
				jq(this).closest('tr').find('td').each(function() {
					jq(this).css('background-color', '#ccc');
				});
				// disable inputs
				jq(this).closest('tr').find('input').each(function() {
					jq(this).prop('disabled', true);
				});
				// click to show dropdowns
				jq(this).closest('tr').find('td .plTxt').each(function() {
					jq(this).click();
				});
				// disable dropdowns 
				jq(this).closest('tr').find('select').each(function() {
					jq(this).prop('disabled', true);
				});
				// mark the Live Nation Row for future exclusion.
				jq(this).closest('tr').addClass('LNRow');
				foundLNRow = true;
			}
		});
		if (foundLNRow == true)
			break;
	}
	// hide bonus details and deal settlement ledgers for the LNE row
	jq("#gbMainTable tr.LNRow").find("span.icon-arrow").first().hide();
	jq("#gbMainTable tr.LNRow").find("input.dl").first().hide();
	jq("#gbMainTable tr.LNRow").find("div.actionsBtn").first().hide();
	jq("#gbMainTable tr.LNRow").next().hide();
	jq("#gbMainTable tr.LNRow").next().next().hide();
}

/**
 *  Event handler for the Event Profit column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function eventProfitChangedHandler( evt ){
	console.log('event event profit handler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).each(function(){
		if (jq.isNumeric(parseInt(jq( this ).val()))){
			console.log('value' + jq( this ).val());
	    	total += parseInt(jq( this ).val());
		}
	});
	console.log('total = ' + total);

	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
		jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).val(remainder);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).change();

}

/**
 *  Event handler for the Event Loss column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function eventLossChangedHandler( evt ){
	console.log('event event loss handler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'EventLoss__c' )).each(function(){
	    if (jq.isNumeric(parseInt(jq( this ).val()))){
	    	total += parseInt(jq( this ).val());
		}
	});
	
	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventLoss__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventLoss__c' )).change();

}

/**
 *  Event handler for the Expense Adjustment Profit column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function expenseAdjustmentProfitChangedHandler( evt ){
	console.log('expenseAdjustmentProfitChangedHandler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentProfit__c' )).each(function(){
	    if (jq.isNumeric(parseInt(jq( this ).val()))){
	    	total += parseInt(jq( this ).val());
		}
	});
	
	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentProfit__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentProfit__c' )).change();

}

/**
 *  Event handler for the Expense Adjustment Loss column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function expenseAdjustmentLossChangedHandler( evt ){
	console.log('expenseAdjustmentLossChangedHandler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentLoss__c' )).each(function(){
	    if (jq.isNumeric(parseInt(jq( this ).val()))){
	    	total += parseInt(jq( this ).val());
		}
	});
	
	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentLoss__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentLoss__c' )).change();

}

/**
 *  Event handler for the Ancillary Revenue column.
 *  Calculates remainder and stores in Live Nation row.
 **/
function ancillaryRevenueChangedHandler( evt ){
	console.log('ancillaryRevenueChangedHandler');
	var total = 0;
	var remainder = 0;

	jq('#gbMainTable > tbody > tr.dr').not('.LNRow').find(createFieldInputSelector( 'AncillaryRevenue__c' )).each(function(){
	    if (jq.isNumeric(parseInt(jq( this ).val()))){
	    	total += parseInt(jq( this ).val());
		}
	});
	
	if (total > 100){
		alert('The total of non Live Nation rows cannot be greater than 100. Current Total = '+total);
	} 

	remainder = 100 - total;
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'AncillaryRevenue__c' )).val(remainder);
	jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'AncillaryRevenue__c' )).change();

}

/**
 *  Sets listeners on the columns.
 **/
function setlisteners(){
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "EventProfit__c" ),eventProfitChangedHandler );
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "EventLoss__c"),eventLossChangedHandler );
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "ExpenseAdjustmentProfit__c" ),expenseAdjustmentProfitChangedHandler );
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "ExpenseAdjustmentLoss__c" ),expenseAdjustmentLossChangedHandler );
	jq("#gbMainTable > tbody > tr.dr").not(".LNRow").on( "change", createFieldInputSelector( "AncillaryRevenue__c" ),ancillaryRevenueChangedHandler );
}

/**
 *  Calls a recalculation of the columns.
 **/
function recalculateLNRow(){
	eventProfitChangedHandler();
	eventLossChangedHandler();
	expenseAdjustmentProfitChangedHandler();
	expenseAdjustmentLossChangedHandler();
	ancillaryRevenueChangedHandler();
}
/*
//Filename:grunt_src/primarycopromoters.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
/**
 *  Defaults the PrimarySecondaryCoPromoter__c field to Primary
 **/
function setPrimarySecondaryCoPromoter(){
	jq('#gbMainTable').find(createFieldInputSelector('PrimarySecondaryCoPromoter__c')).each(function() {
        jq(this).val('Primary').change();
        jq(this).prop("disabled", true); 
    
	});
}

jq(document).ready(function() {
	var initialFocus = true;

	//-- always call after jq(document).ready for all scripts
	convertGridInfoMap(gridInfoMap);

	//-- mark the grid as not ready, so change events should not be fired
	markTableReady(false);

	makeLiveNationRowReadOnly();
	
	//"Event Total" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');

	jq('#gbMainTable ' + createFieldSelector('RecordTypeId')).hide();
	jq('#gbMainTable ' + createFieldSelector('PrimarySecondaryCoPromoter__c')).hide();
	jq('#gbMainTable tr.firstHeader td.nc').hide();
	jq('#gbMainTable ' + createFieldSelector('Rank__c')).closest('td').hide();

	jq('input.createNew').click(function(){ // if a new row is added we need ...
		setlisteners(); //update listeners
		setPrimarySecondaryCoPromoter(); // set default Primary/Secondary Co-Promoter
		jq("#gbMainTable > tbody > tr > td > span.minus").on("click", recalculateLNRow); // listen for row removals and recalculate

		//set record type to co-promoter
		var newRowEl=jq('#gbMainTable tbody > tr.dr')[0];
		var recordTypeInput=jq(newRowEl).find(createFieldInputSelector('RecordTypeId'));
		recordTypeInput.val('Co-Promoter').change();
		recordTypeInput.closest('td').hide();
		jq(newRowEl).find(createFieldInputSelector('PrimarySecondaryCoPromoter__c')).closest('td').hide();
		jq('#gbMainTable tbody > tr.firstHeader td.nc').hide(); // hide Rank header
		jq(newRowEl).find(createFieldInputSelector('Rank__c')).closest('td').hide();
		setPrimarySecondaryCoPromoter();
	});

	jq('input.saveBtn').click(function(){ // extra validation on totals
		if (parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventProfit__c' )).val()) < 0 ||
			parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'EventLoss__c' )).val()) < 0 ||
			parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentProfit__c' )).val()) < 0 ||
			parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'ExpenseAdjustmentLoss__c' )).val()) < 0 ||
			parseInt(jq('#gbMainTable tr.LNRow').find(createFieldInputSelector( 'AncillaryRevenue__c' )).val()) < 0){

			alert('The total of non Live Nation rows cannot be greater than 100. Please make sure there are no negative numbers in the Live Nation row.');
			return false;
		}
	});

	jq('.saveBtn').click(function() {
		parent.postMessage('Saving', '*');
	});

	jq('.deleteItem').click(function() {
		parent.postMessage('Saving', '*');
	});	

	parent.postMessage('Loaded','*');
	

	jq('.saveBtn').click(function() {
		parent.postMessage('Saving', '*');
	});

	jq('.deleteItem').click(function() {
		parent.postMessage('Saving', '*');
	});	
	
	parent.postMessage('Loaded','*');
	
	setlisteners();
	markTableReady(true);
	gridStateMessagingController();

	var fieldInfoPrimary = {
        fields : {
            BonusBase__c: {
                type: 'drop',
                order: 1,
                prepop: 'true'
            },
            Type__c: {
                type: 'drop',
                order: 2,
                prepop: 'true'
            },
            BonusAmount__c: {
                type: 'text',
                order: 3,
                prepop: 'false'
            },
            rangeStart: {
                type: 'text',
                order: 4,
                prepop: 'calc'
            },
            rangeEnd: {
                type: 'text',
                order: 5,
                prepop: 'false'
            },
            Increment__c: {
                type: 'text',
                order: 6,
                prepop: 'true'
            }      
        },
        uniqueness: 'copromoter',
        tableNewRowLabel: 'Create new Bonus Detail',
        tableOrder: 1,
        humanGridName: 'Bonus Detail',
        shortGridName: 'primary'
    };

    var copromoterBonusPrimary = new lneBonusHelp(fieldInfoPrimary);
});
