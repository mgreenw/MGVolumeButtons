//
//  MGVolumeButtons.swift
//  MGVolumeButtons
//
//  Created by Max Greenwald on 2/27/16.
//  Copyright © 2016 Max Greenwald. All rights reserved.
//

import AVFoundation
import MediaPlayer

public class MGVolumeButtons : NSObject {
    
    public var volumeUp:() -> Void
    public var volumeDown:() -> Void
    var isStealing:Bool
	
    let session:AVAudioSession
	let volumeView:MPVolumeView
	let sysVol:MPMusicPlayerController
    var volume:Float
	let MIN_VOL: Float = 0.1
	let MAX_VOL: Float = 0.9
	var boundsTimer: NSTimer
    
    // create
    public override init() {
		

        isStealing = false
		
        volumeUp = {}
        volumeDown = {}
		
		sysVol = MPMusicPlayerController.systemMusicPlayer()
		
		volumeView = MPVolumeView(frame: CGRectMake(-100, -100, 0, 0))
		volumeView.showsRouteButton = false
		
		session = AVAudioSession.sharedInstance()
		do {
			try session.setCategory(AVAudioSessionCategoryAmbient)
		} catch {
			// TODO handle nicely
		}
		
		volume = session.outputVolume
		
		boundsTimer = NSTimer.init()
		
		super.init()

    }
	
	public func shouldInterrputOtherAudio(shouldInterrupt: Bool) {
		do {
			try session.setCategory((shouldInterrupt) ?
				AVAudioSessionCategoryPlayback : AVAudioSessionCategoryAmbient)
		} catch {
			// TODO handle nicely
		}
	}
	
	func setSystemVolume(newVol: Float) {
		
		for view: UIView in volumeView.subviews {
			if (view.superclass == UISlider.self) {
				
				volume = newVol
				let slider:UISlider = view as! UISlider
				slider.setValue(newVol, animated: false)
				slider.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
				
				// potential code to remove the HUD volume popover
				/*let delayInNanoSeconds:Int64 = 1
				let popTime: dispatch_time_t  = dispatch_time(DISPATCH_TIME_NOW, delayInNanoSeconds)
				dispatch_after(popTime, dispatch_get_main_queue(), {
					
				})*/

				}
			
		}
	}
	
	func enforceSystemVolumeBounds() {
		if (session.outputVolume > MAX_VOL) {
			setSystemVolume(MAX_VOL)
		}
		
		if (session.outputVolume < MIN_VOL) {
			setSystemVolume(MIN_VOL)
		}
		volume = session.outputVolume
	}
    
    public func startStealing() {
		
        // no need to reinitialize the stealer
        if (isStealing) {
			return
		}
		
		isStealing = true
    
        do {
            try session.setActive(true)
        } catch {
            // TODO: handle this nicely
        }

        
        session.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.New, context: nil)

		// TODO: Currently does not work if put inside viewdidload
		UIApplication.sharedApplication().keyWindow?.rootViewController?.view.addSubview(volumeView)
		
		enforceSystemVolumeBounds()
		
		volume = session.outputVolume
		
		boundsTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("enforceSystemVolumeBounds"), userInfo: nil, repeats: true)
		
    }

	
    public func stopStealing() {
		
		if (!isStealing) {
			return
		}
		
		isStealing = false
		
		do {
			try session.setActive(false)
		} catch {
			// TODO: handle this nicely
		}
		
		session.removeObserver(self, forKeyPath: "outputVolume")
		
		boundsTimer.invalidate()
		
    }
	
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		
        if (keyPath == "outputVolume") {
            if let dic = change {
                handleVolumeChange((Float) (dic["new"] as! NSNumber))
            }
        }
		
    }
    
    func handleVolumeChange(newVolume:Float) {
		
		
		
        if (volume == newVolume) {
			return
		}
		
		if (abs(volume - newVolume) != 0.0625) {
			enforceSystemVolumeBounds()
			return
		}
		
        (newVolume > volume) ? volumeUp () : volumeDown()
		
		// set the system volume to something very slightly diffent as not to cause a continuous loop
		setSystemVolume(volume-0.000001)
		
		
    }
    
}

