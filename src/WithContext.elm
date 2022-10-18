module WithContext exposing
    ( WithContext
    , fromHtml
    , toHtml
    , node
    , text
    , lift
    )

{-| Cleaner, hack-free way to pass contexts to Elm view functions.

    Simple port of arowM/elm-html-with-context to make it work with rtfeldman/elm-css


# Types

@docs WithContext


# Converters

@docs fromHtml
@docs toHtml


# Core functions

@docs node
@docs text


# Low level functions

@docs lift

-}

import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Lazy as Html


{-| An opaque type for representing `Html` with a context.

    A `Node` is a wrapper for "a function that can take a list of `Html` functions, and return `Html` value, with a context".

    A `Leaf` is a wrapper for "a `Html` value, with a context".

-}
type WithContext context msg
    = Node (context -> List (Html msg) -> Html msg) (List (WithContext context msg))
    | Leaf (context -> Html msg)


{-| A constructor for `WithContext` from `Html`.
-}
fromHtml : (context -> Html msg) -> WithContext context msg
fromHtml =
    Leaf


{-| Convert to `Html`.
-}
toHtml : context -> WithContext context msg -> Html msg
toHtml context withContext =
    case withContext of
        Node func children ->
            List.map (toHtml context) children |> func context

        Leaf func ->
            Html.lazy func context


{-| Custom node.
-}
node : (context -> List (Html msg) -> Html msg) -> List (WithContext context msg) -> WithContext context msg
node =
    Node


{-| Text node.
-}
text : (context -> String) -> WithContext context msg
text func =
    func >> Html.text |> Leaf


{-| This function is supposed to be used with functions in `WithContext.Lazy`.
Please see [actual use case](https://github.com/arowM/elm-css-modules-helper/tree/master/examples/real-world) for detail.
-}
lift : (context -> subContext) -> WithContext subContext msg -> WithContext context msg
lift func withContext =
    case withContext of
        Node subcontextFunc children ->
            List.map (lift func) children
                |> Node (func >> subcontextFunc)

        Leaf subcontextFunc ->
            func >> subcontextFunc |> Leaf
