/* testingSuite for FrACT


History
=======

2025-09-11 testSuite more systematic using anonymous functions
2025-08-18 `runRespondingCorrectly` uses `doResponseChain`;
    rename `tellIframeReturningPromise3Ms` → `postToIframe`
2025-08-14 `testBalm` only once, add `ensureHomeState` to make more robust against previous state
2025-03-28 `doDemoRun` w/o Demo preset
2025-02-08 had added more tests, now add look at Settings in fullscreen
2025-02-02 fix regression: restore demo run
2025-01-30 move fullscreen to front, otherwise won't work (delay user interaction??)
2025-01-28 add grating shapes, cleanup
2025-01-10 add settingsPanes etc., convert function declarations to arrow functions
2025-01-05 add rewardPicturesWhenDone
2025-01-01 created

*/

'use strict';
const NO = false, YES = !NO;
const textarea = document.createElement('textarea');
const listener4textarea = (e) => {addText(JSON.stringify(e.data));};


const errorAlert = () => {
	alert("An error occured in `testingSuite`")
}


const tellIframe = (message) => {
	document.getElementById('fractFrame').contentWindow.postMessage(message);
}
const tellIframe3Ms = (m1, m2, m3) => {
	tellIframe({m1: m1, m2: m2, m3: m3});
}

const pauseMS = 300, pauseViewMS = 2000;

const tellIframeReturningPromise = (message, timeout = 1000) => {
  return new Promise((resolve, reject) => {
	const iframe = document.getElementById('fractFrame');
	const messageListener = (event) => {
	  if (event.source === iframe.contentWindow) {
		window.removeEventListener('message', messageListener);
		if (event.data.error) {
		  reject(new Error(event.data.error));
		} else {
		  resolve(event.data);
		}
	  }
	};
	window.addEventListener('message', messageListener);
	iframe.contentWindow.postMessage(message, '*');
	setTimeout(() => {
	  window.removeEventListener('message', messageListener);
	  reject(new Error('Timeout: No response from iframe within ' + timeout + "ms."));
	}, timeout);
  });
}


const postToIframe = (m1, m2, m3, timeout = 1000) => {
	const msg = {m1: m1, m2: m2, m3: m3};
	return tellIframeReturningPromise(msg, timeout);
}


const addText = (text) => {
	text = text.replaceAll('"', '').replaceAll(',', ',  ');
	text = text.replaceAll(':', ': ').replace('{', '');
	text = text.replace('}', '').replace('m1:', '');
	text = text.replace('m2:', '').replace('m3:', '');
	const box = document.getElementById('scrollBox');
	box.value += text + '\n';
	box.scrollTop = box.scrollHeight; /* Auto-scroll to bottom */
}


const pauseMilliseconds = (ms) => {
	return new Promise(resolve => setTimeout(resolve, ms));
}


const oneStep3Ms = async (m1, m2, m3, timeout = 1000) => {
	const response = await postToIframe(m1, m2, m3, timeout);
	if (!response.success) errorAlert();
	return response;
}


const ensureHomeState = async () => {
    await postToIframe('setHomeState', '', '');
	await pauseMilliseconds(20);
}


/* exported doDemoRun */
const doDemoRun = async () => {
    await ensureHomeState();
	await oneStep3Ms('setSetting', 'preset', 'Testing');
    await oneStep3Ms('setSetting', 'autoRunIndex', 2);
    await oneStep3Ms('setSetting', 'nTrials08', 18);
    await oneStep3Ms('run', 'Acuity', 'Letters', 20000); // long delay for entire run
    await oneStep3Ms('setSetting', 'preset', 'Standard Defaults');
}


/* exported demoRunAndRestore */
const demoRunAndRestore = async () => {
    await ensureHomeState();
	let response = await oneStep3Ms('getSetting', 'distanceInCM', '');
	const distanceInCM = response.m3;
	await oneStep3Ms('setSetting', 'distanceInCM', 400);

	response = await oneStep3Ms('getSetting', 'calBarLengthInMM', '');
	const calBarLengthInMM = response.m3; // store for later restore
	await oneStep3Ms('setSetting', 'calBarLengthInMM', 170);

	response = await oneStep3Ms('getSetting', 'nTrials08', '');
	const nTrials08 = response.m3;
	await oneStep3Ms('setSetting', 'nTrials08', 18);

	response = await oneStep3Ms('getSetting', 'showResponseInfoAtStart', '');
	const showResponseInfoAtStart = response.m3;
	await oneStep3Ms('setSetting', 'showResponseInfoAtStart', 0);

	response = await oneStep3Ms('getSetting', 'autoRunIndex', '');
	const autoRunIndex = response.m3;
	await oneStep3Ms('setSetting', 'autoRunIndex', 2);

	response = await oneStep3Ms('run', 'Acuity', 'Letters', 20000); // long delay for entire run
	//const runSuccess = response.success;

	// restore settings
	await oneStep3Ms('setSetting', 'distanceInCM', distanceInCM);
	await oneStep3Ms('setSetting', 'calBarLengthInMM', calBarLengthInMM);
	await oneStep3Ms('setSetting', 'nTrials08', nTrials08);
	await oneStep3Ms('setSetting', 'showResponseInfoAtStart', showResponseInfoAtStart);
	await oneStep3Ms('setSetting', 'autoRunIndex', autoRunIndex);
}


