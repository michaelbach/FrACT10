/* file "webAppServiceWorker.js" */


const cacheName = 'FrACT10-sw-2023-07-03';

/* Fetching content using Service Worker */
self.addEventListener('fetch', (e) => {
  /*console.info("[Service Worker] responding to fetch event…");*/
  e.respondWith((async () => {
    const r = await caches.match(e.request);
    /*console.info(`[Service Worker] Fetching resource: ${e.request.url}`);*/
    if (r) return r;
    const response = await fetch(e.request);
    const cache = await caches.open(cacheName);
    /*console.info(`[Service Worker] Caching new resource: ${e.request.url}`);*/
    cache.put(e.request, response.clone());
    return response;
  })());
});


/* Installing Service Worker */
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(cacheName).then((cache) => {
      return cache.addAll([ /* Cache all these files */
  	    './',
        './Browser.environment/dataURLs.txt',
        './Browser.environment/MHTMLData.txt',
        './Browser.environment/MHTMLPaths.txt',
        './Browser.environment/MHTMLTest.txt',
        './Browser.environment/FrACT.sj',
      	'./index.html',
        './Info.plist',
        './Resources/allRewards4800x200.png',
        './Resources/CreditcardPlus2x50.png',
        './Resources/MainMenu.cib',
        './Resources/buttons/butCntC.png',
		'./Resources/buttons/butCntE.png',
		'./Resources/buttons/butCntLett.png',
		'./Resources/buttons/buttonAcuityC.png',
		'./Resources/buttons/buttonAcuityE.png',
		'./Resources/buttons/buttonAcuityLett.png',
		'./Resources/buttons/buttonAcuityLineByLine.png',
		'./Resources/buttons/buttonAcuityTAO.png',
		'./Resources/buttons/buttonAcuityVernier.png',
		'./Resources/buttons/iconAbout.png',
		'./Resources/buttons/iconFullscreen.png',
		'./Resources/buttons/iconHelp.png',
		'./Resources/buttons/iconSettings.png',
		'./Resources/icons/FrACT_icon-128.png',
		'./Resources/icons/FrACT_icon-390.png',
		'./Resources/icons/FrACT_icon-512.png',
		'./Resources/icons/FrACT3icon.ico',
		'./Resources/icons/icon.png',
		'./Resources/keyMaps/keyMap4.png',
		'./Resources/keyMaps/keyMap4keysOnly.png',
		'./Resources/keyMaps/keyMap8.png',
		'./Resources/keyMaps/keyMapUpDownOnly.png',
		'./Resources/optotypeEs/optotypeE000.png',
		'./Resources/optotypeEs/optotypeE090.png',
		'./Resources/optotypeEs/optotypeE180.png',
		'./Resources/optotypeEs/optotypeE270.png',
		'./Resources/sounds/runEnd.mp3',
		'./Resources/sounds/trialNo.mp3',
		'./Resources/sounds/trialYes.mp3',
		'./Resources/TAOs/butterfly.png',
		'./Resources/TAOs/car.png',
		'./Resources/TAOs/duck.png',
		'./Resources/TAOs/flower.png',
		'./Resources/TAOs/heart.png',
		'./Resources/TAOs/house.png',
		'./Resources/TAOs/moon.png',
		'./Resources/TAOs/rabbit.png',
		'./Resources/TAOs/rocket.png',
		'./Resources/TAOs/tree.png',
		]);
    })
  );
});


self.addEventListener('activate', function(event) {
  var cacheWhitelist = [cacheName];
  event.waitUntil(
    caches.keys().then(function(keyList) {
      return Promise.all(keyList.map(function(key) {
        if (cacheWhitelist.indexOf(key) === -1) {
          return caches.delete(key);
        }
      }));
    })
  )
});
