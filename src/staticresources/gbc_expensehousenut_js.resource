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
//Filename:grunt_src/expensehousenut.js
//-- #	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#
*/
/** current window **/
var overlayWindow;

/**
 *  Gets a boolean value from a gridbuddy input
 *  @param row (Element) - jQuery element of the row to select within
 *  @param fieldAPI (String) - api name of the field to ask for
**/
function getBooleanInputValue( row, fieldAPI ){
	if( !gridInfoByField.hasOwnProperty( fieldAPI )){
		throw( "gridInfoByField[" + fieldAPI + "] does not exist" );
	}
	var el = jq( row ).find( createFieldInputSelector( fieldAPI ) );
	if( !el || el.length < 1 ){
		//-- @TODO: investigate further - this happens if there is a select that hasn't been used yet... (facepalm)
		return( jq( row ).find( createFieldSelector( fieldAPI ) + " div" ).text() );
	} else {
		return( el.is(":checked") );
	}
}

function rowHasHouseNutChecked(row) {
	return jq(row).closest('tr').find(createFieldInputSelector( 'HouseNut__c' )).is(':checked');
}

function rowIsX50148X(row) {
	return jq(row).closest('tr').find(createFieldSelector('GLAccount__c')).find(':contains("House Nut")').length > 0;
}

