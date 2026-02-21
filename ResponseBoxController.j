/*
 This file is part of FrACT10, a vision test battery.
 © 2026 Michael Bach, bach@uni-freiburg.de, <https://michaelbach.de>

 ResponseBoxController
 Deals with incoming responses from a smartphone-based virtual response box
 Commands = messages are the same as used in the HTML messages

 */

@import "Globals.j"

@implementation ResponseBoxController: CPObject

+ (void) init { //console.info("ResponseBoxController>init")
    const firebaseConfig = {
        apiKey: "AIzaSyC5n1oOxi4AKDbloL3dzzuKXWyZ0f-3hVc",
        authDomain: "fractresponsedispatch.firebaseapp.com",
        projectId: "fractresponsedispatch",
        storageBucket: "fractresponsedispatch.firebasestorage.app",
        messagingSenderId: "831450499406",
        appId: "1:831450499406:web:8a6eb122648d0bac67761f",
        databaseURL: "https://fractresponsedispatch-default-rtdb.europe-west1.firebasedatabase.app"
    };
    const app = window.firebaseInitializeApp(firebaseConfig);
    const db = window.firebaseGetDatabase(app);
    const responseRef = window.firebaseRef(db, 'responses/' + gCurrentUUID);
    firebaseOnValue(responseRef, (snapshot) => {
        const data = snapshot.val();
        if (data) {
            window.firebaseResponseReceived(data); //bridge to Cappuccino
        }
    });
    //goOnline(db); //goOffline(db);

    //https://console.firebase.google.com/project/fractresponsedispatch
    window.firebaseResponseReceived = function(data) { //console.info( "data:", data);
        if (!data.appName || !data.session || !data.value || !data.timestamp) return;
        if ((data.value === undefined) || (data.timestamp === undefined)) return;
        if (data.appName.length + data.session.length + data.value.length + data.timestamp.length > 200) return;
        const deltaT = Date.now() - data.timaestamp; //console.info("deltaT", deltaT);
        if (deltaT > 1000) { //console.warn("deltaT too high: ", deltaT);
            return;
        }
        if (data.session !== gCurrentUUID) {
            console.info("ResponseBoxController, Wrong sessionID: ", data.session, ", expected: ", gCurrentUUID);
            return;
        }
        //console.info("firebaseResponseReceived", data.appName, data.session, data.value, data.timestamp);
        //[gAppController setResultString: data.appName + ", " + data.session + ", "+  data.value];
        [[CPNotificationCenter defaultCenter] postNotificationName: "dispatchNotification" object: nil userInfo: data.value];
        //console.info(data.value);
    }
}


@end
