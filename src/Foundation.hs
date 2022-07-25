{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleInstances,
             MultiParamTypeClasses, DeriveDataTypeable,
             GeneralizedNewtypeDeriving, ViewPatterns, EmptyDataDecls#-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE DataKinds #-}

module Foundation where

import Yesod.Core
import Yesod
import Data.Text
import Database.Persist.Postgresql
import Yesod.Static

staticFiles "static"

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Users
  name Text
  password Text
  UniqueName name
  deriving Show
Tasks
  title Text
  done Bool
  userId UsersId
  deriving Show
|]

data App = App{connPool :: ConnectionPool, getStatic :: Static}

mkYesodData "App" $(parseRoutesFile "routes.yesodroutes")

myLayout :: Widget -> Handler Html
myLayout widget = do
  pc <- widgetToPageContent widget
  withUrlRenderer
    [hamlet|
      $doctype 5
      <html lang=pt-br>
        <head>
          <meta name=viewport content=width=device-width,initial-scale=1.0>
          <meta charset=utf-8>
          <title>To Do List
          <link rel=stylesheet href=https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/css/bootstrap.min.css>
          <style>
            @import url("https://fonts.googleapis.com/css2?family=Poppins&display=swap");
            * { font-family: 'Poppins', sans-serif; }
        <body>
          ^{pageBody pc}
          <script src=https://cdn.jsdelivr.net/npm/bootstrap@5.2.0/dist/js/bootstrap.bundle.min.js>
    |]

instance Yesod App where
  defaultLayout = myLayout
  makeSessionBackend _ =
    fmap Just $ defaultClientSessionBackend (24 * 60 * 7) "client_session_key.aes"

instance RenderMessage App FormMessage where
  renderMessage _ _ = defaultFormMessage

instance YesodPersist App where
  type YesodPersistBackend App = SqlBackend
  runDB f = do
    master <- getYesod
    let pool = connPool master
    runSqlPool f pool