//
//  WongListVC.swift
//  Wong Park
//
//  Created by Daniel Prastiwa on 24/07/19.
//  Copyright © 2019 Kipacraft. All rights reserved.
//

import UIKit
import CoreData

class WongListVC: UITableViewController {
    
    var moc: NSManagedObjectContext? {
        didSet {
            if let moc = moc {
                lessonService = LessonService(moc: moc)
            }
        }
    }
    
    private var lessonService: LessonService?
    private let cellId = "cellId"
    private var students = [Student]()
    private var studentToUpdate: Student?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navControl = self.navigationController {
            navControl.navigationBar.prefersLargeTitles = true
            navigationItem.title = "Wong Park"
            
            let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButton))
            navigationItem.rightBarButtonItem = addBarButton
        }
        
        tableView.register(WongListTableViewCell.self, forCellReuseIdentifier: cellId)
        
        loadStudents()
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! WongListTableViewCell
        cell.textLabel?.text = students[indexPath.row].name
        cell.detailTextLabel?.text = students[indexPath.row].lesson?.type
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        studentToUpdate = students[indexPath.row]
        present(alertController(actionType: "update"), animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            lessonService?.delete(student: students[indexPath.row])
            students.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        
        //tableView.reloadData()
    }
    
    
    // MARK: - UI
    func alertController(actionType: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Wong Park Lesson",
                                                message: "Student Info",
                                                preferredStyle: .alert)
        
        alertController.addTextField { [weak self] (textField: UITextField) in
            textField.placeholder = "Name"
            textField.text = self?.studentToUpdate == nil ? "" : self?.studentToUpdate?.name
        }
        
        alertController.addTextField { [weak self] (textField: UITextField) in
            textField.placeholder = "Lesson Type: Ski | Snowboard"
            textField.text = self?.studentToUpdate?.lesson?.type ?? ""
        }
        
        let defaultAction = UIAlertAction(title: actionType.uppercased(),
                                          style: .default,
                                          handler: addStudentActionHandler(actionType, alertController))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [weak self] (action) in
            self?.studentToUpdate = nil
        }
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    
    private func addStudentActionHandler(_ actionType: String,
                                         _ alertController: UIAlertController) -> ((UIAlertAction) -> ()) {
        return { [weak self] action in
            guard
                let studentName = alertController.textFields?[0].text,
                let lesson = alertController.textFields?[1].text
                else { return }
            
            if actionType.caseInsensitiveCompare("add") == .orderedSame {
                if let lessonType = LessonType(rawValue: lesson.lowercased()) {
                    self?.lessonService?.addStudent(name: studentName,
                                                    for: lessonType)
                    { isSuccess, studentList in
                        if isSuccess {
                            self?.students = studentList
                        }
                    }
                }
            }
            else {
                guard let name = alertController.textFields?.first?.text, !name.isEmpty,
                    let studentToUpdate = self?.studentToUpdate,
                    let lessonType = alertController.textFields?[1].text
                    else { return }
                
                self?.lessonService?.update(current: studentToUpdate, with: name, for: lessonType)
                self?.studentToUpdate = nil
            }
            
            DispatchQueue.main.async {
                self?.loadStudents()
            }
            
        }
    }
    
    
    private func loadStudents() {
        if let studentList = lessonService?.getAllStudents() {
            students = studentList
            tableView.reloadData()
        }
    }
    
    
    
}
