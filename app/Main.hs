{-# LANGUAGE DeriveDataTypeable #-}

-- (with stackage) you can run this like
-- > stack exec search-download-exe -- --key=<youtube api key> --keyword=<search keyword> [--format=mp3]

module Main where

import Lib
import System.Console.CmdArgs
import Control.Monad
import qualified Network.HTTP as H (urlEncode)
import System.Process

data Args =
  Args { keyword     :: String
       , key         :: String
       , format :: String
       } deriving (Show, Data, Typeable)

cmdargs = Args { keyword = def,
                 key = def,
                 format = def }

options :: String -> [String]
options audioFormat = case audioFormat of
  "mp3" -> ["-x", "--audio-format=mp3"]
  _ -> []

getDownloadUrl :: String -> String
getDownloadUrl vidId =
  "https://www.youtube.com/watch?v=" ++ (H.urlEncode vidId)

main :: IO ()
main = do
  -- Generate search url
  a <- cmdArgs cmdargs
  let searchUrl = getSearchUrl (keyword a) (key a)
  putStrLn ("searching " ++ searchUrl)

  -- Call API for search
  results_json <- callSearch searchUrl
  let results = decodeSearchResults results_json

  -- Generate download url
  let downloadUrlE = fmap (getDownloadUrl . getOneId) results
  let downloadUrl = either (const "") id downloadUrlE
  putStrLn ("downloading " ++ downloadUrl)

  -- Call youtube-dl to perform the download
  output <- readProcess "youtube-dl" (options (format a) ++ [downloadUrl]) []
  putStrLn (output)
  -- callSearch url >>= putStrLn . show . decodeSearchResults
