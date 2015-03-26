//
//  StreamClipsController.swift
//  VideoConcat
//
//  Created by Michael Frain on 3/24/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit
import Alamofire
import AVKit
import AVFoundation

class StreamClipsController: UIViewController {
    @IBOutlet weak var buttonStream: UIButton!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var textAddress: UITextField!
    @IBOutlet weak var tableStreamClips: UITableView!
    @IBOutlet weak var labelStatus: UILabel!
    
    var decodedArray: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fetchClips(sender: UIButton!) {
        let startDate = NSDate()
        labelStatus.text = "Status: retrieving available clips"
        Alamofire.request(.GET, "http://\(textAddress.text)/stream")
            .response { (request, response, data, error) in
                let playlistData = data as NSData
                let string = NSString(data: playlistData, encoding: NSUTF8StringEncoding)
                playlistData.writeToFile("\(Utilities.applicationSupportDirectory())/stream.m3u8", atomically: true)
                let interval = startDate.timeIntervalSinceDate(NSDate())
                self.labelStatus.text = "Status: \(self.decodedArray.count) playlist of stream ready in \(interval * -1) seconds."
                let viewer = AVPlayerViewController()
                let playerItem = AVPlayerItem(URL: NSURL(fileURLWithPath: "\(Utilities.applicationSupportDirectory())/stream.m3u8"))
                let player = AVPlayer(playerItem: playerItem)
                viewer.player = player
                self.presentViewController(viewer, animated: true, completion: nil)
        }
    }
    
    @IBAction func createManifest() {
        
    }
    
    @IBAction func closeWindow(sender: UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension StreamClipsController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = decodedArray.count
        return rows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileStreamCell") as UITableViewCell
        let fullPath = decodedArray[indexPath.row]
        let components = fullPath.componentsSeparatedByString("/")
        let readPath = components[components.count - 1]
        cell.textLabel!.text = readPath
        return cell
    }
}
