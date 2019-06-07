{-
   this describes the data that will be used in my app
-}


module Model exposing (ConvertedData, CountryData, CountryInfo(..), Datum, DetailedFile, Directory(..), FileData, Files, MaybeListDatum(..), Model, Search(..), countryInfoList)

import Browser.Dom exposing (Viewport)
import File exposing (File)



{-
   MY MODEL:
       Directory : which page we're on
       viewport : Size of current viewport
       files : another type alias with all my file data
       accessGranted : Whether the user has uploaded the correct files and can continue to the site
       data : list of all my converted data
       searchData : the list of data that gets returned when the user searches stuff up.
       searchString : Current string entered in the searchbar which the user uses to search up a country
-}


type alias Model =
    { directory : Directory
    , viewport : Maybe Viewport
    , files : Files
    , accessGranted : Bool
    , data : List ConvertedData
    , searchData : Search
    , searchString : String
    }



-- DIRECTORY TYPE AND HELPER DATA TYPES


type Directory
    = HomePage
    | DataCenter CountryInfo



-- one of the 5 things the countries can have information on. I know the "Search" option is nasty but its the way i implemented it lol. Big yikes.


type CountryInfo
    = BirthRate
    | DeathRate
    | GDP
    | Population
    | UnemploymentRate
    | Unknown
    | Search



-- used in the model initialization


countryInfoList =
    [ BirthRate
    , DeathRate
    , GDP
    , Population
    , UnemploymentRate
    ]



{-
   FILES DATA TYPE
       uploadedFiles : the list of all the uploaded files in a more detailed format (with the file content attached to it)
       fileData : a list  of the fileNames and whether it is contained in the uploaded files. Also contains file content is possible
-}


type alias Files =
    { uploadedFiles : List DetailedFile
    , fileData : List FileData
    }



-- I don't know what I'm doing. This is for the uploaded files.


type alias DetailedFile =
    { name : String
    , content : String
    }



-- one FileData for each of the "BirthRate.txt", "DeathRate.txt", "GDP.txt", "Population.txt", and "UnemploymentRate.txt"


type alias FileData =
    { name : String
    , isUploaded : Bool
    , content : Maybe String
    }



{-

   CONVERTEDDATA DATA TYPE
   Cuntry data organized by the type of data the country has (e.g. BirthRate, DeathRate, etc)

-}


type alias ConvertedData =
    { infoType : CountryInfo
    , data : MaybeListDatum
    }



-- the Maybe type with error handling.


type MaybeListDatum
    = Success (List Datum)
    | Error String



{-
   DATUM: every little data thing in the Country.

   ranking: Integer value of where the country is in the standing.
   country: the country name in a string
   info: the value held in a string. This keeps the commas basically. The parser disregards the dollar sign and whatnot so we dont need to worry about those.
-}


type alias Datum =
    { ranking : Int
    , country : String
    , info : String
    }



{-
   SEARCH DATA TYPE and helper data types

   NoInput : If the user does not provide a string for us to search through
   NoCountry : If the user's input is not part of any country name. Input is not case sensitive
   DataError : Either the user fails to upload a text file or one of the text files messes up
   List (List CountryData) : a list of each individual country and its information.
-}


type Search
    = NoInput
    | NoCountry
    | DataError String
    | List (List CountryData)



{-
   CountryData is a datum of a individual country and its info. Sorry about the bad naming lol
   I made all the values strings because they are held in the Datum type as strings. Idk its just easier lol.
   I also made them Maybe Strings because some of the text files dont have all the cuntries in them, so a country might be missing a data point.
-}

    
type alias CountryData =
    { country : String
    , birthRate : Maybe String
    , deathRate : Maybe String
    , gdp : Maybe String
    , population : Maybe String
    , unemployment : Maybe String
    }
