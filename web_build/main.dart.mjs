
// `modulePromise` is a promise to the `WebAssembly.module` object to be
//   instantiated.
// `importObjectPromise` is a promise to an object that contains any additional
//   imports needed by the module that aren't provided by the standard runtime.
//   The fields on this object will be merged into the importObject with which
//   the module will be instantiated.
// This function returns a promise to the instantiated module.
export const instantiate = async (modulePromise, importObjectPromise) => {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + js;
    }

    // Converts a Dart List to a JS array. Any Dart objects will be converted, but
    // this will be cheap for JSValues.
    function arrayFromDartList(constructor, list) {
      const exports = dartInstance.exports;
      const read = exports.$listRead;
      const length = exports.$listLength(list);
      const array = new constructor(length);
      for (let i = 0; i < length; i++) {
        array[i] = read(list, i);
      }
      return array;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {

_1: (x0,x1,x2) => x0.set(x1,x2),
_2: (x0,x1,x2) => x0.set(x1,x2),
_3: (x0,x1) => x0.transferFromImageBitmap(x1),
_4: x0 => x0.arrayBuffer(),
_5: (x0,x1) => x0.transferFromImageBitmap(x1),
_6: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._6(f,arguments.length,x0) }),
_7: x0 => new window.FinalizationRegistry(x0),
_8: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
_9: (x0,x1) => x0.unregister(x1),
_10: (x0,x1,x2) => x0.slice(x1,x2),
_11: (x0,x1) => x0.decode(x1),
_12: (x0,x1) => x0.segment(x1),
_13: () => new TextDecoder(),
_14: x0 => x0.buffer,
_15: x0 => x0.wasmMemory,
_16: () => globalThis.window._flutter_skwasmInstance,
_17: x0 => x0.rasterStartMilliseconds,
_18: x0 => x0.rasterEndMilliseconds,
_19: x0 => x0.imageBitmaps,
_167: x0 => x0.select(),
_168: (x0,x1) => x0.append(x1),
_169: x0 => x0.remove(),
_172: x0 => x0.unlock(),
_177: x0 => x0.getReader(),
_189: x0 => new MutationObserver(x0),
_206: (x0,x1) => new OffscreenCanvas(x0,x1),
_208: (x0,x1,x2) => x0.addEventListener(x1,x2),
_209: (x0,x1,x2) => x0.removeEventListener(x1,x2),
_212: x0 => new ResizeObserver(x0),
_215: (x0,x1) => new Intl.Segmenter(x0,x1),
_216: x0 => x0.next(),
_217: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
_294: x0 => x0.close(),
_295: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
_296: x0 => new window.ImageDecoder(x0),
_297: x0 => x0.close(),
_298: x0 => ({frameIndex: x0}),
_299: (x0,x1) => x0.decode(x1),
_302: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._302(f,arguments.length,x0) }),
_303: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._303(f,arguments.length,x0) }),
_304: (x0,x1) => ({addView: x0,removeView: x1}),
_305: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._305(f,arguments.length,x0) }),
_306: f => finalizeWrapper(f, function() { return dartInstance.exports._306(f,arguments.length) }),
_307: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
_308: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._308(f,arguments.length,x0) }),
_309: x0 => ({runApp: x0}),
_310: x0 => new Uint8Array(x0),
_312: x0 => x0.preventDefault(),
_313: x0 => x0.stopPropagation(),
_314: (x0,x1) => x0.addListener(x1),
_315: (x0,x1) => x0.removeListener(x1),
_316: (x0,x1) => x0.prepend(x1),
_317: x0 => x0.remove(),
_318: x0 => x0.disconnect(),
_319: (x0,x1) => x0.addListener(x1),
_320: (x0,x1) => x0.removeListener(x1),
_322: (x0,x1) => x0.append(x1),
_323: x0 => x0.remove(),
_324: x0 => x0.stopPropagation(),
_328: x0 => x0.preventDefault(),
_329: (x0,x1) => x0.append(x1),
_330: x0 => x0.remove(),
_331: x0 => x0.preventDefault(),
_336: (x0,x1) => x0.appendChild(x1),
_337: (x0,x1,x2) => x0.insertBefore(x1,x2),
_338: (x0,x1) => x0.removeChild(x1),
_339: (x0,x1) => x0.appendChild(x1),
_340: (x0,x1) => x0.transferFromImageBitmap(x1),
_341: (x0,x1) => x0.append(x1),
_342: (x0,x1) => x0.append(x1),
_343: (x0,x1) => x0.append(x1),
_344: x0 => x0.remove(),
_345: x0 => x0.remove(),
_346: x0 => x0.remove(),
_347: (x0,x1) => x0.appendChild(x1),
_348: (x0,x1) => x0.appendChild(x1),
_349: x0 => x0.remove(),
_350: (x0,x1) => x0.append(x1),
_351: (x0,x1) => x0.append(x1),
_352: x0 => x0.remove(),
_353: (x0,x1) => x0.append(x1),
_354: (x0,x1) => x0.append(x1),
_355: (x0,x1,x2) => x0.insertBefore(x1,x2),
_356: (x0,x1) => x0.append(x1),
_357: (x0,x1,x2) => x0.insertBefore(x1,x2),
_358: x0 => x0.remove(),
_359: x0 => x0.remove(),
_360: (x0,x1) => x0.append(x1),
_361: x0 => x0.remove(),
_362: (x0,x1) => x0.append(x1),
_363: x0 => x0.remove(),
_364: x0 => x0.remove(),
_365: x0 => x0.getBoundingClientRect(),
_366: x0 => x0.remove(),
_367: x0 => x0.blur(),
_368: x0 => x0.remove(),
_369: x0 => x0.blur(),
_370: x0 => x0.remove(),
_383: (x0,x1) => x0.append(x1),
_384: x0 => x0.remove(),
_385: (x0,x1) => x0.append(x1),
_386: (x0,x1,x2) => x0.insertBefore(x1,x2),
_387: x0 => x0.preventDefault(),
_388: x0 => x0.preventDefault(),
_389: x0 => x0.preventDefault(),
_390: x0 => x0.preventDefault(),
_391: x0 => x0.remove(),
_392: (x0,x1) => x0.observe(x1),
_393: x0 => x0.disconnect(),
_394: (x0,x1) => x0.appendChild(x1),
_395: (x0,x1) => x0.appendChild(x1),
_396: (x0,x1) => x0.appendChild(x1),
_397: (x0,x1) => x0.append(x1),
_398: x0 => x0.remove(),
_399: (x0,x1) => x0.append(x1),
_401: (x0,x1) => x0.appendChild(x1),
_402: (x0,x1) => x0.append(x1),
_403: x0 => x0.remove(),
_404: (x0,x1) => x0.append(x1),
_408: (x0,x1) => x0.appendChild(x1),
_409: x0 => x0.remove(),
_969: () => globalThis.window.flutterConfiguration,
_970: x0 => x0.assetBase,
_975: x0 => x0.debugShowSemanticsNodes,
_976: x0 => x0.hostElement,
_977: x0 => x0.multiViewEnabled,
_978: x0 => x0.nonce,
_980: x0 => x0.fontFallbackBaseUrl,
_981: x0 => x0.useColorEmoji,
_985: x0 => x0.console,
_986: x0 => x0.devicePixelRatio,
_987: x0 => x0.document,
_988: x0 => x0.history,
_989: x0 => x0.innerHeight,
_990: x0 => x0.innerWidth,
_991: x0 => x0.location,
_992: x0 => x0.navigator,
_993: x0 => x0.visualViewport,
_994: x0 => x0.performance,
_995: (x0,x1) => x0.fetch(x1),
_1000: (x0,x1) => x0.dispatchEvent(x1),
_1001: (x0,x1) => x0.matchMedia(x1),
_1002: (x0,x1) => x0.getComputedStyle(x1),
_1004: x0 => x0.screen,
_1005: (x0,x1) => x0.requestAnimationFrame(x1),
_1006: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1006(f,arguments.length,x0) }),
_1010: (x0,x1) => x0.warn(x1),
_1013: () => globalThis.window,
_1014: () => globalThis.Intl,
_1015: () => globalThis.Symbol,
_1018: x0 => x0.clipboard,
_1019: x0 => x0.maxTouchPoints,
_1020: x0 => x0.vendor,
_1021: x0 => x0.language,
_1022: x0 => x0.platform,
_1023: x0 => x0.userAgent,
_1024: x0 => x0.languages,
_1025: x0 => x0.documentElement,
_1026: (x0,x1) => x0.querySelector(x1),
_1029: (x0,x1) => x0.createElement(x1),
_1031: (x0,x1) => x0.execCommand(x1),
_1035: (x0,x1) => x0.createTextNode(x1),
_1036: (x0,x1) => x0.createEvent(x1),
_1040: x0 => x0.head,
_1041: x0 => x0.body,
_1042: (x0,x1) => x0.title = x1,
_1045: x0 => x0.activeElement,
_1047: x0 => x0.visibilityState,
_1048: () => globalThis.document,
_1049: (x0,x1,x2) => x0.addEventListener(x1,x2),
_1050: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
_1051: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
_1052: (x0,x1,x2) => x0.removeEventListener(x1,x2),
_1055: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1055(f,arguments.length,x0) }),
_1056: x0 => x0.target,
_1058: x0 => x0.timeStamp,
_1059: x0 => x0.type,
_1061: x0 => x0.preventDefault(),
_1065: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
_1070: x0 => x0.firstChild,
_1076: x0 => x0.parentElement,
_1078: x0 => x0.parentNode,
_1081: (x0,x1) => x0.removeChild(x1),
_1082: (x0,x1) => x0.removeChild(x1),
_1083: x0 => x0.isConnected,
_1084: (x0,x1) => x0.textContent = x1,
_1087: (x0,x1) => x0.contains(x1),
_1092: x0 => x0.firstElementChild,
_1094: x0 => x0.nextElementSibling,
_1095: x0 => x0.clientHeight,
_1096: x0 => x0.clientWidth,
_1097: x0 => x0.offsetHeight,
_1098: x0 => x0.offsetWidth,
_1099: x0 => x0.id,
_1100: (x0,x1) => x0.id = x1,
_1103: (x0,x1) => x0.spellcheck = x1,
_1104: x0 => x0.tagName,
_1105: x0 => x0.style,
_1107: (x0,x1) => x0.append(x1),
_1108: (x0,x1) => x0.getAttribute(x1),
_1109: x0 => x0.getBoundingClientRect(),
_1112: (x0,x1) => x0.closest(x1),
_1114: (x0,x1) => x0.querySelectorAll(x1),
_1115: x0 => x0.remove(),
_1116: (x0,x1,x2) => x0.setAttribute(x1,x2),
_1118: (x0,x1) => x0.removeAttribute(x1),
_1119: (x0,x1) => x0.tabIndex = x1,
_1121: (x0,x1) => x0.focus(x1),
_1122: x0 => x0.scrollTop,
_1123: (x0,x1) => x0.scrollTop = x1,
_1124: x0 => x0.scrollLeft,
_1125: (x0,x1) => x0.scrollLeft = x1,
_1126: x0 => x0.classList,
_1127: (x0,x1) => x0.className = x1,
_1131: (x0,x1) => x0.getElementsByClassName(x1),
_1132: x0 => x0.click(),
_1133: (x0,x1) => x0.hasAttribute(x1),
_1136: (x0,x1) => x0.attachShadow(x1),
_1140: (x0,x1) => x0.getPropertyValue(x1),
_1142: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
_1144: (x0,x1) => x0.removeProperty(x1),
_1146: x0 => x0.offsetLeft,
_1147: x0 => x0.offsetTop,
_1148: x0 => x0.offsetParent,
_1150: (x0,x1) => x0.name = x1,
_1151: x0 => x0.content,
_1152: (x0,x1) => x0.content = x1,
_1165: (x0,x1) => x0.nonce = x1,
_1170: x0 => x0.now(),
_1172: (x0,x1) => x0.width = x1,
_1174: (x0,x1) => x0.height = x1,
_1178: (x0,x1) => x0.getContext(x1),
_1251: x0 => x0.width,
_1252: x0 => x0.height,
_1256: x0 => x0.status,
_1258: x0 => x0.body,
_1259: x0 => x0.arrayBuffer(),
_1264: x0 => x0.read(),
_1265: x0 => x0.value,
_1266: x0 => x0.done,
_1268: x0 => x0.name,
_1269: x0 => x0.x,
_1270: x0 => x0.y,
_1273: x0 => x0.top,
_1274: x0 => x0.right,
_1275: x0 => x0.bottom,
_1276: x0 => x0.left,
_1285: x0 => x0.height,
_1286: x0 => x0.width,
_1287: (x0,x1) => x0.value = x1,
_1289: (x0,x1) => x0.placeholder = x1,
_1290: (x0,x1) => x0.name = x1,
_1291: x0 => x0.selectionDirection,
_1292: x0 => x0.selectionStart,
_1293: x0 => x0.selectionEnd,
_1296: x0 => x0.value,
_1298: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
_1303: x0 => x0.readText(),
_1304: (x0,x1) => x0.writeText(x1),
_1305: x0 => x0.altKey,
_1306: x0 => x0.code,
_1307: x0 => x0.ctrlKey,
_1308: x0 => x0.key,
_1309: x0 => x0.keyCode,
_1310: x0 => x0.location,
_1311: x0 => x0.metaKey,
_1312: x0 => x0.repeat,
_1313: x0 => x0.shiftKey,
_1314: x0 => x0.isComposing,
_1315: (x0,x1) => x0.getModifierState(x1),
_1316: x0 => x0.state,
_1319: (x0,x1) => x0.go(x1),
_1320: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
_1321: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
_1322: x0 => x0.pathname,
_1323: x0 => x0.search,
_1324: x0 => x0.hash,
_1327: x0 => x0.state,
_1333: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1333(f,arguments.length,x0,x1) }),
_1335: (x0,x1,x2) => x0.observe(x1,x2),
_1338: x0 => x0.attributeName,
_1339: x0 => x0.type,
_1340: x0 => x0.matches,
_1344: x0 => x0.matches,
_1345: x0 => x0.relatedTarget,
_1346: x0 => x0.clientX,
_1347: x0 => x0.clientY,
_1348: x0 => x0.offsetX,
_1349: x0 => x0.offsetY,
_1352: x0 => x0.button,
_1353: x0 => x0.buttons,
_1354: x0 => x0.ctrlKey,
_1355: (x0,x1) => x0.getModifierState(x1),
_1356: x0 => x0.pointerId,
_1357: x0 => x0.pointerType,
_1358: x0 => x0.pressure,
_1359: x0 => x0.tiltX,
_1360: x0 => x0.tiltY,
_1361: x0 => x0.getCoalescedEvents(),
_1362: x0 => x0.deltaX,
_1363: x0 => x0.deltaY,
_1364: x0 => x0.wheelDeltaX,
_1365: x0 => x0.wheelDeltaY,
_1366: x0 => x0.deltaMode,
_1371: x0 => x0.changedTouches,
_1373: x0 => x0.clientX,
_1374: x0 => x0.clientY,
_1375: x0 => x0.data,
_1376: (x0,x1) => x0.type = x1,
_1377: (x0,x1) => x0.max = x1,
_1378: (x0,x1) => x0.min = x1,
_1379: (x0,x1) => x0.value = x1,
_1380: x0 => x0.value,
_1381: x0 => x0.disabled,
_1382: (x0,x1) => x0.disabled = x1,
_1383: (x0,x1) => x0.placeholder = x1,
_1384: (x0,x1) => x0.name = x1,
_1385: (x0,x1) => x0.autocomplete = x1,
_1386: x0 => x0.selectionDirection,
_1387: x0 => x0.selectionStart,
_1388: x0 => x0.selectionEnd,
_1392: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
_1399: (x0,x1) => x0.add(x1),
_1402: (x0,x1) => x0.noValidate = x1,
_1403: (x0,x1) => x0.method = x1,
_1404: (x0,x1) => x0.action = x1,
_1409: (x0,x1) => x0.getContext(x1),
_1412: x0 => x0.convertToBlob(),
_1431: x0 => x0.orientation,
_1432: x0 => x0.width,
_1433: x0 => x0.height,
_1434: (x0,x1) => x0.lock(x1),
_1451: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1451(f,arguments.length,x0,x1) }),
_1461: x0 => x0.length,
_1462: (x0,x1) => x0.item(x1),
_1463: x0 => x0.length,
_1464: (x0,x1) => x0.item(x1),
_1465: x0 => x0.iterator,
_1466: x0 => x0.Segmenter,
_1467: x0 => x0.v8BreakIterator,
_1470: x0 => x0.done,
_1471: x0 => x0.value,
_1472: x0 => x0.index,
_1476: (x0,x1) => x0.adoptText(x1),
_1478: x0 => x0.first(),
_1479: x0 => x0.next(),
_1480: x0 => x0.current(),
_1493: x0 => x0.hostElement,
_1494: x0 => x0.viewConstraints,
_1496: x0 => x0.maxHeight,
_1497: x0 => x0.maxWidth,
_1498: x0 => x0.minHeight,
_1499: x0 => x0.minWidth,
_1500: x0 => x0.loader,
_1501: () => globalThis._flutter,
_1502: (x0,x1) => x0.didCreateEngineInitializer(x1),
_1503: (x0,x1,x2) => x0.call(x1,x2),
_1504: () => globalThis.Promise,
_1505: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1505(f,arguments.length,x0,x1) }),
_1508: x0 => x0.length,
_1511: x0 => x0.tracks,
_1515: x0 => x0.image,
_1520: x0 => x0.codedWidth,
_1521: x0 => x0.codedHeight,
_1524: x0 => x0.duration,
_1528: x0 => x0.ready,
_1529: x0 => x0.selectedTrack,
_1530: x0 => x0.repetitionCount,
_1531: x0 => x0.frameCount,
_1604: (x0,x1) => x0.querySelector(x1),
_1605: (x0,x1) => x0.createElement(x1),
_1606: (x0,x1) => x0.append(x1),
_1622: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
_1631: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
_1636: (x0,x1) => x0.canShare(x1),
_1637: (x0,x1) => x0.share(x1),
_1643: x0 => ({files: x0}),
_1644: () => ({}),
_1645: (x0,x1,x2) => new File(x0,x1,x2),
_1646: (x0,x1) => x0.getItem(x1),
_1648: (x0,x1,x2) => x0.setItem(x1,x2),
_1652: (x0,x1) => x0.querySelector(x1),
_1653: (x0,x1) => x0.querySelector(x1),
_1679: () => new Array(),
_1680: x0 => new Array(x0),
_1682: (o, t) => typeof o === t,
_1683: (o, c) => o instanceof c,
_1684: (x0,x1,x2,x3,x4,x5) => x0.call(x1,x2,x3,x4,x5),
_1687: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1687(f,arguments.length,x0) }),
_1688: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1688(f,arguments.length,x0) }),
_1689: (x0,x1,x2) => x0.call(x1,x2),
_1693: (o, a) => o + a,
_1703: (o, a) => o == a,
_1714: (decoder, codeUnits) => decoder.decode(codeUnits),
_1715: () => new TextDecoder("utf-8", {fatal: true}),
_1716: () => new TextDecoder("utf-8", {fatal: false}),
_1717: v => v.toString(),
_1718: (d, digits) => d.toFixed(digits),
_1722: x0 => new WeakRef(x0),
_1723: x0 => x0.deref(),
_1724: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1724(f,arguments.length,x0) }),
_1725: x0 => new FinalizationRegistry(x0),
_1726: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
_1728: (x0,x1) => x0.unregister(x1),
_1729: Date.now,
_1731: s => new Date(s * 1000).getTimezoneOffset() * 60 ,
_1732: s => {
      if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
        return NaN;
      }
      return parseFloat(s);
    },
