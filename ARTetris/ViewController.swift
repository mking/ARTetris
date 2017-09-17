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
    
    @IBOutlet var imageView: UIImageView!
    
    var didTap = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    var sessionConfig: ARSessionConfiguration = ARWorldTrackingSessionConfiguration()
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
    
    
    private func getSessionConfiguration() -> ARSessionConfiguration {
        if ARWorldTrackingSessionConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingSessionConfiguration()
            configuration.planeDetection = .horizontal
            return configuration;
        } else {
            // Slightly less immersive AR experience due to lower end processor
            return ARSessionConfiguration()
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
        
        let scene = TetrisScene(config, self.sceneView.scene, x, y, z)
        self.tetris = TetrisEngine(config, well, scene)
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
    }
    
    private func addGestures() {
        let swiftDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        swiftDown.direction = .down
        self.view.addGestureRecognizer(swiftDown)
        
        let swiftUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        swiftUp.direction = .up
        self.view.addGestureRecognizer(swiftUp)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc private func handleSwipe(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .down) {
            // drop down tetromino on swipe down
            tetris?.drop()
        } else {
            // rotate tetromino on swipe up
//            tetris?.rotate()
        }
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        if tetris == nil {
            if (sender.state == .ended) {
                didTap = true
            }
            
            return
        }
    }
    
    @IBAction func handleLeftSwipe(_ sender: UISwipeGestureRecognizer) {
        tetris?.rotateY(-1)
    }
    
    @IBAction func handleRightSwipe(_ sender: UISwipeGestureRecognizer) {
        tetris?.rotateY(1)
    }
    
    @IBAction func handleUpSwipe(_ sender: UISwipeGestureRecognizer) {
        tetris?.rotateX(-1)
    }
    
    @IBAction func handleDownSwipe(_ sender: UISwipeGestureRecognizer) {
        tetris?.rotateX(1)
    }
}
