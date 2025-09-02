-- | [browser.storage.local](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/storage/local)
-- |
-- | This a low level binding with minimal safety. Because the storage can store arbitrary json, this binding uses
-- | [`Json`](https://pursuit.purescript.org/packages/purescript-argonaut-core/7.0.0/docs/Data.Argonaut.Core#t:Json) from
-- | [`argonaut-core`](https://pursuit.purescript.org/packages/purescript-argonaut-core/7.0.0).
-- | Encoding/decoding to/from [`Json`](https://pursuit.purescript.org/packages/purescript-argonaut-core/7.0.0/docs/Data.Argonaut.Core#t:Json)
-- | is left to the user of this binding. 
module Browser.Storage.Local
  ( clear
  , getByKey
  , getWithDefault
  , getKeys
  , remove
  , set
  ) where

import Prelude

import Data.Argonaut.Core (Json)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Promise (Promise)
import Promise.Aff as Promise
import Type.Row.Homogeneous (class Homogeneous)

foreign import _getByKeyImpl :: EffectFn1 String (Promise Json)
foreign import _getByArrayImpl :: EffectFn1 (Array String) (Promise Json)
foreign import _getByRecordImpl :: forall r. EffectFn1 { | r } (Promise { | r })

-- | Retrieve an item stored in the local storage by key. If there isn't an
-- | associated value to that key, it will return an empty object (object with no
-- | field) if exist, return an Objet with the key as the field and stored value
-- | as its value.
getByKey :: String -> Aff Json
getByKey = Promise.toAffE <<< runEffectFn1 _getByKeyImpl

-- | Similar to `getByKey` but use record instead. The record's fields are used as
-- | the key. If there isn't a value associated with the key, the original value
-- | from the arguments will be used. 
getWithDefault :: forall r. Homogeneous r Json => { | r } -> Aff { | r }
getWithDefault = Promise.toAffE <<< runEffectFn1 _getByRecordImpl

foreign import _set :: forall r. EffectFn1 { | r } (Promise Unit)

set :: forall r. Homogeneous r Json => { | r } -> Aff Unit
set = Promise.toAffE <<< runEffectFn1 _set

foreign import _clear :: Effect (Promise Unit)

clear :: Aff Unit
clear = Promise.toAffE _clear

foreign import _remove :: EffectFn1 (Array String) (Promise Unit)

remove :: Array String -> Aff Unit
remove = Promise.toAffE <<< runEffectFn1 _remove

foreign import _getKeys :: Effect (Promise (Array String))

getKeys :: Aff (Array String)
getKeys = Promise.toAffE _getKeys