const doResponseChain = async (invertedKeys = NO, delay = pauseMS) => {
	let response, rChar;
	while (YES) {
		response = await postToIframe('getValue', 'isInRun', '');
		if (!response.m2) break;
		await pauseMilliseconds(delay);
		response = await postToIframe('getValue', 'currentAlternative', '');
		if (!response.success) return;
		if (invertedKeys) { //keys need to be inverted for BaLM
			switch (response.m3) {
				case 0: rChar = "4";  break; // ←
				default: rChar = "6"; // 0, angle 0°: →
			}
		} else {
		   switch (response.m3) {
			   case 7: rChar = "3";  break;
			   case 6: rChar = "2";  break; // ↓
			   case 5: rChar = "1";  break;
			   case 4: rChar = "4";  break; // ←
			   case 3: rChar = "7";  break;
			   case 2: rChar = "8";  break; // ↑
			   case 1: rChar = "9";  break;
			   default: rChar = "6"; // 0, angle 0°: →
		   }
		}
		await pauseMilliseconds(delay); // otherwise blindingly fast
		response = await postToIframe('respondWithChar', rChar, '');
		await pauseMilliseconds(40);// to allow possible unloading the test run at end
		if (!response.success) break;
	}
}


/* runRespondingCorrectly */
const runRespondingCorrectly = async () => {
	await postToIframe('setSetting', 'preset', 'Testing');
	tellIframe3Ms('run', 'acuity', 'LandoltC');
	doResponseChain(NO, 100);
}


const testColorStuff = async () => {
	let response = await oneStep3Ms('getSetting', 'windowBackgroundColor', '');
	if (response.m3 != "FFFFE6") errorAlert();

	response = await oneStep3Ms('getSetting', 'acuityForeColor', '');
	if (response.m3 != "000000") errorAlert();
	await oneStep3Ms('setSetting', 'acuityForeColor', 'FF0000');
	response = await oneStep3Ms('getSetting', 'acuityForeColor', '');
	if (response.m3 != "FF0000") errorAlert();

	response = await oneStep3Ms('getSetting', 'acuityBackColor', '');
	if (response.m3 != "FFFFFF") errorAlert();
	await oneStep3Ms('setSetting', 'acuityBackColor', '0000FF');
	response = await oneStep3Ms('getSetting', 'acuityBackColor', '');
	if (response.m3 != "0000FF") errorAlert();

	response = await oneStep3Ms('getSetting', 'gratingForeColor', '');
	if (response.m3 != "AAAAAA") errorAlert();
	response = await oneStep3Ms('getSetting', 'gratingBackColor', '');
	if (response.m3 != "555555") errorAlert();

	await oneStep3Ms('setSetting', 'nTrials04', 1);
	await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	tellIframe3Ms('run','acuity', 'TumblingE');
}


const testMultipleOptotypes = async () => {
	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	await oneStep3Ms('setSetting', 'nTrials08', 1);
	await oneStep3Ms('setSetting', 'nTrials04', 1);
	await oneStep3Ms('setSetting', 'nTrials02', 1);
	await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	tellIframe3Ms('run','acuity', 'TAO');
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','acuity', 'Vernier');
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','contrast', 'LandoltC');
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','contrast', 'Grating');
}


const testAcuityCrowdingPossibilities = async () => {
	await oneStep3Ms('setSetting', 'nTrials08', 1);
	await oneStep3Ms('setSetting', 'nTrials04', 1);
	await oneStep3Ms('setSetting', 'nTrials02', 1);
	await oneStep3Ms('setSetting', 'acuityStartingLogMAR', 0.3);
	const kCrowdingTypeMax = 6; /* 6 */
	for (let iCrowdingType = 1; iCrowdingType <= kCrowdingTypeMax; iCrowdingType++) {
		await oneStep3Ms('setSetting', 'crowdingType', iCrowdingType);
		tellIframe3Ms('run','acuity', 'Letters');
		await pauseMilliseconds(pauseViewMS);
	}
}