_1733: () => {
          let stackString = new Error().stack.toString();
          let frames = stackString.split('\n');
          let drop = 2;
          if (frames[0] === 'Error') {
              drop += 1;
          }
          return frames.slice(drop).join('\n');
        },
_1734: () => typeof dartUseDateNowForTicks !== "undefined",
_1735: () => 1000 * performance.now(),
_1736: () => Date.now(),
_1737: () => {
      // On browsers return `globalThis.location.href`
      if (globalThis.location != null) {
        return globalThis.location.href;
      }
      return null;
    },
_1738: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
_1739: () => new WeakMap(),
_1740: (map, o) => map.get(o),
_1741: (map, o, v) => map.set(o, v),
_1742: () => globalThis.WeakRef,
_1747: () => globalThis.FinalizationRegistry,
_1753: s => JSON.stringify(s),
_1754: s => printToConsole(s),
_1755: a => a.join(''),
_1756: (o, a, b) => o.replace(a, b),
_1758: (s, t) => s.split(t),
_1759: s => s.toLowerCase(),
_1760: s => s.toUpperCase(),
_1761: s => s.trim(),
_1762: s => s.trimLeft(),
_1763: s => s.trimRight(),
_1765: (s, p, i) => s.indexOf(p, i),
_1766: (s, p, i) => s.lastIndexOf(p, i),
_1767: (s) => s.replace(/\$/g, "$$$$"),
_1768: Object.is,
_1769: s => s.toUpperCase(),
_1770: s => s.toLowerCase(),
_1771: (a, i) => a.push(i),
_1775: a => a.pop(),
_1776: (a, i) => a.splice(i, 1),
_1778: (a, s) => a.join(s),
_1779: (a, s, e) => a.slice(s, e),
_1782: a => a.length,
_1784: (a, i) => a[i],
_1785: (a, i, v) => a[i] = v,
_1787: (o, offsetInBytes, lengthInBytes) => {
      var dst = new ArrayBuffer(lengthInBytes);
      new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
      return new DataView(dst);
    },
