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

execDownload :: [String] -> IO String
execDownload options =
  readProcess "youtube-dl" options []

main :: IO ()
main = do
  -- Extract cmd args
  a <- cmdArgs cmdargs

  -- Generate search url
  let searchUrl = getSearchUrl (keyword a) (key a)
  putStrLn ("searching " ++ searchUrl)

  -- Call API for search
  results <- callSearch searchUrl

  -- Generate download url
  let downloadUrlE = fmap (getDownloadUrl . getOneId) results
  output <- case downloadUrlE of
    Left message -> return message
    Right downloadUrl -> do
      putStrLn ("downloading " ++ downloadUrl)

      -- Call youtube-dl to perform the download
      let processOptions = (options (format a)) ++ [downloadUrl]
      execDownload processOptions

  putStrLn (output)