/**
 *  Logic handler (NON DEV) version of the ancillary revenue section under the events page.
**/
function expenseRecordChangedHandler( evt ){
	var nut = false;
	var ledgerString, o, parentCell, parentRow;
	console.log( "housenut - something changed in the rate type" );
	console.log('evt is ');
	console.log(evt);

	if( !isTableReady() || this == window){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);

	if(jq(this).closest("tr").hasClass("nr") || isHouseNutRow === true){
		return;
	}

	var ledgerEntry = {};
	var parentCell = jq(evt.target).closest('td');
	var parentRow = jq(evt.target).closest('tr');
	ledgerEntry.Id = jq(parentRow).attr('id');
	//this.parentElement = jq(parentRow).get(0);

	ledgerEntry.OfferRateType__c = getInputValue( parentRow, 'OfferRateType__c' );
	ledgerEntry.OfferRate__c = sanitizeNumber( getInputValue( parentRow, 'OfferRate__c' ));
	ledgerEntry.OfferRate__c = ledgerEntry.OfferRate__c || 0;
	ledgerEntry.OfferMin__c = sanitizeNumber( getInputValue( parentRow, 'OfferMin__c' ));
	ledgerEntry.OfferMin__c = ledgerEntry.OfferMin__c || 0;
	ledgerEntry.OfferMax__c = sanitizeNumber( getInputValue( parentRow, 'OfferMax__c' ));
	ledgerEntry.OfferMax__c = ledgerEntry.OfferMax__c || 0;
	ledgerEntry.OfferAtSellout__c = sanitizeNumber( getInputValue( parentRow, 'OfferAtSellout__c' ));
	ledgerEntry.OfferAtSellout__c = ledgerEntry.OfferAtSellout__c  || 0;
	ledgerEntry.OfferAtProjection__c = sanitizeNumber( getInputValue( parentRow, 'OfferAtProjection__c' ));
	ledgerEntry.OfferAtProjection__c = ledgerEntry.OfferAtProjection__c  || 0;
	ledgerEntry.SettleAtActual__c = getBooleanInputValue( parentRow, 'SettleAtActual__c' );
	ledgerEntry.SettleAtActual__c  = ledgerEntry.SettleAtActual__c;
	ledgerEntry.InHouseRateType__c = getInputValue( parentRow, 'InHouseRateType__c' );
	ledgerEntry.InHouseRateType__c = ledgerEntry.InHouseRateType__c || 0;
	ledgerEntry.InHouseRate__c = sanitizeNumber( getInputValue( parentRow, 'InHouseRate__c' ));
	ledgerEntry.InHouseRate__c = ledgerEntry.InHouseRate__c || 0;
	ledgerEntry.InHouseMin__c = sanitizeNumber( getInputValue( parentRow, 'InHouseMin__c' ));
	ledgerEntry.InHouseMin__c = ledgerEntry.InHouseMin__c || 0;
	ledgerEntry.InHouseMax__c = sanitizeNumber( getInputValue( parentRow, 'InHouseMax__c' ));
	ledgerEntry.InHouseMax__c = ledgerEntry.InHouseMax__c || 0;
	ledgerEntry.InHouseProjection__c = sanitizeNumber( getInputValue( parentRow, 'InHouseProjection__c' ));
	if (ledgerEntry.InHouseProjection__c.length === 0) {
		console.log('RESET ledgerEntry.InHouseProjection__c');
		ledgerEntry.InHouseProjection__c = 0;
	}
	ledgerEntry.ExpenseAdjustment__c = sanitizeNumber( getInputValue( parentRow, 'ExpenseAdjustment__c' ));
	ledgerEntry.ExpenseAdjustment__c = ledgerEntry.ExpenseAdjustment__c  || null;
	
	//-- the event is always going to be more up to date.
	//var currentField = gridInfoById[ this.getAttribute( "name" ) ].fieldName;
	//ledgerEntry[ currentField ] = evt.target.value;
	console.log('ledgerEntry is');
	console.log(ledgerEntry);
	ledgerString = JSON.stringify( ledgerEntry );
	console.log(ledgerString);

	var url = createApexURL( "LNE_EventExpenseCalculationAPI" );
	//console.log( "calling[" + url + "]" );

	if(jq(this).closest("div").hasClass("childDataContainer")) {
		o = 'LedgerEntryBreakout__c';
	} else {
		o = 'LedgerEntry__c';
	}

	var sendData = {};
	sendData[o] = ledgerString;
	console.log('Updating GL Account or Breakout? - o = ' + o);
	console.log('send Data');
	console.log(sendData);

	jq.ajax({
		url: url,
		data: sendData,
		context: this,
		dataType: 'jsonp'
	}).done( function( results ){
		//debugger
		if( results && results.isSuccessful === true ){
			console.log( "fields updated" );
			console.log(results);
			
			if (results && results.data) {

				if (!results.data.OfferAtSellout__c) {
					results.data.OfferAtSellout__c = 0;
				}
				var newOfferAtSellout = formatNumber( results.data.OfferAtSellout__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.OfferAtSellout__c.fieldName ) ).val( newOfferAtSellout ).change();

				if (!results.data.OfferAtProjection__c) {
					results.data.OfferAtProjection__c = 0;
				}
				var newOfferAtProjection = formatNumber( results.data.OfferAtProjection__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.OfferAtProjection__c.fieldName ) ).val( newOfferAtProjection ).change();

				if (!results.data.InHouseProjection__c) {
					results.data.InHouseProjection__c = 0;
				}
				var newInHouseProjection = formatNumber( results.data.InHouseProjection__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.InHouseProjection__c.fieldName ) ).val( newInHouseProjection ).change();
				
				if (!results.data.ExpenseAdjustment__c) {
					results.data.ExpenseAdjustment__c = 0;
				}
				var newExpenseAdjustment = formatNumber( results.data.ExpenseAdjustment__c );
				jq( this.parentElement ).find( createFieldInputSelector( gridInfoByField.ExpenseAdjustment__c.fieldName ) ).val( newExpenseAdjustment ).change();

			}
		} else {
			//-- the service ran into a problem, but not catestrophic.
			console.log( "service error. something likely wasn't set correctly so we tell the user" );
			alert( results.message );
		}
	}).fail( function(){
		//-- this should only happen if the service is not found or the results are not in JSON.
		console.log( "service failure" );
		debugger;
	}).always( function(){
		window.setTimeout(disableNutCalculatedFields('nutcheck',evt.target), 1000);
		window.setTimeout(disableNutCalculatedFields('nutcheck',evt.target), 2000);
		window.setTimeout(disableNutCalculatedFields('nutcheck',evt.target), 4000);

		//console.log( "always jsonp" );
	});
}


