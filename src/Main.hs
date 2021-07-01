{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric     #-}

{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE DataKinds #-}

module Main where

import           Web.Spock
import           Web.Spock.Config
import           Web.Spock.Lucid        (lucid)
import           Lucid
import           Data.Text              (Text, pack, unpack)
import           Data.IORef
import           Control.Monad          (forM_)
import           Control.Monad.IO.Class (liftIO)
import           Data.Semigroup         ((<>))
import           Data.Aeson             hiding (json)
import           GHC.Generics

import           Control.Monad.Logger    (LoggingT, runStdoutLoggingT)
import           Database.Persist        hiding (get)
import qualified Database.Persist        as P
import           Database.Persist.Sqlite hiding (get)
import           Database.Persist.TH


type Server = SpockM SqlBackend () () ()

type ApiAction a = SpockAction SqlBackend () () a

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Person json -- The json keyword will make Persistent generate sensible ToJSON and FromJSON instances for us.
  name Text
  age Int
  deriving Show
|]

runSQL :: (HasSpock m, SpockConn m ~ SqlBackend)  => SqlPersistT (LoggingT IO) a -> m a
runSQL action = runQuery $ \conn -> runStdoutLoggingT $ runSqlConn action conn

errorJson :: Int -> Text -> ApiAction ()
errorJson code message =
  json $
    object
    [ "result" .= String "failure"
    , "error" .= object ["code" .= code, "message" .= message]
    ]

app :: Server
app = do    
    get root $ do
        allPeople <- runSQL $ selectList [] [Asc PersonId]
        lucid $ do
            h1_ "People"
            ul_ $ forM_ allPeople $ \people -> li_ $ do
                "Name : "
                toHtml (unpack (personName (entityVal people)))
                ", Age : "
                toHtml (show (personAge (entityVal people)))
                " years"
            h2_ "New Person"
            form_ [method_ "post"] $ do
                label_ $ do
                    "Name: "
                    input_ [name_ "name"]
                label_ $ do
                    "Age: "
                    input_ [name_ "age"]
                input_ [type_ "submit", value_ "Add Person"]
    post root $ do
        namePerson <- param' "name"
        agePerson <- param' "age"
        let newPerson = 
                Person {personName = namePerson, personAge = agePerson}
            in runSQL $ insert newPerson
        redirect "/"

    get "api" $ do
        allPeople <- runSQL $ selectList [] [Asc PersonId]
        json allPeople
    post "api" $ do
        maybePerson <- jsonBody :: ApiAction (Maybe Person)
        case maybePerson of
            Nothing -> errorJson 1 "Failed to parse request body as Person"
            Just thePerson -> do
                newId <- runSQL $ insert thePerson
                json $ object ["result" .= String "success", "id" .= newId]
    get ("api" <//> var) $ \personId -> do
        maybePerson <- runSQL $ P.get personId :: ApiAction (Maybe Person)
        case maybePerson of
            Nothing -> errorJson 2 "Could not find a person with matching id"
            Just thePerson -> json thePerson


main :: IO ()
main = do
    pool <- runStdoutLoggingT $ createSqlitePool "api.db" 5
    
    cfg <- defaultSpockCfg () (PCPool pool) ()
    runStdoutLoggingT $ runSqlPool (do runMigration migrateAll) pool
    runSpock 3000 (spock cfg app)
