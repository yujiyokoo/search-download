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


download :: [String] -> String -> IO String
download args downloadUrl = do
  putStrLn ("downloading " ++ downloadUrl)
  let cmdLineArgs = args ++ [downloadUrl]
  readProcess "youtube-dl" cmdLineArgs []

main :: IO ()
main = do
  -- Extract cmd args
  a <- cmdArgs cmdargs

  -- Generate search url
  let searchUrl = getSearchUrl (keyword a) (key a)
  putStrLn ("searching " ++ searchUrl)

  -- Call API for search
  -- Either a list of results, or fail
  resultsE <- callSearch searchUrl

  -- Join flattens the inner either produced by getOneId
  let resultE = join $ getOneId <$> resultsE

  -- Generate download url
  let downloadUrlE = getDownloadUrl <$> resultE
  let parsedArgs = options (format a)
  output <- either (return . id) (download parsedArgs) downloadUrlE

  putStrLn (output)

