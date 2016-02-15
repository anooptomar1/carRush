//
//  GameViewController.swift
//  Cars3d
//
//  Created by Lucas Farris on 12/02/16.
//  Copyright (c) 2016 Farris. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    var camera:SCNNode!
    var ground:SCNNode!
    var scene:SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createScene()
        createCamera()
        createGround()
        createScenario()
    }
    
    func createScenario() {
        for i in 20...70 {
            let laneMaterial = SCNMaterial()
            if i%5<2 {
                laneMaterial.diffuse.contents = UIColor.clearColor()
            } else {
                laneMaterial.diffuse.contents = UIColor.blackColor()
            }
            let laneGeometry = SCNBox(width: 0.2, height: 0.1, length: 1, chamferRadius:0)
            laneGeometry.materials = [laneMaterial]
            let lane = SCNNode(geometry: laneGeometry)
            lane.position = SCNVector3(x: 0, y: 0, z: -Float(i))
            scene.rootNode.addChildNode(lane)
            let moveDown = SCNAction.moveByX(0, y:0 , z: 5, duration: 0.3)
            let moveUp = SCNAction.moveByX(0, y: 0, z: -5, duration: 0)
            let moveLoop = SCNAction.repeatActionForever(SCNAction.sequence([moveDown, moveUp]))
            lane.runAction(moveLoop)
        }
    }
    
    func createScene () {
        scene = SCNScene()
        let scnView = self.view as! SCNView
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        scnView.playing = true
        scnView.autoenablesDefaultLighting = true
    }
    
    func createCamera () {
        camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(x: 0, y: 25, z: -18)
        camera.eulerAngles = SCNVector3(x: -1, y: 0, z: 0)
        camera.camera?.aperture = 1/2
        scene.rootNode.addChildNode(camera)
    }
    
    func createGround () {
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0.5
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.whiteColor()
        groundGeometry.materials = [groundMaterial]
        ground = SCNNode(geometry: groundGeometry)
        scene.rootNode.addChildNode(ground)
    }
    
}
