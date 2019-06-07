module View exposing (view)

import Element exposing (Element, FocusStyle)
import Element.Background as Background
import Fonts
import Html exposing (Html)
import Model exposing (Directory(..), Model)
import Msg exposing (Msg(..))
import View.DataCenterView exposing (dataCenterView)
import View.HomeView exposing (homePageView)


view : Model -> Html Msg
view model =
    htmlPage <|
        case model.directory of
            HomePage ->
                homePageView model

            DataCenter country ->
                dataCenterView model


htmlPage : Element Msg -> Html Msg
htmlPage page =
    Element.layoutWith
        { options = [ Element.focusStyle focusStyle ] }
        [ Fonts.default
        , Background.color (Element.rgb255 0 0 0)
        ]
        page



-- makes it so that the input boxes don't have that bue border outline when it's active


focusStyle : FocusStyle
focusStyle =
    { borderColor = Nothing
    , backgroundColor = Nothing
    , shadow = Nothing
    }