_1788: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
_1789: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
_1790: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
_1791: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
_1792: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
_1793: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
_1794: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
_1796: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
_1797: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
_1798: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
_1799: (t, s) => t.set(s),
_1801: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
_1802: o => o.byteLength,
_1803: o => o.buffer,
_1804: o => o.byteOffset,
_1805: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
_1806: (b, o) => new DataView(b, o),
_1807: (b, o, l) => new DataView(b, o, l),
_1808: Function.prototype.call.bind(DataView.prototype.getUint8),
_1809: Function.prototype.call.bind(DataView.prototype.setUint8),
_1810: Function.prototype.call.bind(DataView.prototype.getInt8),
_1811: Function.prototype.call.bind(DataView.prototype.setInt8),
_1812: Function.prototype.call.bind(DataView.prototype.getUint16),
_1813: Function.prototype.call.bind(DataView.prototype.setUint16),
_1814: Function.prototype.call.bind(DataView.prototype.getInt16),
_1815: Function.prototype.call.bind(DataView.prototype.setInt16),
_1816: Function.prototype.call.bind(DataView.prototype.getUint32),
_1817: Function.prototype.call.bind(DataView.prototype.setUint32),
_1818: Function.prototype.call.bind(DataView.prototype.getInt32),
_1819: Function.prototype.call.bind(DataView.prototype.setInt32),
_1822: Function.prototype.call.bind(DataView.prototype.getBigInt64),
_1823: Function.prototype.call.bind(DataView.prototype.setBigInt64),
_1824: Function.prototype.call.bind(DataView.prototype.getFloat32),
_1825: Function.prototype.call.bind(DataView.prototype.setFloat32),
_1826: Function.prototype.call.bind(DataView.prototype.getFloat64),
_1827: Function.prototype.call.bind(DataView.prototype.setFloat64),
_1828: (x0,x1) => x0.getRandomValues(x1),
_1829: x0 => new Uint8Array(x0),
_1830: () => globalThis.crypto,
_1841: (x0,x1) => x0.postMessage(x1),
_1843: x0 => new Worker(x0),
_1846: x0 => ({create: x0}),
_1847: (x0,x1,x2) => x0.getFileHandle(x1,x2),
_1855: (x0,x1,x2) => x0.open(x1,x2),
_1869: (x0,x1) => new SharedWorker(x0,x1),
_1870: x0 => x0.start(),
_1871: (x0,x1,x2) => x0.postMessage(x1,x2),
_1872: (x0,x1,x2) => x0.postMessage(x1,x2),
_1873: x0 => x0.close(),
_1874: x0 => x0.terminate(),
_1875: () => new MessageChannel(),
_1881: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1881(f,arguments.length,x0) }),
_1882: x0 => x0.close(),
_1883: x0 => new BroadcastChannel(x0),
_1884: x0 => globalThis.Array.isArray(x0),
_1885: (x0,x1) => x0.postMessage(x1),
_1888: (x0,x1) => ({kind: x0,table: x1}),
_1889: x0 => x0.kind,
_1890: x0 => x0.table,
_1891: (x0,x1) => ({i: x0,p: x1}),
_1892: (x0,x1) => ({c: x0,r: x1}),
_1893: x0 => x0.i,
_1894: x0 => x0.p,
_1895: x0 => x0.c,
_1896: x0 => x0.r,
_1906: (x0,x1) => x0.send(x1),
_1907: x0 => x0.send(),
_1910: (o, t) => o instanceof t,
_1912: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1912(f,arguments.length,x0) }),
_1913: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1913(f,arguments.length,x0) }),
_1914: o => Object.keys(o),
_1915: (ms, c) =>
              setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
