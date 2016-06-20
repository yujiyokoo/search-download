{-# LANGUAGE OverloadedStrings, DeriveGeneric #-}

module Lib
    ( callSearch
    , getSearchUrl
    , decodeSearchResults
    , getOneId
    ) where

import qualified Data.ByteString.Lazy as B
import Network.HTTP.Conduit (simpleHttp)
import qualified Network.HTTP as H (urlEncode)
import Data.Aeson (decode, eitherDecode)
import Data.Aeson.Types
import Data.Text
import Control.Monad
import GHC.Generics

--------------------------------------

youtubeUrl :: String
youtubeUrl = "https://www.googleapis.com/youtube/v3/search?part=snippet"

getSearchUrl :: String -> String -> String
getSearchUrl query api_key =
  youtubeUrl ++
    "&q=" ++ (H.urlEncode query) ++
    "&key=" ++ (H.urlEncode api_key)

callSearch :: String -> IO B.ByteString
callSearch search_url = simpleHttp search_url

decodeSearchResults :: B.ByteString -> Either String SnippetResults
decodeSearchResults = eitherDecode

-- This should switch to using monad for errors
getOneId :: SnippetResults -> String
getOneId (SnippetResults [])  = ""
getOneId (SnippetResults (x:xs)) = videoId x

data SnippetResults =
  SnippetResults [ SnippetResult ] deriving Show

data SnippetResult =
  SnippetResult { title       :: String
                , description :: String
                , kind        :: String
                , videoId     :: String
                } deriving Show

-- For nested object parsing: http://stackoverflow.com/questions/24742872/parsing-an-array-with-haskell-aeson#24743369
instance FromJSON SnippetResults where
  parseJSON jsn = case jsn of
    Object v -> (v .: "items") >>= (fmap SnippetResults) . parseJSON
    x -> fail $ "unexpected json: " ++ show x

instance FromJSON SnippetResult where
  parseJSON (Object v) = do
    s <- v .: "snippet"
    t <- s .: "title"
    d <- s .: "description"
    id  <- v .: "id"
    k   <- id .: "kind"
    vid <- id .: "videoId"
    return SnippetResult { title = t, description = d, kind = k, videoId = vid }

