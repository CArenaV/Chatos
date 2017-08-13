//
//  ContactsVC.swift
//  Chattos
//
//  Created by Shalabh  Soni on 8/11/17.
//  Copyright © 2017 Shalabh  Soni. All rights reserved.
//

import Foundation
import Contacts
import UIKit
import SwiftyBeaver

class ContactsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating{
    
    //@IBOutlet weak var searchController: UISearchBar!
    var searchController:UISearchController!;
    var sections : Dictionary<String,[String]>!
    var contactsSortedAr = [String]()
    var filteredContactsSortedAr = [String]()
    @IBOutlet weak var tableViewCell: UITableViewCell!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied || status == .restricted {
            presentSettingsActionSheet()
            return
        }
        
        let store = CNContactStore()
        var contacts = [CNContact]()
        let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey as NSString, CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
        do {
            try store.enumerateContacts(with: request) { contact, stop in
                contacts.append(contact)
            }
        } catch {
            print(error)
        }
        
        // do something with the contacts array (e.g. print the names)
        searchController = UISearchController(searchResultsController: nil)
        
        
        createSections(contacts: contacts)
        
        // filteredContactsSortedAr = contactsSortedAr
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    
    
    
    func createSections(contacts: [CNContact]){
        var nameAr =  [String]()
        for contact in contacts{
            let name = contact.givenName
            let lName = contact.familyName
            nameAr.append("\(name)|\(lName)")
            
        }
        contactsSortedAr = nameAr.sorted { $0 < $1 }
        createIndex(contactsAr: nameAr)
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        // If we haven't typed anything into the search bar then do not filter the results
        if searchController.searchBar.text! == "" {
            filteredContactsSortedAr = contactsSortedAr
        } else {
            SwiftyBeaver.info(searchController.searchBar.text)
            // Filter the results
            filteredContactsSortedAr = contactsSortedAr.filter { $0.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        
        
        createIndex(contactsAr: filteredContactsSortedAr)
        SwiftyBeaver.error(filteredContactsSortedAr)
        self.tableView.reloadData()
    }
    
    
    
    func createIndex(contactsAr: [String]){
        var index = 0
        sections = Dictionary<String,[String]>()
        filteredContactsSortedAr = contactsAr.sorted { $0 < $1 }
        SwiftyBeaver.info(filteredContactsSortedAr)
        for i in 0..<filteredContactsSortedAr.count{
            var startAlphabet = String(filteredContactsSortedAr[i].characters.prefix(1))
            startAlphabet = startAlphabet.capitalized
            if sections[startAlphabet] == nil{
                sections[startAlphabet] = [filteredContactsSortedAr[i]]
            }else{
                var arE = sections[startAlphabet]
                arE?.append(filteredContactsSortedAr[i])
                sections.updateValue(arE!, forKey: startAlphabet)
            }
        }
    }
    
    
    
    func presentSettingsActionSheet() {
        let alert = UIAlertController(title: "Permission to Contacts", message: "This app needs access to contacts in order to ...", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        SwiftyBeaver.info(sections.count)
        return sections.count
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var x = sections.keys.sorted()[section]
        return (sections[x]?.count)!
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath);
        var x = sections[(sections.keys.sorted())[indexPath.section]]
        
        
        //  var itm = Array(sections.values)[indexPath.section].index
        // SwiftyBeaver.info(Array(sections.values)[[indexPath.section].index + indexPath.row)]
        //        SwiftyBeaver.info(indexPath.row)
        let fName = x?[indexPath.row].components(separatedBy: "|")[0]
        var lName = x?[indexPath.row].components(separatedBy: "|")[1]
        
        var attributedString = NSMutableAttributedString(string: "\(fName!) ")
        var attrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 15)]
        var boldString = NSMutableAttributedString(string:lName!, attributes:attrs)
        
        attributedString.append(boldString)
        
        
        
        cell.textLabel?.attributedText = attributedString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(sections.keys.sorted())[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Array(sections.keys.sorted())
        
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
}