const testContrastCrowding = async () => {
	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	await oneStep3Ms('setSetting', 'distanceInCM', 150);//so enough fit on screen
	await oneStep3Ms('setSetting', 'nTrials08', 1);
	await oneStep3Ms('setSetting', 'nTrials04', 1);
	await oneStep3Ms('setSetting', 'nTrials02', 1);
    await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
    await oneStep3Ms('setSetting', 'contrastCrowdingType', 6);
    await oneStep3Ms('setSetting', 'enableTouchControls', NO);
	tellIframe3Ms('run','contrast', 'Letters');
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','contrast', 'LandoltC');
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','contrast', 'TumblingE');
	await pauseMilliseconds(pauseViewMS);
}


const testShowRewardPictures = async () => {
	await oneStep3Ms('setSetting', 'crowdingType', 0);
	await oneStep3Ms('getSetting', 'showRewardPicturesWhenDone', "");
    await oneStep3Ms('setSetting', 'showRewardPicturesWhenDone', YES);
    await oneStep3Ms('setSetting', 'timeoutRewardPicturesInSeconds', 3);
	tellIframe3Ms('run','acuity', 'Letters');
	await pauseMilliseconds(pauseViewMS);
	await oneStep3Ms('setSetting', 'showRewardPicturesWhenDone', NO);
}


const testLinesOfOptotypes = async () => { //console.info("testLinesOfOptotypes");
	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	tellIframe3Ms('run','acuity', 'Line');
    await postToIframe('redraw', '', ''); /* should not be necessary */
	await pauseMilliseconds(pauseViewMS);
	await postToIframe('respondWithChar', "2", '');
    await postToIframe('redraw', '', '');
	await pauseMilliseconds(pauseViewMS);
	await postToIframe('respondWithChar', "2", '');
    await postToIframe('redraw', '', '');
	await pauseMilliseconds(pauseViewMS);
	await postToIframe('respondWithChar', "5", '');
	await postToIframe('respondWithChar', "5", ''); /* 2x5: exit test */
    await postToIframe('redraw', '', '');
	await pauseMilliseconds(pauseViewMS);
    await oneStep3Ms('setSetting', 'lineByLineLinesIndex', '2');
    tellIframe3Ms('run','acuity', 'Line');
    await postToIframe('redraw', '', '');
    await pauseMilliseconds(pauseViewMS);
    await postToIframe('respondWithChar', "5", '');
    await postToIframe('redraw', '', '');
    await postToIframe('respondWithChar', "5", ''); /* exit the test */
    await postToIframe('redraw', '', '');
}


const testAllSettings = async () => {
	const kPaneMax = 6; /* 6 */
	for (let iPane = 0; iPane <= kPaneMax; iPane++) {
		await oneStep3Ms('settingsPane', iPane, '');
		await pauseMilliseconds(pauseViewMS);
	}
	await oneStep3Ms('settingsPane', -1, '');
}


const testAllGratingShapes = async () => { //console.info("testAllGratingShapes");
	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	await oneStep3Ms('setSetting', 'nTrials02', 1);
	await oneStep3Ms('setSetting', 'nTrials04', 1);
    await oneStep3Ms('setSetting', 'enableTouchControls', NO);
	const kGratingShapeMax = 3; /* 3 */
	for (let iGratingType = 0; iGratingType <= kGratingShapeMax; iGratingType++) {
		await oneStep3Ms('setSetting', 'gratingShapeIndex', iGratingType);
		tellIframe3Ms('run','contrast', 'Grating');
		await pauseMilliseconds(pauseViewMS);
	}
}


const testSafariBugWithClippedGrating = async () => { //console.info("testBalm");
    await oneStep3Ms('setSetting', 'Preset', 'Testing');
    await oneStep3Ms('setSetting', 'isGratingMasked', YES);
    await oneStep3Ms('setSetting', 'nTrials04', 1);
    await oneStep3Ms('setSetting', 'gratingShapeIndex', 1); // sine
    await oneStep3Ms('setSetting', 'gratingMaskDiaInDeg', 1.5);
    await oneStep3Ms('setSetting', 'enableTouchControls', NO);
    tellIframe3Ms('run','contrast', 'Grating');
    await pauseMilliseconds(pauseViewMS);
    await pauseMilliseconds(pauseViewMS);
}


const testBalm = async () => { //console.info("testBalm");
	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	await oneStep3Ms('setSetting', 'nTrials02', 4);
	await oneStep3Ms('setSetting', 'nTrials04', 4);
    await oneStep3Ms('setSetting', 'distanceInCM', 20);
	await pauseMilliseconds(pauseMS);
   	tellIframe3Ms('run','acuity', 'BalmLight');
	await doResponseChain(YES);
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','acuity', 'BalmLocation');
	await doResponseChain();
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','acuity', 'BalmMotion');
	await doResponseChain();
}


