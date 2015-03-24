//
//  StreamPlayController.swift
//  VideoConcat
//
//  Created by Michael Frain on 3/22/15.
//  Copyright (c) 2015 Michael Frain. All rights reserved.
//

import UIKit
import AVKit

class StreamPlayController: AVPlayerViewController {
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if player.status == .ReadyToPlay {
            player.play()
        }
    }
}