_1916: (handle) => clearTimeout(handle),
_1917: (ms, c) =>
          setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
_1918: (handle) => clearInterval(handle),
_1919: (c) =>
              queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
_1920: () => Date.now(),
_1924: x0 => new URL(x0),
_1925: (x0,x1) => new URL(x0,x1),
_1926: (x0,x1) => globalThis.fetch(x0,x1),
_1927: (x0,x1,x2,x3) => x0.call(x1,x2,x3),
_1928: x0 => ({initial: x0}),
_1929: x0 => new WebAssembly.Memory(x0),
_1930: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1930(f,arguments.length,x0) }),
_1931: f => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return dartInstance.exports._1931(f,arguments.length,x0,x1,x2,x3,x4) }),
_1932: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1932(f,arguments.length,x0,x1,x2) }),
_1933: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1933(f,arguments.length,x0,x1,x2,x3) }),
_1934: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1934(f,arguments.length,x0,x1,x2,x3) }),
_1935: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1935(f,arguments.length,x0,x1,x2) }),
_1936: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1936(f,arguments.length,x0,x1) }),
_1937: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1937(f,arguments.length,x0,x1) }),
_1938: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1938(f,arguments.length,x0) }),
_1939: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1939(f,arguments.length,x0) }),
_1940: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1940(f,arguments.length,x0,x1,x2,x3) }),
_1941: f => finalizeWrapper(f, function(x0,x1,x2,x3) { return dartInstance.exports._1941(f,arguments.length,x0,x1,x2,x3) }),
_1942: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1942(f,arguments.length,x0,x1) }),
_1943: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1943(f,arguments.length,x0,x1) }),
_1944: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1944(f,arguments.length,x0,x1) }),
_1945: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1945(f,arguments.length,x0,x1) }),
_1946: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1946(f,arguments.length,x0,x1) }),
_1947: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1947(f,arguments.length,x0,x1) }),
_1948: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1948(f,arguments.length,x0,x1,x2) }),
_1949: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1949(f,arguments.length,x0,x1,x2) }),
_1950: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._1950(f,arguments.length,x0,x1,x2) }),
_1951: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1951(f,arguments.length,x0) }),
_1952: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1952(f,arguments.length,x0) }),
_1953: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1953(f,arguments.length,x0) }),
_1954: f => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return dartInstance.exports._1954(f,arguments.length,x0,x1,x2,x3,x4) }),
_1955: f => finalizeWrapper(f, function(x0,x1,x2,x3,x4) { return dartInstance.exports._1955(f,arguments.length,x0,x1,x2,x3,x4) }),
_1956: (x0,x1,x2,x3,x4,x5,x6) => x0.call(x1,x2,x3,x4,x5,x6),
_1957: (x0,x1,x2,x3,x4,x5,x6,x7) => x0.call(x1,x2,x3,x4,x5,x6,x7),
_1958: (x0,x1,x2,x3,x4) => x0.call(x1,x2,x3,x4),
_1959: x0 => x0.continue(),
_1960: () => globalThis.indexedDB,
_1962: x0 => x0.arrayBuffer(),
_1963: x0 => new SharedArrayBuffer(x0),
_1964: x0 => new SharedArrayBuffer(x0),
_1965: x0 => ({at: x0}),
_1973: x0 => x0.synchronizationBuffer,
_1974: x0 => x0.communicationBuffer,
_1975: (x0,x1,x2,x3) => ({clientVersion: x0,root: x1,synchronizationBuffer: x2,communicationBuffer: x3}),
_1976: x0 => new SharedArrayBuffer(x0),
_1977: (x0,x1) => globalThis.IDBKeyRange.bound(x0,x1),
_1978: x0 => ({autoIncrement: x0}),
_1979: (x0,x1,x2) => x0.createObjectStore(x1,x2),
_1980: x0 => ({unique: x0}),
_1981: (x0,x1,x2,x3) => x0.createIndex(x1,x2,x3),
_1982: (x0,x1) => x0.createObjectStore(x1),
_1983: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1983(f,arguments.length,x0) }),
_1984: x0 => x0.close(),
_1985: (x0,x1,x2) => x0.transaction(x1,x2),
_1988: (x0,x1) => x0.objectStore(x1),
_1989: (x0,x1) => x0.index(x1),
_1990: x0 => x0.openKeyCursor(),
_1991: (x0,x1) => x0.objectStore(x1),
_1992: (x0,x1) => x0.index(x1),
_1993: (x0,x1) => x0.getKey(x1),
_1994: (x0,x1) => x0.objectStore(x1),
_1995: (x0,x1) => ({name: x0,length: x1}),
_1996: (x0,x1) => x0.put(x1),
_1997: (x0,x1) => x0.objectStore(x1),
_1998: (x0,x1) => x0.get(x1),
_1999: (x0,x1) => x0.objectStore(x1),
_2000: (x0,x1) => x0.openCursor(x1),
_2002: (x0,x1) => x0.objectStore(x1),
_2003: x0 => globalThis.IDBKeyRange.only(x0),
_2004: x0 => new Blob(x0),
_2005: (x0,x1,x2) => x0.put(x1,x2),
_2006: (x0,x1) => x0.update(x1),
_2007: (x0,x1) => x0.objectStore(x1),
_2008: (x0,x1) => x0.update(x1),
_2009: (x0,x1) => x0.objectStore(x1),
_2010: (x0,x1) => x0.objectStore(x1),
_2011: (x0,x1) => x0.delete(x1),
_2012: (x0,x1) => x0.update(x1),
_2013: (x0,x1) => x0.objectStore(x1),
_2014: (x0,x1) => x0.delete(x1),
_2015: (x0,x1) => x0.objectStore(x1),
_2016: (x0,x1) => x0.delete(x1),
_2019: x0 => x0.name,
_2020: x0 => x0.length,
_2021: x0 => x0.createSyncAccessHandle(),
_2022: (x0,x1) => x0.truncate(x1),
_2023: (x0,x1) => x0.truncate(x1),
_2024: x0 => x0.close(),
_2025: x0 => x0.close(),
_2026: x0 => x0.flush(),
_2027: x0 => x0.getSize(),
_2028: x0 => x0.flush(),
_2029: (x0,x1) => x0.truncate(x1),
_2031: x0 => globalThis.BigInt(x0),
_2032: x0 => globalThis.Number(x0),
_2035: x0 => globalThis.Object.keys(x0),
_2040: (x0,x1) => globalThis.WebAssembly.instantiateStreaming(x0,x1),
_2041: x0 => x0.call(),
_2042: x0 => x0.exports,
_2043: x0 => x0.instance,
_2047: x0 => x0.buffer,
_2048: () => globalThis.WebAssembly.Global,
_2051: () => globalThis.navigator,
_2052: x0 => x0.getDirectory(),
_2053: (x0,x1) => x0.read(x1),
_2054: (x0,x1,x2) => x0.read(x1,x2),
_2055: (x0,x1) => x0.write(x1),
_2056: (x0,x1,x2) => x0.write(x1,x2),
_2057: x0 => ({create: x0}),
_2058: (x0,x1,x2) => x0.getDirectoryHandle(x1,x2),
_2059: () => new XMLHttpRequest(),
_2060: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
_2061: (x0,x1,x2) => x0.setRequestHeader(x1,x2),
_2063: x0 => x0.getAllResponseHeaders(),
_2064: x0 => globalThis.URL.createObjectURL(x0),
_2065: x0 => ({type: x0}),
_2066: (x0,x1) => new Blob(x0,x1),
_2067: () => new XMLHttpRequest(),
_2069: () => new FileReader(),
_2070: (x0,x1) => x0.readAsArrayBuffer(x1),
_2078: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2078(f,arguments.length,x0) }),
_2079: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._2079(f,arguments.length,x0) }),
_2101: (x0,x1) => x0.key(x1),
_2327: (s, m) => {
          try {
            return new RegExp(s, m);
          } catch (e) {
            return String(e);
          }
        },
