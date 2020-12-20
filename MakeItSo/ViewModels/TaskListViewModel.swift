//
//  TaskListViewModel.swift
//  MakeItSo
//
//  Created by Pavel Hollovic on 12/11/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import Foundation
import Combine
import Resolver

class TaskListViewModel: ObservableObject {//Observable object means that the object will change = UI will react faster to changes
    @Published var taskRepository: TaskRepository = Resolver.resolve() //using resolver to call task Repository just like normal property
    @Published var taskCellViewModels = [TaskCellViewModel]() //this contains the models of cell. It is publish so we can bind Task List view to it
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
      taskRepository.$tasks.map { tasks in
        tasks.map { task in
          TaskCellViewModel(task: task)
        }
      }
      .assign(to: \.taskCellViewModels, on: self)
      .store(in: &cancellables)
    }

    func removeTasks(atOffsets indexSet: IndexSet) {
      // remove from repo
      let viewModels = indexSet.lazy.map { self.taskCellViewModels[$0] }
      viewModels.forEach { taskCellViewModel in
        taskRepository.removeTask(taskCellViewModel.task) // (1)
      }
    }
    
    func addTask(task: Task) {
      taskRepository.addTask(task)
    }
  }
