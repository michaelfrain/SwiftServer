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
        return false
    }
    // MARK: - IBActions
    
    @IBAction func playbackPressed(sender: UIButton!) {
        startDate = NSDate()
        var assetList = [AnyObject]()
        let predicate = NSPredicate(format: "SELF ENDSWITH '.ts'")
        filteredArray = selectedFileList.filter { predicate!.evaluateWithObject($0) }
        
        if 0 == 0 {
            if filteredArray.count > 0 {
                for fileName in selectedFileList {
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
        } else if 0 == 1 {
            createManifest(selectedFileList)
            let error = NSErrorPointer()
            let success = startServer(error)
            let fullPath = "http://localhost:8080/Playlist.m3u8"
            let escapedPath = fullPath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let playlistURL = NSURL(string: escapedPath!)
            let data = NSData(contentsOfURL: playlistURL!)
            let asset = AVURLAsset(URL: playlistURL, options: nil)
            let playerItem = AVPlayerItem(asset: asset)
            
            let player = AVPlayer(playerItem: playerItem)
            
            let playerController = AVPlayerViewController()
            playerController.player = player
            presentViewController(playerController, animated: true, completion: nil)
        }
    }
    
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
