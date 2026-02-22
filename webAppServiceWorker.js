//
//file "webAppServiceWorker.js"
//

const cacheName = "FrACT10·2026-02-22d";


//Fetching content using Service Worker, this is called on reload. If cache name has changed, `install` is next
self.addEventListener('fetch', (event) => {
    //console.info("webAppServiceWorker responding to fetch event…");
    event.respondWith((async () => {
        const response1 = await caches.match(event.request);
        if (response1) return response1;
        const response2 = await fetch(event.request);
        const cache = await caches.open(cacheName);
        //console.info(`webAppServiceWorker Caching new resource: ${event.request.url}`);
               await cache.put(event.request, response2.clone());
        return response2;
    })());
});


//Installing Service Worker, this is called first, before "AppController>init"
self.addEventListener('install', (event) => {
    //console.info("webAppServiceWorker responding to install event…");
    event.waitUntil(
                    caches.open(cacheName).then((cache) => {
                        return cache.addAll([ //Cache all these files
                            './',
                            './Browser.environment/dataURLs.txt',
                            './Browser.environment/FrACT.sj',
                            './Browser.environment/MHTMLData.txt',
                            './Browser.environment/MHTMLPaths.txt',
                            './Browser.environment/MHTMLTest.txt',
                            './index.html',
                            './Info.plist',
                            './Resources/allRewardSprites.webp',
                            './Resources/plasticCard4calibration.png',
                            './Resources/MainMenu.cib',
                            './Resources/buttons/buttonAcuityC.png',
                            './Resources/buttons/buttonAcuityE.png',
                            './Resources/buttons/buttonAcuityLett.png',
                            './Resources/buttons/buttonAcuityLineByLine.png',
                            './Resources/buttons/buttonAcuityTAO.png',
                            './Resources/buttons/buttonAcuityVernier.png',
                            './Resources/buttons/buttonBalm.png',
                            './Resources/buttons/buttonContrastC.png',
                            './Resources/buttons/buttonContrastE.png',
                            './Resources/buttons/buttonContrastLett.png',
                            './Resources/buttons/buttonGrating.png',
                            './Resources/buttons/iconAbout.png',
                            './Resources/buttons/iconCross.png',
                            './Resources/buttons/iconFullscreen.svg',
                            './Resources/buttons/iconHelp.png',
                            './Resources/buttons/iconSettings.png',
                            './Resources/buttons/qrcode.svg',
                            './Resources/icons/FrACT_svg_icon.svg',
                            './Resources/js/FileSaver.min.js',
                            './Resources/js/jspdf.plugin.autotable.min.js',
                            './Resources/js/jspdf.umd.min.js',
                            './Resources/js/testingSuite.js',
                            './Resources/js/qrcode.min.js',
                            './Resources/keyMaps/keyMap4.png',
                            './Resources/keyMaps/keyMap4keysOnly.png',
                            './Resources/keyMaps/keyMap8.png',
                            './Resources/keyMaps/keyMapUpDownOnly.png',
                            './Resources/keyMaps/keyMap8gratings.avif',
                            './Resources/optotypeEs/optotypeE000.png',
                            './Resources/optotypeEs/optotypeE090.png',
                            './Resources/optotypeEs/optotypeE180.png',
                            './Resources/optotypeEs/optotypeE270.png',
                            './Resources/sounds/runEnd/cuteLevelUp.mp3',
                            './Resources/sounds/runEnd/gong.mp3',
                            './Resources/sounds/trialNo/error2.mp3',
                            './Resources/sounds/trialNo/whistle.mp3',
                            './Resources/sounds/trialStart/click02.mp3',
                            './Resources/sounds/trialStart/notify1.mp3',
                            './Resources/sounds/trialStart/notify2.mp3',
                            './Resources/sounds/trialYes/miniPop.mp3',
                            './Resources/sounds/trialYes/tink.mp3',
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


//Activate Service Worker, this is called after the `install` event
self.addEventListener('activate', function(event) {
    //console.info("webAppServiceWorker responding to activate event…");
    const cacheWhitelist = [cacheName];
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
