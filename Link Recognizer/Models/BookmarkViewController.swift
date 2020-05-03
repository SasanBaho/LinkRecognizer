//
//  BookmarkViewController.swift
//  Link Recognizer
//
//  Created by Sasan Baho on 2020-04-26.
//  Copyright © 2020 Sasan Baho. All rights reserved.
//

import Foundation

import UIKit

class BookmarkViewController: UITableViewController {
    let k = Constants()
    let defaults = UserDefaults.standard
    var url : String?
    var bookmarks : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let items  = defaults.array(forKey: "bookmarkList") as? [String] {
            bookmarks = items
        }
    }

    func addToBookmark(url: String) {
        bookmarks.append(url)
        self.defaults.set(self.bookmarks, forKey: "bookmarkList")
        let insertionIndexPath = IndexPath(row: bookmarks.count - 1, section: 0)
        tableView.insertRows(at: [insertionIndexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return bookmarks.count
       }
       
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        cell.textLabel!.text = bookmarks[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: Notification.Name(k.tappedBookmarkUrl), object: self, userInfo: ["urlKey" : bookmarks[indexPath.row]])
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            bookmarks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.defaults.set(self.bookmarks, forKey: "bookmarkList")
        }
    }
    
    @IBAction func addBookmarkButton(_ sender: UIBarButtonItem) {
        addToBookmark(url: url!)
    }
    
    @IBAction func closeBookmarkButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion:    nil)
    }
}
