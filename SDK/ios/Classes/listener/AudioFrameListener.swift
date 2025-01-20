//
//  AudioFrameListener.swift
//  tencent_trtc_cloud
//
//  Created by vincepzhang on 2023/12/26.
//

import Foundation
import TXLiteAVSDK_Professional

class AudioFrameListener: NSObject, TRTCAudioFrameDelegate {
    let basicChannel: FlutterBasicMessageChannel
    
    init(basicChannel: FlutterBasicMessageChannel) {
        self.basicChannel = basicChannel
    }
    
    func onCapturedAudioFrame(_ frame: TRTCAudioFrame) {
        var dataByteArray: [UInt8] = []
        frame.data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
            dataByteArray = Array(pointer)
        }
        
        var extraDataByteArray: [UInt8] = []
        frame.extraData?.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
            extraDataByteArray = Array(pointer)
        }
        
        basicChannel.sendMessage(["method": "onCapturedAudioFrame",
                                  "params": ["data": dataByteArray,
                                             "sampleRate": frame.sampleRate.rawValue,
                                             "channels": frame.channels,
                                             "timestamp": frame.timestamp,
                                             "extraData": extraDataByteArray]])
    }
    
    func onLocalProcessedAudioFrame(_ frame: TRTCAudioFrame) {
        // MARK: TODO
    }
    
    func onRemoteUserAudioFrame(_ frame: TRTCAudioFrame, userId: String) {
        // MARK: TODO
    }
    
    func onMixedAllAudioFrame(_ frame: TRTCAudioFrame) {
        // MARK: TODO
    }
    
    func onMixedPlay(_ frame: TRTCAudioFrame) {
        // MARK: TODO
    }
    
    func onVoiceEarMonitorAudioFrame(_ frame: TRTCAudioFrame) {
        // MARK: TODO
    }
}
