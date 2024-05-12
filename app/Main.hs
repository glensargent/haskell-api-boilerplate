{-# LANGUAGE OverloadedStrings #-}
module Main where

import Control.Monad.Reader
import Database.SQLite.Simple as DB
import Network.Wai.Middleware.Cors
import Web.Scotty.Trans

data HandlerEnv = HandlerEnv
  { conn :: Connection
  }

type AppM = ReaderT HandlerEnv IO

main :: IO ()
main = do
  appConn <- DB.open "app.db"
  let env = HandlerEnv appConn
  -- execute_ conn "CREATE TABLE IF NOT EXISTS scans (id INTEGER PRIMARY KEY, name TEXT)"
  scottyT 3000 (`runReaderT` env) $ do
    middleware simpleCors
    get "/" $ handleIndex

handleIndex :: ActionT AppM ()
handleIndex = do
  -- connection <- asks conn
  text "test"
