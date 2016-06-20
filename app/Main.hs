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

getDownloadUrl vidId =
  either (const "") id videoUrl
  where
    videoUrl = liftM2 (++) (Right "https://www.youtube.com/watch?v=") ((liftM H.urlEncode) vidId)

main :: IO ()
main = do
  a <- cmdArgs cmdargs
  let searchUrl = getSearchUrl (keyword a) (key a)
  putStrLn ("searching " ++ searchUrl)

  results_json <- callSearch searchUrl
  let results = decodeSearchResults results_json
  let vidId = (liftM getOneId) results

  let downloadUrl = getDownloadUrl vidId
  putStrLn ("downloading " ++ downloadUrl)
  let message = "downloading the fuck out of " ++ downloadUrl
  putStrLn (show message)

  -- do the call to download
  output <- readProcess "youtube-dl" (options (format a) ++ [downloadUrl]) []
  putStrLn (output)
  -- callSearch url >>= putStrLn . show . decodeSearchResults