function offerRateTypeChanged( parentRow, newRateType ){

	if( !isTableReady() ){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);
	if (isHouseNutRow === true) {
		return;
	}

	try {
		var isFlat = ( newRateType == "Flat" );
		if( isFlat ){
			jq( parentRow ).find( createFieldInputSelector( 'OfferMin__c' ) ).val( '' ).change();
			jq( parentRow ).find( createFieldInputSelector( 'OfferMax__c' ) ).val( '' ).change();
		}
	} catch( err ){
		console.error( 'error occurred when the rateType changed:' + err );
		console.log( err );
	}
}

function markOfferMinMaxReadOnly(parentRow, readOnly) {
	jq( parentRow ).find( createFieldInputSelector( 'OfferMin__c' ) ).attr( "readonly", readOnly );
	jq( parentRow ).find( createFieldInputSelector( 'OfferMax__c' ) ).attr( "readonly", readOnly );
}

function markInHouseMinMaxReadOnly(parentRow, readOnly) {
	jq( parentRow ).find( createFieldInputSelector( 'InHouseMin__c' ) ).attr( "readonly", readOnly );
	jq( parentRow ).find( createFieldInputSelector( 'InHouseMax__c' ) ).attr( "readonly", readOnly );
}
/**
 *  logic that makes the calculation fields readonly and disabled to prevent user input.
 *  <p>Called on document.ready</p>
**/
function inHouseRateTypeChanged( parentRow, newRateType ){

	if( !isTableReady() ){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);
	if (isHouseNutRow === true) {
		return;
	}
	
	var ledgerNutField = jq(parentRow).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
	if (jq(ledgerNutField).prop('checked')) {
		console.log('houseNut checked for ledger bailing');
		return false;
	}

	try {
		var isFlat = ( newRateType == "Flat" );
		if( isFlat ){
			jq( parentRow ).find( createFieldInputSelector( 'InHouseMin__c' ) ).val( '' ).change();
			jq( parentRow ).find( createFieldInputSelector( 'InHouseMax__c' ) ).val( '' ).change();
		}
	} catch( err ){
		console.error( 'error occurred when the rateType changed:' + err );
		console.log( err );
	}
}

/** Change Handler for the offer rate type. **/
function offerRateTypeChangeHandler( evt ){
	console.log( 'offer rateType has changed' );

	if( !isTableReady() || this == window){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);
	if (isHouseNutRow === true) {
		return;
	}

	//debugger;

	if( evt ){
		var parentRow = evt.target.parentElement.parentElement;
		var newRateType = evt.target.value;

		var ledgerNutField = jq(parentRow).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
		if (jq(ledgerNutField).prop('checked')) {
			console.log('houseNut checked for ledger bailing');
			return false;
		}

		offerRateTypeChanged( parentRow, newRateType );
		if(!jq(this.closest("tr")).hasClass("nr")){
			markOfferMinMaxReadOnly(parentRow, newRateType == "Flat");
			expenseRecordChangedHandler(evt);
		}
	} else {
		jq("#gbMainTable " + createFieldSelector( "OfferRateType__c" ) ).each( function( index, el ){

			var parentRow = el.parentElement;
			var ledgerNutField = jq(parentRow).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
			if (jq(ledgerNutField).prop('checked')) {
				console.log('houseNut checked for ledger bailing');
				return false;
			}

			if( parentRow && parentRow.hasAttribute( "id" )){
				var newRateType = getInputValue( parentRow, 'OfferRateType__c' );
				markOfferMinMaxReadOnly(parentRow, newRateType == "Flat");
			}
		});
	}
}

