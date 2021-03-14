//
//  TaskListTableViewController.swift
//  TaskList
//
//  Created by Vladimir on 09/02/2021.
//  Copyright © 2021 Embler. All rights reserved.
//

import UIKit

class TaskListTableViewController: UITableViewController {

    //MARK: - Private Properties
    private let storageManager = StorageManager.shared
    private var taskList: [Task] = []
    private var alertViewController: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(with: TaskTableViewCell.self)
        tableView.tableFooterView = UIView()
        
        taskList = storageManager.getTasks()
    }
    
    // MARK: - Ovveride Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: TaskTableViewCell.self)
        cell.taskLabel.text = taskList[indexPath.row].text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskName = taskList[indexPath.row].text
        showAddEditView(isEdit: true, indexPath: indexPath, taskName: taskName)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            storageManager.removeTask(index: indexPath.row)
            taskList = storageManager.getTasks()
            tableView.reloadData()
        }
    }
    
    //MARK: - IB Actions
    @IBAction func addNewTaskBarButtonPresed(_ sender: UIBarButtonItem) {
        showAddEditView(isEdit: false, taskName: "")
    }

    //MARK: - Private Methods
    private func showAddEditView(isEdit: Bool, indexPath: IndexPath = [], taskName: String) {
        let taskName = taskName
        var alertTitle = ""
        var addEditButtonTitle = ""
        var editAddFunctionName: (Int? , String) -> Bool
        var indexPathRow: Int? = nil
        
        if isEdit {
            alertTitle = "Edit Task"
            addEditButtonTitle = "Edit"
            editAddFunctionName = storageManager.isTaskEdited
            indexPathRow = indexPath.row
        } else {
            editAddFunctionName = storageManager.isAddedTask
            alertTitle = "Add new Task"
            addEditButtonTitle = "Add"
        }
        
        alertViewController = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alertViewController.addTextField { (taskTextField) in
            taskTextField.placeholder = "Enter Task"
            taskTextField.text = taskName
            taskTextField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)),
                                    for: .editingChanged)
        }
        
        let taskAction = UIAlertAction(title: addEditButtonTitle, style: .cancel, handler: { _ in
            guard let taskName = self.alertViewController.textFields?.first?.text else { return }

            if editAddFunctionName(indexPathRow, taskName) {
                self.taskList = self.storageManager.getTasks()
                self.tableView.reloadData()
            } else {
                self.showDublicateAlert(isEdited: isEdit)
            }
        })
        taskAction.isEnabled = false
        
        alertViewController.addAction(taskAction)
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            self.alertViewController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertViewController, animated: true, completion: nil)
    }
    
    @objc private func alertTextFieldDidChange(_ sender: UITextField) {
        alertViewController.actions[0].isEnabled = sender.text!.count > 3
    }
    
    private func showDublicateAlert(isEdited: Bool) {
        var message = ""
        if isEdited {
            message = "Task already exist in Task"
        } else {
            message = "Id or Task already exit in Tasks"
        }
        let alert = UIAlertController(title: "Dublicate", message: message, preferredStyle: .alert)
        self.present(alert, animated: true) {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                alert.dismiss(animated: true) {
                    self.present(self.alertViewController, animated: true, completion: nil)
                }
            }
        }
    }
}
