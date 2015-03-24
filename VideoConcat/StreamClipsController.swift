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

class StreamClipsController: UIViewController {
    @IBOutlet weak var buttonStream: UIButton!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var textAddress: UITextField!
    @IBOutlet weak var tableStreamClips: UITableView!
    @IBOutlet weak var labelStatus: UILabel!
    
    var decodedArray: Array<String> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startDate = NSDate()
        labelStatus.text = "Status: retrieving available clips"
        Alamofire.request(.GET, "http://\(textAddress.text)/allclips")
            .response { (request, response, data, error) in
                self.decodedArray = NSKeyedUnarchiver.unarchiveObjectWithData(data! as NSData) as Array<String>
                let interval = startDate.timeIntervalSinceDate(NSDate())
                self.labelStatus.text = "Status: \(self.decodedArray.count) clips ready for stream in \(interval) seconds."
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createManifest() {
        var manifest = ""
        manifest += "#EXTM3U\n"
        manifest += "#EXT-X-VERSION:3\n"
        manifest += "#EXT-X-TARGETDURATION:9\n"
        manifest += "#EXT-X-MEDIA-SEQUENCE:0\n"
        for fullPath in decodedArray {
            manifest += "#EXTINF:8\n"
            let components = fullPath.componentsSeparatedByString("/")
            let manifestPath = components[components.count - 1]
            manifest += "http://\(textAddress.text)/\(manifestPath)\n"
        }
        manifest += "EXT-X-ENDLIST"
        let success = manifest.writeToFile("/private\(Utilities.applicationSupportDirectory())/Playlist.m3u8", atomically: false, encoding: NSUTF8StringEncoding, error: nil)
        if success {
            let viewer = AVPlayerViewController()
        }
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
