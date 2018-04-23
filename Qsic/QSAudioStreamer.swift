//
//  QSAudioStreamer.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/8/10.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import AudioToolbox

public protocol AudioStreamerProtocol : NSObjectProtocol{
    
    func playingDidStart()
    func playingDidEnd()
    func handleNetworkError(error:Error)
}

class QSAudioStreamer : NSObject,URLSessionDataDelegate{
    
    var url: URL?
    var session: URLSession!
    var audioFileStreamID: AudioFileStreamID? = nil
    var packets = [Data]()
    var outputQueue: AudioQueueRef?
    var streamDescription: AudioStreamBasicDescription?
    var readHead: Int = 0
    var volumeValue: Float32 = 0.5
    var isPlaying = false
    var taskFinish = false
    var stopped = false
    var isBreaking = false
    
    weak var delegate: AudioStreamerProtocol?
    
    var framePerSecond: Double {
        get {
            if let streamDescription = self.streamDescription, streamDescription.mFramesPerPacket > 0 {
                return Double(streamDescription.mSampleRate) / Double(streamDescription.mFramesPerPacket)
            }
            return 44100.0 / 1152.0
        }
    }
    
    init(url: URL) {
        super.init()
        self.url = url
        let selfPointer = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        AudioFileStreamOpen(selfPointer, audioFileStreamPropertyListenerProc, audioFileStreamPacketsProc, kAudioFileMP3Type, &audioFileStreamID)
        self.session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        let task = self.session.dataTask(with: url)
        task.resume()
    }
    
    func releaseStreamer() {
        if self.outputQueue != nil {
            AudioQueueDispose(outputQueue!, true)
        }
        self.session.invalidateAndCancel()
        AudioFileStreamClose(audioFileStreamID!)
    }
    
    deinit {
//        mvaddstr(1, 1, "关了")
    }
    
    func play() {
        if self.outputQueue != nil {
            isPlaying = true
            AudioQueueStart(outputQueue!, nil)
        }
    }
    
    func pause() {
        if self.outputQueue != nil {
            AudioQueuePause(outputQueue!)
        }
    }
    
    func stop() {
        if self.outputQueue != nil {
            AudioQueueStop(outputQueue!, true)
        }
    }
    
    func flush() {
        if self.outputQueue != nil {
            AudioQueueFlush(outputQueue!)
        }
    }
    
    func reset() {
        if self.outputQueue != nil {
            AudioQueueReset(outputQueue!)
        }
    }
    
    func replay() {
        reset()
        self.outputQueue = nil
        self.readHead = 0
        DispatchQueue.main.async {
            self.createAudioQueue(audioStreamDescription: self.streamDescription!)
            self.enqueueDataWithPacketsCount(packetCount: Int(self.framePerSecond * 3))
        }
    }
    
    func setVolume(value:Float32) {
        self.volumeValue = value
        if self.outputQueue != nil {
            AudioQueueSetParameter(self.outputQueue!, kAudioQueueParam_Volume, value)
        }
    }
    
    fileprivate func storePackets(numberOfPackets: UInt32, numberOfBytes: UInt32, data: UnsafeRawPointer, packetDescription: UnsafeMutablePointer<AudioStreamPacketDescription>) {
        for i in 0 ..< Int(numberOfPackets) {
            let packetStart = packetDescription[i].mStartOffset
            let packetSize = packetDescription[i].mDataByteSize
            let packetData = Data.init(bytes: data.advanced(by: Int(packetStart)), count: Int(packetSize))
            
            self.packets.append(packetData)
        }
        
        if isBreaking && numberOfPackets != 0{
            let packetCount = Int(self.framePerSecond * 3)
            if readHead + packetCount <= packets.count {
                isBreaking = false
                play()
                self.enqueueDataWithPacketsCount(packetCount: packetCount)
            }
        }
        
        if readHead == 0 && Double(packets.count) > self.framePerSecond * 3 && self.outputQueue != nil {
            AudioQueueStart(self.outputQueue!, nil)
            self.enqueueDataWithPacketsCount(packetCount: Int(self.framePerSecond * 3))
            isPlaying = true
            if delegate != nil {
                delegate!.playingDidStart()
            }
        }
    }
    
    fileprivate func parseData(data: Data) {
        let bytes = [UInt8](data)
        let status = AudioFileStreamParseBytes(self.audioFileStreamID!, UInt32(data.count), bytes, AudioFileStreamParseFlags(rawValue: 0))
        if status != 0 {
            //do sth
        }
    }
    
    fileprivate func createAudioQueue(audioStreamDescription: AudioStreamBasicDescription) {
        var audioStreamDescription = audioStreamDescription
        self.streamDescription = audioStreamDescription
        var status: OSStatus = 0
        let selfPointer = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        status = AudioQueueNewOutput(&audioStreamDescription, audioQueueOutputCallback, selfPointer, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue, 0, &self.outputQueue)
        if self.outputQueue != nil {
            AudioQueueSetParameter(self.outputQueue!, kAudioQueueParam_Volume, volumeValue)
        }
        assert(noErr == status)
        status = AudioQueueAddPropertyListener(self.outputQueue!, kAudioQueueProperty_IsRunning, audioQueueRunningListener, selfPointer)
        assert(noErr == status)
        AudioQueuePrime(self.outputQueue!, 0, nil)
        isPlaying = true
        AudioQueueStart(self.outputQueue!, nil)
    }
    
