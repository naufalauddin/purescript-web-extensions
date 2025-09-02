module Browser.Sessions where

import Browser.Event (SimpleEvent)
import Browser.Tabs (Tab)
import Browser.Windows (Window)
import Data.Options (Option, Options, opt, options)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, runEffectFn1, runEffectFn2, runEffectFn3)
import Foreign (Foreign)
import Prelude (Unit, (#), (>>>))
import Promise (Promise)
import Promise.Aff as Promise

data Filter

maxResults :: Option Filter Int
maxResults = opt "maxResults"

type Session =
  { lastModified :: Number
  , tab :: Tab -- Maybe Tab
  , window :: Window -- Maybe Window
  }

foreign import onChanged :: SimpleEvent

--type SessionId = String -- too much work 4 now.
foreign import restoreImpl :: EffectFn1 String (Promise Session)

restore :: String -> Aff Session
restore = runEffectFn1 restoreImpl >>> Promise.toAffE

foreign import getRecentlyClosedImpl :: EffectFn1 Foreign (Promise (Array Session))

getRecentlyClosed :: Options Filter -> Aff (Array Session)
getRecentlyClosed opts = getRecentlyClosed' (options opts)
  where
  getRecentlyClosed' :: Foreign -> Aff (Array Session)
  getRecentlyClosed' = runEffectFn1 getRecentlyClosedImpl >>> Promise.toAffE

foreign import setWindowValueImpl :: EffectFn3 Int String String (Promise Unit)
foreign import getWindowValueImpl :: EffectFn2 Int String (Promise String)

-- should be: int -> string -> either string object -> effect promise unit
setWindowValue :: Int -> String -> String -> Aff Unit
setWindowValue id key value = runEffectFn3 setWindowValueImpl id key value # Promise.toAffE

getWindowValue :: Int -> String -> Aff String
getWindowValue id key = runEffectFn2 getWindowValueImpl id key # Promise.toAffE
