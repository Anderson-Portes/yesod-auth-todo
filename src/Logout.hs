{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
module Logout where

import Foundation
import Yesod.Core

getLogoutR :: Handler Html
getLogoutR = do
  deleteSession "login"
  redirect LoginR