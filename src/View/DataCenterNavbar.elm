module View.DataCenterNavbar exposing (navbar)

import Element exposing (Attribute, Element, centerX, el, fill, height, padding, px, row, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input exposing (button)
import Model exposing (..)
import Msg exposing (Msg(..))


navbar : Model -> Element Msg
navbar model =
    row [ width fill ]
        (navbarViewList model)


navbarViewList : Model -> List (Element Msg)
navbarViewList model =
    List.map
        (navbarFramework model)
        navbarMapList


navbarFramework : Model -> ( String, CountryInfo ) -> Element Msg
navbarFramework model ( name, countryInfo ) =
    button
        (navbarElementAttributes model countryInfo)
        { onPress = Just (ChangeDataCenterDirectory countryInfo)
        , label = el [ centerX ] (text name)
        }


navbarMapList : List ( String, CountryInfo )
navbarMapList =
    [ ( "BirthRate.txt", BirthRate )
    , ( "DeathRate.txt", DeathRate )
    , ( "GDP.txt", GDP )
    , ( "Population.txt", Population )
    , ( "UnemploymentRate.txt", UnemploymentRate )
    , ( "Search", Search )
    ]



-- checks to see in the model if we're in that specific directory. if we are we make the text bold.


navbarElementAttributes : Model -> CountryInfo -> List (Attribute Msg)
navbarElementAttributes model dir =
    case model.directory of
        DataCenter countryInfo ->
            if countryInfo == dir then
                activeNavbarAttr

            else
                basicNavbarAttr

        HomePage ->
            basicNavbarAttr



-- lmao i just make the border transparent if it's not active what disgusting code lmao


basicNavbarAttr : List (Attribute Msg)
basicNavbarAttr =
    [ padding 20, width fill, navBorder, Border.color (Element.rgba 1 1 1 0) ]


activeNavbarAttr : List (Attribute Msg)
activeNavbarAttr =
    [ padding 20, width fill, navBorder, Border.color (Element.rgb 1 1 1) ]



-- we always have a border of 2 - we just change the colour. This is because if we change the width of the border, we'll shoft the navbar a bit and itll be annoying


navBorder : Attribute Msg
navBorder =
    Border.widthEach
        { bottom = 2
        , left = 0
        , right = 0
        , top = 0
        }
