//
//  ReceiveClipsController.swift
//  VideoConcat
//
//  Created by Michael Frain on 3/24/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

class ReceiveClipsController: UIViewController {
    @IBOutlet weak var tableClips: UITableView!
    @IBOutlet weak var textServerName: UITextField!
    @IBOutlet weak var labelDownloadStatus: UILabel!
    
    var decodedArray: Array<String> = []
    var indexArray: Array<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func pullClipList(sender: UIButton!) {
        let startDate = NSDate()
        labelDownloadStatus.text = "Status: Downloading Clips"
        Alamofire.request(.GET, "http://\(textServerName.text)/allclips")
            .response { (request, response, data, error) in
            self.decodedArray = NSKeyedUnarchiver.unarchiveObjectWithData(data! as NSData) as Array<String>
            self.tableClips.reloadData()
            let interval = startDate.timeIntervalSinceDate(NSDate()) * -1
            self.labelDownloadStatus.text = "Status: Clips Downloaded in \(interval) seconds"
        }
    }
    
    @IBAction func downloadSelectedClips(sender: UIButton!) {
        let startDate = NSDate()
        labelDownloadStatus.text = "Status: Preparing video"
        let parameters = ["clips" : indexArray]
        Alamofire.request(.GET, "http://\(textServerName.text)/download", parameters: parameters, encoding: .URL)
            .response { (request, response, data, error) in
                let clipDict = NSKeyedUnarchiver.unarchiveObjectWithData(data! as NSData) as [String : NSData]
                for clipPath in clipDict.keys {
                    let data = clipDict[clipPath]
                    data?.writeToFile(clipPath, atomically: true)
                }
        }
    }
    
    @IBAction func closeWindow(sender: UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ReceiveClipsController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = decodedArray.count
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell") as UITableViewCell
        let fullPath = decodedArray[indexPath.row]
        let components = fullPath.componentsSeparatedByString("/")
        cell.textLabel!.text = components[components.count - 1]
        return cell
    }
}

extension ReceiveClipsController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        indexArray.append(indexPath.row)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let index = find(indexArray, indexPath.row)
        if index != nil {
            indexArray.removeAtIndex(index!)
        }
    }
}

extension ReceiveClipsController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