/** Change Handler for the in house rate type. **/
function inHouseRateTypeChangeHandler( evt ){
	console.log( 'in house rateType has changed' );

	if( !isTableReady() || this == window){
		//-- don't dispatch the event until the table is ready
		return;
	}

	const isHouseNutRow = rowHasHouseNutChecked(this);
	if (isHouseNutRow === true) {
		return;
	}

	//debugger;

	if( evt ){
		var parentRow = evt.target.parentElement.parentElement;
		var newRateType = evt.target.value;
		var ledgerNutField = jq(parentRow).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
		inHouseRateTypeChanged( parentRow, newRateType );
		if(!jq(this.closest("tr")).hasClass("nr")){
			markInHouseMinMaxReadOnly(parentRow, newRateType == "Flat");
			expenseRecordChangedHandler(evt);
		}
	} else {
		jq("#gbMainTable " + createFieldSelector( "InHouseRateType__c" ) ).each( function( index, el ){
			var parentRow = el.parentElement;

			if( parentRow && parentRow.hasAttribute( "id" )){
				var newRateType = getInputValue( parentRow, 'InHouseRateType__c' );
				markInHouseMinMaxReadOnly(parentRow, newRateType == "Flat");
			}
		});
	}
}

/**
 *  logic that makes the calculation fields readonly and disabled to prevent user input.
 *  <p>Called on document.ready</p>
**/
function disableCalculatedFields(){

	var offerAtSelloutFields = jq("#gbMainTable").find(  createFieldInputSelector("OfferAtSellout__c"));
	var offerAtProjectionFields = jq("#gbMainTable").find(  createFieldInputSelector("OfferAtProjection__c"));
	var inHouseProjectionFields = jq("#gbMainTable").find(  createFieldInputSelector("InHouseProjection__c"));
	var expenseAdjustmentFields = jq("#gbMainTable").find(  createFieldInputSelector("ExpenseAdjustment__c"));

	for(var i = 0; i < offerAtSelloutFields.length; i++){

		offerAtSelloutFields[i].readOnly = true;
		offerAtProjectionFields[i].readOnly = true;
		inHouseProjectionFields[i].readOnly = true;
		expenseAdjustmentFields[i].readOnly= true;
	}
}


