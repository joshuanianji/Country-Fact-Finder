{-
   FILE PARSERRR LSJDFHSLDJFKHLSDKJFHSLDKFJHL
-}


module FileParser exposing (convertFiles, newFileData, toDetailedFile)

import File exposing (File)
import Maybe.Extra exposing (isJust)
import Model exposing (..)
import Msg exposing (Msg(..))
import Parser exposing (..)
import Result.Extra as Result
import Task exposing (Task)



-- use Task.map to turn a file to a talk which the Elm runtime runs to make a detailedFile


toDetailedFile : File -> Task x DetailedFile
toDetailedFile file =
    File.toString file
        |> Task.map
            (\contents ->
                DetailedFile (File.name file) contents
            )



-- checks to see if all the files are in a list. Creates a fileData and if all the correct files are uploaded, grants access (returns a model with granted access)


newFileData : Model -> List DetailedFile -> Model
newFileData model uploadedFiles =
    let
        fileNameList =
            [ "BirthRate.txt"
            , "DeathRate.txt"
            , "GDP.txt"
            , "Population.txt"
            , "UnemploymentRate.txt"
            ]

        -- the list of FileData (check Model.elm)
        hasFileList =
            List.map
                (\acceptableFileName ->
                    getFileData acceptableFileName uploadedFiles
                )
                fileNameList

        -- a single boolean that's true if all the file data booleans are true
        hasAllFiles =
            hasFileList
                |> List.all (\x -> x.isUploaded == True)

        fileData =
            Files
                uploadedFiles
                hasFileList
    in
    { model | files = fileData, accessGranted = hasAllFiles }



-- given a name of the acceptable file data (such as BirthRate.txt), and the detailed uploaded files, returns the list of filedata.


getFileData : String -> List DetailedFile -> FileData
getFileData name detailedFiles =
    let
        foundFile =
            findFileIn detailedFiles name
    in
    FileData
        name
        (isJust foundFile)
        -- if the file is Nothing our "isUploaded" will be Nothing (this is what isJust does)
        (Maybe.map .content foundFile)


findFileIn : List DetailedFile -> String -> Maybe DetailedFile
findFileIn list fileName =
    case list of
        file :: files ->
            if fileName == file.name then
                Just file

            else
                findFileIn files fileName

        [] ->
            Nothing


{--}
-- converts the strings into data types and puts that into the model


convertFiles : List FileData -> List ConvertedData
convertFiles fileDataList =
    List.map
        (\fileData ->
            fileData.content
                |> Maybe.map (String.split "\n")
                |> Maybe.map (List.map (Parser.run datumParser))
                |> Maybe.map Result.combine
                |> convertMaybeData fileData
        )
        fileDataList



-- parse the fileContent (fileContent.content : String) into data (List Datum).
-- I used Parser.oneOf so if there is a dollar sign the thing won't crash and it just reads the number after the dollar sign


datumParser : Parser Datum
datumParser =
    Parser.succeed Datum
        |= Parser.int
        |. Parser.spaces
        |= countryName
        |. Parser.spaces
        |= infoParser



-- helps parse the information (e.g. GDP, population, etc.). I'll deal with the "2018 est. stuff later."


infoParser : Parser String
infoParser =
    Parser.succeed ()
        |. Parser.chompUntilEndOr "  "
        |> getChompedString



-- converts maybe data, putting all errors in the Error type of the MaybeConvertedData


convertMaybeData : FileData -> Maybe (Result (List DeadEnd) (List Datum)) -> ConvertedData
convertMaybeData fileData maybeResultData =
    case maybeResultData of
        Just resultData ->
            case resultData of
                Ok data ->
                    convertData fileData (Success data)

                Err deadends ->
                    -- it's funny because I don't think "deadEndsToString" actually works at the moment ripperoni
                    deadends
                        |> deadEndsToString
                        |> Error
                        |> convertData fileData

        Nothing ->
            ConvertedData
                (stringToCountryInfo fileData.name)
                (Error "No File Data")



-- makes the convertedData type


convertData : FileData -> MaybeListDatum -> ConvertedData
convertData fileData data =
    ConvertedData
        (stringToCountryInfo fileData.name)
        data



-- returns the country name. Looks until there is more than one space


countryName : Parser String
countryName =
    Parser.getChompedString <|
        Parser.succeed ()
            |. Parser.chompUntil "  "


stringToCountryInfo : String -> CountryInfo
stringToCountryInfo string =
    case string of
        "BirthRate.txt" ->
            BirthRate

        "DeathRate.txt" ->
            DeathRate

        "GDP.txt" ->
            GDP

        "Population.txt" ->
            Population

        "UnemploymentRate.txt" ->
            UnemploymentRate

        "Search" ->
            Search

        _ ->
            Unknown
