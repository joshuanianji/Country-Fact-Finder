{-
   this is the view after the user has inputted all the files and we can show the data. There will be a small 'x' at the top right if they wish to change files though (they won't need to but flex lol)
-}


module View.DataCenterView exposing (dataCenterView)

import Colours
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Model exposing (..)
import Msg exposing (Msg(..))
import Subscriptions exposing (ViewPortArgs(..), viewPortHeightWidth)
import View.DataCenterNavbar exposing (navbar)



-- the big boy view thing


dataCenterView : Model -> Element Msg
dataCenterView model =
    Element.column
        [ Font.color Colours.whiteFont
        , Background.image "src/img/night_earth.png"
        , Element.width Element.fill
        , Element.height Element.fill
        ]
        [ header model
        , navbar model
        , body model
        ]



-- this is the "header thing" with "Data Center" title, country search, etc.


header : Model -> Element Msg
header model =
    Element.row
        [ Element.width Element.fill ]
        [ headerTitle
        , closeButton
        ]


headerTitle : Element Msg
headerTitle =
    Element.el
        [ Font.size 40
        , Font.bold
        , Element.centerX
        ]
        (Element.text "Data Center")



-- displays the thing!!


body : Model -> Element Msg
body model =
    let
        currDir =
            case model.directory of
                DataCenter info ->
                    info

                _ ->
                    Unknown
    in
    case currDir of
        Search ->
            searchPage model

        _ ->
            dataDisplay model currDir



-- searches data and displayes them below


searchPage : Model -> Element Msg
searchPage model =
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.spacing 20
        , Element.padding 20
        ]
        [ search model
        , displaySearchResults model
        ]



-- the search bar and the search button


search : Model -> Element Msg
search model =
    Element.row
        [ Element.width Element.fill
        , Element.spacing 10
        ]
        [ Element.column
            [ Element.centerX ]
            [ userHelperText
            , searchBar model
            ]
        , searchButton
        ]



-- tells user to search for a country ree


userHelperText : Element Msg
userHelperText =
    Element.el
        [ Element.width Element.fill
        , Font.center
        , Font.size 20
        ]
        (Element.text "Search for a country!")



-- search bar lmao


searchBar : Model -> Element Msg
searchBar model =
    Input.text
        [ Font.center
        , Font.size 40
        , Element.padding 15
        , Background.color Colours.clear
        , inputBorder
        , Border.rounded 0
        , halfWidth model
        , Element.centerX
        ]
        { onChange = SearchString
        , text = model.searchString
        , placeholder = Nothing
        , label =
            Input.labelHidden "S E A R C H"
        }



-- search button


searchButton : Element Msg
searchButton =
    Input.button
        [ Border.width 1
        , Element.padding 20
        , Element.centerX
        , Element.height Element.fill
        , Font.center
        , Border.rounded 7
        , Element.mouseOver
            [ Background.color Colours.translucent
            ]
        , Element.mouseDown
            [ Font.color (Element.rgb255 0 0 0)
            ]
        ]
        { onPress = Just SearchCountry
        , label = Element.text "Search"
        }



-- displays search results in a table


displaySearchResults : Model -> Element Msg
displaySearchResults model =
    case model.searchData of
        NoInput ->
            Element.el [] (Element.text "No Input")

        NoCountry ->
            Element.el [] (Element.text "No Country Found")

        DataError string ->
            Element.el [] (Element.text ("No text files uploaded! Error message: " ++ string))

        List countryDataList ->
            searchResultTable model countryDataList


searchResultTable : Model -> List CountryData -> Element Msg
searchResultTable model data =
    Element.table
        [ Element.width Element.fill
        , Element.height Element.fill
        , Element.centerX
        , Element.fill
            |> Element.maximum
                (round <|
                    case model.viewport of
                        Just viewport ->
                            viewport.viewport.height - 296

                        Nothing ->
                            69
                )
            |> Element.height
        , Element.scrollbarY
        ]
        { data = data
        , columns =
            [ { header = headerStyle "Country"
              , width = Element.fill
              , view =
                    \datum ->
                        dataStyle datum.country
              }
            , { header = headerStyle "BirthRate"
              , width = Element.fill
              , view =
                    \datum ->
                        maybeTextStyle datum.birthRate BirthRate
              }
            , { header = headerStyle "DeathRate"
              , width = Element.fill
              , view =
                    \datum ->
                        maybeTextStyle datum.deathRate DeathRate
              }
            , { header = headerStyle "GDP"
              , width = Element.fill
              , view =
                    \datum ->
                        maybeTextStyle datum.gdp GDP
              }
            , { header = headerStyle "Population"
              , width = Element.fill
              , view =
                    \datum ->
                        maybeTextStyle datum.population Population
              }
            , { header = headerStyle "Unemployment"
              , width = Element.fill
              , view =
                    \datum ->
                        maybeTextStyle datum.unemployment UnemploymentRate
              }
            ]
        }



-- looks at the model to return half of the viewport width.


