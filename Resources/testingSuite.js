/* History
   =======

2025-01-10 add settingsPanes etc., convert function declarations to arrow functions
2025-01-05 add rewardPicturesWhenDone
2025-01-01 created

*/

'use strict';
const NO = false, YES = !NO;
let needToDeactivateAutorun = NO;
let textarea = document.createElement('textarea');
const listener4textarea = (e) => {addText(JSON.stringify(e.data));};

const demoRunAndRestore = () => { /* restore doesn't work */
	needToDeactivateAutorun = NO;
	tellIframe({m1: 'setSetting', m2: 'Preset', m3: 'Demo'});
	/*tellIframe({m1: 'setSetting', m2: 'nTrials08', m3: '3'});*/
	tellIframe({m1: 'run', m2: 'acuity', m3: 'Letters'});
	needToDeactivateAutorun = YES;
}
const tellIframe = (message) => {
	document.getElementById('fractFrame').contentWindow.postMessage(message);
}
const tellIframe3Ms = (m1, m2, m3) => {
	const msg = {m1: m1, m2: m2, m3: m3};  tellIframe(msg);
}

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

const oneStep3Ms = async (m1, m2, m3) => {
	await pauseMilliseconds(300);
	const response = await tellIframeReturningPromise3Ms(m1, m2, m3);
	if (!response.success) errorAlert();
	return response;
}

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
	let response;  const pauseMS = 300, PauseViewMS = 2000;

	addText("TESTING SUITE STARTING\nDuration: ≈ 1 minute.\nDo not press any key until “TESTING SUITE DONE”.\n");

	response = await oneStep3Ms('getVersion', '', '');

	response = await oneStep3Ms('setSetting', 'Preset', 'Standard Defaults');
	response = await oneStep3Ms('getSetting', 'distanceInCM', '');
	if (response.m3 != 399) errorAlert();

	response = await oneStep3Ms('setSetting', 'Preset', 'Testing');
	response = await oneStep3Ms('getSetting', 'distanceInCM', '');
	if (response.m3 != 400) errorAlert(); /* did we really switch to Testing? */
	response = await oneStep3Ms('setSetting', 'nTrials08', 1);
	response = await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	tellIframe3Ms('run','acuity', 'Letters');
	addText(" ↑ Presets 'Standard Defaults' & 'Testing' successfully applied.\n");
	await pauseMilliseconds(PauseViewMS);

	addText(" ↓ Test fullscreen");
	await oneStep3Ms('setFullScreen', YES, '');/* do this later, doesn't work any more ??? */
	await pauseMilliseconds(PauseViewMS * 1.5);  /* security issue? */
	await oneStep3Ms('setFullScreen', NO, '');
	addText("↑ tested fullscreen\n");
	await pauseMilliseconds(PauseViewMS);

	addText(" ↓ Test color stuff");
	response = await oneStep3Ms('getSetting', 'windowBackgroundColor', '');
	if (response.m3 != "FFFFE6") errorAlert();

	response = await oneStep3Ms('getSetting', 'acuityForeColor', '');
	if (response.m3 != "000000") errorAlert();
	response = await oneStep3Ms('setSetting', 'acuityForeColor', 'FF0000');
	response = await oneStep3Ms('getSetting', 'acuityForeColor', '');
	if (response.m3 != "FF0000") errorAlert();

	response = await oneStep3Ms('getSetting', 'acuityBackColor', '');
	if (response.m3 != "FFFFFF") errorAlert();
	response = await oneStep3Ms('setSetting', 'acuityBackColor', '0000FF');
	response = await oneStep3Ms('getSetting', 'acuityBackColor', '');
	if (response.m3 != "0000FF") errorAlert();

	response = await oneStep3Ms('getSetting', 'gratingForeColor', '');
	if (response.m3 != "AAAAAA") errorAlert();
	response = await oneStep3Ms('getSetting', 'gratingBackColor', '');
	if (response.m3 != "555555") errorAlert();

	response = await oneStep3Ms('setSetting', 'nTrials04', 1);
	response = await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	tellIframe3Ms('run','acuity', 'TumblingE');
	addText(" ↑ Colors ok.\n");
	await pauseMilliseconds(PauseViewMS);

	addText(" ↓ Test multiple optotypes");
	response = await oneStep3Ms('setSetting', 'Preset', 'Testing');
	response = await oneStep3Ms('setSetting', 'nTrials08', 1);
	response = await oneStep3Ms('setSetting', 'nTrials04', 1);
	response = await oneStep3Ms('setSetting', 'nTrials02', 1);
	response = await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	tellIframe3Ms('run','acuity', 'TAO');
	await pauseMilliseconds(PauseViewMS);

	tellIframe3Ms('run','acuity', 'Vernier');
	await pauseMilliseconds(PauseViewMS);

	tellIframe3Ms('run','contrast', 'LandoltC');
	await pauseMilliseconds(PauseViewMS);

	tellIframe3Ms('run','contrast', 'Grating');
	addText(" ↑ Test multiple optotypes done.");
	await pauseMilliseconds(PauseViewMS);

	addText("\n ↓ All crowding possibilities.");
	response = await oneStep3Ms('setSetting', 'acuityStartingLogMAR', 0.3);
	for (let iCrowdingType = 1; iCrowdingType <= 6; iCrowdingType++) {
		await oneStep3Ms('setSetting', 'crowdingType', iCrowdingType);
		tellIframe3Ms('run','acuity', 'Letters');
		await pauseMilliseconds(PauseViewMS);
	}
	addText(" ↑ Crowding done.");

	addText("\n ↓ `rewardPicturesWhenDone`.");
	await oneStep3Ms('setSetting', 'crowdingType', 0);
	await oneStep3Ms('getSetting', 'rewardPicturesWhenDone', "");
	await oneStep3Ms('setSetting', 'rewardPicturesWhenDone', YES);
	tellIframe3Ms('run','acuity', 'Letters');
	await pauseMilliseconds(PauseViewMS * 2);

	await oneStep3Ms('setSetting', 'embedInNoise', YES);
	tellIframe3Ms('run','acuity', 'Letters');
	await pauseMilliseconds(PauseViewMS);

