# elm-css-with-context

Simple port of [arowM/elm-html-with-context](https://package.elm-lang.org/packages/arowM/elm-html-with-context/latest/) to make it work with [rtfeldman/elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/).

This package is identical to arowM's, with a few small differences:

* I rewrote all of the functions myself, line by line, in a style that is a little easier for me to read (i.e., no left pizza or left-compose, slightly different argument names under the hood), mostly as a means of better understanding how the original package works.
* There's no `WithContext.Lazy.lazy7`, because [`Html.Styled.Lazy` needs an argument to track styling info](https://github.com/rtfeldman/elm-css/blob/551376deabbfa50eec40a0a735941b4edf7ea592/src/Html/Styled/Lazy.elm#L3-L4) and `WithContext.Lazy` also needs to use an argument to track context info.
* I added a few extra comments here and there, to try to explain things as they became more clear to me.