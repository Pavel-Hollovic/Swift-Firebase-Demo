//
//  AppDelegate+Resolving.swift
//  MakeItSo
//
//  Created by Pavel Hollovic on 22/11/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import Foundation
import Resolver

import FirebaseFirestore

extension Resolver: ResolverRegistering {  //TastDataTaskRepository is injected it whenewer TaskRepository instance is required
  public static func registerAllServices() {
    register { AuthenticationService() }.scope(application) //we registrate authentication to make things easier by injection
    register { FirestoreTaskRepository() as TaskRepository }.scope(application) // only change this to change repository for whole application
  }
}
