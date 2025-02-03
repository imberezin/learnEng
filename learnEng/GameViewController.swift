//
//  GameViewController.swift
//  learnEng
//
//  Created by Israel Berezin on 02/02/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
                
        if let view = self.view as! SKView? {
            let menuScene = MenuScene(size: view.bounds.size)
            menuScene.scaleMode = .aspectFill
            view.presentScene(menuScene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }


    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
