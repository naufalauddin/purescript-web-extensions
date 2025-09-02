"use strict"

export const updateCurrentImpl = browser.tabs.update;

export const updateImpl = browser.tabs.update;
export const queryImpl = browser.tabs.query;

export const executeScriptCurrentImpl = browser.tabs.executeScript;
export const executeScriptImpl = browser.tabs.executeScript;
export const insertCssCurrentImpl = browser.tabs.insertCSS;
export const insertCssImpl = browser.tabs.insertCSS;
export const removeCssCurrentImpl = browser.tabs.removeCSS;
export const removeCssImpl = browser.tabs.removeCSS;

export const _sendMessage = browser.tabs.sendMessage;
export function _sendMessageToFrame(tabId, message, frameId) {
    return browser.tabs.sendMessage(tabId, message, { "frameId": frameId });
}