/*	await oneStep3Ms('setSetting', 'autoFullScreen', YES);
	await pauseMilliseconds(300);
	tellIframe3Ms('run','acuity', 'Letters');
	await pauseMilliseconds(PauseViewMS);*/

	addText("\n ↓ Leave with `Standard Defaults`.");
	response = await oneStep3Ms('setSetting', 'Preset', 'Standard Defaults');

	addText(" ↓ cycle through all panes of Settings");
	for (let iPane = 1; iPane <= 5; iPane++) {
		await oneStep3Ms('settingsPanes', iPane, '');
		await pauseMilliseconds(PauseViewMS);
	}
	await oneStep3Ms('settingsPanes', 0, '');
	response = await oneStep3Ms('settingsPanes', -1, '');
	addText(" ↑ cycle through all panes of Settings one.\n");
	await pauseMilliseconds(PauseViewMS);

	addText(" ↓ cycle through 3 grating shapes");
	tellIframe3Ms('reload', '', '');
	await oneStep3Ms('setSetting', 'Preset', 'Testing');
	await oneStep3Ms('setSetting', 'timeoutResponseSeconds', 1);
	await oneStep3Ms('setSetting', 'nTrials04', 1);
	for (let iGratingType = 0; iGratingType <= 2; iGratingType++) {
		await oneStep3Ms('setSetting', 'gratingShapeIndex', iGratingType);
		tellIframe3Ms('run','acuity', 'Grating');
		await pauseMilliseconds(PauseViewMS);
	}
	addText(" ↑ cycle through 3 grating shapes done.\n");

	tellIframe3Ms('reload', '', '');

	addText(" TESTING SUITE DONE.");

	/*
	response = await oneStep3Ms('xxxx', 'xxxx', 'xxxxxx');
	*/

}
