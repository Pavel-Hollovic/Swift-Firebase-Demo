//
//  TaskRepository.swift
//  MakeItSo
//
//  Created by Pavel Hollovic on 22/11/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//


//note: this repository is accesed from two views. This migh create usynchronization of data. Therfore we could make the reepository SINGLETON.
//BUT we wiil use different approach here: DEPENDENCY INJECTION - it gives some benefits. We need to import framework "Resolver" which is added throuch CocoaPods


import Foundation
import Disk

import Resolver
import Combine

import FirebaseFirestore
import Firebase
import FirebaseFirestoreSwift

class BaseTaskRepository {
    @Published var tasks = [Task]() // array tasks of tasks holding all tasks :D // it is published so clients can easly subscrime update any time
}

protocol TaskRepository: BaseTaskRepository { //this is protocol which defines methods to be used (add, remove, update)
    func addTask(_ task: Task)
    func removeTask(_ task: Task)
    func updateTask(_ task: Task)
}

class TestDataTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject { //this is initializer //inheriting from class and protocol above
    override init() {
        super.init()
        self.tasks = testDataTasks //here we fetch the test data from model
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func removeTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: index)
        }
    }
    
    func updateTask(_ task: Task) {
        if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
            self.tasks[index] = task
        }
    }
}


//local reprository by Disk framework which I imported through CocoaPods
class LocalTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
  override init() {
    super.init()
    loadData()
  }
  
  func addTask(_ task: Task) {
    self.tasks.append(task)
    saveData()
  }
  
  func removeTask(_ task: Task) {
    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
      tasks.remove(at: index)
      saveData()
    }
  }
  
  func updateTask(_ task: Task) {
    if let index = self.tasks.firstIndex(where: { $0.id == task.id } ) {
      self.tasks[index] = task
      saveData()
    }
  }
  
  private func loadData() {
    if let retrievedTasks = try? Disk.retrieve("task.json", from: .documents, as: [Task].self) { // (1)
      self.tasks = retrievedTasks
    }
  }
  
  private func saveData() {
    do {
      try Disk.save(self.tasks, to: .documents, as: "tasks.json") // (2)
    }
    catch let error as NSError {
      fatalError("""
        Domain: \(error.domain)
        Code: \(error.code)
        Description: \(error.localizedDescription)
        Failure Reason: \(error.localizedFailureReason ?? "")
        Suggestions: \(error.localizedRecoverySuggestion ?? "")
        """)
    }
  }
}



class FirestoreTaskRepository: BaseTaskRepository, TaskRepository, ObservableObject {
  var db = Firestore.firestore() // Reference to global FireBase instance
  
    @Published var authenticationService: AuthenticationService = Resolver.resolve()

  var tasksPath: String = "tasks"
  var userId: String = "unknown"
  
  private var cancellables = Set<AnyCancellable>()
  
  override init() {
    super.init()
    //loadData() this is moved under authentication
    
    authenticationService.$user //monitor whenewer user changes
      .compactMap { user in
        user?.uid  //extract user id
      }
      .assign(to: \.userId, on: self) //assign the user id to the class
      .store(in: &cancellables) //what is this for?
    
    // (re)load data if user changes
    authenticationService.$user //monitor whenewer user changes
      .receive(on: DispatchQueue.main) // this is making sure any update is on main thread (pipline) this tells Combine to run it on specific thred/qeue
      .sink { user in
        self.loadData() // if user chages this will kick in and the data will reload
      }
      .store(in: &cancellables)
  }
  
  private func loadData() {
    db.collection(tasksPath)
      .whereField("userId", isEqualTo: self.userId) //IMPORTANT this defines that only data of current user will be fetch in the load
      .order(by: "createdTime")
      .addSnapshotListener { (querySnapshot, error) in // snapshosts ensuring that data will update on every device automaticaly
        // ordred by created time because we want to have tasks orderd chronologicaly not according to random ID
        if let querySnapshot = querySnapshot {
          self.tasks = querySnapshot.documents.compactMap { document -> Task? in // puting into tasks the collection of all the document that are a result of the query (we did not specyfy anything so we have all tasks in collection) thaks to QuerySnapshot
            try? document.data(as: Task.self) // Converting DocumentSnapshot itno a Task
          }
        }
      }
  }
  
  func addTask(_ task: Task) {
    do {
      var userTask = task
      userTask.userId = self.userId //this will assign user ID to new task
      let _ = try db.collection(tasksPath).addDocument(from: userTask) //to the Local tasks is added automaticaly thank to the call from snapshot listener we registered on the tasks
    }
    catch {
      fatalError("Unable to encode task: \(error.localizedDescription).")
    }
  }
  
  func removeTask(_ task: Task) {
    if let taskID = task.id {
      db.collection(tasksPath).document(taskID).delete { (error) in // we first build reference to the document, using the collection path (tasks) and the document ID. Then we use Delet() on the document reference
        if let error = error {
          print("Unable to remove document: \(error.localizedDescription)")
        }
      }
    }
  }
  
  func updateTask(_ task: Task) {
    if let taskID = task.id {
      do {
        try db.collection(tasksPath).document(taskID).setData(from: task) // setData(from:) to update document in FireStore
      }
      catch {
        fatalError("Unable to encode task: \(error.localizedDescription).")
      }
    }
  }
}
