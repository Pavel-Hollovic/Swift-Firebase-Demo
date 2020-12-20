//
//  TaskCellViewModel.swift
//  MakeItSo
//
//  Created by Pavel Hollovic on 22/11/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import Foundation
import Combine
import Resolver

//this ViewModel view with individual rows

class TaskCellViewModel: ObservableObject, Identifiable { //it has to be identifiable because SwiftUI requries that for list .(that is also why we have to implement id variable)
    
    @Published var taskRepository: TaskRepository = Resolver.resolve() //injecting task repository to use updateTask function
    
    @Published var task: Task //it is pabblished because of the annatontion changing id whenewer Task is changed
    
    
    
    var id: String = "" //it has to be change everytime the task is changed
    @Published var completionStateIconName = ""
    
    private var cancellables = Set<AnyCancellable>()// what is this? see it is referenced in task annotations
    
    static func newTask() -> TaskCellViewModel {
        TaskCellViewModel(task: Task(title: "", priority: .medium, completed: false))
    }
    
    init(task: Task) {
        self.task = task
        
        $task //updating name, and icon that represenst the completion status of the task by subscribing to task properity
            .map { $0.completed ? "checkmark.circle.fill" : "circle"} //maping its image to respective image name
            .assign (to: \.completionStateIconName, on: self)
            .store(in: &cancellables)
        
        $task //anottation to task making sure that the task will change id whenewer is changed
            .compactMap { $0.id} //Important we adde here compactMap insted of map because of fireSore (probably see Task Repository)
            .assign(to: \.id, on:self)
            .store(in: &cancellables)
        
        $task // this
          .dropFirst()
          .debounce(for: 0.8, scheduler: RunLoop.main)
          .sink { [weak self] task in
            self?.taskRepository.updateTask(task)
          }
          .store(in: &cancellables)
    }
}