function formatGLsWithBreakouts(){

	const houseNutFieldId = gridInfoByField.HouseNut__c.fieldId;

	var rows = jq("#gbMainTable").find(".dr");
	for(var i = 0; i < rows.length; i++){
		var div = rows[i].closest("div");
		if(!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCount__c")).text()) > 0){
			
			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
		    jq(childrenRow).css("display", "table-row");
		    jq(jq(childrenRow).find("h3.toggleData")[0]).attr("class", "toggleData expanded");
			jq(jq(childrenRow).find("h3.toggleData")[1]).attr("class", "toggleData expanded fixed none");
		    jq(childrenRow).find(".childData").attr("class", "childData expanded");
		    jq(childrenRow).find(".childData").css("display", "block");
			jq(rows[i]).find(createFieldSelector( gridInfoByField.OfferRateType__c.fieldName)).click();
            jq(rows[i]).find(createFieldSelector( gridInfoByField.InHouseRateType__c.fieldName)).click();

		    inputs = jq(rows[i]).find("input");
		    for(var j = 0; j < inputs.length; j ++){
		    	const columnId = jq(jq(inputs[j]).closest("td")[0]).attr("name");

		    	if (columnId != houseNutFieldId) {
		    		inputs[j].readOnly = true;
		    		inputs[j].disabled = true;
		    		jq(inputs[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
		    	}
		    }
		    selects = jq(rows[i]).find("select");
            for (var j = 0; j < selects.length; j++) {

                selects[j].disabled = true;
                jq(selects[j]).attr("class", "gb-cf-bgColor-10-1474564344890");
            }

		} else if (!jq(div).hasClass("childDataContainer") && !jq(rows[i]).hasClass("nd") && parseInt(jq(rows[i]).find(createFieldSelector("RollUpCount__c")).text()) == 0){

			var childrenRow = jq(rows[i].parentElement).find("[name=" + jq(rows[i]).attr("name") +"].cr")[0];
			jq(jq(childrenRow).find(".childHeaderRow")).attr('style', 'display: table-row!important');
		}
	}
}

function firstBreakoutCreation(event) {

	if (!event || !event.target) {
        return;
    }
	
	var childDataContainer = jq(event.target).closest("tr").find(".childDataContainer");
	var tr = jq(childDataContainer).find(".none");
	var newRows = jq(childDataContainer).find(".pldisplayed");

	var generatedRow = jq(childDataContainer).find(".nr").first()[0];
	const nameToFind = jq(jq(event.target).closest("tr")[0]).attr("name");
    var parentTrs = jq("#gbMainTable").find(`tr[name=${nameToFind}]`);
	var GLlevel;
	for(var i = 0; i < parentTrs.length; i++){
		if(!jq(parentTrs[i].closest("div")).hasClass("childDataContainer") && jq(parentTrs[i]).hasClass("dr")){
			GLlevel = parentTrs[i];
		}
	}

	var newSettleAtActual = jq(GLlevel).find(createFieldInputSelector('SettleAtActual__c')).is(':checked');

	if(tr.length == 1 && newRows.length == 1){
		console.log("first breakout");

		jq(childDataContainer).parent().parent().find(".createNew").click();
		//somehow the "click()" above generates two new rows (so we now have three)
		//so we need to delete the third one
		jq(childDataContainer).find(".firstCol").find(".minus").first().click();

		var newDescription =  getInputValue( GLlevel, 'Description__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.Description__c.fieldName ) ).val( newDescription ).change();
		var newRateType =  getInputValue( GLlevel, 'OfferRateType__c' );
		jq( generatedRow ).find( createFieldSelector( gridInfoByField.OfferRateType__c.fieldName ) ).click(); 
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferRateType__c.fieldName ) ).val( newRateType ).change();
		var newOfferRate = getInputValue( GLlevel, 'OfferRate__c' )
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferRate__c.fieldName ) ).val( newOfferRate ).change();
		var newOfferAtSellout = getInputValue( GLlevel, 'OfferAtSellout__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferAtSellout__c.fieldName ) ).click().val( newOfferAtSellout ).change();
		var newOfferAtProjection = getInputValue( GLlevel, 'OfferAtProjection__c' ) ;
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferAtProjection__c.fieldName ) ).val( newOfferAtProjection ).change();
		var newInHouseRateType = getInputValue( GLlevel, 'InHouseRateType__c' );
		jq( generatedRow ).find( createFieldSelector( gridInfoByField.InHouseRateType__c.fieldName ) ).click(); 
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseRateType__c.fieldName ) ).val( newInHouseRateType ).change();
		var newMin = getInputValue( GLlevel, 'OfferMin__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferMin__c.fieldName ) ).val( newMin ).change();
		var newInHouseRate = getInputValue( GLlevel, 'InHouseRate__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseRate__c.fieldName ) ).val( newInHouseRate ).change();	
		var newInHouseMin = getInputValue( GLlevel, 'InHouseMin__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseMin__c.fieldName ) ).val( newInHouseMin ).change();
		var newInHouseMax = getInputValue( GLlevel, 'InHouseMax__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseMax__c.fieldName ) ).val( newInHouseMax ).change();
		var newInHouseProjection = getInputValue( GLlevel, 'InHouseProjection__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.InHouseProjection__c.fieldName ) ).val( newInHouseProjection ).change();
		var newExpenseAdjustment = getInputValue( GLlevel, 'ExpenseAdjustment__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.ExpenseAdjustment__c.fieldName ) ).val( newExpenseAdjustment ).change();
		var newMax = getInputValue( GLlevel, 'OfferMax__c' );
		jq( generatedRow ).find( createFieldInputSelector( gridInfoByField.OfferMax__c.fieldName ) ).val( newMax ).change();

	}
	//find only new rows that haven't been saved to the database yet
	childDataContainer = jq(childDataContainer).find('.nr');

	jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.SettleAtActual__c.fieldName ) ).prop( "checked", newSettleAtActual ).change();

	var offerRateTypeFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( gridInfoByField.OfferRateType__c.fieldName ));
	var inHouseRateTypeFieldsToClickAndShow = jq( childDataContainer ).find( createFieldSelector( gridInfoByField.InHouseRateType__c.fieldName ));

	var fieldsToClick = offerRateTypeFieldsToClickAndShow.toArray().concat(inHouseRateTypeFieldsToClickAndShow.toArray());

    for (var i = 0; i < fieldsToClick.length; i++) {
    	jq(fieldsToClick[i]).click();
    }

    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferRateType__c.fieldName )).attr("class","");
    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferRate__c.fieldName )).attr("class","");
    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseRateType__c.fieldName )).attr("class","");
    jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseRate__c.fieldName )).attr("class","");
    var offerRateTypeFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferRateType__c.fieldName ));
    var offerRateFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferRate__c.fieldName ));
    var offerAtSelloutFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferAtSellout__c.fieldName ));
    var offerAtProjectionFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferAtProjection__c.fieldName ));
    var settleAtActualFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.SettleAtActual__c.fieldName ));
    var inHouseRateTypeFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseRateType__c.fieldName ));
    var offerMinFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferMin__c.fieldName ));
    var inHouseRateFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseRate__c.fieldName ));
    var inHouseMinFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseMin__c.fieldName ));
    var inHouseMaxFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseMax__c.fieldName ));
    var inHouseProjectionFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.InHouseProjection__c.fieldName ));
    var expenseAdjustmentFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.ExpenseAdjustment__c.fieldName ));
    var offerMaxFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.OfferMax__c.fieldName ));
    var notesFields = jq( childDataContainer ).find( createFieldInputSelector( gridInfoByField.Notes__c.fieldName ));


    var fieldsToDisable = offerRateTypeFields.toArray().concat(offerRateFields.toArray(),
													  offerAtSelloutFields.toArray(),
													  offerAtProjectionFields.toArray(),
													  settleAtActualFields.toArray(),
													  inHouseRateTypeFields.toArray(),
													  offerMinFields.toArray(),
													  inHouseRateFields.toArray(),
													  inHouseMinFields.toArray(),
													  inHouseMaxFields.toArray(),
													  inHouseProjectionFields.toArray(),
													  offerMaxFields.toArray(),
													  notesFields.toArray(),
													  expenseAdjustmentFields.toArray());

    for (var i = 0; i < fieldsToDisable.length; i++) {
        jq(fieldsToDisable[i]).attr("disabled", "disabled");
    }

		
}

