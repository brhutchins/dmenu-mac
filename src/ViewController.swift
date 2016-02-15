//
//  Created by Jose Pereira on 2/14/16.
//  Copyright © 2016 Jose Pereira. All rights reserved.
//

import Foundation
import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet private var searchText: NSTextField!
    @IBOutlet private var resultsText: NSTextField!
    
    var appList = [NSURL]()
    var appNameList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchText.delegate = self;
        
        let appDir = NSSearchPathForDirectoriesInDomains(
            .ApplicationDirectory, .LocalDomainMask, true)[0]
        
        appList = getAppList(NSURL(fileURLWithPath: appDir, isDirectory: true))
        
        for app in appList {
            let appName = (app.URLByDeletingPathExtension?.lastPathComponent)
            appNameList.append(appName!)
        }
    }
    
    func getAppList(appDir: NSURL) -> [NSURL] {
        var list = [NSURL]()
        let fileManager = NSFileManager.defaultManager()
        
        do {
            let subs = try fileManager.contentsOfDirectoryAtPath(appDir.path!)
            let totalFiles = subs.count
            
            print(totalFiles)
            for sub in subs {
                let dir = appDir.URLByAppendingPathComponent(sub)
                
                if dir.pathExtension == "app" {
                    print("APP: \(sub)");
                    list.append(dir);
                } else if (dir.hasDirectoryPath) {
                    print("DIR enter!: \(dir.absoluteString)");
                    list.appendContentsOf(self.getAppList(dir))
                } else {
                    print("NOAPP NODIR \(dir)")
                }
            }
        } catch _ {
            NSLog("ERROR")
        }
        return list
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        let list = self.getFuzzyList()
            .map {($0.URLByDeletingPathExtension?.lastPathComponent)!}
        
        self.resultsText.stringValue = (list).joinWithSeparator("  ")
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        let list = self.getFuzzyList()
        print(list.first?.absoluteString)
        
        if let a = list.first {
            NSWorkspace.sharedWorkspace().launchApplication(a.path!)
        }
        
        self.searchText.stringValue = ""
        self.resultsText.stringValue = ""
    }
    
    func getFuzzyList() -> [NSURL] {
        var scoreDict = [NSURL: Double]()
        
        for app in appList {
            let appName = (app.URLByDeletingPathExtension?.lastPathComponent)
            
            let score = FuzzySearch.score(
                originalString: appName!, stringToMatch: self.searchText.stringValue)
            
            if score > 0 {
                scoreDict[app] = score
            }
        }
        
        let resultsList = scoreDict
            .sort({$0.1 > $1.1}).map({$0.0})
        return resultsList
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

