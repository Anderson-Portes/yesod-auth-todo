{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
module Register where

import Foundation
import Yesod.Core
import Yesod

getRegisterR :: Handler Html
getRegisterR = defaultLayout $ do
  isLogged <- lookupSession "login"
  errorMessage <- lookupGetParam "error"
  if isLogged == Nothing then
    [whamlet|
      <div .container-fluid.vh-100>
        <div .row.justify-content-center.align-items-center.h-100>
          <form .col-11.col-md-8.col-lg-6.shadow-sm.rounded-3.border.pt-4 method=post action=@{RegisterR}>
            <h4 .fw-bold>Realize seu cadastro
            <div .form-floating.mb-2>
              <input .form-control type=text name=name placeholder=name #input-name required>
              <label for=input-name>Nome de usuário
            <div .form-floating.mb-4>
              <input .form-control type=password name=password placeholder=senha #input-password required minlength=8>
              <label for=input-password>Senha
            $maybe msg <- errorMessage
              <p .text-danger>#{msg}
            <input type=submit value=Cadastrar .btn.btn-primary.w-100.mb-2>
            <p>Ja possui uma conta? 
              <a .text-decoration-none href=@{LoginR}>Login
    |]
  else
    redirect HomeR

postRegisterR :: Handler Html
postRegisterR = do
  user <- runInputPost $ Users <$> ireq textField "name" <*> ireq textField "password"
  userExists <- runDB (getBy $ UniqueName (usersName user))
  case userExists of
    Nothing -> do
      runDB $ insert user
      redirect LoginR
    _ -> redirect (RegisterR, [("error", "Nome de usuário indisponível")])