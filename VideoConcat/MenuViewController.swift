//
//  MenuViewController.swift
//  VideoConcat
//
//  Created by Michael Frain on 3/20/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import AVKit
import Alamofire

class MenuViewController: UIViewController {
    // MARK: - Instance variables

    var server: HTTPServer!
    var filteredArray: [String] = []
    var startDate: NSDate!
    var selectedFileList: [String] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var buttonCreateVideo: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RecordSegue" {
            
        } else if segue.identifier == "StreamPlaySegue" {
            
            
//            let destinationController = segue.destinationViewController as StreamPlayController
//            destinationController.player = player
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "RecordSegue" {
            return true
        }
        return true
    }
    // MARK: - IBActions
    
//    @IBAction func playbackPressed(sender: UIButton!) {
//                } else if 0 == 1 {
//            createManifest(selectedFileList)
//            let error = NSErrorPointer()
//            let success = startServer(error)
//            let fullPath = "http://localhost:8080/Playlist.m3u8"
//            let escapedPath = fullPath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
//            let playlistURL = NSURL(string: escapedPath!)
//            let data = NSData(contentsOfURL: playlistURL!)
//            let asset = AVURLAsset(URL: playlistURL, options: nil)
//            let playerItem = AVPlayerItem(asset: asset)
//            
//            let player = AVPlayer(playerItem: playerItem)
//            
//            let playerController = AVPlayerViewController()
//            playerController.player = player
//            presentViewController(playerController, animated: true, completion: nil)
//        }
//    }
    
    // MARK: - Server functions
    func createManifest(assetList: Array<String>) {
        var manifestString = ""
        manifestString += "#EXTM3U\n"
        manifestString += "#EXT-X-VERSION:3\n"
        manifestString += "#EXT-X-TARGETDURATION:9\n"
        manifestString += "#EXT-X-MEDIA-SEQUENCE:0\n"
        for assetString in assetList {
            let stringLength = countElements(assetString)
            if assetString.substringFromIndex(advance(assetString.endIndex, -2)) == "ts" {
                let assetArray = assetString.componentsSeparatedByString("/")
                manifestString += "#EXTINF:8\n"
                let urlString = "\(assetArray[assetArray.count - 2])\(assetArray[assetArray.count - 1])"
                manifestString += urlString
                let testUrl = NSURL(string: urlString)
                let testData = NSData(contentsOfURL: testUrl!)
                manifestString += "\n"
            }
        }
        manifestString += "#EXT-X-ENDLIST"
        let generalString: NSString = manifestString
        let error = NSErrorPointer()
        let success = generalString.writeToFile("\(Utilities.applicationSupportDirectory())/Playlist.m3u8", atomically: false, encoding: NSUTF8StringEncoding, error: error)
    }
    
    func startServer(error: NSErrorPointer) -> Bool {
        server = HTTPServer()
        server.setPort(8080)
        server.setDocumentRoot("\(Utilities.applicationSupportDirectory())")
        let success = server.start(error)
        return success
    }
}
