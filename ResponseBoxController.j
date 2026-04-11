/*
 This file is part of FrACT10, a vision test battery.
 © 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 ResponseBoxController
 Deals with incoming responses from a smartphone-based virtual response box
 Commands = messages are the same as used in the HTML messages

 */

@import "Globals.j"

let isFirebaseInitialized = NO;

@implementation ResponseBoxController: CPObject


+ (void) init { //console.info("ResponseBoxController>init")
    if (isFirebaseInitialized) return;
    isFirebaseInitialized = YES;
    (async () => {
        // Dynamic import from CDN
        const fbOrigin = "https://www.gstatic.com/firebasejs/12.9.0/";
        const {initializeApp} = await import(fbOrigin + "firebase-app.js");
        const {getDatabase, ref, onValue} = await import(fbOrigin + "firebase-database.js");
        const firebaseConfig = {
            apiKey: "AIzaSyC5n1oOxi4AKDbloL3dzzuKXWyZ0f-3hVc",
            authDomain: "fractresponsedispatch.firebaseapp.com",
            projectId: "fractresponsedispatch",
            storageBucket: "fractresponsedispatch.firebasestorage.app",
            messagingSenderId: "831450499406",
            appId: "1:831450499406:web:8a6eb122648d0bac67761f",
            databaseURL: "https://fractresponsedispatch-default-rtdb.europe-west1.firebasedatabase.app"
        };
        const app = initializeApp(firebaseConfig);
        const db = getDatabase(app);
        const responseRef = ref(db, "responses/" + gCurrentUUID);

        onValue(responseRef, (snapshot) => {
            const data = snapshot.val();
            if (!data) return;
            if (!data.appName || !data.session || !data.value || !data.timestamp) return;
            if ((data.value === undefined) || (data.timestamp === undefined)) return;
            if (data.appName.length + data.session.length + data.value.length + data.timestamp.length > 200) return;
            const deltaT = Date.now() - data.timestamp; // console.info("deltaT", deltaT);
            if (deltaT > 1000) { //console.warn("deltaT too high: ", deltaT);
                return;
            }
            if (data.session !== gCurrentUUID) {
                console.info("ResponseBoxController, Wrong sessionID: ", data.session, ", expected: ", gCurrentUUID);
                return;
            }
            //console.info("firebaseResponseReceived", data.appName, data.session, data.value, data.timestamp);
            [[CPNotificationCenter defaultCenter] postNotificationName: "dispatchNotification" object: nil userInfo: data.value];
        });
    })();
}


@end
