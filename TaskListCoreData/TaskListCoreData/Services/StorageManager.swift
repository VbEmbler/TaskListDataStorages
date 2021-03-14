//
//  DataManager.swift
//  TaskList
//
//  Created by Vladimir on 03/03/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
    
    //MARK: - Public Propertied
    static let shared = StorageManager()
    
    //MARK: - Private Properties
    private let entityName = "Task"
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: - Initializers
    private init() {}
    
    //MARK: - Public Methods
    public func isAddedTask(_ taskId: Int? = nil, _ taskName: String) -> Bool {
        let id = Int.random(in: 0...100)
        let taskList = getTasks()
        
        for task in taskList {
            if task.id == id || task.text == taskName {
                return false
            }
        }
        
        saveData(taskId: id, taskName: taskName)
        return true
    }
    
    public func getTasks() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
            return []
        }
    }
    
    public func removeTask(task: Task) {
        viewContext.delete(task)
        saveContext()
    }
    
    public func isTaskEdited(_ taskId: Int?, _ newTaskName: String) -> Bool {
        let taskList = getTasks()
        for task in taskList {
            if task.text == newTaskName {
                return false
            }
        }
        
        guard let taskId = taskId else { return false }
        let task = taskList[taskId]
        task.text = newTaskName
        saveContext()
        return true
    }
    
    // MARK: - Core Data Saving support
    public func saveContext () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - Private Properties
    private func saveData(taskId: Int, taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: viewContext) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Task else { return }
        task.id = Int64(taskId)
        task.text = taskName
        saveContext()
    }
}
