//
//  QSAudioStreamer.swift
//  OrbPlayer
//
//  Created by cottonBuddha on 2017/8/10.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import AudioToolbox

enum Status : Int {
    case Stopped
    case Playing
    case Waiting
    case Paused
}

public protocol AudioStreamerProtocol {
    
    func playingDidStart()
    
    func playingDidEnd()
}


class QSAudioStreamer : NSObject,URLSessionDataDelegate{
    
    var url: URL?
    var session : URLSession!
    var audioFileStreamID: AudioFileStreamID? = nil
    var packets = [Data]()
    var outputQueue: AudioQueueRef?
    var streamDescription: AudioStreamBasicDescription?
    var readHead: Int = 0
    
    var loaded = false
    var stopped = false
    
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

        let clientData = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        
        AudioFileStreamOpen(clientData, audioFileStreamPropertyListenerProc, audioFileStreamPacketsProc, kAudioFileMP3Type, &audioFileStreamID)
        self.session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)

        let task = self.session.dataTask(with: url)
        task.resume()
    }
    
    deinit {
        if self.outputQueue != nil {
            AudioQueueReset(outputQueue!)
        }
        AudioFileStreamClose(audioFileStreamID!)
    }

    
    
    func play() {
        if self.outputQueue != nil {
            AudioQueueStart(outputQueue!, nil)
        }
    }
    
    func pause() {
        if self.outputQueue != nil {
            AudioQueuePause(outputQueue!)
        }
    }
    
    func stop() {
        
    }
    
    fileprivate func storePackets(numberOfPackets: UInt32, numberOfBytes: UInt32, data: UnsafeRawPointer, packetDescription: UnsafeMutablePointer<AudioStreamPacketDescription>) {
        for i in 0 ..< Int(numberOfPackets) {
            let packetStart = packetDescription[i].mStartOffset
            let packetSize = packetDescription[i].mDataByteSize
            let packetData = Data.init(bytes: data.advanced(by: Int(packetStart)), count: Int(packetSize))

            self.packets.append(packetData)
        }
        
        if readHead == 0 && Double(packets.count) > self.framePerSecond * 3 {
            AudioQueueStart(self.outputQueue!, nil)
            self.enqueueDataWithPacketsCount(packetCount: Int(self.framePerSecond * 3))
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
//        AudioQueueNewOutput(&audioStreamDescription, audioQueueOutputCallback as! AudioQueueOutputCallback, nil, nil, nil, 0, &self.outputQueue)
        status = AudioQueueNewOutput(&audioStreamDescription, audioQueueOutputCallback, selfPointer, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue, 0, &self.outputQueue)
        
        assert(noErr == status)
        status = AudioQueueAddPropertyListener(self.outputQueue!, kAudioQueueProperty_IsRunning, audioQueueRunningListener, selfPointer)
        assert(noErr == status)
        AudioQueuePrime(self.outputQueue!, 0, nil)
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
        status = AudioQueueEnqueueBuffer(outputQueue!, buffer!, UInt32(packetCount), packetDescs);
        readHead += packetCount
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.parseData(data: data)
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
    status = AudioQueueGetPropertySize(inAQ, propertyID, &dataSize);
    assert(noErr == status)
    if propertyID == kAudioQueueProperty_IsRunning {
        var running: UInt32 = 0
        status = AudioQueueGetProperty(inAQ, propertyID, &running, &dataSize)
        this.stopped = running == 0
    }
}

