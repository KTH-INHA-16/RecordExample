//
//  AudioRecorder.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/24.
//

import Foundation
import Combine
import AVFoundation
import lame
import AudioKit

final class AudioRecorder: NSObject, ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var mixerNode: AVAudioMixerNode?
    private var cancellable: AnyCancellable?
    private var fileName: String
    let dataManager = DataManager.shared
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    @Published var authority = false
    @Published var recording = false {
        didSet {
            objectWillChange.send(self)
            if recording {
                startRecording()
            } else {
                cancellable?.cancel()
                stopRecording()
            }
        }
    }
    
    override init() {
        fileName = ""
        super.init()
        configureSession()
        configureEngine()
    }
    
    func configureSession() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { [unowned self] result in
            switch result {
            case true:
                do {
                    try session.setCategory(.playAndRecord)
                    try session.setActive(result, options: .notifyOthersOnDeactivation)
                } catch {
                    print(error.localizedDescription)
                }
            case false:
                print(result)
            }
            self.authority = result
        }
    }
    
    func configureEngine() {
        audioEngine = AVAudioEngine()
        mixerNode = AVAudioMixerNode()
        
        guard let audioEngine = audioEngine, let mixerNode = mixerNode else {
            return
        }

        
        mixerNode.volume = 0
        audioEngine.attach(mixerNode)
        
        configureNodes()
        
        audioEngine.prepare()
    }
    
    func startRecording() {
        guard let mixerNode = mixerNode, let audioEngine = audioEngine, let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        let tapNode: AVAudioNode = mixerNode
        let format = tapNode.outputFormat(forBus: 0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddhhmmssSSS"
        let dateString = dateFormatter.string(from: Date())
        
        do {
            let file = try AVAudioFile(forWriting: fileURL.appendingPathComponent(dateString), settings: format.settings)
            dataManager.save(attributes: ["file": dateString], type: "Record")
            tapNode.installTap(onBus: 0, bufferSize: 4800, format: format) { buffer, time in
                //let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: 1)
                //let floatBuffer = UnsafeBufferPointer(start: channels[0], count: Int(buffer.frameLength))
                //let data = Data(buffer: floatBuffer)
                try? file.write(from: buffer)
                
                if file.length >= 48000 * 10 {
                    //try? data.write(to: fileURL.appendingPathComponent(dateString+"2"))
                    self.convert(inPcmPath: file.url.path, outMp3Path: file.url.path+"3.mp3")
                    self.stopRecording()
                }
                // 19200
                //self.stopRecording()
                //print(buffer.frameCapacity, buffer.frameLength)
//                if file.length >= (Int(format.sampleRate) * 10 ) {
//                    self.stopRecording()
//                }
            }
            try audioEngine.start()
        } catch {
            print(error.localizedDescription)
       }
    }
    
    func stopRecording() {
        mixerNode?.removeTap(onBus: 0)
        
        audioEngine?.stop()
    }
    
    func convert(inPcmPath: String, outMp3Path: String) {
        var options = FormatConverter.Options()
        // any options left nil will assume the value of the input file
        options.format = "wav"
        options.sampleRate = 48000
        options.bitDepth = 32
        options.eraseFile = true

        let converter = FormatConverter(inputURL: URL(fileURLWithPath: inPcmPath), outputURL: URL(fileURLWithPath: inPcmPath+"2.wav"), options: options)
        
        converter.start { error in
            guard let error = error else {
                DispatchQueue.global().async {
                    let lame = lame_init()
                    lame_set_in_samplerate(lame, 48000)
                    lame_set_out_samplerate(lame, 0)
                    lame_set_brate(lame, 0)
                    lame_set_quality(lame, 4)
                    lame_set_VBR(lame, vbr_default)
                    lame_init_params(lame)

                    let pcmFile: UnsafeMutablePointer<FILE> = fopen(inPcmPath, "rb")
                    fseek(pcmFile, 0 , SEEK_END)
                    let fileSize = ftell(pcmFile)
                    // Skip file header.
                    let fileHeader = 4 * 1024
                    fseek(pcmFile, fileHeader, SEEK_SET)

                    let mp3File: UnsafeMutablePointer<FILE> = fopen(outMp3Path, "wb")

                    let pcmSize = 1024 * 8
                    let pcmbuffer = UnsafeMutablePointer<Int16>.allocate(capacity: Int(pcmSize * 2))

                    let mp3Size: Int32 = 1024 * 8
                    let mp3buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(mp3Size))

                    var write: Int32 = 0
                    var read = 0

                    repeat {

                        let size = MemoryLayout<Int16>.size * 2
                        read = fread(pcmbuffer, size, pcmSize, pcmFile)
                        // Progress
                        if read != 0 {
                            let progress = Float(ftell(pcmFile)) / Float(fileSize)
                            print(progress)
                            //DispatchQueue.main.sync { onProgress(progress) }
                        }

                        if read == 0 {
                            write = lame_encode_flush(lame, mp3buffer, mp3Size)
                        } else {
                            write = lame_encode_buffer_interleaved(lame, pcmbuffer, Int32(read), mp3buffer, mp3Size)
                        }

                        fwrite(mp3buffer, Int(write), 1, mp3File)

                    } while read != 0

                    // Clean up
                    lame_close(lame)
                    fclose(mp3File)
                    fclose(pcmFile)

                    pcmbuffer.deallocate()
                    mp3buffer.deallocate()
                }
                
                return
            }
            print(error.localizedDescription)
        }
    }
    
    private func configureNodes() {
        guard let audioEngine = audioEngine, let mixerNode = mixerNode else {
            return
        }
        
        let inputNode = audioEngine.inputNode
        let inputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 1, interleaved: false)
        //let inputFormat = inputNode.outputFormat(forBus: 0)
        audioEngine.connect(inputNode, to: mixerNode, format: inputFormat)
        
        let mainMixerNode = audioEngine.mainMixerNode

        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 1, interleaved: false)
        audioEngine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    }
}
