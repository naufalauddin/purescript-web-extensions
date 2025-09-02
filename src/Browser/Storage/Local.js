"use strict";

export function _getByKeyImpl(key) {
	return browser.storage.local.get(key)
}

export function _getByArrayImpl(key) {
	return browser.storage.local.get(key)
}

export function _getByRecordImpl(key) {
	return browser.storage.local.get(key)
}

export function _set(keys) {
	return browser.storage.local.set(keys)
}

export function _clear() {
	return browser.storage.local.clear()
}