const testAllPresets = async () => { //console.info("testAllPresets");
    await ensureHomeState();
    const allPresets = ["Standard Defaults", "AT@LeviLab", "BaLM₁₀", "BCM@Scheie", "CNS@Freiburg", "Color Equiluminance", "EndoArt01", "ESU", "ETCF", "Hyper@TUDo", "HYPERION", "Maculight", "ULV@Gensight", "Testing"];
    await oneStep3Ms('settingsPane', 0, ''); /* go to Settings */
    await pauseMilliseconds(pauseViewMS);
    for (let aPreset of allPresets) {
        await oneStep3Ms('setSetting', 'Preset', aPreset);
	    await postToIframe('redraw', '', '');
        await pauseMilliseconds(0.5 * pauseViewMS);
    }
    await oneStep3Ms('settingsPane', -1, ''); /* go to main */
}


// run one sub-test with leading and trailing text info
const doTextTestfunText = async (text, testfun) => {
	addText(" ↓ " + text);
    await ensureHomeState();
	await testfun();
	await pauseMilliseconds(pauseViewMS);
	addText("↑ " + text + ": Done.\n");
}


/* testingSuite */
const testingSuite = async () => {
	const scrollBoxInstance=document.getElementById('scrollBox');
	if (scrollBoxInstance != null) { /* toggling the textarea */
		scrollBoxInstance.remove();
		window.removeEventListener('message', listener4textarea);
		return;
	}
	textarea.id = 'scrollBox';  textarea.readOnly = YES;
	textarea.style.width = '800px';  textarea.style.height = '200px';
	textarea.value = "";
	document.getElementById('belowFractFrame').appendChild(textarea);
	window.addEventListener('message', listener4textarea);
	let response;

	addText("TESTING SUITE STARTING\nDuration: ≈ 2½ minutes.\n\nDo not press any key until “TESTING SUITE done”.\n\nFor early termination: Reload.\n");
/*	Let's leave out for now, because it shows intermediate blank screens after a testing round
await doTextTestfunText("Test fullscreen", async () => {// do this later, doesn't work (safety?)
		await oneStep3Ms('setFullScreen', YES, ''); await pauseMilliseconds(pauseViewMS * 1.5);
		await oneStep3Ms('settingsPane', 0, ''); await pauseMilliseconds(pauseViewMS);
		await oneStep3Ms('setFullScreen', NO, ''); await pauseMilliseconds(pauseViewMS);
		await oneStep3Ms('settingsPane', -1, ''); await pauseMilliseconds(pauseViewMS);
	}); */

    await doTextTestfunText("Internal unit tests", async () => {
        await oneStep3Ms('unittest', 'allAutomatic', '');
    });
	await doTextTestfunText("Test `getVersion` etc.", async () => {
		await oneStep3Ms('setSetting', 'Preset', 'Standard Defaults');
		let response = await oneStep3Ms('getSetting', 'distanceInCM', '');
		if (response.m3 != 399) errorAlert();
	});
	await doTextTestfunText("Test `setSetting` etc.", async () => {
		await oneStep3Ms('setSetting', 'Preset', 'Testing');
		response = await oneStep3Ms('getSetting', 'distanceInCM', '');
		if (response.m3 != 400) errorAlert();
		await oneStep3Ms('setSetting', 'nTrials08', 1);
		await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
		tellIframe3Ms('run','acuity', 'Letters');
	});
	await doTextTestfunText("Test color stuff", testColorStuff);
	await doTextTestfunText("Test multiple optotypes", testMultipleOptotypes);
	await doTextTestfunText("'showIdAndEyeOnMain'", async () => {
		await oneStep3Ms('setSetting', 'showIdAndEyeOnMain', YES); await pauseMilliseconds(2 * pauseViewMS);
		await oneStep3Ms('setSetting', 'showIdAndEyeOnMain', NO);
	});
	await doTextTestfunText("Cycle through acuity crowding possibilities", testAcuityCrowdingPossibilities);
    await doTextTestfunText("Test Contrast Crowding", testContrastCrowding);
	await doTextTestfunText("`showRewardPicturesWhenDone`", testShowRewardPictures);
	await doTextTestfunText("Noise embedding", async () => {
		await oneStep3Ms('setSetting', 'embedInNoise', YES);  tellIframe3Ms('run','acuity', 'Letters');
	});
	await doTextTestfunText("Test 'line(s) of optotypes'", testLinesOfOptotypes);
	await doTextTestfunText("Cycle through all panes of Settings", testAllSettings);
	await doTextTestfunText("Cycle through grating shapes", testAllGratingShapes);
    await doTextTestfunText("test Safari bug with clipped grating", testSafariBugWithClippedGrating);
	await doTextTestfunText("Cycle through BaLM tests", testBalm);
	await doTextTestfunText("Traverse all Presets", testAllPresets);

	addText("↓ Set `Standard Defaults` & Reload.");
	await oneStep3Ms('setSetting', 'Preset', 'Standard Defaults');
	tellIframe3Ms('reload', '', '');
	addText(" TESTING SUITE done.");
}
