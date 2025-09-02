-- | [browser.storage.local]()
module Browser.Storage.Local
  ( clear
  , getByKey
  , getByRecord
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

getByKey :: String -> Aff Json
getByKey = Promise.toAffE <<< runEffectFn1 _getByKeyImpl

getByRecord :: forall r. Homogeneous r Json => { | r } -> Aff { | r }
getByRecord = Promise.toAffE <<< runEffectFn1 _getByRecordImpl

foreign import _set :: forall r. EffectFn1 { | r } (Promise Unit)

set :: forall r. Homogeneous r Json => { | r } -> Aff Unit
set = Promise.toAffE <<< runEffectFn1 _set

foreign import _clear :: Effect (Promise Unit)

clear :: Aff Unit
clear = Promise.toAffE _clear
