{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE QuasiQuotes           #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module Login where

import Foundation
import Yesod.Core
import Yesod

getLoginR :: Handler Html
getLoginR = defaultLayout $ do
  isLogged <- lookupSession "login"
  errorMessage <- lookupGetParam "error"
  if isLogged == Nothing then
    [whamlet|
      <div .container-fluid.vh-100>
        <div .row.justify-content-center.align-items-center.h-100>
          <form .col-11.col-md-8.col-lg-6.shadow-sm.rounded-3.border.pt-4 method=post action=@{LoginR}>
            <h4 .fw-bold>Realize seu login
            <div .form-floating.mb-2>
              <input .form-control type=text name=name placeholder=name #input-name required>
              <label for=input-name>Nome de usuário
            <div .form-floating.mb-4>
              <input .form-control type=password name=password placeholder=senha #input-password required minlength=8>
              <label for=input-password>Senha
            $maybe msg <- errorMessage
              <p .text-danger>#{msg}
            <input type=submit value=Login .btn.btn-primary.w-100.mb-2>
            <p>Não possui uma conta? 
              <a .text-decoration-none href=@{RegisterR}>Cadastre-se
    |]
  else
    redirect HomeR

postLoginR :: Handler Html
postLoginR = do
  user <- runInputPost $ Users <$> ireq textField "name" <*> ireq textField "password"
  userExists <- runDB (getBy $ UniqueName (usersName user))
  case userExists of
    Just (Entity userId userData) -> do
      let samePasswords = (usersPassword userData) == (usersPassword user)
      if samePasswords then do
        setSession "login" (usersName userData)
        redirect HomeR
      else
        redirect (LoginR, [("error", "Login inválido")])
    Nothing -> redirect (LoginR, [("error", "Login inválido")])
