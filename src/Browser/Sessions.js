"use strict"

export const onChanged = browser.sessions.onChanged;

export function restoreImpl(a) {
    return browser.sessions.restore(a)
}

export function getRecentlyClosedImpl(a) {
    return browser.sessions.getRecentlyClosed(a)
}

export function setWindowValueImpl(windowId, key, value) {
    return browser.sessions.setWindowValue(windowId, key, value)
}

export function getWindowValueImpl(windowId, key) {
    return browser.sessions.getWindowValue(windowId, key)
}

