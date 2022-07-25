{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
module Components.Navbar where

import Foundation
import Yesod.Core
import Yesod.Static

navbar :: Widget
navbar = 
  [whamlet|
    <nav .navbar.navbar-expand-lg.border-bottom.shadow-sm>
      <div .container>
        <a .navbar-brand href=@{HomeR}>
          <img src=@{StaticR logo_png} height=30 width=30>
        <button .navbar-toggler type=button data-bs-toggle=collapse data-bs-target=#navbar aria-controls=navbar aria-expanded=false aria-label="Toggle navigation">
          <span .navbar-toggler-icon>
        <div .collapse.navbar-collapse.justify-content-end #navbar>
          <ul .navbar-nav>
            <li .nav-item>
              <a .nav-link.text-danger href=@{LogoutR} #logout-link>Sair
  |]