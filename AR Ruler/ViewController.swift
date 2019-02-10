//
//  ViewController.swift
//  AR Ruler
//
//  Created by Randy Hsu on 2019-02-09.
//  Copyright © 2019 DeveloperRandy. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        self.sceneView.delegate = self
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        self.sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        self.sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.dotNodes.count >= 2 {
            for dotNode in dotNodes {
                dotNode.removeFromParentNode()
            }
            self.dotNodes.removeAll()
            self.textNode.removeFromParentNode()
        }
        
        if let touchLocation = touches.first?.location(in: self.sceneView) {
            let hitTestResults = self.sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
        
    }
    
    func addDot(at hitResult:ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(dotNode)
        self.dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        let p1 = dotNodes[0].simdPosition
        let p2 = dotNodes[1].simdPosition

        let distance = simd_distance(p1, p2) * 100
        displayOnScreen(text: String(format: "%.1f cm", distance), position: p2)
    }
    
    func displayOnScreen(text: String, position: simd_float3) {
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        self.textNode = SCNNode(geometry: textGeometry)
        self.textNode.simdPosition = simd_float3(position.x, position.y + 0.01, position.z)
        self.textNode.scale = SCNVector3(0.01, 0.01, 0.01)

        self.sceneView.scene.rootNode.addChildNode(textNode)
        
    }
}
