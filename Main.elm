{-
   The big boy that holds everything together

-}


module Main exposing (main)

import Browser
import Browser.Dom exposing (Viewport)
import Html exposing (Html)
import Model exposing (..)
import Msg exposing (Msg(..))
import Subscriptions exposing (subscriptions)
import Task
import Update exposing (update)
import View exposing (view)



{- INIT
   initializing the model. I make the default page the home page and make Model.stringContent the `InputStringContent Nothing` type

-}


fileDataInit : Files
fileDataInit =
    { uploadedFiles = []
    , fileData =
        [ FileData "BirthRate.txt" False Nothing
        , FileData "DeathRate.txt" False Nothing
        , FileData "GDP.txt" False Nothing
        , FileData "Population.txt" False Nothing
        , FileData "UnemploymentRate.txt" False Nothing
        ]
    }


dataInit : List ConvertedData
dataInit =
    List.map
        (\countryInfo ->
            ConvertedData
                countryInfo
                (Error "No Data lol")
        )
        countryInfoList


initModel : Model
initModel =
    { directory = HomePage
    , viewport = Nothing
    , files = fileDataInit
    , accessGranted = False
    , data = dataInit
    , searchData = NoInput
    , searchString = ""
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( initModel, Task.perform GetViewport Browser.Dom.getViewport )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
