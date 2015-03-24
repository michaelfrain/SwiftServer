//
//  VideoController.swift
//  VideoConcat
//
//  Created by Michael Frain on 3/20/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation

class VideoController: UIViewController {
    // MARK: - Instance properties
    var isRecording = false
    var currentRecordingTime: Int = 0 {
        didSet {
            if currentRecordingTime < 60 {
                lblRecordingTime.text = "0:\(currentRecordingTime)"
            } else {
                lblRecordingTime.text = "\(currentRecordingTime / 60):\(currentRecordingTime - ((currentRecordingTime / 60) * 60))"
            }
        }
    }
    var timer: NSTimer!
    
    // MARK: - IBOutlets
    @IBOutlet weak var imgVideoViewer: UIImageView!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var lblRecordingTime: UILabel!
    
    // MARK: - Recorder objects
    var recorder: KFRecorder!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        self.view.sendSubviewToBack(imgVideoViewer)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Setup video recorder
        let deviceName = UIDevice.currentDevice().name
        
        recorder = KFRecorder(name: deviceName)
        recorder.session.sessionPreset = AVCaptureSessionPresetHigh
        previewLayer = AVCaptureVideoPreviewLayer(session: recorder.session)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer.frame = imgVideoViewer.bounds
        imgVideoViewer.layer.addSublayer(previewLayer)
        
        recorder.session.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Instance functions
    
    func incrementRecordingTimer(sender: AnyObject) {
        currentRecordingTime++
    }
    
    // MARK: - IBActions
    @IBAction func recordingButtonPressed(sender: UIButton!) {
        if !isRecording {
            lblRecordingTime.text = "0:00"
            lblRecordingTime.textColor = UIColor.greenColor()
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "incrementRecordingTimer:", userInfo: nil, repeats: true)
            btnRecord.setTitle("◼️", forState: .Normal)
            
            recorder.startRecording()
        } else {
            recorder.stopRecording()
            
            lblRecordingTime.textColor = UIColor.redColor()
            
            timer.invalidate()
            btnRecord.setTitle("🔴", forState: .Normal)
            
            recorder.session.stopRunning()
        }
        
        isRecording = !isRecording
    }
    
    @IBAction func closeButtonPressed(sender: UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}