{-
   This home page shows the title page, and also uploads the files. once the files are uploaded, the other pages are available to click.
-}


module View.HomeView exposing (homePageView)

import Colours
import Element exposing (Attr, Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import File exposing (File)
import Fonts
import List
import Model exposing (..)
import Msg exposing (Msg(..))
import Subscriptions exposing (ViewPortArgs(..), viewPortHeightWidth)



-- this is the page where you input the stuff


homePageView : Model -> Element Msg
homePageView model =
    -- this `el` is in charge of the background (so it has to be the full height and width) and has an image
    Element.el
        (List.append
            [ Background.image "src/img/earth_night_2.png"
            , Element.padding 40
            , Font.color Colours.whiteFont
            ]
            (viewPortHeightWidth All model)
        )
        (Element.column
            [ Element.width Element.fill
            , Element.height Element.fill
            , Element.padding 40
            , Element.spacing 20
            ]
            [ countryFactTitle
            , importantInfo
            , uploadFilesButton
            , uploadedFileCheck model
            , advanceToNextStageButton model
            , credits
            ]
        )



-- important info about what files to upload
-- P.S. They'll need to upload "BirthRate, DeathRate, GDP, Population, and UnemploymentRate"


importantInfo : Element Msg
importantInfo =
    Element.el
        [ Element.centerX
        , Element.centerY
        , Element.padding 10
        ]
        (Element.text "Please upload the text files")



-- this button gets the files yeehaw


uploadFilesButton : Element Msg
uploadFilesButton =
    Input.button
        [ Element.centerX
        , Element.centerY
        , Border.color Colours.whiteFont
        , Border.width 1
        , Element.padding 15
        , Border.rounded 5
        , Element.mouseOver
            [ Background.color Colours.translucent
            ]
        ]
        { onPress = Just RequestFiles
        , label = Element.text "Upload"
        }



-- this row that displays the uploaded files


uploadedFileCheck : Model -> Element Msg
uploadedFileCheck model =
    List.map
        uploadedFileElement
        model.files.fileData
        |> Element.row
            [ Element.centerX
            , Element.centerY
            , Element.width Element.fill
            ]



-- this is each little module that takes in an element of the model.files.fileData and returns an element msg


uploadedFileElement : FileData -> Element Msg
uploadedFileElement fileData =
    let
        elementReturn fontColour message =
            Element.column
                [ Element.width Element.fill
                , Element.spacing 10
                ]
                [ Element.el
                    [ Font.bold
                    , Element.centerX
                    , Font.size 25
                    ]
                    (Element.text fileData.name)
                , Element.el
                    [ Element.centerX
                    , Font.color fontColour
                    , Font.bold
                    ]
                    (Element.text message)
                ]
    in
    if fileData.isUploaded then
        elementReturn Colours.greenFont "Uploaded"

    else
        elementReturn Colours.redFont "Not Uploaded"



-- only active if the user has access to the next stage (has uploaded all the text files)
-- Defaults to Search


advanceToNextStageButton : Model -> Element Msg
advanceToNextStageButton model =
    if model.accessGranted then
        Input.button
            [ Element.centerX
            , Element.centerY
            , Background.color Colours.clear
            , Element.padding 15
            , Font.color Colours.greenFont
            , Border.width 1
            , Border.rounded 5
            , Border.color Colours.greenFont
            , Element.mouseOver
                [ Background.color Colours.greenFont
                , Font.color Colours.whiteFont
                ]
            , Font.bold
            ]
            { onPress = Just (ChangeDirectory (DataCenter Search)) -- advances the directory
            , label = Element.text "Text file authentication complete. Click here to advance"
            }

    else
        Element.el
            [ Element.height (Element.px 44)
            , Element.centerY
            ]
            Element.none



-- big "country fact finder" title


countryFactTitle : Element Msg
countryFactTitle =
    Element.el
        [ Font.size 120
        , Element.alignTop
        , Element.centerX
        , Fonts.title
        ]
        (Element.text "Country Fact Finder")



-- credits is just the text saying by Joshua Ji and the Elm Language


credits : Element Msg
credits =
    Element.el
        [ Element.centerX
        , Font.size 20
        , Element.centerY
        , Element.height Element.fill
        ]
        (Element.row
            [ Element.alignBottom ]
            [ Element.text "By Joshua Ji and "
            , elmLink
            ]
        )


elmLink : Element Msg
elmLink =
    Element.row
        []
        [ Element.image
            [ Element.height (Element.px 30)
            , Element.centerY
            ]
            { src = "src/img/elm_logo.png"
            , description = "sexy elm logo. You should click on it!"
            }
        , Element.newTabLink
            [ Font.color Colours.linkColor ]
            { url = "https://elm-lang.org/"
            , label = Element.text " the Elm Language"
            }
        ]