function valuesIsNotBlankOrZero( val ){
	return( !( val == '' || parseFloat( val ) == 0 ) );
}

function disableNutCalculatedFields(mode, target){
	console.log('disableNutCalculatedFields mode ' + mode);
	var parent, rows;
	var ledgerNutField, ledgerNutFieldCell;
	var offerRateTypeField;
	var offerRateField;
	var offerMinField;
	var offerMaxField;
	var offerAtSelloutField;
	var offerAtProjectionField;
	var inHouseProjectionField;
	var expenseAdjustmentField;

	console.log('mode is ' + mode);

	if (mode === 'all') {
		rows = jq("#gbMainTable").find('tr.dr');
	} else if (mode === 'nutcheck') {
		parent = jq(target).closest('td');
		parent = jq(parent).closest('tr');		
		console.log('parent cr is');
		console.log(parent);
		rows = jq(parent);
	} else {
		parent = jq(target).closest('td');
		console.log('parent is');
		console.log(parent);
		parent = jq(parent).closest('tr.cr');		
		console.log('parent cr is');
		console.log(parent);
		rows = jq(parent).find('tr.dr.nr.pldisplayed');
		console.log('rows set to ');
		console.log(rows);
	}


	for (var r = 0; r < rows.length; r++) {
		ledgerNutField = jq(rows[r]).find('td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input');
		ledgerNutFieldCell = jq(ledgerNutField).parent();
		console.log('ledgerNutFieldCell is');
		console.log(jq(ledgerNutFieldCell));
		console.log('about to disable, does nut have mod class?');
		console.log(jq(ledgerNutFieldCell).hasClass('mod'));

		const isX50148X = rowIsX50148X(rows[r]);

		if (jq(ledgerNutFieldCell).hasClass('mod') && !jq(ledgerNutField).prop('checked')) {
			console.log('disableNutCalculatedFields bailing');
			disableNutCalculatedFieldsBeforeSave(ledgerNutField);
			return false;
		} else {
			console.log('if nut checked disable fields');
			if ((jq(ledgerNutField).prop('checked') || jq(rows[r]).find('span.chkd').length > 0) && isX50148X == false) {

				offerRateTypeField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferRateType__c"].fieldId + '"] select');
				offerRateTypeField.prop('disabled','disabled').removeClass('gbrq');;

				offerRateField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferRate__c"].fieldId + '"] input');
				console.log('offerRateField is ');
				console.log(offerRateField);
				if ( valuesIsNotBlankOrZero( offerRateField.val() ) ) {
					offerRateField.val('').change();
				}
				offerRateField.prop('readonly','readonly').removeClass('gbrq');
				
				offerMinField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferMin__c"].fieldId + '"] input');
				if ( valuesIsNotBlankOrZero( offerMinField.val() ) ) {
					offerMinField.val('').change();
				}
				offerMinField.prop('readonly','readonly').removeClass('gbrq');
				
				offerMaxField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferMax__c"].fieldId + '"] input');
				if ( valuesIsNotBlankOrZero( offerMaxField.val() ) ) {
					offerMaxField.val('').change();
				}
				offerMaxField.prop('readonly','readonly').removeClass('gbrq');
				
				offerAtSelloutField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferAtSellout__c"].fieldId + '"] input');
				if ( valuesIsNotBlankOrZero( offerAtSelloutField.val() ) ) {
					offerAtSelloutField.val('').change();
				}
				offerAtSelloutField.prop('readonly','readonly').removeClass('gbrq');		
				
				offerAtProjectionField = jq(rows[r]).find('td[name="' + gridInfoByField["OfferAtProjection__c"].fieldId + '"] input');
				if ( valuesIsNotBlankOrZero( offerAtProjectionField.val() ) ) {
					offerAtProjectionField.val('').change();
				}
				offerAtProjectionField.prop('readonly','readonly').removeClass('gbrq');	

				settleAtActualField = jq(rows[r]).find('td[name="' + gridInfoByField["SettleAtActual__c"].fieldId + '"] input');
				settleAtActualField.prop('checked', false);
				settleAtActualField.prop('disabled','disabled').removeClass('gbrq');	
			} else {
				console.log('disableNutCalculatedFields mode ' + mode  + ' exit with no action');
			}
		}
	}
}