_2328: (x0,x1) => x0.exec(x1),
_2329: (x0,x1) => x0.test(x1),
_2330: (x0,x1) => x0.exec(x1),
_2331: (x0,x1) => x0.exec(x1),
_2332: x0 => x0.pop(),
_2336: (x0,x1,x2) => x0[x1] = x2,
_2338: o => o === undefined,
_2339: o => typeof o === 'boolean',
_2340: o => typeof o === 'number',
_2342: o => typeof o === 'string',
_2345: o => o instanceof Int8Array,
_2346: o => o instanceof Uint8Array,
_2347: o => o instanceof Uint8ClampedArray,
_2348: o => o instanceof Int16Array,
_2349: o => o instanceof Uint16Array,
_2350: o => o instanceof Int32Array,
_2351: o => o instanceof Uint32Array,
_2352: o => o instanceof Float32Array,
_2353: o => o instanceof Float64Array,
_2354: o => o instanceof ArrayBuffer,
_2355: o => o instanceof DataView,
_2356: o => o instanceof Array,
_2357: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
_2359: o => {
            const proto = Object.getPrototypeOf(o);
            return proto === Object.prototype || proto === null;
          },
_2360: o => o instanceof RegExp,
_2361: (l, r) => l === r,
_2362: o => o,
_2363: o => o,
_2364: o => o,
_2365: b => !!b,
_2366: o => o.length,
_2369: (o, i) => o[i],
_2370: f => f.dartFunction,
_2371: l => arrayFromDartList(Int8Array, l),
_2372: (data, length) => {
          const jsBytes = new Uint8Array(length);
          const getByte = dartInstance.exports.$uint8ListGet;
          for (let i = 0; i < length; i++) {
            jsBytes[i] = getByte(data, i);
          }
          return jsBytes;
        },
