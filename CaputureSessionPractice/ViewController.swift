//
//  ViewController.swift
//  CaputureSessionPractice
//
//  Created by 坂本龍哉 on 2021/03/20.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var outputMetadataReadableCodeArray: [AVMetadataMachineReadableCodeObject]?
    let captureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        // ⑧ 承認されたらセッションの設定メソッドを呼ぶ
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                }
            }
        case .denied:
            return
        case .restricted:
            return
        @unknown default:
            fatalError("unknown case")
        }
    }
    
    override func viewDidLayoutSubviews() {  // navigationControllerの高さを取得してからプレビューレイヤーを作成したいのでここで呼び出すことにした
        // ⑩ プレビューレイヤーの作成
        setupPreviewLayer()
        // 11 セッションを起動する
        captureSession.startRunning()
    }
    
    func setupCaptureSession() {
        // ② 設定開始のメソッドを呼んでセッションの設定を行う
        captureSession.beginConfiguration()
        // ③ 取得したデバイスで入力されたものをセッションに追加
        let captureDevice = setupCaptureDevice()
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
              captureSession.canAddInput(captureDeviceInput)
        else { return }
        captureSession.addInput(captureDeviceInput)
        // ④ 次にキャプチャする予定のメディアに適した出力の設定を行う
        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else { return }
        captureSession.addOutput(metadataOutput)
        // ⑤ コールバックの処理に使用するデリゲートとディスパッチキューを設定(まだ使用していない)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // ⑥ ここで指定したタイプのオブジェクトのみがデリゲートのmetadataOutput(_:didOutput:from:)メソッドに転送され、処理される。
        metadataOutput.metadataObjectTypes = [.ean13]
        // ⑦ 設定を終了する
        captureSession.commitConfiguration()
    }
    
    func setupCaptureDevice() -> AVCaptureDevice {
        // ① 対応するデバイスを選択するメソッド
        if let device = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) { return device }
        else if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) { return device }
        else if let device = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) { return device}
        else { fatalError("Missing expected back camera device.") }
    }
    
    func setupPreviewLayer() {
        // ⑨ プレビューをセッションに接続し、viewに追加
        let previewLayer = PreviewView().videoPreviewLayer
        previewLayer.session = self.captureSession
        print(self.view.safeAreaInsets.top)
        previewLayer.frame = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.bounds.width, height: self.view.bounds.height / 5)
        previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(previewLayer)
    }
    
    // 12 デリゲートメソッドを利用して読み込めたときの処理を書く
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            if metadata.stringValue == nil { continue }
            print(metadata.stringValue!)
        }
    }
}
// ⑧ プレビューを作成
class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}


