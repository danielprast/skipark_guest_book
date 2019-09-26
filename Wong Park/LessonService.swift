//
//  LessonService.swift
//  Wong Park
//
//  Created by Daniel Prastiwa on 29/07/19.
//  Copyright © 2019 Kipacraft. All rights reserved.
//

import Foundation
import CoreData


enum LessonType: String {
    case ski, snowboard
}


typealias StudentHandler = (Bool, [Student]) -> ()


class LessonService {
    
    
    private let moc: NSManagedObjectContext
    private var students = [Student]()
    private var lessons = [Lesson]()
    
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    
    // MARK: CREATE
    func addStudent(name: String, for type: LessonType, completion: StudentHandler) {
        let student = Student(context: moc)
        student.name = name
        
        if let lesson = lessonExists(type) {
            register(student, for: lesson)
            students.append(student)
            
            completion(true, students)
        }
        
        save()
    }
    
    
    private func register(_ student: Student, for lesson: Lesson) {
        student.lesson = lesson
    }
    
    
    private func lessonExists(_ type: LessonType) -> Lesson? {
        let request: NSFetchRequest<Lesson> = Lesson.fetchRequest()
        request.predicate = NSPredicate(format: "type = %@", type.rawValue)
        
        var lesson: Lesson?
        
        do {
            let result = try moc.fetch(request)
            lesson = result.isEmpty ? addNew(lesson: type) : result.first
        } catch let err as NSError {
            print("Error getting lesson: \(err.localizedDescription)")
        }
        
        return lesson
    }
    
    
    func addNew(lesson type: LessonType) -> Lesson {
        let lesson = Lesson(context: moc)
        lesson.type = type.rawValue
        return lesson
    }
    
    
    //MARK: READ
    func getAllStudents() -> [Student]? {
        let sortByLesson = NSSortDescriptor(key: "lesson.type", ascending: true)
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortByLesson, sortByName]
        
        let request: NSFetchRequest<Student> = Student.fetchRequest()
        request.sortDescriptors = sortDescriptors
        
        do {
            students = try moc.fetch(request)
            return students
        } catch let err as NSError {
            print("Failed to fetch students: \(err.localizedDescription)")
        }
        
        return nil
    }
    
    
    func getAvailableLesson() -> [Lesson]? {
        let sortByLesson = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptors = [sortByLesson]
        
        let request: NSFetchRequest<Lesson> = Lesson.fetchRequest()
        request.sortDescriptors = sortDescriptors
        
        do {
            lessons = try moc.fetch(request)
            return lessons
        }
        catch let error as NSError {
            print("Error fetching lessons: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    
    //MARK: UPDATE
    func update(current student: Student, with name: String, for lesson: String) {
        // Check if student current lesson == new lesson type
        if student.lesson?.type?.caseInsensitiveCompare(lesson) == .orderedSame {
            let lesson = student.lesson
            let studentList = Array(lesson?.students?.mutableCopy() as! NSSet)
                as! [Student]
            
            if let index = studentList.firstIndex(where: {$0 == student}) {
                studentList[index].name = name
                lesson?.students = NSSet(array: studentList)
            }
        }
        else {
            if let lesson = lessonExists(LessonType(rawValue: lesson)!) {
                lesson.removeFromStudents(student)
                
                student.name = name
                register(student, for: lesson)
            }
        }
        
        save()
    }
    
    
    //MARK: DELETE
    func delete(student: Student) {
        let lesson = student.lesson
        
        students = students.filter { $0 != student }
        lesson?.removeFromStudents(student)
        
        moc.delete(student)
        save()
    }
    
    
    // MARK: MOC
    private func save() {
        do {
            try moc.save()
        } catch let err as NSError {
            print("Save failed: \(err.localizedDescription)")
        }
    }
    
    
    
}
