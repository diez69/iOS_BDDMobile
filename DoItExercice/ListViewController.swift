
import UIKit

class ListViewController: UIViewController {

    var items = ["Pain", "Lait", "Jambon", "Tomate", "Pomme","Jus","Eau","Poire","Aubergine", "Pizza"]
    var items2 = [Item]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredItem = [Item]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createItems()
        getItemsFromJson()
        
    }

    func getItemsFromJson() {
        do {
            let decoder = JSONDecoder()
            self.items2 = try decoder.decode(Array<Item>.self, from: Data(contentsOf : self.getDocumentsDirectory()))
            }
            catch {
                self.items = Array()
            }
            
    }
    func createItems() {
        for item in items {
            let newElement = Item(name : item)
            items2.append(newElement)
        }
    }

    @IBOutlet weak var tableView: UITableView!
    
    //Action : to edit mode
    @IBAction func editAction(_ sender: Any) {
        
        tableView.isEditing = !tableView.isEditing
        
    }
    
    //Action : TextField to add element
    @IBAction func addAction(_ sender: Any) {
        let alertController = UIAlertController(title:"DoIt", message: "New item", preferredStyle: .alert)
        let okAction = UIAlertAction(title :"Ok", style: .default) {
            (action) in
            let textField = alertController.textFields![0]
            let item = Item(name: textField.text!)
            self.items2.append(item)
            
            self.tableView.reloadData()
            self.saveData(self.items2)
            self.searchBar(self.searchBar, textDidChange: self.searchBar.text!)
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ListViewController : UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    //Number rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredItem.count
        }
        return items2.count
    }
    
    //Add element
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCellIdentifier")
        let item: Item
        if isFiltering() {
            item = filteredItem[indexPath.row]
        } else {
            item = items2[indexPath.row]
        }
        cell?.textLabel?.text = item.name
        cell?.accessoryType = (item.checked) ? .checkmark : .none
        return cell!
    }
    
    //Check a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items2[indexPath.row % items2.count]
        item.checked = !item.checked
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        saveData(self.items2)
    }
    
    //If one less element, can not edit
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return items2.count > 1
    }
    
    //Delete a row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            items2.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //Edit element
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceItem = items2.remove(at: sourceIndexPath.row)
        items2.insert(sourceItem, at: destinationIndexPath.row)
        
    }
    
    //Save items on Json file
    func saveData(_ item: [Item]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try? encoder.encode(item)
        try? data?.write(to: getDocumentsDirectory())
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent("items.json", isDirectory: false)
        print(documentsDirectory)
        return documentsDirectory
    }
    
    //SearchBar
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchBar.text?.isEmpty ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItem = items2.filter({( item : Item) -> Bool in
            return item.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
}