    func enqueueDataWithPacketsCount(packetCount: Int) {
        if self.outputQueue == nil {
            return
        }
        
        var packetCount = packetCount
        if readHead + packetCount > packets.count {
            packetCount = packets.count - readHead
        }
        
        let totalSize = packets[readHead ..< readHead + packetCount].reduce(0, { $0 + $1.count })
        var status: OSStatus = 0
        var buffer: AudioQueueBufferRef?
        status = AudioQueueAllocateBuffer(outputQueue!, UInt32(totalSize), &buffer)
        assert(noErr == status)
        buffer?.pointee.mAudioDataByteSize = UInt32(totalSize)
        let selfPointer = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        buffer?.pointee.mUserData = selfPointer
        
        var copiedSize = 0
        var packetDescs = [AudioStreamPacketDescription]()
        for i in 0 ..< packetCount {
            let readIndex = readHead + i
            let packetData = packets[readIndex]
            let rawBuffer = (buffer?.pointee)! as AudioQueueBuffer
            let bytes = [UInt8](packetData)
            memcpy(rawBuffer.mAudioData.advanced(by: copiedSize), bytes, packetData.count)
            let description = AudioStreamPacketDescription(mStartOffset: Int64(copiedSize), mVariableFramesInPacket: 0, mDataByteSize: UInt32(packetData.count))
            packetDescs.append(description)
            copiedSize += packetData.count
        }
        status = AudioQueueEnqueueBuffer(outputQueue!, buffer!, UInt32(packetCount), packetDescs)
        readHead += packetCount
        if (readHead == packets.count && taskFinish && packetCount == 0 && isPlaying) {
            AudioQueueStop(outputQueue!, true)
            isPlaying = false
            if delegate != nil {
                delegate!.playingDidEnd()
            }
        } else if packetCount == 0 {
            isBreaking = true
            pause()
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.parseData(data: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            taskFinish = true
        } else {
            if delegate != nil {
                delegate?.handleNetworkError(error: error!)
            }
        }
    }
}

func audioFileStreamPropertyListenerProc(clientData:UnsafeMutableRawPointer, audioFileStream:AudioFileStreamID, propertyID:AudioFileStreamPropertyID, ioFlag:UnsafeMutablePointer<AudioFileStreamPropertyFlags>) {
    let this = Unmanaged<QSAudioStreamer>.fromOpaque(UnsafeRawPointer(clientData)).takeUnretainedValue()
    if propertyID == kAudioFileStreamProperty_DataFormat {
        var status: OSStatus = 0
        var dataSize: UInt32 = 0
        var writable: DarwinBoolean = false
        status = AudioFileStreamGetPropertyInfo(audioFileStream, kAudioFileStreamProperty_DataFormat, &dataSize, &writable)
        assert(noErr == status)
        var audioStreamDescription: AudioStreamBasicDescription = AudioStreamBasicDescription()
        status = AudioFileStreamGetProperty(audioFileStream, kAudioFileStreamProperty_DataFormat, &dataSize, &audioStreamDescription)
        assert(noErr == status)
        DispatchQueue.main.async {
            this.createAudioQueue(audioStreamDescription: audioStreamDescription)
        }
    }
}

func audioFileStreamPacketsProc(clientData:UnsafeMutableRawPointer, numberBytes:UInt32, numberPackets:UInt32, ioData:UnsafeRawPointer, packetDescription:UnsafeMutablePointer<AudioStreamPacketDescription>) {
    let this = Unmanaged<QSAudioStreamer>.fromOpaque(UnsafeRawPointer(clientData)).takeUnretainedValue()
    this.storePackets(numberOfPackets: numberPackets, numberOfBytes: numberBytes, data: ioData, packetDescription: packetDescription)
}

func audioQueueOutputCallback(_ clientData:UnsafeMutableRawPointer?, _ inAQ:AudioQueueRef, _ inBuffer:AudioQueueBufferRef) {
    let this = Unmanaged<QSAudioStreamer>.fromOpaque(UnsafeRawPointer(clientData)!).takeUnretainedValue()
    let status = AudioQueueFreeBuffer(inAQ, inBuffer)
    assert(noErr == status)
    this.enqueueDataWithPacketsCount(packetCount: Int(this.framePerSecond * 5))
}

func audioQueueRunningListener(clientData: UnsafeMutableRawPointer?, inAQ: AudioQueueRef, propertyID: AudioQueuePropertyID) {
    let this = Unmanaged<QSAudioStreamer>.fromOpaque(UnsafeRawPointer(clientData)!).takeUnretainedValue()
    var status: OSStatus = 0
    var dataSize: UInt32 = 0
    status = AudioQueueGetPropertySize(inAQ, propertyID, &dataSize)
    assert(noErr == status)
    if propertyID == kAudioQueueProperty_IsRunning {
        var running: UInt32 = 0
        status = AudioQueueGetProperty(inAQ, propertyID, &running, &dataSize)
        this.stopped = running == 0
    }
}
