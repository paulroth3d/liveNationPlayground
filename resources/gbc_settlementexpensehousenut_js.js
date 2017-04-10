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
//Filename:grunt_src/lib/LNE_PostMessage2.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
/**
 *  Class representing a dispatchEvent.
**/

/**
 *  Constructs an LNE Post Message (payload).
 *  <p>To be dispatched using the dispatch event</p>
 *  @param pageName - String - name of the page
 *  @param messageType - String - arbitrary name of the message type to be sent.
 *  @param isSuccessful (Boolean) - whether the call was successful or not
 *  @param payload (String|Object) - payload to be provided (will be converted to string)
 *  <p>TypeScript: constructor( pageName:String, messageType:String, isSuccessful:Boolean, payload:Object|String )</p>
**/
		
// Namespaces for the cometd implementation
this.LNE_PostMessage = function(pageName, messageType, isSuccessful, payload ){
	this.sender = pageName;
	this.messageType = messageType;
	this.isSuccessful = isSuccessful;
	this.data = payload;
	
	return( this );
};

/**
 *  Dispatches the event.
 *  @param targetWindow (Window) - target window to dispatch from. i.e. parent
 *  @param targetDomain (String) - target domain to accept the request, defaults to '*'
 *  @return void
 *  <p>Typescript: dispatch( targetWindow:Window, targetDomain:String = '*' ):void</p>
**/
this.LNE_PostMessage.prototype.dispatch = function( targetWindow, targetDomain ){
	if( !targetDomain ){
		targetDomain = '*';
	}
	var dataStr = "";
	var payload = { sender: this.sender, messageType: this.messageType, isSuccessful: this.isSuccessful, data: this.data };
	var payloadStr = JSON.stringify( payload );
	targetWindow.postMessage( payload, targetDomain );
};
	
/**
 *  Whether the event was sent from a given page.
 *  @param pageName (String)
 *  @return boolean - whether the event was sent from that page in a case insensitive manner (true) or not (false)
 *  <p>TypeScript: matchesPage( pageName:String ):boolean</p>
**/
this.LNE_PostMessage.prototype.matchesPage = function( pageName ){
	return( this.sender.toUpperCase() === pageName.toUpperCase() );
};
	
/**
 *  Whether the event was for a specific message.
 *  @param messageType (String)
 *  @return boolean - whether the message matches in a case insensitive manner (true) or not (false)
 *  <p>TypeScript: matchesMessageType( messageType:String ):boolean</p>
**/
this.LNE_PostMessage.prototype.matchesMessageType = function( messageType ){
	return( this.messageType.toUpperCase() === messageType.toUpperCase() );
};
	
/**
 *  Whether it matches both the page and the message type
 *  @param pageName (String)
 *  @param messageType (String)
 *  @return boolean - whether the pageName and the messageType both match in a case insensitive manner.
 *  <p>TypeScript: matchesPageMessage( pageName:String, messageType:String ):boolean</p>
**/
this.LNE_PostMessage.prototype.matchesPageMessage = function( pageName, messageType ){
	return( this.matchesPage( pageName ) && this.matchesMessageType( messageType ));
};
	
//-- static methods
	
/**
 *  Determines the origin of a PostMessage event.
 *  @return String
 *  <p>TypeScript getMessageOrigin( evt:PostMessageEvent ):String</p>
**/
this.LNE_PostMessage.prototype.getMessageOrigin = function( evt ){
	return( event.origin || event.originalEvent.origin );
};
	
/**
 *  Parses a dispatched Event
 *  @param evt (postMessage Event)
 *  @return payload (Object) - instance of the LNE PostMessage (if applicable) - null if not.
 *  <p>TypeScript: getPayload( evt:PostMessageEvent ):LNE_PostMessage</p>
**/
this.LNE_PostMessage.prototype.parse = function( evt ){
	var results = null;
	try {
		if( !evt.data.sender ){
			throw( "not a LNE_PostMessage" );
		}
		
		this.sender = evt.data.sender;
		this.messageType = evt.data.messageType;
		this.isSuccessful = evt.data.isSuccessful;
		this.data = evt.data.data;
		
		//LNE_PostMessage.import( evt.data );
	} catch( err ){
		//console.error( "unable to parse payload" );
		//console.error( err );
		return( false );
	}
	return( true );
};
/*
//Filename:grunt_src/lib/LNE_MessagePostOffice.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
/**
 * Class to help manage different types of postMessages based on postMessageType
 **/