_2373: l => arrayFromDartList(Uint8ClampedArray, l),
_2374: l => arrayFromDartList(Int16Array, l),
_2375: l => arrayFromDartList(Uint16Array, l),
_2376: l => arrayFromDartList(Int32Array, l),
_2377: l => arrayFromDartList(Uint32Array, l),
_2378: l => arrayFromDartList(Float32Array, l),
_2379: l => arrayFromDartList(Float64Array, l),
_2380: (data, length) => {
          const read = dartInstance.exports.$byteDataGetUint8;
          const view = new DataView(new ArrayBuffer(length));
          for (let i = 0; i < length; i++) {
              view.setUint8(i, read(data, i));
          }
          return view;
        },
_2381: l => arrayFromDartList(Array, l),
_2382:       (s, length) => {
        if (length == 0) return '';

        const read = dartInstance.exports.$stringRead1;
        let result = '';
        let index = 0;
        const chunkLength = Math.min(length - index, 500);
        let array = new Array(chunkLength);
        while (index < length) {
          const newChunkLength = Math.min(length - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(s, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      }
      ,
_2383:     (s, length) => {
      if (length == 0) return '';

      const read = dartInstance.exports.$stringRead2;
      let result = '';
      let index = 0;
      const chunkLength = Math.min(length - index, 500);
      let array = new Array(chunkLength);
      while (index < length) {
        const newChunkLength = Math.min(length - index, 500);
        for (let i = 0; i < newChunkLength; i++) {
          array[i] = read(s, index++);
        }
        if (newChunkLength < chunkLength) {
          array = array.slice(0, newChunkLength);
        }
        result += String.fromCharCode(...array);
      }
      return result;
    }
    ,
_2384:     (s) => {
      let length = s.length;
      let range = 0;
      for (let i = 0; i < length; i++) {
        range |= s.codePointAt(i);
      }
      const exports = dartInstance.exports;
      if (range < 256) {
        if (length <= 10) {
          if (length == 1) {
            return exports.$stringAllocate1_1(s.codePointAt(0));
          }
          if (length == 2) {
            return exports.$stringAllocate1_2(s.codePointAt(0), s.codePointAt(1));
          }
          if (length == 3) {
            return exports.$stringAllocate1_3(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2));
          }
          if (length == 4) {
            return exports.$stringAllocate1_4(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3));
          }
          if (length == 5) {
            return exports.$stringAllocate1_5(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4));
          }
          if (length == 6) {
            return exports.$stringAllocate1_6(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5));
          }
          if (length == 7) {
            return exports.$stringAllocate1_7(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6));
          }
          if (length == 8) {
            return exports.$stringAllocate1_8(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6), s.codePointAt(7));
          }
          if (length == 9) {
            return exports.$stringAllocate1_9(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6), s.codePointAt(7), s.codePointAt(8));
          }
          if (length == 10) {
            return exports.$stringAllocate1_10(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6), s.codePointAt(7), s.codePointAt(8), s.codePointAt(9));
          }
        }
        const dartString = exports.$stringAllocate1(length);
        const write = exports.$stringWrite1;
        for (let i = 0; i < length; i++) {
          write(dartString, i, s.codePointAt(i));
        }
        return dartString;
      } else {
        const dartString = exports.$stringAllocate2(length);
        const write = exports.$stringWrite2;
        for (let i = 0; i < length; i++) {
          write(dartString, i, s.charCodeAt(i));
        }
        return dartString;
      }
    }
    ,
