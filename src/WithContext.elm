module WithContext exposing
    ( WithContext
    , fromHtml
    , toHtml
    , node
    , text
    , lift
    )

{-| Cleaner, hack-free way to pass contexts to Elm view functions.

Simple port of [arowM/elm-html-with-context](https://package.elm-lang.org/packages/arowM/elm-html-with-context/latest/) to make it work with [rtfeldman/elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/).


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

  - A `Node` is a wrapper for "a function that can take a list of functions that take a context and return a `Html` value, and return a function that takes a context and returns a `Html` value".
  - A `Leaf` is a wrapper for "a function that takes a context, and returns a `Html` value".

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


{-| Text node. We have to explicitly define this, because it's the only `Html` function that doesn't take a `List Html msg` as an argument.
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
