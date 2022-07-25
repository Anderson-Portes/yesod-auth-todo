{-# LANGUAGE DeriveDataTypeable         #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module Home where

import Foundation
import Yesod.Core
import Yesod
import Database.Persist.Postgresql
import Components.Navbar
import Data.Text

getHomeR :: Handler Html
getHomeR =  do
  isLogged <- lookupSession "login"
  case isLogged of
    Just user -> do
      taskList <- runDB $ (rawSql "select ?? from tasks where user_id = (select id from users where name = ?) order by id desc" [toPersistValue user]) :: Handler [Entity Tasks]
      liftIO $ print taskList
      defaultLayout
        [whamlet|
          ^{navbar}
          <div .container.mt-4>

            <button type=button .btn.btn-primary data-bs-toggle=modal data-bs-target=#modal>
              Adicionar Tarefa
            
            <table .table.mt-3>
              <thead .table-light>
                <tr>
                  <th>Tarefa
                  <th>Status
                  <th>Ações
              <tbody>
                $forall (Entity taskId task) <- taskList
                  <tr>
                    <td>#{tasksTitle task}
                    <td>
                      $if tasksDone task
                        Concluído
                      $else
                        Em andamento
                    <td>
                      <a .btn.btn-danger.btn-sm href=@{DeleteR taskId}>Deletar

            <div .modal.fade #modal tabindex=-1 aria-labelledby=modalLabel aria-hidden=true>
              <div .modal-dialog>
                <div .modal-content>
                  <div .modal-header>
                    <h5 .modal-title #modalLabel>Adicionar Tarefa
                    <button type=button .btn-close data-bs-dismiss=modal aria-label=Close>
                  <div .modal-body>
                    <form method=post action=@{HomeR}>
                      <div .form-floating.mb-2>
                        <input .form-control type=text name=title placeholder=title #input-title required>
                        <label for=input-title>Título...
                      <div .form-check.form-check-inline>
                        <input type=radio name=done #input-done-1 .form-check-input required value=on>
                        <label for=input-done-1 .form-check-label>Concluído
                      <div .form-check.form-check-inline>
                        <input type=radio name=done #input-done-2 .form-check-input required value=no>
                        <label for=input-done-2 .form-check-label>Em andamento
                      <input type=submit .btn.btn-primary.d-block.mt-4 value=Adicionar>
        |]
    Nothing -> redirect LoginR
  

postHomeR :: Handler Html
postHomeR = do
  isLogged <- lookupSession "login"
  case isLogged of
    Nothing -> redirect LoginR
    Just login -> do
      user <- runDB $ getBy (UniqueName login)
      case user of
        Just (Entity userId userData) -> do
          task <- runInputPost $ Tasks <$> ireq textField "title" <*> ireq boolField "done"
          liftIO $ print (task userId)
          runDB $ insert (task userId)
          redirect HomeR
        Nothing -> redirect LogoutR