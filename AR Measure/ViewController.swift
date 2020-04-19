//
//  ViewController.swift
//  AR Measure
//
//  Created by Abdelrahman Shehab on 4/18/20.
//  Copyright © 2020 Abdelrahman Shehab. All rights reserved.
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
        sceneView.delegate = self

        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    //MARK: - Setting The Location of 2-Dots

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2{
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestTouchs = sceneView.hitTest(touchLocation, types: .featurePoint)

            if let hitResult = hitTestTouchs.first {
                addDot(at: hitResult)
            }
        }
    }

    // Create Dot Method
    func addDot(at hitResult: ARHitTestResult) {

        let dotGeometry = SCNSphere(radius: 0.005)
        let dotMaterials = SCNMaterial()
        let dotNode = SCNNode(geometry: dotGeometry)

        dotMaterials.diffuse.contents = UIColor.red
        dotGeometry.materials = [dotMaterials]

        dotNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )

        sceneView.scene.rootNode.addChildNode(dotNode)

        dotNodes.append(dotNode)

        if dotNodes.count >= 2 {
            calculate()
        }
    }
    //MARK: - Calculating The Distance between 2-Dots
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]

        let distance = sqrt(
                pow(end.position.x - start.position.x, 2) +
                pow(end.position.y - start.position.y, 2) +
                pow(end.position.z - start.position.z, 2)
        )

        // distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
        let distanceCm = String(format: "%.2f", abs(distance * 100))
        updateText(text: "\(distanceCm) cm", atPosition: end.position)
        print(distanceCm)
    }

    //MARK: - Updating Text
    func updateText(text: String, atPosition position: SCNVector3) {

        textNode.removeFromParentNode()

        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)

        textGeometry.firstMaterial?.diffuse.contents = UIColor.green

        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)

        sceneView.scene.rootNode.addChildNode(textNode)
    }


}
