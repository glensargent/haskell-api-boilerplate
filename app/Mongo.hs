{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad.Reader
import Control.Monad (unless)
import Data.Aeson
import GHC.Generics
import Network.Wai.Middleware.Cors
import Web.Scotty.Trans
import Data.Text (Text)
import Database.MongoDB
import Control.Exception (throwIO)

data HandlerEnv = HandlerEnv
  { 
    -- conn :: Connection
  }
--
--
--
type AppM = ReaderT HandlerEnv IO

data User = User
  { name :: Text,
    age :: Int
  }
  deriving (Show, Generic)

instance ToJSON User

instance FromJSON User

main :: IO ()
main = do
  repSet <- openReplicaSetSRV' "clusterurl"
  p <- primary repSet
  is_auth <- access p master "admin" $ auth "glen-local" "password"
  unless is_auth (throwIO $ userError "Authentication failed")
  e <- access p master "database" allCollections
  print e

  let env = HandlerEnv
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
  json User {
    name = nameParam,
    age = 900
  }

handlePostExample :: ActionT AppM ()
handlePostExample = do
  reqBody <- jsonData
  liftIO $ print $ name reqBody
  liftIO $ print $ age reqBody