function disableNutCalculatedFieldsBeforeSave(target){
	console.log('disableNutCalculatedFieldsBeforeSave');
	var parent, rows;
	var ledgerNutField;
	var offerRateTypeField;
	var offerRateField;
	var offerMinField;
	var offerMaxField;
	var offerAtSelloutField;
	var offerAtProjectionField;
	var inHouseProjectionField;
	var expenseAdjustmentField;

	parent = jq(target).closest('td');
	parent = jq(parent).closest('tr');		

	offerRateTypeField = jq(parent).find('td[name="' + gridInfoByField["OfferRateType__c"].fieldId + '"] select').first();
	offerRateTypeField.attr('class','');

	offerRateField = jq(parent).find('td[name="' + gridInfoByField["OfferRate__c"].fieldId + '"] input').first();
	offerRateField.attr('class','text');
}

function hideFields() {
	jq(createFieldSelector('Category__c')).hide();
	jq(createFieldSelector('RollUpCount__c')).hide();
}

function makeX50148XRowsReadonly() {
	setTimeout(disableX50148XRows, 1100);
}

function disableX50148XRows() {
	var $row = jq('tr.dr td[name=v0]:contains("House Nut")').parent();
	$row.find(createFieldSelector('OfferRateType__c')).click();
	$row.find(createFieldSelector('InHouseRateType__c')).click();
	var $inputs = $row.find('input, textarea, select');	
	$inputs.attr('disabled', true);
	$row.find('.gbrq').removeClass('gbrq');
	$row.next('.cr').find('.createNew').hide();	
}

