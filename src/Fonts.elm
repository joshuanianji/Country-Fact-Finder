{-
      When you set texts to be a specific imported font, you'll have to do something like this;

   Font.family
       [ Font.external
           { name = "Open Sans"
           , url = "https://fonts.googleapis.com/css?family=Open+Sans"
           }
       ]

       That's super annoying so I'm making a file of functions that just return those things lol.
-}


module Fonts exposing (default, title)

import Element exposing (Attribute)
import Element.Font as Font
import Msg exposing (Msg)


default : Attribute Msg
default =
    Font.family
        [ Font.external
            { name = "Open Sans"
            , url = "https://fonts.googleapis.com/css?family=Open+Sans"
            }
        ]


title : Attribute Msg
title =
    Font.family
        [ Font.external
            { name = "Cormorant"
            , url = "https://fonts.googleapis.com/css?family=Cormorant:700"
            }
        , Font.serif
        ]
