//
//  File.swift
//  MakeItSo
//
//  Created by Pavel Hollovic on 17.12.2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import Foundation
import Firebase
import AuthenticationServices


class AuthenticationService: ObservableObject {
  
  @Published var user: User? // This published property provides access to inforamtion which user is currently log in
  
  func signIn() { // when this is called
    registerStateListener() // we call this method to monitor state when he sign in or out
    Auth.auth().signInAnonymously() // This ask firebase to sing in the user anonymously
  }
  
  private func registerStateListener() {
    Auth.auth().addStateDidChangeListener { (auth, user) in // This monitor if the user is log in
      print("Sign in state has changed.")
      self.user = user
      
      if let user = user {
        let anonymous = user.isAnonymous ? "anonymously " : ""
        print("User signed in \(anonymous)with user ID \(user.uid).")
      }
      else {
        print("User signed out.")
      }
    }
  }
  
}