_2385: () => ({}),
_2386: () => [],
_2387: l => new Array(l),
_2388: () => globalThis,
_2389: (constructor, args) => {
      const factoryFunction = constructor.bind.apply(
          constructor, [null, ...args]);
      return new factoryFunction();
    },
_2390: (o, p) => p in o,
_2391: (o, p) => o[p],
_2392: (o, p, v) => o[p] = v,
_2393: (o, m, a) => o[m].apply(o, a),
_2395: o => String(o),
_2396: (p, s, f) => p.then(s, f),
_2397: s => {
      if (/[[\]{}()*+?.\\^$|]/.test(s)) {
          s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
      }
      return s;
    },
_2400: x0 => x0.index,
_2402: x0 => x0.length,
_2404: (x0,x1) => x0[x1],
_2405: (x0,x1) => x0.exec(x1),
_2407: x0 => x0.flags,
_2408: x0 => x0.multiline,
_2409: x0 => x0.ignoreCase,
_2410: x0 => x0.unicode,
_2411: x0 => x0.dotAll,
_2412: (x0,x1) => x0.lastIndex = x1,
_2413: (o, p) => p in o,
_2414: (o, p) => o[p],
_2415: (o, p, v) => o[p] = v,
_2417: (x0,x1,x2) => globalThis.Atomics.wait(x0,x1,x2),
_2419: (x0,x1,x2) => globalThis.Atomics.notify(x0,x1,x2),
_2420: (x0,x1,x2) => globalThis.Atomics.store(x0,x1,x2),
_2421: (x0,x1) => globalThis.Atomics.load(x0,x1),
_2422: () => globalThis.Int32Array,
_2424: () => globalThis.Uint8Array,
_2426: () => globalThis.DataView,
_2429: x0 => x0.byteLength,
_2515: (x0,x1) => x0.withCredentials = x1,
_2517: x0 => x0.responseURL,
_2518: x0 => x0.status,
_2519: x0 => x0.statusText,
_2521: (x0,x1) => x0.responseType = x1,
_2522: x0 => x0.response,
_4337: () => globalThis.window,
_4416: x0 => x0.navigator,
_4663: x0 => x0.localStorage,
_4787: x0 => x0.userAgent,
_4788: x0 => x0.vendor,
_4800: x0 => x0.storage,
_4838: x0 => x0.data,
_4873: x0 => x0.port1,
_4874: x0 => x0.port2,
_4879: (x0,x1) => x0.onmessage = x1,
_4963: x0 => x0.port,
_5002: x0 => x0.length,
_7988: x0 => x0.type,
_8127: () => globalThis.document,
_8218: x0 => x0.body,
_8579: (x0,x1) => x0.id = x1,
_8595: x0 => x0.children,
_10267: (x0,x1) => x0.type = x1,
_10292: x0 => x0.result,
_12278: x0 => x0.result,
_12279: x0 => x0.error,
_12290: (x0,x1) => x0.onupgradeneeded = x1,
_12292: x0 => x0.oldVersion,
_12383: x0 => x0.key,
_12384: x0 => x0.primaryKey,
_12386: x0 => x0.value,
_14514: x0 => x0.name,
_14515: x0 => x0.message
    };

    const baseImports = {
        dart2wasm: dart2wasm,


        Math: Math,
        Date: Date,
        Object: Object,
        Array: Array,
        Reflect: Reflect,
    };

    const jsStringPolyfill = {
        "charCodeAt": (s, i) => s.charCodeAt(i),
        "compare": (s1, s2) => {
            if (s1 < s2) return -1;
            if (s1 > s2) return 1;
            return 0;
        },
        "concat": (s1, s2) => s1 + s2,
        "equals": (s1, s2) => s1 === s2,
        "fromCharCode": (i) => String.fromCharCode(i),
        "length": (s) => s.length,
        "substring": (s, a, b) => s.substring(a, b),
    };

    dartInstance = await WebAssembly.instantiate(await modulePromise, {
        ...baseImports,
        ...(await importObjectPromise),
        "wasm:js-string": jsStringPolyfill,
    });

    return dartInstance;
}

// Call the main function for the instantiated module
// `moduleInstance` is the instantiated dart2wasm module
// `args` are any arguments that should be passed into the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

