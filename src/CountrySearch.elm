module CountrySearch exposing (find)

import Model exposing (..)


find : String -> List ConvertedData -> Search
find searchString dataList =
    let
        output =
            List []
    in
    output
        |> add BirthRate searchString dataList
        |> add DeathRate searchString dataList
        |> add GDP searchString dataList
        |> add Population searchString dataList
        |> add UnemploymentRate searchString dataList
        |> check



-- just checks if the length of the list is 0 lol


check : Search -> Search
check search =
    case search of
        List list ->
            if List.length list == 0 then
                NoCountry

            else
                List list

        anythingElse ->
            anythingElse



-- takes in the current output (Search type), searches through the `List ConvertedData` and adds their data. returns the output.


add : CountryInfo -> String -> List ConvertedData -> Search -> Search
add countryInfo searchString data search =
    case search of
        NoInput ->
            NoInput

        NoCountry ->
            NoCountry

        DataError string ->
            -- check if country info is in model.data. If it is, do nothing. Else, add a new error message.
            case filterCountryInfo countryInfo data of
                [ a ] ->
                    DataError string

                [] ->
                    DataError (string ++ " || " ++ countryInfoToString countryInfo ++ " was not found in the data")

                _ ->
                    DataError (string ++ " || " ++ countryInfoToString countryInfo ++ " was found multiple times in the data")

        List list ->
            -- checks the filtered data with respect to the countryInfo.
            case filterCountryInfo countryInfo data of
                [ convertedData ] ->
                    -- filtering is successful. We check the convertedData.data to see if it is valid.
                    case convertedData.data of
                        -- Lol i called it countryTidbitDataList because its like country tidbit data and its in a list get it. Also the keyword "data" was taken and I use it too much ree
                        Success countryTidbitDataList ->
                            -- convertedData is successful. We now filter countryTidbitDataList to find which ones have the user keyword in it.
                            case filterCountryName searchString countryTidbitDataList of
                                [] ->
                                    -- uh oh spaghatti o's we haven't found a country lol. I still choose to keep the List as is. If it was only because a text file doesn't have a country in it, we shouldn't have to crash the entire process.
                                    List list

                                tidbitData ->
                                    -- now that we have countries we can start to finally fill in the Search that has been passed to this function
                                    -- TODO
                                    let
                                        simplifiedData =
                                            tidbitData
                                                |> List.map simplify
                                    in
                                    list
                                        |> countryDataModifier simplifiedData countryInfo
                                        |> List

                        Error string ->
                            -- just output error lol
                            "detected error '"
                                ++ string
                                ++ "' in `"
                                ++ countryInfoToString countryInfo
                                ++ "`"
                                |> DataError

                [] ->
                    "`"
                        ++ countryInfoToString countryInfo
                        ++ "` was not found in the data"
                        |> DataError

                _ ->
                    "`"
                        ++ countryInfoToString countryInfo
                        ++ "` was found multiple times in the data"
                        |> DataError



-- filters a `List ConvertedData` by the CountryInfo. Returns the MaybeListDatum, which is basically the meat of the ConvertedData type.


filterCountryInfo : CountryInfo -> List ConvertedData -> List ConvertedData
filterCountryInfo countryInfo data =
    List.filter
        (\convertedData -> convertedData.infoType == countryInfo)
        data



-- filters country names given the List Datum (like 3 data types down the Model type) to see which ones have the country names.


filterCountryName : String -> List Datum -> List Datum
filterCountryName searchChars data =
    List.filter
        (\datum ->
            datum.country
                |> String.toLower
                |> String.contains (searchChars |> String.toLower)
        )
        data



-- Searched through filterOutputList to see if the country names are equal. Man all of these three functions are so similar ip.


filterOutputList : String -> List CountryData -> List CountryData
filterOutputList searchCountry data =
    List.filter
        (\datum -> datum.country == searchCountry)
        data



-- converts a Datum type to a tuple with the country name and the information. basically strips the "ranking". This is just to simplify and im scared of the coding mountain ahead of me rn.


simplify : Datum -> ( String, String )
simplify datum =
    ( datum.country, datum.info )



-- LOLLL USES TAIL END RECURSION TO MODIFY THE `LIST COUNTRYDATA` IM CRYING.
-- basically searched through the `CountryData` list is there is a country that matches a country in the tuple. changes the value and mvoes on. Oh god the time complexity on this shit algorithm must be like n^3 or something ew.


countryDataModifier : List ( String, String ) -> CountryInfo -> List CountryData -> List CountryData
countryDataModifier tupleList countryInfo data =
    case tupleList of
        ( country, info ) :: tail ->
            case filterOutputList country data of
                [ countryData ] ->
                    List.map
                        (\x ->
                            if x == countryData then
                                case countryInfo of
                                    BirthRate ->
                                        { countryData | birthRate = Just info }

                                    DeathRate ->
                                        { countryData | deathRate = Just info }

                                    GDP ->
                                        { countryData | gdp = Just info }

                                    Population ->
                                        { countryData | population = Just info }

                                    UnemploymentRate ->
                                        { countryData | unemployment = Just info }

                                    _ ->
                                        -- i have to put this here but this would never happen
                                        countryData

                            else
                                x
                        )
                        data
                        -- we change the data of the country and move onto the next (country, info) tuple
                        |> countryDataModifier tail countryInfo

                [] ->
                    -- we add a new CountryData type to our thing
                    countryDataModifier
                        tail
                        countryInfo
                        (List.append
                            (newCountryData countryInfo ( country, info ))
                            data
                        )

                _ ->
                    -- shouldn't happen! this means there are more than two countries with the same name in our CountryData list! I just do nothing though lmao
                    data

        [] ->
            data



-- generates a CountryData based on countryInfo and the tuple of (country, info)


newCountryData : CountryInfo -> ( String, String ) -> List CountryData
newCountryData countryInfo ( country, info ) =
    let
        outputCountryData =
            nothingCountry country
    in
    case countryInfo of
        BirthRate ->
            [ { outputCountryData | birthRate = Just info } ]

        DeathRate ->
            [ { outputCountryData | deathRate = Just info } ]

        GDP ->
            [ { outputCountryData | gdp = Just info } ]

        Population ->
            [ { outputCountryData | population = Just info } ]

        UnemploymentRate ->
            [ { outputCountryData | unemployment = Just info } ]

        _ ->
            -- any other case we don't do anything
            []



-- CountryData type with all Nothings for default stuff


nothingCountry : String -> CountryData
nothingCountry name =
    CountryData
        name
        Nothing
        Nothing
        Nothing
        Nothing
        Nothing



-- name says it all. I just dont want to use Debug.log because ew.


countryInfoToString : CountryInfo -> String
countryInfoToString countryInfo =
    case countryInfo of
        BirthRate ->
            "BirthRate"

        DeathRate ->
            "DeathRate"

        GDP ->
            "GDP"

        Population ->
            "Population"

        UnemploymentRate ->
            "UnemploymentRate"

        Unknown ->
            "Unknown"

        Search ->
            "Search"
