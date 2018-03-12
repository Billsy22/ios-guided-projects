//
//  ContactsTableViewController.swift
//  AddressBook
//
//  Created by Andrew Madsen on 3/6/18.
//  Copyright © 2018 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
	
	// MARK: Overridden
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
		tableView.refreshControl = refreshControl
		
		fetchedResultsController.delegate = self
		do {
			try fetchedResultsController.performFetch()
		} catch {
			NSLog("Error starting fetched results controller: \(error)")
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "AddContact" {
			let detailVC = segue.destination as! ContactDetailViewController
			detailVC.contact = ContactsController.shared.createNewContact()
			detailVC.setEditing(true, animated: false) // Start in edit mode
		}
		
		if segue.identifier == "ShowContactDetail" {
			let detailVC = segue.destination as! ContactDetailViewController
			guard let cell = sender as? UITableViewCell,
				let indexPath = tableView.indexPath(for: cell) else { return }
			
			detailVC.contact = fetchedResultsController.object(at: indexPath)
		}
	}
	
	// MARK: Public Methods
	
	// MARK: Actions
	
	@IBAction func refresh(_ sender: UIRefreshControl) {
		let controller = ContactsController.shared
		controller.syncAllContacts { (error) in
			
			defer {
				DispatchQueue.main.async {
					sender.endRefreshing()
				}
			}
			
			if let error = error {
				NSLog("Error syncing contacts: \(error)")
				return
			}
		}
	}
	
	// MARK: UITableViewDelegate/DataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections?[section]
		return sectionInfo?.numberOfObjects ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
		
		let contact = fetchedResultsController.object(at: indexPath)
		cell.textLabel?.text = contact.fullName
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let contact = fetchedResultsController.object(at: indexPath)
			contact.managedObjectContext?.delete(contact)
		}
	}
	
	// MARK: NSFetchedResultsControllerDelegate
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert:
			tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
		case .delete:
			tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
		default: // Only .insert and .delete are valid
			break
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { break }
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		case .delete:
			guard let indexPath = indexPath else { break }
			tableView.deleteRows(at: [indexPath], with: .automatic)
		case .move:
			guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { break }
			tableView.moveRow(at: oldIndexPath, to: newIndexPath)
		case .update:
			guard let indexPath = indexPath else { break }
			tableView.reloadRows(at: [indexPath], with: .automatic)
		}
	}
	
	// MARK: Private Methods
	
	// MARK: Public Properties
	
	// MARK: Private Properties
	
	private let fetchedResultsController: NSFetchedResultsController<Contact> = {
		let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
		
		return NSFetchedResultsController(fetchRequest: fetchRequest,
										  managedObjectContext: Database.shared.mainContext,
										  sectionNameKeyPath: "firstLetterOfLastName",
										  cacheName: nil)
	}()
	
	// MARK: Outlets
}
