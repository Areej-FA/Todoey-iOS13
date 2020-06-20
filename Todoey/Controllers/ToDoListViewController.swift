//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController{
    
    var itemArray = [Item]()
    
    var selectedCatgory : Category? {
        didSet{
           loadItems()
        }
    }
     
    let defaults = UserDefaults.standard
    
    
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
     //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: -chack item
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: -Add new item
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
           
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCatgory
            self.itemArray.append(newItem)
            
            self.saveItems()
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertText) in
            
            alertText.placeholder = "create new item"
            textField = alertText
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveItems() {
        do{
            try context.save()
        } catch {
          print(error)
        }
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicte : NSPredicate? = nil) {
        
        let catgoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCatgory!.name!)
        
        if let addtionalPredicate = predicte{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [catgoryPredicate, addtionalPredicate])
        }else{
            request.predicate = catgoryPredicate
        }
        
        do{
        itemArray = try context.fetch(request)
        }catch{
            print(error)
        }
        
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate
extension ToDoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let  predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate

        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicte: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
