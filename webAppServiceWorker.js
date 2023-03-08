/* file "webAppServiceWorker.js" */


const cacheName = 'FrACT10-sw-v5';


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
        'index.html',
        'Info.plist',
        'Browser.environment/capp.sj',
        'Browser.environment/dataURLs.txt',
        'Browser.environment/MHTMLData.txt',
        'Browser.environment/MHTMLPaths.txt',
        'Browser.environment/MHTMLTest.txt',
        'Resources/allRewards4800x200.png',
        'Resources/CreditcardPlus2x50.png',
        'Resources/MainMenu.cib',
        'Resources/buttons/butCntC.png',
		'Resources/buttons/butCntE.png',
		'Resources/buttons/butCntLett.png',
		'Resources/buttons/buttonAcuityC.png',
		'Resources/buttons/buttonAcuityE.png',
		'Resources/buttons/buttonAcuityLett.png',
		'Resources/buttons/buttonAcuityLineByLine.png',
		'Resources/buttons/buttonAcuityTAO.png',
		'Resources/buttons/buttonAcuityVernier.png',
		'Resources/buttons/iconAbout.png',
		'Resources/buttons/iconFullscreen.png',
		'Resources/buttons/iconHelp.png',
		'Resources/buttons/iconSettings.png'
      ]);
    })
  );
});
/*  to be done…
dither
icons
keyMaps
optotypeEs
sounds
TAOs
*/


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
