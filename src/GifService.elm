module GifService exposing (getRandomGif, voteForGif)

import Http
import Task
import Json.Decode exposing (Decoder, at, string, bool)
import Json.Encode as Encode


decodeGifUrl : Decoder String
decodeGifUrl =
    at [ "data", "image_url" ] string


decodeNothingReally : Decoder Bool
decodeNothingReally =
    at [ "data", "success" ] bool


getRandomGif : String -> Task.Task Http.Error String
getRandomGif topic =
    Http.toTask (Http.get ("https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic) decodeGifUrl)


voteForGif : String -> Http.Request Bool
voteForGif gifUrl =
    Http.post
        "http://localhost:4444/api/vote"
        (Http.jsonBody (Encode.object [ ( "url", Encode.string gifUrl ) ]))
        decodeNothingReally
