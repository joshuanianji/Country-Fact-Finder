{-
   My own colours and stuff
-}


module Colours exposing (clear, greenFont, linkColor, redFont, translucent, whiteFont)

import Element exposing (Color, rgb255, rgba)



-- font colour (it's not white lol!)


whiteFont : Color
whiteFont =
    rgb255 215 215 215


linkColor : Color
linkColor =
    rgb255 97 181 204


greenFont : Color
greenFont =
    rgb255 0 128 0


redFont : Color
redFont =
    rgb255 220 20 60


clear : Color
clear =
    rgba 0 0 0 0


translucent : Color
translucent =
    rgba 255 255 255 0.2
