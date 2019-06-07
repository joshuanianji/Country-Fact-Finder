module Update exposing (update)

import Browser.Dom
import CountrySearch
import File.Select as Select
import FileParser exposing (convertFiles, newFileData, toDetailedFile)
import List
import Model exposing (..)
import Msg exposing (Msg(..))
import Task exposing (perform)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- called at page load and just gets the viewport of the page lol
        GetViewport viewport ->
            ( { model | viewport = Just viewport }, Cmd.none )

        -- I know one of the vars is height and one of them is width but I don't use them so whatever
        WindowResized var1 var2 ->
            ( model, Task.perform GetViewport Browser.Dom.getViewport )

        GrantAccess ->
            ( { model | accessGranted = True }, Cmd.none )

        DenyAccess ->
            ( { model | accessGranted = False }, Cmd.none )

        -- changes directory to and fro the home and data centre
        ChangeDirectory directory ->
            case directory of
                DataCenter _ ->
                    -- also analyzes files if the user goes to the DataCenter
                    update AnalyzeFiles { model | directory = directory }

                HomePage ->
                    ( { model | directory = directory }, Cmd.none )

        --- converts data and stuff
        AnalyzeFiles ->
            -- converts the files with strings into data my program can read and interpret
            let
                convertedFiles =
                    convertFiles (Debug.log "converting " model.files.fileData)
            in
            ( { model | data = Debug.log "converted files" convertedFiles }, Cmd.none )

        -- USER SELECTS FILES. WHEN THEY DO, PASS THOSE FILES ON TO SELECTFILES
        RequestFiles ->
            ( model, Select.files [ "text/plain" ] SelectFiles )

        -- AFTER USER SELECTED THE FILES PERFORM TAKSS TO READ THE FILE AND TURN THEM INTO THE DETAILEDFILE TYPE
        SelectFiles file fileList ->
            -- as said in the Msg.elm file, the first argument is the first file, while the other argument is the rest of the files. This guarantees that we have at least one file chosen, as claimed by elm-package.org
            ( model
            , List.map
                toDetailedFile
                (file :: fileList)
                |> Task.sequence
                |> Task.perform LoadedFiles
            )

        -- ONCE THE FILES ARE ALL LOADED RUN THE NEWFILEDATA FUNCTION
        LoadedFiles detailedFiles ->
            ( newFileData model detailedFiles, Cmd.none )

        {-
           THIS SECTION IS ABOUT THE DATA CENTRE STUFF
        -}
        ChangeDataCenterDirectory homePageInfo ->
            ( { model | directory = DataCenter homePageInfo }, Cmd.none )

        -- every time the user inputs a character, we change the model's "searchString" property
        SearchString string ->
            ( { model | searchString = string }, Cmd.none )

        -- Called when the search button is pressed.
        -- searches through our model (using linear search lmao) to find the countries that contain the string in our input. Only searches if the user has at least one character in the search bar.
        SearchCountry ->
            if model.searchString == "" then
                ( { model | searchData = NoInput }, Cmd.none )

            else if not (isAllAlpha model.searchString) then
                -- if there are any apostrophes, commas, etc then we disregard. This is kinda bad but oh well lmao
                ( { model | searchData = NoCountry }, Cmd.none )

            else
                -- THE HARD PART I HAVEN'T DONE YET
                ( { model
                    | searchData =
                        model.data
                            |> CountrySearch.find model.searchString
                  }
                , Cmd.none
                )



-- checks to see if string contains all alpha numeric characters (numbers of letters)


isAllAlpha : String -> Bool
isAllAlpha string =
    string
        |> String.toList
        |> List.map Char.isAlpha
        |> List.all identity
