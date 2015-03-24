//
//  CombineClipsController.swift
//  VideoConcat
//
//  Created by Michael Frain on 3/24/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit
import MediaPlayer

class CombineClipsController: UIViewController {
    @IBOutlet weak var tableFiles: UITableView!
    @IBOutlet weak var buttonCombine: UIButton!
    
    var fileNamesOnlyArray: [String] = []
    var fileList: [String] {
        let error = NSErrorPointer()
        var finalArray: [String] = []
        let docDirectory = Utilities.applicationSupportDirectory()
        let docArray = NSFileManager.defaultManager().contentsOfDirectoryAtPath(docDirectory, error: error) as [String]
        
        for secondDocDirectory in docArray {
            if secondDocDirectory != "Result.mp4" && secondDocDirectory != "Playlist.m3u8" {
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

    var selectedCells: [String] = []
    var startDate: NSDate!
    var filteredArray: [String] = []
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
    
    @IBAction func combineTapped(sender: UIButton!) {
        startDate = NSDate()
        var assetList = [AnyObject]()
        let predicate = NSPredicate(format: "SELF ENDSWITH '.ts'")
        filteredArray = selectedCells.filter { predicate!.evaluateWithObject($0) }
        
        if filteredArray.count > 0 {
            for fileName in selectedCells {
                let fileURL = NSURL(fileURLWithPath: fileName)
                let mediaAsset = KMMediaAsset.assetWithURL(fileURL, withFormat: .TS) as KMMediaAsset
                assetList.append(mediaAsset)
            }
        }
        
        let mp4URL = NSURL(fileURLWithPath: "\(Utilities.applicationSupportDirectory())/Result.mp4")
        let mp4Asset = KMMediaAsset.assetWithURL(mp4URL, withFormat: .MP4) as KMMediaAsset
        
        let exportSession = KMMediaAssetExportSession(inputAssets: assetList)
        exportSession.outputAssets = [mp4Asset]
        exportSession.exportAsynchronouslyWithCompletionHandler({
            if exportSession.status == .Completed {
                let finalDate = NSDate()
                let interval = finalDate.timeIntervalSinceDate(self.startDate)
                let alertController = UIAlertController(title: "BOOM", message: "This mp4 was compiled in \(interval) seconds.", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Let's watch it!", style: UIAlertActionStyle.Default) {(action: UIAlertAction!) -> Void in
                    let playbackController = MPMoviePlayerViewController(contentURL: mp4URL)
                    playbackController.moviePlayer.fullscreen = true
                    self.presentMoviePlayerViewControllerAnimated(playbackController)
                    playbackController.moviePlayer.play()
                }
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else if exportSession.status == .Failed {
                NSLog("Export failed: %@", exportSession.error.localizedDescription)
            }
        })
    }
    
    @IBAction func closeWindow(sender: UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CombineClipsController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = fileList.count
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell") as UITableViewCell
        cell.textLabel!.text = fileList[indexPath.row]
        return cell
    }
}

extension CombineClipsController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedCells.append(fileList[indexPath.row])
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let index = find(selectedCells, fileList[indexPath.row])
        if index != nil {
            selectedCells.removeAtIndex(index!)
        }
    }
}
