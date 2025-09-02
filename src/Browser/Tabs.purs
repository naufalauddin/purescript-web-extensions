module Browser.Tabs
  ( TabId(..)
  , Tab(..)
  , TabStatus
  , tabStatusLoading
  , tabStatusComplete
  , WindowType
  , windowTypeNormal
  , windowTypePopup
  , windowTypePanel
  , windowTypeDevtools
  , InsertDetails
  , allFrames
  , code
  , cssOrigin
  , file
  , frameId
  , matchAboutBlank
  , runAt
  , executeScript
  , executeScriptCurrent
  , insertCss
  , insertCssCurrent
  , removeCss
  , removeCssCurrent
  , TabDetails
  , active
  , audible
  , autoDiscardable
  , cookieStoreId
  , currentWindow
  , discarded
  , hidden
  , highlighted
  , index
  , lastFocusedWindow
  , loadReplace
  , muted
  , openerTabId
  , pinned
  , selected
  , successorTabId
  , title
  , url
  , windowId
  , windowType
  , update
  , updateCurrent
  , query
  , unsafeSendMessage
  , unsafeSendMessageToFrame
  , status
  ) where

import Prelude

import Promise (Promise)
import Data.Function.Uncurried (Fn1, Fn2, Fn3, runFn1, runFn2, runFn3)
import Data.Options (Option, Options, opt, options)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn1, EffectFn2, runEffectFn1, runEffectFn2)
import Foreign (Foreign)
import Promise.Aff as Promise

-- | Type safe representation of an integer id of a tab
newtype TabId = TabId Int

-- | Record with all info about tab. See
-- | [MDN](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/Tab)
-- | for more info. TODO: i'm unsure if the functions here
-- | return it with all values present, be careful for now.
-- | TODO: write Foreign reader for Tab
type Tab =
  { active :: Boolean
  , audible :: Boolean
  , autoDiscardable :: Boolean
  , cookieStoreId :: String
  , discarded :: Boolean
  , favIconUrl :: String
  , height :: Int
  , hidden :: Boolean
  , highlighted :: Boolean
  , id :: TabId
  , incognito :: Boolean
  , index :: Int
  , isArticle :: Boolean
  , isInReaderMode :: Boolean
  , lastAccessed :: Number
  , mutedInfo :: String
  , openerTabId :: TabId
  , pinned :: Boolean
  , selected :: Boolean
  , sessionId :: String
  , status :: TabStatus
  , title :: String
  , url :: String
  , width :: Int
  , windowId :: Int
  }

-- | Type safe representation of TabStatus strings. Really is a enum, but for
-- | interop encoded as strings.
-- | [tabs.TabStatus](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/TabStatus)
-- | ### Possible values:
newtype TabStatus = TabStatus String

tabStatusLoading ∷ TabStatus
tabStatusLoading = TabStatus "loading"

tabStatusComplete ∷ TabStatus
tabStatusComplete = TabStatus "complete"

-- | Type safe representation of WindowType strings. Really is a enum, but for
-- | interop encoded as strings.
-- | [tabs.WindowType](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/WindowType)
-- | ### Possible values:
newtype WindowType = WindowType String

windowTypeNormal ∷ WindowType
windowTypeNormal = WindowType "normal"

windowTypePopup ∷ WindowType
windowTypePopup = WindowType "popup"

windowTypePanel ∷ WindowType
windowTypePanel = WindowType "panel"

windowTypeDevtools ∷ WindowType
windowTypeDevtools = WindowType "devtools"

-- | Options for inserting scripts and CSS, also for removing CSS
-- | ### Options:
data InsertDetails

allFrames :: Option InsertDetails Boolean
allFrames = opt "allFrames"

code :: Option InsertDetails String
code = opt "code"

cssOrigin :: Option InsertDetails String
cssOrigin = opt "cssOrigin"

file :: Option InsertDetails String
file = opt "file"

frameId :: Option InsertDetails Int
frameId = opt "frameId"

matchAboutBlank :: Option InsertDetails Boolean
matchAboutBlank = opt "matchAboutBlank"

runAt :: Option InsertDetails String
runAt = opt "runAt"

foreign import executeScriptImpl :: EffectFn2 Int Foreign (Promise (Array Foreign))
foreign import executeScriptCurrentImpl :: EffectFn1 Foreign (Promise (Array Foreign))
foreign import insertCssImpl :: EffectFn2 Int Foreign (Promise Unit)
foreign import insertCssCurrentImpl :: EffectFn1 Foreign (Promise Unit)
foreign import removeCssImpl :: EffectFn2 Int Foreign (Promise Unit)
foreign import removeCssCurrentImpl :: EffectFn1 Foreign (Promise Unit)

-- | Execute script with given options in given tab.
-- | [tabs.executeScript](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/executeScript)
executeScript :: TabId -> Options InsertDetails -> Aff (Array Foreign)
executeScript (TabId id) = options >>> runEffectFn2 executeScriptImpl id >>> Promise.toAffE

