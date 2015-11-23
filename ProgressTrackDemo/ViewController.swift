//
//  ViewController.swift
//  ProgressTrack
//
//  Created by HDD103033 on 2015/10/22.
//  Copyright © 2015年 Yalight. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ProgressTrackDelegate {
    
    @IBOutlet var progressLabel1: UILabel!
    @IBOutlet var progressTrack1: ProgressTrack!
    @IBOutlet var progressTrack2: ProgressTrack!
    @IBOutlet var progressTrack3: ProgressTrack!
    @IBOutlet var progressTrack4: ProgressTrack!
    @IBOutlet var progressTrack5: ProgressTrack!
    @IBOutlet var progressTrack6: ProgressTrack!
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressTrack1.trackData = createTestTrackData(36, maxValue: 1.0, minValue: 0.0)
        progressTrack1.colorStyle = ProgressTrack.ColorStyle.RED
        progressTrack1.delegate = self
        
        progressTrack2.delegate = self
        progressTrack2.backgroundColor = UIColor.clearColor()
        progressTrack2.colorStyle = ProgressTrack.ColorStyle.ORANGE
        progressTrack2.trackData = createTestTrackData(100, maxValue: 1.0, minValue: 0.0)
        progressTrack2.currentBarIndex = 10
        progressTrack2.barHeightRatio = 0.75
        view.addSubview(progressTrack2)
        
        progressTrack3.colorStyle = ProgressTrack.ColorStyle.YELLOW
        progressTrack3.trackData = createTestTrackData(100, maxValue: 100.0, minValue: 0.0)
        progressTrack3.progressValue = 0.33
        progressTrack3.minimumValue = 0
        progressTrack3.maximumValue = 100
        view.addSubview(progressTrack3)
        
        progressTrack4.colorStyle = ProgressTrack.ColorStyle.GREEN
        progressTrack4.trackData = createTestTrackData(20, maxValue: 1.0, minValue: 0.0)
        progressTrack4.progressValue = 0.55
        progressTrack4.gapWidth = 5
        view.addSubview(progressTrack4)
        
        progressTrack5.colorStyle = ProgressTrack.ColorStyle.BLUE
        progressTrack5.trackData = createTestTrackData(50, maxValue: 1.0, minValue: 0.0)
        progressTrack5.progressValue = 0.77
        progressTrack5.barHeightRatio = 0.2
        view.addSubview(progressTrack5)
        
        progressTrack6.colorStyle = ProgressTrack.ColorStyle.PURPLE
        progressTrack6.trackData = createTestTrackData(30, maxValue: 1.0, minValue: 0.0)
        progressTrack6.progressValue = 0.99
        view.addSubview(progressTrack6)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "update", userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createTestTrackData(dataCount: Int, maxValue: Float, minValue: Float) -> [Float] {
        var trackData: [Float] = []
        
        srand(UInt32(time(UnsafeMutablePointer<time_t>())))
        
        for _ in 0..<dataCount {
            let value = (Float(rand()) / Float(RAND_MAX)) * (maxValue - minValue) / 2 + (maxValue - minValue) / Float(2) + minValue
            //let value = (Float(rand()) / Float(RAND_MAX)) * (maxValue - minValue) + minValue
            //let value = maxValue / Float(dataCount) * Float(i)
            trackData.append(value)
        }
        
        return trackData
    }
    
    func update() {

        progressTrack2.progressValue += 0.004 //0.0004
        
        if(progressTrack2.progressValue >= 1) {
            timer!.invalidate()
        }
        
        let barIndex = progressTrack2.currentBarIndex
        
        if barIndex > 50 {
            progressTrack2.gapWidth = 1
            progressTrack2.colorStyle = ProgressTrack.ColorStyle.BLUE
        } else {
            progressTrack2.colorStyle = ProgressTrack.ColorStyle.ORANGE
        }
    }
    
    func progressTrackBarTappedUp(progressTrack: ProgressTrack, fromProgressValue: Float, toProgressValue: Float) {
        
        let fromBarIndex = progressTrack.getBarIndexByProgressValue(fromProgressValue)
        let toBarIndex = progressTrack.getBarIndexByProgressValue(toProgressValue)
        
        let fromBarValue = progressTrack.trackData[fromBarIndex]
        let toBarValue = progressTrack.trackData[toBarIndex]
        
        if progressTrack == progressTrack1 {
            progressLabel1.text = "Progess value = \(progressTrack.progressValue)"
        } else if progressTrack == progressTrack2 {
            if toBarIndex < 50 {
                progressTrack2.colorStyle = ProgressTrack.ColorStyle.ORANGE
            } else {
                progressTrack2.colorStyle = ProgressTrack.ColorStyle.BLUE
            }
        }
        
        print("barTapped fromBarIndex:[\(fromBarIndex)]=\(fromBarValue) toBarIndex:[\(toBarIndex)]=\(toBarValue) \(toProgressValue)")
    }
}
