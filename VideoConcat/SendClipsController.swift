//
//  SendClipsController.swift
//  VideoConcat
//
//  Created by Michael Frain on 3/24/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import AVKit
import Alamofire

class SendClipsController: UIViewController {
    var fileNamesOnlyArray: [String] = []
    var fileList: [String] {
        let error = NSErrorPointer()
        var finalArray: [String] = []
        let docDirectory = Utilities.applicationSupportDirectory()
        let docArray = NSFileManager.defaultManager().contentsOfDirectoryAtPath(docDirectory, error: error) as [String]
        
        for secondDocDirectory in docArray {
            if secondDocDirectory != "Result.mp4" && secondDocDirectory != "Playlist.m3u8" && secondDocDirectory != "stream.m3u8" {
                let fullDirectory = "\(docDirectory)/\(secondDocDirectory)"
                let secondDocArray = NSFileManager.defaultManager().contentsOfDirectoryAtPath(fullDirectory, error: error) as [String]
                for finalDocDirectory in secondDocArray {
                    let finalDocPathArray = NSFileManager.defaultManager().contentsOfDirectoryAtPath("\(fullDirectory)/\(finalDocDirectory)", error: error) as [String]
                    for halfPath in finalDocPathArray {
                        if halfPath.substringFromIndex(advance(halfPath.endIndex, -2)) == "ts" {
                            let fullPath = "\(fullDirectory)/\(finalDocDirectory)/\(halfPath)"
                            finalArray.append(fullPath)
                            fileNamesOnlyArray.append(halfPath)
                        }
                    }
                }
            }
        }
        return finalArray
    }
    var selectedFileList: [String] = []
    
    @IBOutlet weak var tableViewFiles: UITableView!
    @IBOutlet weak var textServerName: UITextField!
    @IBOutlet weak var labelConnectionStatus: UILabel!

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
    
    @IBAction func uploadPressed(sender: UIButton!) {
        labelConnectionStatus.text = "Status: Connected, sending files"
        var i = 0
        let startDate = NSDate()
        for selectedItem in selectedFileList {
            Alamofire.upload(.POST, "http://\(textServerName.text)/upload", NSURL(fileURLWithPath: selectedItem)!)
            .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                if totalBytesWritten == totalBytesExpectedToWrite {
                    i++
                    self.labelConnectionStatus.text = "Status: \(i) of \(self.selectedFileList.count) files written"
                    if i == self.selectedFileList.count {
                        let endDate = NSDate()
                        let interval = endDate.timeIntervalSinceDate(startDate)
//                        self.labelConnectionStatus.text += " \(interval) seconds"
                    }
                }
            }
        }
    }
    
    @IBAction func closeWindow(sender: UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SendClipsController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileListCell") as UITableViewCell
        let fullPath = fileList[indexPath.row]
        let components = fullPath.componentsSeparatedByString("/")
        cell.textLabel!.text = components[components.count - 1]
        return cell
    }
}

extension SendClipsController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedFileList.append(fileList[indexPath.row])
        NSLog("\(selectedFileList)")
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let index = find(selectedFileList, fileList[indexPath.row])
        if index != nil {
            selectedFileList.removeAtIndex(index!)
        }
    }
}

extension SendClipsController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}