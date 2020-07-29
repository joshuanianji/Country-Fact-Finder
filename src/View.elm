module View exposing (view)

import Element exposing (Element, FocusStyle)
import Element.Background as Background
import Fonts
import GithubLogo
import Html exposing (Html)
import Model exposing (Directory(..), Model)
import Msg exposing (Msg(..))
import View.DataCenterView exposing (dataCenterView)
import View.HomeView exposing (homePageView)


view : Model -> Html Msg
view model =
    htmlPage model <|
        case model.directory of
            HomePage ->
                homePageView model

            DataCenter country ->
                dataCenterView model


htmlPage : Model -> Element Msg -> Html Msg
htmlPage model page =
    Element.layoutWith
        { options = [ Element.focusStyle focusStyle ] }
        [ Fonts.default
        , Background.color (Element.rgb255 0 0 0)
        , Element.inFront <|
            case model.directory of
                HomePage ->
                    GithubLogo.view
                        { href = "https://github.com/joshuanianji/Country-Fact-Finder"
                        , bgColor = "#ffffff00"
                        , bodyColor = "#fff"
                        }
                        |> Element.el
                            [ Element.alignRight
                            , Element.alignTop
                            ]

                _ ->
                    Element.none
        ]
        page



-- makes it so that the input boxes don't have that bue border outline when it's active


focusStyle : FocusStyle
focusStyle =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }
