{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module Delete where

import Foundation
import Yesod.Core
import Yesod
import Components.Navbar

getDeleteR :: TasksId -> Handler Html
getDeleteR taskId = do
  task <- runDB $ get404 taskId
  isLogged <- lookupSession "login"
  case isLogged of
    Nothing -> redirect LoginR
    Just user -> do
      user <- runDB $ getBy (UniqueName user)
      case user of
        Nothing -> redirect LogoutR
        Just (Entity uid userData) -> do
          let isUserValid = uid == (tasksUserId task)
          if isUserValid then defaultLayout $ do
            [whamlet|
              ^{navbar}
              <div .container.mt-5>
                <form method=post action=@{DeleteR taskId}>
                  <h2>Deseja excluir esta tarefa ? "#{tasksTitle task}"
                  <input type=submit .btn.btn-danger value=Sim>
                  <a href=@{HomeR} .btn.btn-secondary>Não
            |]
          else
            redirect HomeR
          

postDeleteR :: TasksId -> Handler Html
postDeleteR taskId = do
  task <- runDB $ get404 taskId
  isLogged <- lookupSession "login"
  case isLogged of
    Nothing -> redirect LoginR
    Just name -> do
      user <- runDB $ getBy (UniqueName name)
      case user of
        Nothing -> redirect LogoutR
        Just (Entity userId userData) -> do
          let isUserValid = userId == (tasksUserId task)
          if isUserValid then do
            runDB $ delete taskId
            redirect HomeR
          else
            redirect HomeR