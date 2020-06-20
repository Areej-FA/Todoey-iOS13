//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Areej on 3/3/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
     //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCatgory = categories[indexPath.row]
        }
    }
    
    //MARK: - Add new catgory
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategory()
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            
            textField = field
            textField.placeholder  = "Add new category"
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - save category
    func saveCategory() {
        do{
            try context.save()
        } catch {
            print(error)
        }
    }
    
    //MARK: - load catgories on the screen
    func loadCategories(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do{
            categories = try context.fetch(request)
        }catch{
            print(error)
        }
        tableView.reloadData()
    }

    
    
}
