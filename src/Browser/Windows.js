"use strict"

export const onRemoved = browser.windows.onRemoved;

export function getAllImpl() {
    return browser.windows.getAll
}

export function getAllImpl1(getInfo) {
    return browser.windows.getAll(getInfo)
}

export function createImpl(createData) {
    return browser.windows.create(createData)
}

export function removeImpl(windowId) {
    return browser.windows.remove(windowId)
}