halfWidth : Model -> Attribute Msg
halfWidth model =
    case model.viewport of
        Just viewport ->
            viewport.scene.width
                / 2
                |> round
                |> Element.px
                |> Element.width

        Nothing ->
            -- this shouldn't happen
            Element.width (Element.px 100)


inputBorder : Attribute Msg
inputBorder =
    Border.widthEach
        { bottom = 2
        , left = 0
        , right = 0
        , top = 0
        }



-- the page for displaying the data for each countryInfo (the GDP, Population, etc.). Handles errors.


dataDisplay : Model -> CountryInfo -> Element Msg
dataDisplay model countryDirectory =
    let
        filteredData =
            List.filter
                (\x -> x.infoType == countryDirectory)
                model.data
    in
    case filteredData of
        [ convertedData ] ->
            case convertedData.data of
                Success data ->
                    tableDisplay model data convertedData.infoType

                Error errors ->
                    Element.el [] (Element.text errors)

        [] ->
            Element.el [] (Element.text "no filteredData???? bruh")

        list ->
            -- SHOULD NEVER HAPPEN (this means that there is more than one 'GDP' in the model.data, for example.). Therefore I did some random dumb code lol
            Element.row
                []
                (List.map
                    (\num ->
                        if num == 1 then
                            Element.text "1 Bruh"

                        else
                            Element.text (String.fromInt num ++ " Bruhs")
                    )
                    (List.range 1 20)
                )



-- displays data in the table (e.g. GDP, Birth Rate, Etc.). Maximum height is height of screen minus the heights of the navigation bars - it will create a scrollbar if exceeded


tableDisplay : Model -> List Datum -> CountryInfo -> Element Msg
tableDisplay model data countryInfoType =
    Element.table
        [ Element.width Element.fill
        , Element.centerX
        , Element.padding 20
        , Element.fill
            |> Element.maximum
                (round <|
                    case model.viewport of
                        Just viewport ->
                            viewport.viewport.height - 152

                        Nothing ->
                            69
                )
            |> Element.height
        , Element.scrollbarY
        ]
        { data = data
        , columns =
            [ { header = headerStyle "Ranking"
              , width = Element.fill
              , view =
                    \datum ->
                        dataStyle (String.fromInt datum.ranking)
              }
            , { header = headerStyle "Country"
              , width = Element.fill
              , view =
                    \datum ->
                        dataStyle datum.country
              }
            , { header = headerStyle "Info"
              , width = Element.fill
              , view =
                    \datum ->
                        textStyle datum.info countryInfoType
              }
            ]
        }



-- HELPER FUNCTIONS FOR THE DISPLAYDATA FUNCTION
-- headerStyle puts paddings around the stuff lol


headerStyle : String -> Element Msg
headerStyle title =
    Element.el
        [ Element.padding 10
        , Element.centerX
        , Font.bold
        , Font.size 30
        ]
        (Element.text title)



-- dataStyle is to style to texts with padding and such


dataStyle : String -> Element Msg
dataStyle data =
    Element.el
        [ Element.padding 10
        , Element.centerX
        ]
        (Element.text data)



-- textStyle styles the text in the data table and also adds relevant data (e.g. dollar sign before when it's GDP). Also trims the data for example if there are too many spaces at the end of the beginning.


textStyle : String -> CountryInfo -> Element Msg
textStyle data countryInfoType =
    Element.el
        [ Element.padding 10
        , Element.centerX
        ]
        (data
            |> String.trim
            |> textStyler countryInfoType
            |> Element.text
        )



-- maybeTextStyle is the same thing as textStyle except with a maybe handler. I think i should have combined these functions but im too dumb and/or lazy


maybeTextStyle : Maybe String -> CountryInfo -> Element Msg
maybeTextStyle data countryInfoType =
    Element.el
        [ Element.padding 10
        , Element.centerX
        ]
        (data
            |> Maybe.map String.trim
            |> Maybe.map (textStyler countryInfoType)
            |> Maybe.withDefault "Not found"
            |> Element.text
        )



-- helps to style the text based on the country info and stuff


textStyler : CountryInfo -> String -> String
textStyler countryInfoType string =
    case countryInfoType of
        BirthRate ->
            string ++ " per 1000"

        DeathRate ->
            string ++ " per 1000"

        GDP ->
            string ++ " USD"

        Population ->
            string ++ " people"

        UnemploymentRate ->
            string ++ "%"

        Search ->
            string ++ "this shouldn't happen!!! Why is this happening lol"

        Unknown ->
            string ++ " penis"



-- for the user to exit the awesome dataCenterView lol


closeButton : Element Msg
closeButton =
    Element.el
        [ Element.width Element.shrink
        , Element.height Element.shrink
        , Element.mouseOver
            [ Font.color Colours.redFont ]
        , Font.size 40
        , Element.padding 20
        , onClick (ChangeDirectory HomePage) -- goes back to the home page
        , Element.pointer
        , Font.center
        , Element.alignRight
        , Element.alignTop
        ]
        (Element.text "×")
