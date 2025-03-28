/* History
   =======

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
const tellIframeReturningPromise3Ms = (m1, m2, m3, timeout = 1000) => {
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
	const response = await tellIframeReturningPromise3Ms(m1, m2, m3, timeout);
	if (!response.success) errorAlert();
	return response;
}


const doDemoRun = () => {
	tellIframe({m1: 'setSetting', m2: 'Preset', m3: 'Testing'});
    tellIframe({m1: 'setSetting', m2: 'autoRunIndex', m3: '2'});
	tellIframe({m1: 'setSetting', m2: 'nTrials08', m3: '12'});
	tellIframe({m1: 'run', m2: 'acuity', m3: 'Letters'});
}


async function demoRunAndRestore() {
   let response = await oneStep3Ms('getSetting', 'distanceInCM', '');
   const distanceInCM = response.m3;
   await oneStep3Ms('setSetting', 'distanceInCM', 400);

   response = await oneStep3Ms('getSetting', 'calBarLengthInMM', '');
   const calBarLengthInMM = response.m3; // store for later restore
   await oneStep3Ms('setSetting', 'calBarLengthInMM', 170);

   response = await oneStep3Ms('getSetting', 'nTrials08', '');
   const nTrials08 = response.m3;
   await oneStep3Ms('setSetting', 'nTrials08', 12);

   response = await oneStep3Ms('getSetting', 'responseInfoAtStart', '');
   const responseInfoAtStart = response.m3;
   await oneStep3Ms('setSetting', 'responseInfoAtStart', 0);

   response = await oneStep3Ms('getSetting', 'autoRunIndex', '');
   const autoRunIndex = response.m3;
   await oneStep3Ms('setSetting', 'autoRunIndex', 2);

   response = await oneStep3Ms('run', 'Acuity', 'Letters', 20000); // long delay for entire run
   const runSuccess = response.success;

   // restore settings
   await oneStep3Ms('setSetting', 'distanceInCM', distanceInCM);
   await oneStep3Ms('setSetting', 'calBarLengthInMM', calBarLengthInMM);
   await oneStep3Ms('setSetting', 'nTrials08', nTrials08);
   await oneStep3Ms('setSetting', 'responseInfoAtStart', responseInfoAtStart);
   await oneStep3Ms('setSetting', 'autoRunIndex', autoRunIndex);

   //console.info("sucessfully: ", runSuccess, " ran and restored.");
}


async function runRespondingCorrectly() {
	let response, rChar;
	await tellIframeReturningPromise3Ms('setSetting', 'preset', 'Testing');
	tellIframe3Ms('run', 'acuity', 'LandoltC');
	while (YES) {
		response = await tellIframeReturningPromise3Ms('getValue', 'isInRun', '');
		if (!response.m2) return;// run done
		//response = await tellIframeReturningPromise3Ms('getValue', 'currentTrial', '');
		response = await tellIframeReturningPromise3Ms('getValue', 'currentAlternative', '');
		if (!response.success) return;
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
		await pauseMilliseconds(100); // otherwise blindingly fast
		response = await tellIframeReturningPromise3Ms('respondWithChar', rChar, '');
		if (!response.success) return;
	}
}


async function responseChain(invertedKeys) {
	let response, rChar;
	while (YES) {
		response = await tellIframeReturningPromise3Ms('getValue', 'isInRun', '');
		if (!response.m2) break;
		await pauseMilliseconds(2 * pauseMS);
		response = await tellIframeReturningPromise3Ms('getValue', 'currentAlternative', '');
		if (!response.success) return;
		if (invertedKeys) {
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
		await pauseMilliseconds(pauseMS); // otherwise blindingly fast
		response = await tellIframeReturningPromise3Ms('respondWithChar', rChar, '');
		await pauseMilliseconds(40);// to allow possible unloading the test run at end
		if (!response.success) break;
	}
}


const testingSuite = async () => {
	const kCrowdingTypeMax = 6; /* 6 */
	const kPaneMax = 5; /* 5 */
	const kGratingShapeMax = 3; /* 3 */
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

	addText("TESTING SUITE STARTING\nDuration: ≈ 1 minute.\nDo not press any key until “TESTING SUITE done”.\n");
    await pauseMilliseconds(pauseViewMS);

	addText(" ↓ Test fullscreen");
	await oneStep3Ms('setFullScreen', YES, '');/* do this later, doesn't work any more ??? */
	await pauseMilliseconds(pauseViewMS * 1.5);  /* security issue? */
	await oneStep3Ms('settingsPane', 0, '');
	await pauseMilliseconds(pauseViewMS);
	await oneStep3Ms('settingsPane', -1, '');
	await pauseMilliseconds(pauseViewMS);
	await oneStep3Ms('setFullScreen', NO, '');
	addText("↑ tested fullscreen\n");
	await pauseMilliseconds(pauseViewMS);

	response = await oneStep3Ms('getVersion', '', '');

	await oneStep3Ms('setSetting', 'Preset', 'Standard Defaults');
	response = await oneStep3Ms('getSetting', 'distanceInCM', '');
	if (response.m3 != 399) errorAlert();

	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	response = await oneStep3Ms('getSetting', 'distanceInCM', '');
	if (response.m3 != 400) errorAlert();
	await oneStep3Ms('setSetting', 'nTrials08', 1);
	await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	tellIframe3Ms('run','acuity', 'Letters');
	addText(" ↑ Presets 'Standard Defaults' & 'Testing' successfully applied.\n");
	await pauseMilliseconds(pauseViewMS);

	addText(" ↓ Test color stuff");
	response = await oneStep3Ms('getSetting', 'windowBackgroundColor', '');
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
	addText(" ↑ Colors ok.\n");
	await pauseMilliseconds(pauseViewMS);

	addText(" ↓ Test multiple optotypes");
	response = await oneStep3Ms('setSetting', 'Preset', 'Testing');
	response = await oneStep3Ms('setSetting', 'nTrials08', 1);
	response = await oneStep3Ms('setSetting', 'nTrials04', 1);
	response = await oneStep3Ms('setSetting', 'nTrials02', 1);
	response = await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	tellIframe3Ms('run','acuity', 'TAO');
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','acuity', 'Vernier');
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','contrast', 'LandoltC');
	await pauseMilliseconds(pauseViewMS);
	tellIframe3Ms('run','contrast', 'Grating');
	await pauseMilliseconds(pauseViewMS);
	addText(" ↑ Test multiple optotypes done.");

	addText("\n ↓ Cycle through crowding possibilities.");
	response = await oneStep3Ms('setSetting', 'acuityStartingLogMAR', 0.3);
	for (let iCrowdingType = 1; iCrowdingType <= kCrowdingTypeMax; iCrowdingType++) {
		await oneStep3Ms('setSetting', 'crowdingType', iCrowdingType);
		tellIframe3Ms('run','acuity', 'Letters');
		await pauseMilliseconds(pauseViewMS);
	}
	addText(" ↑ Cycle through crowding done.\n");

	addText(" ↓ `rewardPicturesWhenDone`.");
	await oneStep3Ms('setSetting', 'crowdingType', 0);
	await oneStep3Ms('getSetting', 'rewardPicturesWhenDone', "");
    await oneStep3Ms('setSetting', 'rewardPicturesWhenDone', YES);
    await oneStep3Ms('setSetting', 'timeoutRewardPicturesInSeconds', 3);
	tellIframe3Ms('run','acuity', 'Letters');
	await pauseMilliseconds(pauseViewMS * 2);
    addText(" ↑ `rewardPicturesWhenDone`: Done.\n");
	await oneStep3Ms('setSetting', 'rewardPicturesWhenDone', NO);

    addText(" ↓ Noise embedding");
	await oneStep3Ms('setSetting', 'embedInNoise', YES);
	tellIframe3Ms('run','acuity', 'Letters');
    addText(" ↑ Noise embedding: Done.\n");
	await pauseMilliseconds(pauseViewMS);

	addText("\n ↓ cycle through all panes of Settings");
	for (let iPane = 0; iPane <= kPaneMax; iPane++) {
		await oneStep3Ms('settingsPane', iPane, '');
		await pauseMilliseconds(pauseViewMS);
	}
	response = await oneStep3Ms('settingsPane', -1, '');
	addText(" ↑ cycle through all panes of Settings done.\n");
	await pauseMilliseconds(pauseViewMS);

	addText(" ↓ cycle through grating shapes");
	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	await oneStep3Ms('setSetting', 'nTrials02', 1);
	await oneStep3Ms('setSetting', 'nTrials04', 1);
	for (let iGratingType = 0; iGratingType <= kGratingShapeMax; iGratingType++) {
		await oneStep3Ms('setSetting', 'gratingShapeIndex', iGratingType);
		tellIframe3Ms('run','contrast', 'Grating');
		await pauseMilliseconds(pauseViewMS);
	}
	addText(" ↑ cycle through grating shapes done.\n");
	await pauseMilliseconds(pauseViewMS);

	addText(" ↓ cycle through BaLM tests.\n");
	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	await oneStep3Ms('setSetting', 'nTrials02', 4);
	await oneStep3Ms('setSetting', 'nTrials04', 4);
    await oneStep3Ms('setSetting', 'distanceInCM', 20);
	await pauseMilliseconds(pauseMS);
   	tellIframe3Ms('run','acuity', 'BalmLight');
	await responseChain(YES);
	tellIframe3Ms('run','acuity', 'BalmLocation');
	await responseChain(NO);
	tellIframe3Ms('run','acuity', 'BalmMotion');
	await responseChain(NO);
	addText(" ↑ cycle through BaLM tests done.\n");

	addText("↓ Leave with `Standard Defaults`.");
	response = await oneStep3Ms('setSetting', 'Preset', 'Standard Defaults');

	addText("\n Reload.");
	tellIframe3Ms('reload', '', '');

	addText(" TESTING SUITE done.");

	/*
	response = await oneStep3Ms('xxxx', 'xxxx', 'xxxxxx');
	*/

}


async function testBalm() { console.info("testBalm");
	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	await oneStep3Ms('setSetting', 'nTrials02', 4);
	await oneStep3Ms('setSetting', 'nTrials04', 4);
    await oneStep3Ms('setSetting', 'distanceInCM', 20);
	await oneStep3Ms('settingsPane', 0, '');
	await pauseMilliseconds(pauseMS);
	await oneStep3Ms('settingsPane', -1, '');
	await pauseMilliseconds(pauseMS);
	tellIframe3Ms('run','acuity', 'BalmLight');
	await responseChain(YES);
	tellIframe3Ms('run','acuity', 'BalmLocation');
	await responseChain(NO);
	tellIframe3Ms('run','acuity', 'BalmMotion');
	await responseChain(NO);
}
