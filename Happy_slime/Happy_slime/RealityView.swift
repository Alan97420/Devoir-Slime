//
//  RealityView.swift
//  Happy_slime
//
//  Created by Alan CHAN CHUN TIM on 23/11/2019.
//  Copyright © 2019 Alan CHAN CHUN TIM. All rights reserved.
//

import UIKit
import RealityKit

class RealityView: UIViewController {

    @IBOutlet weak var arView: ARView!
    var slime : Slime3D.Box!
    override func viewDidLoad() {
        super.viewDidLoad()

        slime = try! Slime3D.loadBox()
        slime.generateCollisionShapes(recursive: true)
        arView.scene.anchors.append(slime)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
