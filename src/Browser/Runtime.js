"use strict"

export const onMessage = browser.runtime.onMessage;
export const onStartup = browser.runtime.onStartup;
export const onSuspend = browser.runtime.onSuspend;

export function addMessageListener_(ev, cb) {
	var wrappedCb = function (message, sender, sendResponse) {
		var args =
		{
			"message": message
			, "sender": sender
			, "sendResponse": sendResponse
		};
		return cb(args);
	}
	ev.addListener(wrappedCb);
}

export const getUrl = browser.runtime.getURL;
