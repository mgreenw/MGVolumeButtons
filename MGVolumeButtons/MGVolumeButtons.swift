//
//  MGVolumeButtons.swift
//  MGVolumeButtons
//
//  Created by Max Greenwald on 2/27/16.
//  Copyright © 2016 Max Greenwald. All rights reserved.
//

import AVFoundation

public class MGVolumeButtons : NSObject {
    
    public var volumeUp:() -> Void
    public var volumeDown:() -> Void
    var isStealing:Bool
    let session:AVAudioSession
    var volume:Float
    
    // create
    public override init() {
        session = AVAudioSession.sharedInstance()
        isStealing = false
        
        volumeUp = {}
        volumeDown = {}
        
        volume = session.outputVolume
        
    }
    
    
    public func startStealing() {
        // no need to reinitialize the stealer
        if (isStealing) {return}
    
        do {
            try session.setActive(true)
        } catch {
            // TODO: handle this nicely
        }
        
        volume = session.outputVolume
        
        session.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.New, context: nil)
        
    }

    
    public func stopStealing() {
        
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "outputVolume") {
            if let dic = change {
                handleVolumeChange((Float) (dic["new"] as! NSNumber))
            }
        }
    }
    
    func handleVolumeChange(newVolume:Float) {
        if (volume == newVolume) {return}
        (newVolume > volume) ? volumeUp () : volumeDown()
    }
    
}

