module Browser.Runtime
  ( onStartup
  , onSuspend
  , MessageEvent
  , MessageDict
  , MessageArgument(..)
  , MessageSender
  , onMessage
  , addMessageListener
  , sendMessage
  , sendMessageToFrame
  , getUrl
  ) where

import Prelude

import Browser.Event (SimpleEvent, class Event)
import Browser.Tabs (Tab, unsafeSendMessage, unsafeSendMessageToFrame, TabId)
import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn2, EffectFn1, runEffectFn2, mkEffectFn1)
import Foreign (Foreign, readNull, readString, readInt)
import Foreign.Index ((!))

-- | Event that fires when the extension installed first starts up.
-- | [runtime.onStartup](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/onStartup)
foreign import onStartup :: SimpleEvent
-- | Event that fires just before the extension is unloaded.
-- | [runtime.onSuspend](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/onSuspend)
foreign import onSuspend :: SimpleEvent

-- | The message event type, parametrized by message body type and by response
-- | type. For example, if you want to send and receive an object with a single
-- | string, you need to create your own event object:
-- | ``` purescript
-- | type MyMessageEvent = MessageEvent {str :: String} Unit
-- | myMessageEvent :: MyMessageEvent
-- | myMessageEvent = onMessage
-- | ```
foreign import data MessageEvent :: Type -> Type -> Type

instance messageEvent :: Event (MessageEvent m r) Unit (MessageArgument m r) Boolean where
  addListener ev _ callback =
    let
      validateArgs = MessageArgument <<< readMessageDict
      wrappedCallback = mkEffectFn1 (callback <<< validateArgs)
    in
      runEffectFn2 addMessageListener_ ev wrappedCallback

-- | Arguments passed to your callback on message event
type MessageDict m r =
  { message :: m
  , sender :: MessageSender
  , sendResponse :: r -> Effect Unit
  }

-- | Real type is filled with nulls and undefineds
type MessageDict' m r =
  { message :: m
  , sender :: Foreign
  , sendResponse :: r -> Effect Unit
  }

readMessageDict :: forall m r. MessageDict' m r -> MessageDict m r
readMessageDict d = d { sender = readSender d.sender }
  where
  default =
    { tab: Nothing
    , frameId: Nothing
    , id: Nothing
    , url: Nothing
    , tlsChannelId: Nothing
    }

  readSender :: Foreign -> MessageSender
  readSender = either (const default) (identity) <<< runExcept <<< read
  read val = do
    -- TODO: real tab reading
    -- FIXME: the following line throws a runtime error: `m is undefined`
    -- with no location info.
    -- tab <- val ! "tab" >>= readNull >>= traverse unsafeFromForeign
    let tab = Nothing
    frameId <- val ! "frameId" >>= readNull >>= traverse readInt
    id <- val ! "id" >>= readNull >>= traverse readInt
    url <- val ! "url" >>= readNull >>= traverse readString
    tlsChannelId <- val ! "tlsChannelId" >>= readNull >>= traverse readString
    pure
      { tab: tab
      , frameId: frameId
      , id: id
      , url: url
      , tlsChannelId: tlsChannelId
      }

-- | Wrapped MessageDict to have an Event instance, as type synonym parameters
-- | are disallowed in instance declaration. If you want a callback that takes
-- | an unwrapped record, use `addMessageListener`
data MessageArgument m r = MessageArgument (MessageDict m r)

-- | [MessageSender](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/MessageSender)
type MessageSender =
  { tab :: Maybe Tab
  , frameId :: Maybe Int
  , id :: Maybe Int
  , url :: Maybe String
  , tlsChannelId :: Maybe String
  }

-- | Event that fires when you manually send a message between your scripts.
-- | [runtime.onMessage](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/onMessage)
foreign import onMessage :: forall m r. MessageEvent m r

-- | More convenient way to add listener to an onMessage event. You can use the
-- | first argument between event sender and receiver to make sure they send
-- | and receive the same types.
-- |
-- | Arguments:
-- |    - `MessageEvent m r` - Proxy to typed event
addMessageListener
  :: forall m r
   . MessageEvent m r
  -> (MessageDict m r -> Effect Boolean)
  -> Effect Unit
addMessageListener ev callback =
  let
    wrappedCallback = mkEffectFn1 (callback <<< readMessageDict)
  in
    runEffectFn2 addMessageListener_ ev wrappedCallback

foreign import addMessageListener_
  :: forall m r
   . EffectFn2 (MessageEvent m r) (EffectFn1 (MessageDict' m r) Boolean) Unit

-- | Safely send message with concrete types.
-- | [tabs.sendMessage](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/tabs/sendMessage)
sendMessage :: forall m r. MessageEvent { | m } { | r } -> TabId -> { | m } -> Aff { | r }
sendMessage _ = unsafeSendMessage

-- | Same but send to a specific frame
sendMessageToFrame
  :: forall m r
   . MessageEvent { | m } { | r }
  -> TabId
  -> { | m }
  -> Int
  -> Aff { | r }
sendMessageToFrame _ = unsafeSendMessageToFrame

-- | Get resolved url to extension resource.
-- | [runtime.getURL](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/getURL)
foreign import getUrl :: String -> String
