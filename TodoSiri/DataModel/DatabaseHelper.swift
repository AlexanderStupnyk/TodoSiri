//
//  DatabaseHelper.swift
//  SiriNotes
//
//  Created by Steven Beyers on 6/14/17.
//  Copyright © 2017 Chariot. All rights reserved.
//

import UIKit
import CoreData
import Intents

class DatabaseHelper: NSObject {
    private static var instance = DatabaseHelper()
    class var shared: DatabaseHelper {
        get {
            return instance
        }
    }
    
    var categories = [Category]()
    var itemArray = [Item]()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        
        let appName: String = "TodoSiri"
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        let group = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alex.TodoSiri")
        let storeUrl =  group!.appendingPathComponent("TodoSiri.sqlite")
        
        
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.url = storeUrl
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url:  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.alex.TodoSiri")!.appendingPathComponent("TodoSiri.sqlite"))]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        let context = persistentContainer.viewContext
        do{
            categories = try context.fetch(request)
        }
        catch{
            print("Error fetching dta from context \(error)")
        }
    }
    
    func loadItems(categoryName: String, with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        let context = persistentContainer.viewContext
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }
        else{
            request.predicate = categoryPredicate
        }
        
        
        do{
            itemArray = try context.fetch(request)
        }
        catch{
            print("Error fetching dta from context \(error)")
        }
    }
    
    func saveItems(){
        let context = persistentContainer.viewContext
        do{
            try context.save()
        }
        catch{
            print("Error dsving context, \(error)")
        }
        
    }
    
    
    func createList(name: String) -> Category? {
        let context = persistentContainer.viewContext
        let newCategory = Category(context: context)
        newCategory.name = name
        do{
            try context.save()
            return newCategory
        }
        catch{
            print("Error sving context, \(error)")
        }
        return nil
    }
    
    func add(tasks: [String], toList listName: String) {
        loadCategories()
        print(categories)
        if let category = categories.first(where: {$0.name == listName}) {
            for taskName in tasks{
                let context = persistentContainer.viewContext
                let newItem = Item(context: context)
                newItem.title = taskName
                newItem.done = false
                newItem.parentCategory = category
                saveItems()
            }
        }
    }
    
}

