module Browser.Windows where

import Prelude

import Browser.Event (SimpleEvent)
import Browser.Tabs (Tab)
import Data.Options (Option, Options, opt, options)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Foreign (Foreign)
import Promise (Promise)
import Promise.Aff as Promise

data GetInfo

populate :: Option GetInfo Boolean
populate = opt "populate"

windowTypes :: Option GetInfo (Array String)
windowTypes = opt "windowTypes"

data CreateData

allowScriptsToClose :: Option CreateData Boolean
allowScriptsToClose = opt "allowScriptsToClose"

focused :: Option CreateData Boolean
focused = opt "focused"

height :: Option CreateData Int
height = opt "height"

incognito :: Option CreateData Boolean
incognito = opt "incognito"

left :: Option CreateData Int
left = opt "left"

state :: Option CreateData String
state = opt "state"

tabId :: Option CreateData Int
tabId = opt "tabId"

titlePreface :: Option CreateData String
titlePreface = opt "titlePreface"

top :: Option CreateData Int
top = opt "top"

type' :: Option CreateData String
type' = opt "type"

-- String OR Array String , canonically.
url :: Option CreateData (Array String)
url = opt "url"

width :: Option CreateData Int
width = opt "width"

-- should this be data instead of type? wtf
type Window =
  { alwaysOnTop :: Boolean
  , focused :: Boolean
  , height :: Int
  , id :: Int
  , incognito :: Boolean
  , left :: Int
  , sessionId :: String
  , state :: String
  , tabs :: Array Tab
  , title :: String
  , top :: Int
  , type :: String
  , width :: Int
  }

foreign import onRemoved :: SimpleEvent
foreign import getAllImpl :: Effect (Promise (Array Window))
foreign import getAllImpl1 :: EffectFn1 Foreign (Promise (Array Window))
foreign import createImpl :: EffectFn1 Foreign (Promise Window)
foreign import removeImpl :: EffectFn1 Int (Promise Unit)

-- | Get info on all windows.
getAll :: Aff (Array Window)
getAll = Promise.toAffE getAllImpl

getAll1 :: Options GetInfo -> Aff (Array Window)
getAll1 opts = getAll1' (options opts)
  where
  getAll1' :: Foreign -> Aff (Array Window)
  getAll1' = runEffectFn1 getAllImpl1 >>> Promise.toAffE

-- | Create a window.
create :: Options CreateData -> Aff Window
create opts = create' (options opts)
  where
  create' :: Foreign -> Aff Window
  create' = runEffectFn1 createImpl >>> Promise.toAffE

remove :: Int -> Aff Unit
remove = runEffectFn1 removeImpl >>> Promise.toAffE
