module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onMouseEnter, onMouseLeave, onSubmit)
import Http
import Task
import GifService exposing (getRandomGif, voteForGif)


---- MODEL ----


type alias Model =
    { gifOne : String
    , gifTwo : String
    , hoveredGif : ActiveGif
    , query : String
    }


init : ( Model, Cmd Msg )
init =
    ( { gifOne = ""
      , gifTwo = ""
      , hoveredGif = Neither
      , query = "cats"
      }
    , Task.attempt NextGifs <|
        Task.map2 (\gifOne gifTwo -> ( gifOne, gifTwo ))
            (GifService.getRandomGif "cats")
            (GifService.getRandomGif "cats")
    )



---- UPDATE ----


type ActiveGif
    = One
    | Two
    | Neither


type Msg
    = NextGifs (Result Http.Error ( String, String ))
    | UpdateQuery String
    | LoadGifs
    | HoverOnGif ActiveGif
    | StopHover
    | VoteForGif ActiveGif
    | VoteCounted (Result Http.Error Bool)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateQuery query ->
            ( { model | query = query }, Cmd.none )

        LoadGifs ->
            ( model
            , Task.attempt NextGifs <|
                Task.map2 (\gifOne gifTwo -> ( gifOne, gifTwo ))
                    (GifService.getRandomGif model.query)
                    (GifService.getRandomGif model.query)
            )

        NextGifs (Ok ( gifOne, gifTwo )) ->
            ( { model
                | gifOne = gifOne
                , gifTwo = gifTwo
              }
            , Cmd.none
            )

        NextGifs (Err _) ->
            ( model, Cmd.none )

        HoverOnGif gif ->
            ( { model | hoveredGif = gif }, Cmd.none )

        StopHover ->
            ( { model | hoveredGif = Neither }, Cmd.none )

        VoteForGif gif ->
            case gif of
                One ->
                    ( model, Http.send VoteCounted <| (voteForGif model.gifOne) )

                Two ->
                    ( model, Http.send VoteCounted <| (voteForGif model.gifTwo) )

                Neither ->
                    ( model, Cmd.none )

        VoteCounted (Ok _) ->
            update LoadGifs model

        VoteCounted (Err _) ->
            update LoadGifs model



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ Html.form [ class "app__query-form", onSubmit LoadGifs ]
            [ input
                [ class "app__query"
                , type_ "text"
                , placeholder "Let's look for something new"
                , onInput UpdateQuery
                , value model.query
                ]
                []
            ]
        , section [ class "app__gifs-wrapper" ]
            [ div
                [ class "app__gif"
                , onMouseEnter (HoverOnGif One)
                , onMouseLeave StopHover
                , onClick (VoteForGif One)
                ]
                [ img [ src model.gifOne ] []
                , div [ class (determineOverlayClass model.hoveredGif One) ] [ text "+1" ]
                ]
            , div
                [ class "app__gif"
                , onMouseEnter (HoverOnGif Two)
                , onMouseLeave StopHover
                , onClick (VoteForGif Two)
                ]
                [ img [ src model.gifTwo ] []
                , div [ class (determineOverlayClass model.hoveredGif Two) ] [ text "+1" ]
                ]
            ]
        , button [ class "app__dgaf-button", onClick LoadGifs ] [ text "i dgaf, they both suck" ]
        ]


determineOverlayClass : ActiveGif -> ActiveGif -> String
determineOverlayClass activeGif currentGif =
    if currentGif == activeGif then
        "app__gif-overlay--active"
    else
        "app__gif-overlay--inactive"



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