jq(document).ready( function(){
	var initialFocus = true;

	//-- always call after jq(document).ready for all scripts
	console.log('gridInfoMap');
	console.log(gridInfoMap.gridInfo);
	convertGridInfoMap( gridInfoMap );

	//-- mark the grid as not ready, so change events should not be fired
	markTableReady( false );

	//The Offer Rate Type, Offer Rate / $, Offer Min, Offer Max, Offer At Sellout, Offer At Projection are nulled out 
	//and not editable or calculated
	hideFields();
	disableNutCalculatedFields('all');
	disableCalculatedFields();
	window.setTimeout(disableNutCalculatedFields('all'), 2000);

	jq('#gbMainTable').on('click', 'td[name="' + gridInfoByField["HouseNut__c"].fieldId + '"] input', function(e) {
		console.log('house nut clicked');
		var $row = jq(e.target).closest('tr');
		var badRow=$row;
		var runCount = 0;

		setTimeout( function(){
			if (runCount < 32) {
				var badInputs = jq( badRow ).find( '.gbrq' );
				jq( badRow ).find( '.gbrq' ).removeClass( 'gbrq' );
				offerRateTypeField = jq(badRow).find('td[name="' + gridInfoByField["OfferRateType__c"].fieldId + '"] select').first();
				offerRateTypeField.prop('disabled','disabled');
				runCount++;
			}
		}, 25);

	});

	jq('#gbMainTable').on('click', '[title="Create new Expense Breakout"]', function(e) {
		disableNutCalculatedFields('single',e.target);
	});

	//-- change handler for the RateType__c cell (not input) but that can be through createFieldInputSelector
	var changeSelectors =  createFieldSelector("OfferRateType__c") + ', '+ createFieldSelector("OfferRate__c") + ', ' + createFieldSelector("OfferMin__c") + ', ' + createFieldSelector("OfferMax__c") + ', ' + createFieldSelector("SettleAtActual__c") + ', ' + createFieldSelector("InHouseRateType__c") + ', ' + createFieldSelector("InHouseRate__c") + ', ' + createFieldSelector("InHouseMin__c") + ', ' + createFieldSelector("InHouseMax__c");
	jq("#gbMainTable").on( 'change', changeSelectors, expenseRecordChangedHandler );

	jq("#gbMainTable").on( 'click', '.createNew', function(event){
        firstBreakoutCreation(event);
        hideFields();
    });
	
	jq("#gbMainTable").on('click', '.pl.ui-selectee', function(e) {
		var kids, nut, parent;
		parent = jq(e.target).closest('td');
		parent = jq(parent).closest('tr');	

		kids = (parent).find('td[name="v18"]').text();
		kids = parseInt(kids) ? parseInt(kids) : 0;
		if (kids) {
	       jq( parent ).find( "select" ).prop( "disabled", true );
	       jq( parent ).find( "input" ).attr( "readonly", true ).attr( "disabled", true );
	       jq( parent ).find( "select" ).removeClass('gbrq');
	       jq( parent ).find( "input" ).removeClass('gbrq');
	        nut = jq( parent ).find(createFieldSelector("HouseNut__c"));
	        nut = nut.find('input');
	        nut.attr( "readonly", false ).attr( "disabled", false );   
		} else {
			disableNutCalculatedFields('nutcheck',e.target);
		}
	});

	jq("#gbMainTable").on( 'change', createFieldSelector("OfferRateType__c"), offerRateTypeChangeHandler );
	offerRateTypeChangeHandler( null );
	jq("#gbMainTable").on( 'change', createFieldSelector("InHouseRateType__c"), inHouseRateTypeChangeHandler );
	inHouseRateTypeChangeHandler( null );

	jq( "#gbMainTable > tbody > tr > td[name='v18']" ).each( function( elIndex, el ){
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
	       	toggle.each( function( elIndex, el ) {
	       		el.click();
	       	});

		} 
	});

	//"Event Total" Label
    var firstRow = jq(".summaryRow td[name=v0]");
    var secondRow = firstRow.next();
    secondRow.remove();
    firstRow.attr('colspan', 2);
    firstRow.css('text-align','center')
    firstRow.html('Event Total');

	formatGLsWithBreakouts();

	markTableReady(true);

	gridStateMessagingController('nutter');
	disableX50148XRows();
	makeX50148XRowsReadonly();
});