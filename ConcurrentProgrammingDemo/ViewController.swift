//
//  ViewController.swift
//  ConcurrentProgrammingDemo
//
//  Created by Ky Nguyen on 12/15/15.
//  Copyright © 2015 Ky Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet var images: [UIImageView]!
    
    @IBOutlet weak var downloadTimeLabel: UILabel!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var sliderValueLabel: UILabel!
    
    // MARK: Override funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Actions
    
   
    @IBAction func runDownloadMainThread(sender: AnyObject) {

        prepareToStart()
        
        for var i = 0; i < images.count; i++ {
            
            images[i].image = downloadImage(imageUrl[i])
            downloadCompleted()
        }
    }
    
    @IBAction func runConcurrent(sender: AnyObject) {
        
        prepareToStart()
        runConcurrentQueue()
    }
    
    @IBAction func runSerial(sender: AnyObject) {

        prepareToStart()
        runSerialQueue()
    }
    
    @IBAction func runSerial2Queues(sender: AnyObject) {
        
        prepareToStart()
        runSerial2Queues()
    }
    
    @IBAction func runQueueOperation(sender: AnyObject) {
        
        prepareToStart()
        runNSOperationQueue()
    }
    
    @IBAction func cancelDidTap(sender: AnyObject) {
        
        queue.cancelAllOperations()
    }
    
    // MARK: Definition
    
    var countDownloaded = 0
    
    let imageUrl = [
        "http://www.silverlandhotels.com/blog/wp-content/uploads/2015/08/hcmc_itinerary.jpeg",
        "http://icho2014.hus.edu.vn/Img/upload/hoguom.jpg",
        "http://apttravel.com/documents/10182/3288866/ha_long_bay.jpg",
        "http://xinchaovietnam.org/wp-content/uploads/2015/05/9.jpg"
    ]
    
    var startTime: NSDate?
    
    var endTime: NSDate?
    
    // MARK: Functions 
    
    func prepareToStart() {
        
        reset()
        startTime = NSDate()
    }
    
    func reset() {
        
        for image in images {
            
            image.image = nil
        }
        
        downloadTimeLabel.text = "Download time: "
        countDownloaded = 0
    }
    
    func downloadImage(url: String) -> UIImage {
        
        let data = NSData(contentsOfURL: NSURL(string: url)!)
        return UIImage(data: data!)!
    }
    
    func calculateTimeDownload() {
        
        endTime = NSDate()
        
        let timespan = endTime?.timeIntervalSinceDate(startTime!)
        
        downloadTimeLabel.text = "Download time: \(timespan!) seconds"
    }
    
    func downloadCompleted() {
        
        self.countDownloaded++
        if self.countDownloaded >= 4 {
            
            self.calculateTimeDownload()
        }
    }
    
    func runDownloadTask(index: Int) {
        
        let img = self.downloadImage(self.imageUrl[index])
        dispatch_async(dispatch_get_main_queue(), {
            
            self.images[index].image = img
            self.downloadCompleted()
        })

    }
    
    func runConcurrentQueue() {
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) { () -> Void in
            
            self.runDownloadTask(0)
        }
        dispatch_async(queue) { () -> Void in

            self.runDownloadTask(1)
        }
        dispatch_async(queue) { () -> Void in

            self.runDownloadTask(2)
        }
        dispatch_async(queue) { () -> Void in

            self.runDownloadTask(3)
        }
    }

    func runSerialQueue() {
        
        let serialQueue = dispatch_queue_create("imagesQueue", DISPATCH_QUEUE_SERIAL)
        
        dispatch_async(serialQueue) { () -> Void in
            
            self.runDownloadTask(0)
            
        }
        dispatch_async(serialQueue) { () -> Void in
            
            self.runDownloadTask(1)
        }
        dispatch_async(serialQueue) { () -> Void in
            
            self.runDownloadTask(2)
        }
        dispatch_async(serialQueue) { () -> Void in
            
            self.runDownloadTask(3)
        }
    }
    
    func runSerial2Queues() {
        
        let queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL)
        let queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_SERIAL)
        
        dispatch_async(queue1) { () -> Void in
            
            self.runDownloadTask(0)
            
        }
        dispatch_async(queue1) { () -> Void in
            
            self.runDownloadTask(1)
        }
        dispatch_async(queue2) { () -> Void in
            
            self.runDownloadTask(2)
        }
        dispatch_async(queue2) { () -> Void in
            
            self.runDownloadTask(3)
        }
    }
    
    var queue = NSOperationQueue();
    
    func runNSOperationQueue() {
        
        queue = NSOperationQueue();
        
        func createOperation(index: Int) -> NSBlockOperation {
            
            let operation = NSBlockOperation(block: {
                
                self.runDownloadTask(index)
            })
            
            operation.completionBlock = {
                print("Operation \(index + 1) completed, cancelled:\(operation.cancelled)")
            }

            return operation
        }
   
        let operation1 = createOperation(0)
        queue.addOperation(operation1)

        let operation2 = createOperation(1)
        operation2.addDependency(operation1)
        queue.addOperation(operation2)

        let operation3 = createOperation(2)
        operation3.addDependency(operation2)
        queue.addOperation(operation3)
        
        let operation4 = createOperation(3)
        queue.addOperation(operation4)
    }
    
}



