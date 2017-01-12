//
//  GameScene.swift
//  Game3
//
//  Created by Dinh Cong Thang on 2016-12-25.
//  Copyright © 2016 Dinh Cong Thang. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicCatagory {
    static let player : UInt32 = 0x1 << 1
    static let ledge : UInt32 = 0x1 << 2
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    var walls = SKNode()
    var ledge = SKSpriteNode()
    var fireEffect = SKEmitterNode()
    var leftW = SKSpriteNode()
    var rightW = SKSpriteNode()
    var scorelbl = SKLabelNode()
    var restartBtn = SKSpriteNode()
    var isDie = false
    var gameStart = false
    var randTime = 0.8
    var score:Int = 0{
        didSet{
        scorelbl.text = "\(score)"
        }
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xffffffff)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
    
    func createBtn(){
        restartBtn = SKSpriteNode(imageNamed: "restart")
        restartBtn.size = CGSize(width: 200, height: 100)
        restartBtn.position = CGPoint(x: frame.width/2, y: frame.height/2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        self.addChild(restartBtn)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
        
    }
    
    func restartGame(){
    self.removeAllActions()
    self.removeAllChildren()
    isDie = false
    gameStart = false
    score = 0
    initScene()
    
    }
    
    func addLedges(){
        let minX = leftW.size.width + ledge.size.width/2
        let maxX = self.size.width/2 + 51
        ledge = SKSpriteNode(imageNamed: "ledge")
        ledge.name = "ledge"
        ledge.position = CGPoint(x: minX, y: frame.size.height + 100)
        ledge.yScale = 0.5
        ledge.physicsBody = SKPhysicsBody(rectangleOf: ledge.size)
        ledge.physicsBody?.categoryBitMask = PhysicCatagory.ledge
        ledge.physicsBody?.contactTestBitMask = PhysicCatagory.player
        ledge.physicsBody?.collisionBitMask = PhysicCatagory.player
        ledge.physicsBody?.affectedByGravity = false
        ledge.physicsBody?.isDynamic = false
        ledge.zPosition = 1

    //move ledge
    let moveLedge = SKAction.moveTo(y: -50, duration: TimeInterval(2.5))
    let removeLedge = SKAction.removeFromParent()
    ledge.run(SKAction.sequence([moveLedge,removeLedge]))
    
    let posXarr = [minX,maxX,minX,maxX,minX,maxX,minX,maxX]
    let randomIndex = Int(arc4random_uniform(UInt32(posXarr.count)))
    let randomPos = posXarr[randomIndex]
    
    ledge.position.x = randomPos
    self.addChild(ledge)
    score = score + 1
    }
    
    func spawnLedges(){
        let spawnLedge = SKAction.run({
            () in self.addLedges()
        })
        
        let delaySpawnLedge = SKAction.wait(forDuration: TimeInterval(randTime))
        self.run(SKAction.repeatForever(SKAction.sequence([spawnLedge,delaySpawnLedge])))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if(firstBody.categoryBitMask == PhysicCatagory.player && secondBody.categoryBitMask == PhysicCatagory.ledge ||
            firstBody.categoryBitMask == PhysicCatagory.ledge && secondBody.categoryBitMask == PhysicCatagory.player){
        
            enumerateChildNodes(withName: "ledge", using: ({
                (node,error) in
                node.speed = 0
                self.removeAllActions()
            }))
            self.run(SKAction.playSoundFileNamed("sound/break.wav", waitForCompletion: true))
            player.physicsBody?.affectedByGravity = true
            player.physicsBody?.isDynamic = true
            player.removeAllActions()
            fireEffect.removeFromParent()
            if(isDie == false){
                isDie = true
                createBtn()
            }
            
        }
    }
    
    func initScene(){
        backgroundColor = UIColor.black
        
        //add scorelbl
        scorelbl.text = "0"
        scorelbl.fontSize = 30.0
        scorelbl.fontColor = UIColor.white
        scorelbl.position = CGPoint(x: 20, y: frame.size.height - 100)
        scorelbl.zPosition = 5
        self.addChild(scorelbl)
        
    //create wall
        
        leftW = SKSpriteNode(imageNamed: "wall")
        leftW.xScale = 0.15
        leftW.anchorPoint = CGPoint(x: 0, y: 0.5)
        leftW.position = CGPoint(x: 0, y: frame.size.height/2)
        leftW.zPosition = 2
        
        rightW = SKSpriteNode(imageNamed: "wall")
        rightW.xScale = 0.15
        rightW.anchorPoint = CGPoint(x: 1, y: 0.5)
        rightW.position = CGPoint(x: frame.size.width, y: frame.size.height/2)
        rightW.zPosition = 2
        
        walls.addChild(leftW)
        walls.addChild(rightW)
        
        self.addChild(walls)
        
    //create player
        player = SKSpriteNode(imageNamed: "arrow")
        player.position = CGPoint(x: player.size.width/2 + leftW.size.width, y: player.size.height + 20)
        player.setScale(0.6)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = PhysicCatagory.player
        player.physicsBody?.contactTestBitMask = PhysicCatagory.ledge
        player.physicsBody?.collisionBitMask = PhysicCatagory.ledge
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.zPosition = 3
        self.addChild(player)
        addFireEffect()
        
        spawnLedges()
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

            //add control to player
            if(player.position.x < frame.size.width/2){
                let moveRight = frame.size.width - rightW.size.width - player.size.width/2
                player.run(SKAction.moveTo(x: moveRight, duration: TimeInterval(0.2)))
                
            }
            if(player.position.x > frame.size.width/2){
                let moveLeft = leftW.size.width + player.size.width/2
                player.run(SKAction.moveTo(x: moveLeft, duration: TimeInterval(0.2)))
            }
        

            
        
        
        for touch in touches{
            let location = touch.location(in: self)
            if(isDie == true){
                if(restartBtn.contains(location)){
                    restartGame()
                }
            }
        }
    }
    
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.run(SKAction.playSoundFileNamed("sound/bg.mp3", waitForCompletion: true))
            initScene()
        
    }
    
    func addFireEffect(){
        fireEffect = SKEmitterNode(fileNamed: "fire.sks")!
        fireEffect.position = player.position
        fireEffect.setScale(0.2)
        fireEffect.zRotation = CGFloat(M_PI * 2)
        self.addChild(fireEffect)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if(isDie == false){
            
            
            if(score <= 10){
                randTime = 0.8
            }else if(score >= 11){
                randTime = 0.35
            }
            
            if(player.position.y < frame.size.height/2 + 150){
                player.run(SKAction.moveTo(y: frame.size.height/2 + 150, duration: TimeInterval(5)))
                fireEffect.position = player.position
                fireEffect.position.y = player.position.y - 25
                
            }else{
                player.position.y = frame.size.height/2 + 150
            }
        }

    }
}
