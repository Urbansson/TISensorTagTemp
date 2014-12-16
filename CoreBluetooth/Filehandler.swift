//
//  filehandler.swift
//  sendData
//
//  Created by Max Berkenstam on 2014-12-15.
//  Copyright (c) 2014 Max Berkenstam. All rights reserved.
//

import Foundation

class Filehandler:NSObject, NSStreamDelegate {
    private let filename = "temp.txt"
    private let dirs:[String]?
    private var path:String = ""
    private var hostIP:CFString
    private var hostPORT:UInt32
    var outputStream: NSOutputStream!
    var inputStream: NSInputStream!
    
    init(hostIP:String,hostPORT:UInt32){
       
        // network
        self.hostIP = hostIP as CFString
        self.hostPORT = hostPORT as UInt32
         super.init()
        
        //local file
        dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        if ((dirs) != nil) {
            let dir = dirs![0]; //this document directory
            path = dir.stringByAppendingPathComponent(filename);
            
        }
        //self.connect()
        
        
    }
    
    func changeServer(hostIP:String,hostPORT:UInt32){
    
        self.hostIP = hostIP as CFString
        self.hostPORT = hostPORT as UInt32
    }
    
    
    func connect() { // https://gist.github.com/kvannotten/57ddd5531c228e7e08c6
        var readStream : Unmanaged<CFReadStream>?
        var writeStream : Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, self.hostIP, self.hostPORT, &readStream, &writeStream)
        
        inputStream = readStream!.takeUnretainedValue()
        outputStream = writeStream!.takeUnretainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        //inputStream!.open()
        outputStream.open()
    }
    func send(){ // http://stackoverflow.com/questions/26331636/writing-a-string-to-an-nsoutputstream-in-swift
        //var pointer = UnsafePointer
        
        self.connect()

        
        var text  = self.read();
        var d: NSData = text.dataUsingEncoding(NSUTF8StringEncoding)!
        outputStream.write(UnsafePointer<UInt8>(d.bytes), maxLength: d.length)
        
         text  = "\n";
         d = text.dataUsingEncoding(NSUTF8StringEncoding)!
        outputStream.write(UnsafePointer<UInt8>(d.bytes), maxLength: d.length)
        outputStream.close()
        outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream = nil
    }
    
    
     // http://stackoverflow.com/questions/24097826/read-and-write-data-from-text-file
    func write(textString:String) -> Void{
        if ((dirs) != nil) {
            //let text = "some text!"
            //writing
            
            textString.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
        }
    //reading
    // let text2 = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
    }
    func read() -> String{
        return String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
    }
    func append(textString:String) -> Void{
        var oldtext:String = read()
        write(oldtext+textString)
    }
    ///*
    func stream(theStream: NSStream, handleEvent streamEvent: NSStreamEvent){
        if(streamEvent == NSStreamEvent.EndEncountered){
            println("close con ")
            outputStream.close()
        }
    }
    
    
     /*
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch eventCode{
        case NSStreamEvent.OpenCompleted:
            println("Stream opened")
            break
        case NSStreamEvent.HasSpaceAvailable:
            if outputStream == aStream{
                println("outputstream is ready!")
            }
            break
        case NSStreamEvent.HasBytesAvailable:
            println("has bytes")
            break
            
        case NSStreamEvent.ErrorOccurred:
            println("Can not connect to the host!")
            break
        case NSStreamEvent.EndEncountered:
            outputStream.close()
            outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            outputStream = nil
            break
            
        default:
            println("Unknown event")
        }
    }
    // */
    
}