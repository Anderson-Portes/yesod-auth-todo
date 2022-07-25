{-# LANGUAGE OverloadedStrings #-}

import Application ()
import Foundation
import Yesod.Core
import Yesod.Static
import Database.Persist.Postgresql
import Control.Monad.Logger (runStdoutLoggingT)
import Control.Monad.IO.Class (liftIO)

connStr = "dbname=bd_tarefas host=localhost user=postgres password=root port=5432"

main :: IO ()
main = runStdoutLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
  flip runSqlPersistMPool pool $ do
    runMigration migrateAll
  static@(Static settings) <- static "static"
  warp 3000 (App pool static)