this.LNE_MessagePostOffice = function( handlerScope ){
	if( !handlerScope ){
		this.handlerScope = this;
	} else {
		this.handlerScope = handlerScope;
	}
	this.handlers = {};
	
	this.unknownHandlerDefault = function( myPostMessage ){
		var errorMessage = 'there was no handler for messageType:' + myPostMessage.messageType;
		console.error( errorMessage ); console.error( arguments );
		debugger;
	};
	
	this.unknownHandler = this.unknownHandlerDefault;
};

/**
 * Adds a new handler based on messageType
 * @param messageType (string)
 * @param handler (function)
 **/
this.LNE_MessagePostOffice.prototype.addTypeHandler = function( messageType, handler ){
	if( messageType ){
		this.handlers[messageType]=handler;
	} else {
		this.unknownHandler = handler;
	}
};

/**
 *  Handles a new call that comes in
 *  @param postMessage event
 *  @return boolean - whether the postMessage could be handled (true) or not (false);
 **/
this.LNE_MessagePostOffice.prototype.receiveMessage = function( postMessage ){
	var myPostMessage = new LNE_PostMessage();
	if( myPostMessage.parse(postMessage) ){
		if( this.handlers.hasOwnProperty( myPostMessage.messageType ) ){
			this.handlers[ myPostMessage.messageType ].call( this.handlerScope, myPostMessage );
			return( true );
		} if( this.unknownHandler ){
			this.unknownHandler.call( this.handlerScope, myPostMessage );
			return( false );
		} else {
			this.unknownHandlerDefault.call( this.handlerScope, myPostMessage );
			return( false );
		}
	} else {
		//-- not our message
		return( false );
	}
};

/**
 *  Listens for Window PostMessage events.
 *  var postOffice = new LNE_MessagePostOffice(this);
 *  postOffice.listenForPostEvents(window);
 *  @param window
 **/
