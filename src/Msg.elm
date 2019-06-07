{-
   Controls the messages and sstuff

   GetViewport : the message for the beginning where we initially find the viewport
   WindowResized is called whenever the window size is changed.

   GrantAccess is called when the user has uplaoded the files and can proceed to the next stage of the app
   DenyAccess is called when the user wants to change the files

   LoadedFiles has a rather weird structure: the first argument is the first file the user uploads and the list is the rest of the files.

-}


module Msg exposing (Msg(..))

import Browser.Dom exposing (Viewport)
import File exposing (File)
import Model exposing (..)


type Msg
    = GetViewport Viewport
    | WindowResized Int Int
    | GrantAccess
    | DenyAccess
    | AnalyzeFiles
    | ChangeDirectory Directory -- goes from the home page to the data center page
      -- This section is about the requesting files
    | RequestFiles
    | SelectFiles File (List File)
    | LoadedFiles (List DetailedFile)
      -- this section is about the Data Centre
    | ChangeDataCenterDirectory CountryInfo -- changes the view in the data center page
    | SearchString String
    | SearchCountry
