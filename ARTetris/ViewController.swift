//
//  ViewController.swift
//  ARTetris
//
//  Created by Yuri Strot on 6/27/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var tetris: TetrisEngine?
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    var movementHandler: TetrisMovementHandler!
    
    var startScale: Float = 0
    var startRotation: Float = 0
    var didTap = false
    var showTutorial = false
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkCamera()
        
//        // Set the view's delegate
//        sceneView.delegate = self
//
//        // Create a new scene
//        sceneView.scene = SCNScene()
//        // Use default lighting
//        sceneView.autoenablesDefaultLighting = true
        setupScene()
        setupFocusSquare()
        addGestures()
        
        showTutorial = TetrisDefaults.showTutorial
        TetrisDefaults.showTutorial = false
        if showTutorial {
            showTemporaryMessage(message: "Point the camera to a flat surface", completion: { _ in
                self.showTemporaryMessage(message: "Tap to place the board. Use two fingers to pinch or rotate the board.")
            })
        }
    }
    
    func checkCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status != .authorized && status != .notDetermined {
            let alert = UIAlertController(title: nil, message: "This app requires access to the camera. Please enable the permission in Settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Run the view's session
        sceneView.session.run(getSessionConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARKit / ARSCNView
    let session = ARSession()
    var sessionConfig: ARConfiguration = ARWorldTrackingConfiguration()
    var use3DOFTracking = false 
    var use3DOFTrackingFallback = false
    var screenCenter: CGPoint?
    
    func setupScene() {
        // set up sceneView
        sceneView.delegate = self
        sceneView.session = session
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = false
        
        sceneView.preferredFramesPerSecond = 60
        sceneView.contentScaleFactor = 1.3
        //sceneView.showsStatistics = true
        
        sceneView.scene.lightingEnvironment.intensity = 25.0
        
        DispatchQueue.main.async {
            self.screenCenter = self.sceneView.bounds.mid
        }
        
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
    }
    
    
    private func getSessionConfiguration() -> ARConfiguration {
        if ARWorldTrackingConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            return configuration;
        } else {
            // Slightly less immersive AR experience due to lower end processor
            return AROrientationTrackingConfiguration()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        // We need async execution to get anchor node's position relative to the root
//        DispatchQueue.main.async {
//            self.updateFocusSquare()
//            if let planeAnchor = anchor as? ARPlaneAnchor {
//                // For a first detected plane
//                if (self.tetris == nil && self.didTap) {
//                    self.placeTetris(planeAnchor: planeAnchor, node: node)
//
////                    // get center of the plane
////                    let x = planeAnchor.center.x + node.position.x
////                    let y = planeAnchor.center.y + node.position.y
////                    let z = planeAnchor.center.z + node.position.z
////                    // initialize Tetris with a well placed on this plane
////                    let config = TetrisConfig.standard
////                    let well = TetrisWell(config)
////                    let scene = TetrisScene(config, self.sceneView.scene, x, y, z)
////                    self.tetris = TetrisEngine(config, well, scene)
//                }
//            }
//        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func placeTetris() {
        // place tetris at last focus square position
//        print("+++ focus square position \(focusSquare!.position)")
        
        // initialize Tetris with a well placed on this plane
        let config = TetrisConfig.standard
        let well = TetrisWell(config)
        
        let x = focusSquare!.position.x
        let y = focusSquare!.position.y
        let z = focusSquare!.position.z
        let cell = 0.03 * focusSquare!.scaleBasedOnDistance(camera: self.session.currentFrame?.camera)
        let lineWidth = 0.001 * focusSquare!.scaleBasedOnDistance(camera: self.session.currentFrame?.camera)

        movementHandler = TetrisMovementHandler(config: config, position: SCNVector3(x, y ,z), cell: cell, lineWidth: lineWidth)
        let scene = TetrisScene(config, self.sceneView.scene, movementHandler, x, y, z, cell, restartButton, lineWidth, { (currentScore, previousScore) in
            self.showTemporaryMessage(message: "Congratulations! \(currentScore) is the new high score. The previous high score was \(previousScore).")
        })
        let overlay = TetrisOverlay(scoreLabel: scoreLabel)
        self.tetris = TetrisEngine(config, well, scene, overlay)
        
        if showTutorial {
            showTemporaryMessage(message: "Create a line of blocks to score points", completion: { _ in
                self.showTemporaryMessage(message: "Swipe left and right to rotate. Swipe up to rotate vertically. Swipe down to drop.")
            })
        }
    }
    
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {            
            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor as? ARPlaneAnchor
//            print("+++ plane anchor position \(planeAnchor!.center)")
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor, true)
        }
        
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if infinitePlane || !highQualityFeatureHitTestResult {
            let pointOnPlane = objectPos ?? SCNVector3Zero
            
            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
    
    
    
    // MARK: - Focus Square
    var focusSquare: FocusSquare?
    
    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        sceneView.scene.rootNode.addChildNode(focusSquare!)
        
        //textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
    
    func updateFocusSquare() {
        guard let screenCenter = screenCenter else { return }
        if self.tetris != nil {
            focusSquare?.hide()
        } else {
            focusSquare?.unhide()
        }
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare?.position)
        if let worldPos = worldPos {
            focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
        }
        
        if didTap && tetris == nil {
            placeTetris()
        }
        
//        if let s = focusSquare, let p = s.lastPosition {
//            print("tetris position \(p)")
//        }
    }
    
    private func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.view.addGestureRecognizer(tap)
    }

    @objc private func handleTap(sender: UITapGestureRecognizer) {
        if tetris == nil {
            if (sender.state == .ended) {
                didTap = true
            }
            
            return
        } else {
            tapTranslate(sender: sender)
        }
    }
    
    func tapTranslate(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let position = sender.location(in: sceneView)
            let results = sceneView.hitTest(position, options: [.categoryBitMask: TetrisCategories.arrow.rawValue, .searchMode: SCNHitTestSearchMode.all.rawValue])
            for result in results {
                if let name = result.node.name {
                    var flash = false
                    switch name {
                    case "left":
                        tetris!.left()
                        flash = true
                    case "right":
                        tetris!.right()
                        flash = true
                    case "backward":
                        tetris!.backward()
                        flash = true
                    case "forward":
                        tetris!.forward()
                        flash = true
                    default:
                        break
                    }
                    if flash {
                        movementHandler.flash(node: sceneView.scene.rootNode.childNode(withName: "arrow-\(name)", recursively: true)!)
                    }
                }
            }
        }
    }
    
    @IBAction func handleLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        tetris?.rotateY(-1)
    }
    
    @IBAction func handleRightSwipe(_ sender: UISwipeGestureRecognizer) {
        tetris?.rotateY(1)
    }
    
    @IBAction func handleUpSwipe(_ sender: UISwipeGestureRecognizer) {
        tetris?.rotateX(1)
    }
    
    @IBAction func handlePinch(_ sender: UIPinchGestureRecognizer) {
        guard tetris != nil else { return }

        switch sender.state {
        case .began:
            startScale = tetris!.scene.scale
        case .changed:
            tetris!.scene.scale = startScale * Float(sender.scale)
        default:
            break
        }
    }
    
    @IBAction func restart(_ sender: UIButton) {
        assert(tetris != nil, "shouldn't show restart button if game hasn't started yet")
        restartButton.isHidden = true
        tetris!.restart()
    }
    
    @IBAction func handleMenu(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Quit", style: .`default`, handler: { _ in
            if let tetris = self.tetris {
                TetrisDefaults.topScore = tetris.scores
            }
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func handleDown(_ sender: UISwipeGestureRecognizer) {
        tetris?.drop()
    }
    
    func showTemporaryMessage(message: String, completion: ((Bool) -> Void)? = nil) {
        messageLabel.text = message
        messageLabel.alpha = 1.0
        UIView.animate(withDuration: 1.0, delay: 4.0, options: .curveEaseOut, animations: {
            self.messageLabel.alpha = 0.0
        }, completion: completion)
    }
    
    @IBAction func handleRotate(_ sender: UIRotationGestureRecognizer) {
        guard tetris != nil else { return }
        
        switch sender.state {
        case .began:
            startRotation = tetris!.scene.rotation
        case .changed:
            tetris!.scene.rotation = startRotation - Float(sender.rotation)
        default:
            break
        }
    }
}
