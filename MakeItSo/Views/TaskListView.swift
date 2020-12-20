//
//  ContentView.swift
//  MakeItSo
//
//  Created by Peter Friese on 10/01/2020.
//  Copyright © 2020 Google LLC. All rights reserved.
//

import SwiftUI


//LIST

struct TaskListView: View {
  @ObservedObject var taskListVM = TaskListViewModel() //Cooncting to ViewModel, we have to use observedObject to bidnd list to its property taskCellViewsmodels
    @State var presentAddNewItem = false
  
  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        List {
            ForEach (taskListVM.taskCellViewModels) { taskCellVM in
                TaskCell(taskCellVM: taskCellVM) // we are using task cell View model to render task cells in the list
          }
          .onDelete { indexSet in
            self.taskListVM.removeTasks(atOffsets: indexSet)
          }
            if presentAddNewItem {  //logic for adding new item to list //this is a flag guarding whole block to be visible and aviable anytime user taps "new task button"
                TaskCell(taskCellVM: TaskCellViewModel.newTask()) { result in
                    if case .success(let task) = result {    //this is trailing closure that recives result
                        self.taskListVM.addTask(task: task) //If the result is success we extract Task from the resulst in order to add new TaskCellViewModel
                            // any ohter cases are ignored (specificly "empty" when user does not input new text)
                    }
                    self.presentAddNewItem.toggle() //any othe cases
                } //enitre block is in list so it will add empty cell whenver we click on new task button:)
            }
        }
        Button(action: { self.presentAddNewItem.toggle() }) { //This is describing the add buttom at the bottom.
          HStack {
            Image(systemName: "plus.circle.fill")
              .resizable()
              .frame(width: 20, height: 20)
            Text("New Task")
          }
        }
        .padding()
        .accentColor(Color(UIColor.systemRed))
      }
      .navigationBarTitle("Tasks")
    }
  }
}



struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}



//CELL

struct TaskCell: View {
  @ObservedObject var taskCellVM: TaskCellViewModel // we are connecting TaskCell to its View Model
  var onCommit: (Result<Task, InputError>) -> Void = { _ in } //
  
  var body: some View {
    HStack {
      Image(systemName: taskCellVM.completionStateIconName) //This is now connected to VM to see the completation icon name
        .resizable()
        .frame(width: 20, height: 20)
        .onTapGesture {
          self.taskCellVM.task.completed.toggle()
        }
      TextField("Enter task title", text: $taskCellVM.task.title, // Text field enables us to write into every cell and edit name
                onCommit: { // onCommit is required here becuase we want add new task only when user taps on newTask
                  if !self.taskCellVM.task.title.isEmpty {
                    self.onCommit(.success(self.taskCellVM.task))
                  }
                  else {
                    self.onCommit(.failure(.empty))
                  }
      }).id(taskCellVM.id)
    }
  }
}

enum InputError: Error {
  case empty
}