-- | Same but in current tab
executeScriptCurrent :: Options InsertDetails -> Aff (Array Foreign)
executeScriptCurrent = options >>> runEffectFn1 executeScriptCurrentImpl >>> Promise.toAffE

-- | Insert CSS with given options in given tab.
-- | [tabs.insertCSS](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/insertCSS)
insertCss :: TabId -> Options InsertDetails -> Aff Unit
insertCss (TabId id) = options >>> runEffectFn2 insertCssImpl id >>> Promise.toAffE

-- | Same but in current tab
insertCssCurrent :: Options InsertDetails -> Aff Unit
insertCssCurrent = options >>> runEffectFn1 insertCssCurrentImpl >>> Promise.toAffE

-- | Remove CSS with given options from given tab.
-- | [tabs.removeCSS](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/removeCSS)
removeCss :: TabId -> Options InsertDetails -> Aff Unit
removeCss (TabId id) = options >>> runEffectFn2 insertCssImpl id >>> Promise.toAffE

-- | Same but in current tab
removeCssCurrent :: Options InsertDetails -> Aff Unit
removeCssCurrent = options >>> runEffectFn1 insertCssCurrentImpl >>> Promise.toAffE

-- | Options for updating tabs state or querying existing tabs. They mostly
-- | copy fields of `Tab`
-- | ### Options:
data TabDetails

active :: Option TabDetails Boolean
active = opt "active"

audible :: Option TabDetails Boolean
audible = opt "audible"

autoDiscardable :: Option TabDetails Boolean
autoDiscardable = opt "autoDiscardable"

cookieStoreId :: Option TabDetails String
cookieStoreId = opt "cookieStoreId"

currentWindow :: Option TabDetails Boolean
currentWindow = opt "currentWindow"

discarded :: Option TabDetails Boolean
discarded = opt "discarded"

hidden :: Option TabDetails Boolean
hidden = opt "hidden"

highlighted :: Option TabDetails Boolean
highlighted = opt "highlighted"

index :: Option TabDetails Int
index = opt "index"

lastFocusedWindow :: Option TabDetails Boolean
lastFocusedWindow = opt "lastFocusedWindow"

loadReplace :: Option TabDetails Boolean
loadReplace = opt "loadReplace"

muted :: Option TabDetails Boolean
muted = opt "muted"

openerTabId :: Option TabDetails TabId
openerTabId = opt "openerTabId"

pinned :: Option TabDetails Boolean
pinned = opt "pinned"

status :: Option TabDetails TabStatus
status = opt "status"

selected :: Option TabDetails Boolean
selected = opt "selected"

successorTabId :: Option TabDetails TabId
successorTabId = opt "successorTabId"

title :: Option TabDetails String
title = opt "title"

url :: Option TabDetails String
url = opt "url"

windowId :: Option TabDetails Int
windowId = opt "windowId"

windowType :: Option TabDetails WindowType
windowType = opt "windowType"

foreign import updateCurrentImpl :: Fn1 Foreign (Promise Tab)
foreign import updateImpl :: Fn2 Int Foreign (Promise Tab)
foreign import queryImpl :: Fn1 Foreign (Promise (Array Tab))

-- | Update tab's state: navigate to a new URL or modify properties.
-- | [tabs.update](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/update)
update :: TabId -> Options TabDetails -> Promise Tab
update (TabId id) = options >>> runFn2 updateImpl id

-- | Same but in current tab
updateCurrent :: Options TabDetails -> Promise Tab
updateCurrent = options >>> runFn1 updateCurrentImpl

-- | Query matching tabs
-- | [tabs.query](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/query)
query :: Options TabDetails -> Promise (Array Tab)
query = options >>> runFn1 queryImpl

foreign import _sendMessage :: forall m r. Fn2 Int { | m } (Promise { | r })
foreign import _sendMessageToFrame
  :: forall m r. Fn3 Int { | m } Int (Promise { | r })

-- | Send serializable message to a background script and receive a response.
-- | The function is unsafe because the caller decides on the types of message
-- | and response. For safe version, see `Browser.Runtime.sendMessage`
-- | [tabs.sendMessage](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/sendMessage)
unsafeSendMessage :: forall m r. TabId -> { | m } -> Promise { | r }
unsafeSendMessage (TabId id) = runFn2 _sendMessage id

-- | Same but send to a specific frame
unsafeSendMessageToFrame :: forall m r. TabId -> { | m } -> Int -> Promise { | r }
unsafeSendMessageToFrame (TabId id) = runFn3 _sendMessageToFrame id

instance showTabId :: Show TabId where
  show (TabId id) = "TabId " <> show id

instance showTabStatus :: Show TabStatus where
  show (TabStatus s) = "TabStatus." <> s

instance showWindowType :: Show WindowType where
  show (WindowType s) = "WindowType." <> s
