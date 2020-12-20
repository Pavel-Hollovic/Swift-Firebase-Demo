//
//  Task.swift
//  MakeItSo
//
//  Created by Pavel Hollovic on 12/11/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift //this ensusures support for Codable


enum TaskPriority: Int, Codable { //enum groups related values, in swift you dont have to asign value to each of them
    //Importatnt adding Codale to make TaskRepository Save and Load Function work!
    case high
    case medium
    case low
}

struct Task: Codable, Identifiable { //this is model of Task we will reference this model throught the whole code (Struct (and Classes) are automaticaly aviable in ohter part of code), Struct is complete data type (can be insereted to classses and applied to varibles)
    //Importatnt adding Codale to make TaskRepository Save and Load Function work!
    @DocumentID var id: String? //DocumentID property wrapper tells Firebase to map this property when decoding the document
    //var id: String = UUID().uuidString - used withot firebase
    var title: String
    var priority: TaskPriority
    var completed: Bool
    @ServerTimestamp var createdTime: Timestamp? //Firestore will write time here when writing on the serever
    var userId: String? //addition which is determinating which user is able to see the task
}

#if DEBUG
let testDataTasks = [ //let varable that is not going to change
    Task(title: "Implement UI", priority: .medium, completed: false),
    Task(title: "Connect to Firebase", priority: .medium, completed: false),
    Task(title: "Write report", priority: .high, completed: false),
    Task(title: "Finish Project", priority: .high, completed: false)
]

#endif
