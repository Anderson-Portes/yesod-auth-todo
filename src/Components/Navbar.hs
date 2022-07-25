{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
module Components.Navbar where

import Foundation
import Yesod.Core

navbar :: Widget
navbar = 
  [whamlet|
    <nav .navbar.navbar-expand-lg.border-bottom.shadow-sm>
      <div .container>
        <a .navbar-brand href=@{HomeR}>Home
        <button .navbar-toggler type=button data-bs-toggle=collapse data-bs-target=#navbar aria-controls=navbar aria-expanded=false aria-label="Toggle navigation">
          <span .navbar-toggler-icon>
        <div .collapse.navbar-collapse.justify-content-end #navbar>
          <ul .navbar-nav>
            <li .nav-item>
              <a .nav-link.text-danger href=@{LogoutR} #logout-link>Sair
  |]