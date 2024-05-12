{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import Control.Monad.Reader
import Database.SQLite.Simple as DB
import Network.Wai.Middleware.Cors
import Web.Scotty.Trans
import Data.Aeson
import GHC.Generics

data HandlerEnv = HandlerEnv
  { conn :: Connection
  }

type AppM = ReaderT HandlerEnv IO

data User = User {
  name :: String,
  age :: Int
} deriving (Show, Generic)
instance ToJSON User
instance FromJSON User


main :: IO ()
main = do
  appConn <- DB.open "app.db"
  let env = HandlerEnv appConn
  -- execute_ conn "CREATE TABLE IF NOT EXISTS scans (id INTEGER PRIMARY KEY, name TEXT)"
  scottyT 3000 (`runReaderT` env) $ do
    middleware simpleCors
    get "/" $ handleIndex
    get "/:name" $ handleParamExample
    post "/user" $ handlePostExample

handleIndex :: ActionT AppM ()
handleIndex = do
  -- connection <- asks conn
  text "hello world"

handleParamExample :: ActionT AppM ()
handleParamExample = do
  nameParam <- pathParam "name"
  text ("hello " <> nameParam)

handlePostExample :: ActionT AppM ()
handlePostExample = do
  reqBody <- jsonData
  liftIO $ print $ name reqBody
  liftIO $ print $ age reqBody