this.LNE_MessagePostOffice.prototype.listenForPostEvents = function( targetWindow ){
	targetWindow.addEventListener('message',this.receiveMessage.bind(this),false);
};
/*
//Filename:grunt_src/SettlementExpenseHelper.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
var parentEvent = {};

function commonInit() {
	convertGridInfoMap(gridInfoMap);
	markTableReady(false);
	showEventTotalLabel();
	hideAndDisableCommonFields();
	formatGLsWithBreakouts();

	var observer = new MutationObserver(function(mutations) {
	      mutations.forEach(function(mutationRecord) {
	          if (mutationRecord.target.childElementCount > 0) {
	          	hideAndDisableCommonFields();
	          }
	      });
	  });

	  var target = document.getElementsByClassName('fixedHeaderContainer');
	  for (var i = 0; i < target.length; i++) {
	    observer.observe(target[i], { childList : true });
	  }

	  window.addEventListener("message", listenForEventResponse, false);
	  window.parent.postMessage({'requestedAction': 'getEventObject'}, '*');
}

function listenForEventResponse(event) {
	if (event.data.requestedAction === 'parentEventData') {
		if (event.data.data) {
			try {
				parentEvent = JSON.parse(event.data.data);
			} catch (e) {
				console.log(e);
			}
		}
	}
}

function collapseHouseNutGrouping() {
	jq('.groupByRow.grp1 .grpValue').each(function(index,element){
		if (jq(element).text().startsWith('Yes')) {
			if (jq(element).closest('tr').hasClass('off') == false) {
				jq(element).closest('tr').click();
			}
		}
	});
}

function formatGLsWithBreakouts(){
	var rows = jq("#gbMainTable").find(".dr");
	for(var i = 0; i < rows.length; i++){
		var div = rows[i].closest("div");
		if(!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCountSettlement__c")).text()) > 0){
			
			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
		    jq(childrenRow).css("display", "table-row");
		    jq(jq(childrenRow).find("h3.toggleData")[0]).attr("class", "toggleData expanded");
			jq(jq(childrenRow).find("h3.toggleData")[1]).attr("class", "toggleData expanded fixed none");
		    jq(childrenRow).find(".childData").attr("class", "childData expanded");
		    jq(childrenRow).find(".childData").css("display", "block");

		    jq(rows[i]).find(createFieldSelector("SettlementRateType__c")).click();

		    inputs = jq(rows[i]).find("input,textarea");
		    for(var j = 0; j < inputs.length; j ++){

		    	inputs[j].readOnly = true;
		    	inputs[j].disabled = true;
		    	jq(inputs[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
		    }
		    
		    selects = jq(rows[i]).find("select");
            for (var j = 0; j < selects.length; j++) {

                selects[j].disabled = true;
                jq(selects[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
            }
		} else if (!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCountSettlement__c")).text()) == 0){
			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
			jq(jq(childrenRow).find(".childHeaderRow")).attr('style', 'display: table-row!important');
		}
	}

	collapseHouseNutGrouping();
}

function firstBreakoutCreation(evt){

	if (!evt || !evt.target) {
		return;
	}

	var childDataContainer = jq(evt.target).closest("tr").find(".childDataContainer");
	var tr = jq(childDataContainer).find(".none");
	var newRows = jq(childDataContainer).find(".nr");

	jq(newRows).find(createFieldInputSelector( "SettlementOnly__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])).each(function(index, element){
		jq(element).attr('checked','checked').change();
	});

	if(tr.length == 1 && newRows.length == 1){

		jq(childDataContainer).parent().parent().find(".createNew").click();
		//somehow the "click()" above generates two new rows (so we now have three)
		//so we need to delete the third one
		jq(childDataContainer).find(".firstCol").find(".minus").first().click();

		var generatedRow = jq(childDataContainer).find(".nr").first()[0];
		const nameToFind = jq(jq(evt.target).closest("tr")[0]).attr("name");
		var parentTrs = jq("#gbMainTable").find(`tr[name=${nameToFind}]`);
		var GLlevel;
		for(var i = 0; i < parentTrs.length; i++){
			if(!jq(parentTrs[i].closest("div")).hasClass("childDataContainer") && jq(parentTrs[i]).hasClass("dr")){
				GLlevel = parentTrs[i];
			}
		}

		var newDescription =  getInputValue( GLlevel, 'Description__c' );
		jq( generatedRow ).find( createFieldInputSelector( 'Description__c' ) ).val( newDescription ).change();

		var newSettlementRateType =  getInputValue( GLlevel, 'SettlementRateType__c' );
		jq( generatedRow ).find( createFieldSelector( 'SettlementRateType__c' ) ).click(); 
		jq( generatedRow ).find( createFieldInputSelector( 'SettlementRateType__c' ) ).val( newSettlementRateType ).change();

		var newPromoterAmountRate = getInputValue( GLlevel, 'PromoterAmountRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'PromoterAmountRate__c' ) ).val( newPromoterAmountRate ).change();

		var newPromoterAmount = getInputValue( GLlevel, 'PromoterAmount__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'PromoterAmount__c' ) ).val( newPromoterAmount ).change();

		var newArtistAmountRate = getInputValue( GLlevel, 'ArtistAmountRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'ArtistAmountRate__c' ) ).val( newArtistAmountRate ).change();

		var newArtistAmount = getInputValue( GLlevel, 'ArtistAmount__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'ArtistAmount__c' ) ).val( newArtistAmount ).change();
		
		var newVenueAmountRate = getInputValue( GLlevel, 'VenueAmountRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'VenueAmountRate__c' ) ).val( newVenueAmountRate ).change();

		var newVenueAmount = getInputValue( GLlevel, 'VenueAmount__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'VenueAmount__c' ) ).val( newVenueAmount ).change();

		var newLNTouringAmountRate = getInputValue( GLlevel, 'LNTouringAmountRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'LNTouringAmountRate__c' ) ).val( newLNTouringAmountRate ).change();

		var newLNTouringAmount = getInputValue( GLlevel, 'LNTouringAmount__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'LNTouringAmount__c' ) ).val( newLNTouringAmount ).change();

		var newSettlementNotes = getInputValue( GLlevel, 'SettlementNotes__c' )
		jq( generatedRow ).find( createFieldInputSelector( 'SettlementNotes__c' ) ).val( newSettlementNotes ).change();
	}

	//find only new rows that haven't been saved to the database yet
	childDataContainer = jq(childDataContainer).find('.nr');

	var settlementRateTypeFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( 'SettlementRateType__c' ));

	var fieldsToClick = settlementRateTypeFieldsToClickAndShow.toArray();

    for (var i = 0; i < fieldsToClick.length; i++) {
    	jq(fieldsToClick[i]).click();
    }
}

function manageCalculationFields() {
	const fieldSelectors = `${createFieldSelector("SettlementRateType__c")},
						  	${createFieldSelector("PromoterAmountRate__c")},
						  	${createFieldSelector("ArtistAmountRate__c")},
						  	${createFieldSelector("VenueAmountRate__c")},
						  	${createFieldSelector("LNTouringAmountRate__c")}`;

	const showOrHide = viewCalculations() == true ? 'show' : 'hide';
	
	jq("#gbMainTable").find(fieldSelectors).each(function(index, el){
		if (jq(el).closest('tr').closest('table').attr('class') == 'mainTable') {
			jq(el)[showOrHide]();
		}
	});

	const breakoutFieldSelectors = `${createFieldSelector( "SettlementRateType__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  	${createFieldSelector( "PromoterAmountRate__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  	${createFieldSelector( "ArtistAmountRate__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  	${createFieldSelector( "VenueAmountRate__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  	${createFieldSelector( "LNTouringAmountRate__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])}`;

	jq("#gbMainTable table.childTable").find(breakoutFieldSelectors)[showOrHide]();

	const disabled = viewCalculations();

	const fieldAmountSelectors = `${createFieldInputSelector("PromoterAmount__c")},
						  		  ${createFieldInputSelector("ArtistAmount__c")},
						  		  ${createFieldInputSelector("VenueAmount__c")},
						  		  ${createFieldInputSelector("LNTouringAmount__c")}`;

	jq("#gbMainTable").find(fieldAmountSelectors).each(function(index, el){
		if (jq(el).closest('tr').closest('table').attr('class') == 'mainTable') {
			jq(el).attr('disabled', disabled);
		}
	});

	const breakoutAmountFieldSelectors = `${createFieldInputSelector( "PromoterAmount__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  		  ${createFieldInputSelector( "ArtistAmount__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  		  ${createFieldInputSelector( "VenueAmount__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])},
								  		  ${createFieldInputSelector( "LNTouringAmount__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])}`;

	jq("#gbMainTable table.childTable").find(breakoutAmountFieldSelectors).attr('disabled', disabled);
}

function viewCalculations() {
	var p = window.location.href.match(/[&?]showHideCalculations=([^&?]+)($|[&?])/)[1];
	if (p != null && p != undefined && p.indexOf('View') >= 0) {
		return false;
	}

	return true;
}

function calculateTotal(evt) {
	if (evt.target) {
		calculateTotalForRow(jq(evt.target).closest('tr'));
	} else {
		jq("#gbMainTable " + createFieldInputSelector( "PromoterAmount__c" ) ).each( function( index, el ){
	      var parentRow = jq(el).closest('tr');
	      calculateTotalForRow(parentRow);
	    });
	}
}

function calculateTotalForRow(row) {
	var promoter = getFloat(row, 'PromoterAmount__c');
	var artist = getFloat(row, 'ArtistAmount__c');
	var venue = getFloat(row, 'VenueAmount__c' );
	var touring = getFloat(row, 'LNTouringAmount__c' );

	var newTotal = promoter + artist + venue + touring;

	jq(row).find(createFieldInputSelector('Settlement__c')).val(formatNumber(newTotal)).change();
	calculateVarianceForRow(row);
}

function calculateVariance(evt) {
	if (evt.target) {
		calculateTotalForRow(jq(evt.target).closest('tr'));
	} else {
		jq("#gbMainTable " + createFieldInputSelector( "PromoterAmount__c" ) ).each( function( index, el ){
	      var parentRow = jq(el).closest('tr');
	      calculateTotalForRow(parentRow);
	    });
	}
}

function calculateVarianceForRow(row) {
	var offer = getFloat(row, 'OfferAtSellout__c');
	var total = getFloat(row, 'Settlement__c') ;

	var newVariance = offer - total;

	jq(row).find(createFieldSelector('SettlementExpenseVariance__c')).text(`USD ${formatNumber(newVariance)}`);
}

function runCalculations(evt) {
	if (evt.target) {
		runCalculationsForRow(jq(evt.target).closest('tr'), jq(evt.target).closest('td'));
	}
}

function runCalculationsForRow(row, changedField) {
	const changedFieldRateTypeName = gridInfoById[jq(changedField).attr('name')].fieldName;
	const fieldValueName = changedFieldRateTypeName.replace('Rate','');
	const settlementRateType = getInputValue(row, 'SettlementRateType__c');
	
	var amountRate = getFloat(row, changedFieldRateTypeName);
	var newAmount;
	var multiplier;

	if (!isBlank(settlementRateType)) {
		switch(settlementRateType) {
			case 'Flat':
				multiplier = 1;
				break;
			case 'Per Drop Count':
				multiplier = getNumber(parentEvent._props.ActualDropCount__c);
				break;
			case 'Per Paid Ticket':
				multiplier = getNumber(parentEvent._props.SettlementPaidTickets__c);
				break;
			case '% of Net Gross':
				amountRate /= 100;
				multiplier = getNumber(parentEvent._props.SettlementNetGross__c);
				break;
			case '% of Gross':
				amountRate /= 100;
				multiplier = getNumber(parentEvent._props.SettlementGross__c);
				break;
			case '% of Adjusted Gross':
				amountRate /= 100;
				multiplier = getNumber(parentEvent._props.SettlementAdjustedGross__c);
				break;
			default:
				break;
		}
	}

	if (!isBlank(multiplier)) {
		newAmount = amountRate * multiplier;
	}

	jq(row).find(createFieldInputSelector(fieldValueName)).val(formatNumber(newAmount)).change();
}

function settlementRateTypeChanged(evt) {
	if (evt.target) {
		const parentRow = jq(evt.target).closest('tr');
		runCalculationsForRow(parentRow, jq(parentRow).find(createFieldSelector("PromoterAmountRate__c")));
		runCalculationsForRow(parentRow, jq(parentRow).find(createFieldSelector("ArtistAmountRate__c")));
		runCalculationsForRow(parentRow, jq(parentRow).find(createFieldSelector("VenueAmountRate__c")));
		runCalculationsForRow(parentRow, jq(parentRow).find(createFieldSelector("LNTouringAmountRate__c")));
	}
}

function showEventTotalLabel() {
	var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');
}

function getFloat(row, field) {
	var result = parseFloat(sanitizeNumber(getInputValue(row, field)));
	if (!result) {
		result = parseFloat(sanitizeNumber(getText(row, field)));
	}

	if (!result || isNaN(result)) {
		return 0.0;
	}

	return result;
}

function getNumber(v) {
	return isBlank(v) ? 0.0 : v;
}

function getText(row, field) {
	return jq(row).find(createFieldSelector(field)).text();
}

function isBlank(v) {
	return v == null || v == undefined || v == "";
}

function createCommonChangeSelectors() {
	var changeSelectors = `${createFieldSelector("PromoterAmount__c")},
						   ${createFieldSelector("ArtistAmount__c")},
						   ${createFieldSelector("VenueAmount__c")},
						   ${createFieldSelector("LNTouringAmount__c")}`;
						   
	jq("#gbMainTable").on( 'change', changeSelectors, calculateTotal );

	var calculationChangeSelectors = `${createFieldSelector("PromoterAmountRate__c")},
						   			  ${createFieldSelector("ArtistAmountRate__c")},
						   			  ${createFieldSelector("VenueAmountRate__c")},
						   			  ${createFieldSelector("LNTouringAmountRate__c")}`;
						   
	jq("#gbMainTable").on( 'change', calculationChangeSelectors, runCalculations );
	jq("#gbMainTable").on( 'change', createFieldSelector("SettlementRateType__c"), settlementRateTypeChanged );
}

function hideAndDisableCommonFields() {
	hideCommonFields();
	manageCalculationFields();
	disableCommonFields();
}

function disableCommonFields() {
	jq(createFieldInputSelector('Settlement__c')).attr("disabled", "disabled");
}

function hideCommonFields() {
	jq(createFieldSelector('RollUpCountSettlement__c')).hide();
	jq(createFieldSelector( "SettlementRateType__c", gridChildrenInfoMap['LedgerEntryBreakout__c'])).hide();
}
/*
//Filename:grunt_src/settlementexpensehousenut.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
this.postOffice = new LNE_MessagePostOffice(this);

var eventMethod = window.addEventListener ? 'addEventListener' : 'attachEvent';
var eventer = window[eventMethod];
var messageEvent = eventMethod == 'attachEvent' ? 'onmessage' : 'message';

function sendMessage(){
	var pageName = 'SettlementExpenseHouseNutGrid';
    var isSuccessful = true;

	//-- some custom message type. Again, only saveComplete is special/recognized for now.
	var messageType = 'defaultFees';

	//-- send the data payload as an object with stuff to return.
	//-- always include src as some unique identifier for the page
	var data = {
		src: window.location.href
	};

	var postMessage = new LNE_PostMessage( pageName, messageType, isSuccessful, data );

	//-- works if in a grid overlay
	postMessage.dispatch( parent );

}


this.postOffice.addTypeHandler( 'defaultFees_completed', function( myPostMessage ){
  	console.log('Default Fees Completed');
 	jq('.refreshBtn').click();
});

postOffice.listenForPostEvents(window);

function defaultFees(){
	console.log('default fees action fired');
	sendMessage();
}

function makeX50148XRowsReadonly() {
	setTimeout(function() {
		var $row = jq('tr.dr td[name=v0]:contains("House Nut")').parent();
		var $inputs = $row.find('input, textarea');	
		
		$inputs.attr('disabled', true);
		$row.next('.cr').find('.createNew').hide();	
	}, 2000);
}

jq(document).ready( function(){
	commonInit();

	jq('#gbMainTable').on('click', 'td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input', function(e) {
		console.log('house nut clicked');
		var $row = jq(e.target).closest('tr');
		var badRow=$row;
		var runCount = 0;

		setTimeout( function(){
			if (runCount < 32) {
				var badInputs = jq( badRow ).find( '.gbrq' );
				jq( badRow ).find( '.gbrq' ).removeClass( 'gbrq' );
				runCount++;
			}
		}, 25);

	});

	createCommonChangeSelectors();

	jq("#gbMainTable").on( 'click', '.createNew', function(evt){
		hideAndDisableCommonFields();
		firstBreakoutCreation(evt);
	});
	
	jq("#gbMainTable").on('click', '.pl.ui-selectee', function(e) {
		var kids, nut, parent;
		parent = jq(e.target).closest('td');
		parent = jq(parent).closest('tr');	

		kids = (parent).find(createFieldSelector("RollUpCountSettlement__c")).text();
		kids = parseInt(kids) ? parseInt(kids) : 0;
		if (kids) {
	       jq( parent ).find( "select" ).prop( "disabled", true );
	       jq( parent ).find( "input" ).attr( "readonly", true ).attr( "disabled", true );
	       jq( parent ).find( "select" ).removeClass('gbrq');
	       jq( parent ).find( "input" ).removeClass('gbrq');
	        nut = jq( parent ).find(createFieldSelector("HouseNut__c"));
	        nut = nut.find('input');
	        nut.attr( "readonly", false ).attr( "disabled", false );   
		}
	});

	jq( `#gbMainTable > tbody > tr > ${createFieldSelector("RollUpCountSettlement__c")}` ).each( function( elIndex, el ){
		var con, nextRow, nut, toggle;
		var childCount = -1;
		try { childCount = parseInt( el.innerText ); } catch( err ){}
		if ( childCount > 0 ) {
	       	var parentRow = jq( el ).closest( "tr" );
	       	jq( parentRow ).find( "select" ).attr( "disabled", true );
	       	jq( parentRow ).find( "input" ).attr( "readonly", true ).attr( "disabled", true );
	       	jq( parentRow ).find( "select" ).removeClass('gbrq');
	       	jq( parentRow ).find( "input" ).removeClass('gbrq'); 
	        nut = jq( parentRow ).find(createFieldSelector("HouseNut__c"));
	        nut = nut.find('input');
	        nut.attr( "readonly", false ).attr( "disabled", false );

	        jq( parentRow ).find('.icon-arrow').first().click();
	       	nextRow = jq(parentRow).next('tr');
	       	toggle = jq( nextRow ).find('.toggleData').first();
	       	toggle = toggle.find('.icon-arrow').first();
	       	if (jq(toggle).closest('h3').hasClass('collapsed')) {
	       		toggle.each( function() {
		       		el.click();
		       	});
	       	}
		} 
	});

	markTableReady(true);

	gridStateMessagingController('nutter');
	makeX50148XRowsReadonly();
});