//
//  DataManager.swift
//  TaskList
//
//  Created by Vladimir on 03/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation

import KeychainSwift

class KeychainManager {
    
    //MARK: - Public Propertied
    static let shared = KeychainManager()

    //MARK: - Private Properties
    private let keychainSwift = KeychainSwift()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let taskKey = "tasks"
    
    
    //MARK: - Initializers
    private init() {}
    
    //MARK: - Public Methods
    public func isAddedTask(_ taskId: Int? = nil, _ taskName: String) -> Bool {
        let id = Int.random(in: 0...100)
        var taskList = getTasks()
        
        for task in taskList {
            if task.id == id || task.text == taskName {
                return false
            }
        }
        
        let task = Task(id: id, text: taskName)
        taskList.append(task)
        saveData(for: taskList)

        return true
    }
    
    public func getTasks() -> [Task] {
        var taskList: [Task] = []
        
        if let tasksData = keychainSwift.getData(taskKey), let tasks = try? decoder.decode([Task].self, from: tasksData) {
            taskList = tasks
        }
        
        return taskList
    }
    
    public func removeTask(index: Int) {
        var taskList = getTasks()
        taskList.remove(at: index)
        saveData(for: taskList)
    }
    
    public func isTaskEdited(_ taskId: Int?, _ newTaskName: String) -> Bool {
        var taskList = getTasks()
        
        for task in taskList {
            if task.text == newTaskName {
                return false
            }
        }
        
        guard let taskId = taskId else { return false }
        taskList[taskId].text = newTaskName
        saveData(for: taskList)
        return true
    }
    
    //MARK: - Private Properties
    private func saveData(for taskList: [Task]) {
        if let tasksData = try? encoder.encode(taskList) {
            keychainSwift.set(tasksData, forKey: taskKey)
        }
    }
}
