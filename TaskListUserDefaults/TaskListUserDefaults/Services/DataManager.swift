//
//  DataManager.swift
//  TaskList
//
//  Created by Vladimir on 03/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation

class DataManager {
    
    //MARK: - Public Propertied
    static let shared = DataManager()
    public var tasks: [Task] = [Task(id: 1, text: "First"),
                                Task(id: 8, text: "Test"),
                                Task(id: 15, text: "AnyTask")]
    
    //MARK: - Initializers
    private init() {}
    
    
    //MARK: - Public Methods
    public func isAddedTask(_ taskId: Int? = nil, _ taskName: String) -> Bool {
        let id = Int.random(in: 0...100)
        for task in tasks {
            if task.id == id || task.text == taskName {
                return false
            }
        }
        tasks.append(Task(id: id, text: taskName))
        return true
    }
    
    public func removeTask(id: Int) {
        tasks.remove(at: id)
    }
    
    public func isTaskEdited(_ taskId: Int?, _ newTaskName: String) -> Bool {
        for task in tasks {
            if task.text == newTaskName {
                return false
            }
        }
        guard let taskId = taskId else { return false }
        tasks[taskId].text = newTaskName
        return true
    }
}
