//
//  GameScene.swift
//  SuperSoduku
//
//  Created by BIINGYANN HSIUNG on 12/20/14.
//  Copyright (c) 2014 BIINGYANN HSIUNG. All rights reserved.
//

import SpriteKit



class GameScene: SKScene,GameSceneDelegation
{
    class var systemFont:String {
        return "Futura-Medium"
    }

    let exitButtonFont = "GillSans-Bold";
    var difficulty:GameDifficulty = GameDifficulty.easy
    var gameControllerDelegation: GameControllerDelegation?
    var gridCellController:GridCellController?
    var bannerHeight:CGFloat {
        return self.frame.height > 480 ? 50 : 0
    }
    var completeEffect:CompleteEffect?
    
    override func didMoveToView(view: SKView) {
        makeGrid()
        makeNumberButtons()
        if(difficulty.dimension >= 2){
            makeColorButtons()
        }
        makeUtil()
        self.backgroundColor = SKColor(red: 0.90, green: 0.90, blue: 0.85, alpha: 1)
        //completeEffect = CompleteEffect.complete(self,score:1234)
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch:UITouch = touches.anyObject() as UITouch;
        let location = touch.locationInNode(self);
        let touchedNode = nodeAtPoint(location)
        if touchedNode is SKLabelNode{
            if let button:SKLabelNode = touchedNode as? SKLabelNode{
                if let buttonName:String = button.name {
                    if(buttonName == "exit-button"){
                        self.gameControllerDelegation?.quitFromGame()
                    }else if(buttonName == "replay-button"){
                        gridCellController?.shuffleCellFixStatus()
                        gridCellController?.assignCellNumbers()
                        completeEffect?.dismiss()
                    }
                }
            }
        }
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    func makeUtil()
    {
        var exitButtonNode = SKLabelNode(fontNamed: exitButtonFont)
        exitButtonNode.text = "QUIT"
        exitButtonNode.fontSize = 18
        
        let x:CGFloat = frame.width - 10;
        let bottomPadding:CGFloat = 30
        let y:CGFloat = -1 * ( self.frame.height - bannerHeight - bottomPadding);
        
        let bgNode = SKShapeNode(path: CGPathCreateWithRoundedRect(
            CGRectMake(0, 0, 80, 30), 4, 4, nil));
        bgNode.strokeColor = SKColor.clearColor()
        bgNode.fillColor = GridCellColor.red.color
        bgNode.position = CGPointMake(x-bgNode.frame.width, y - bgNode.frame.height/2)
        
        exitButtonNode.position = CGPointMake(bgNode.position.x + bgNode.frame.width/2, y)
        exitButtonNode.fontColor = SKColor.whiteColor()
        exitButtonNode.name = "exit-button"
        exitButtonNode.fontName = GameScene.systemFont
        exitButtonNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        exitButtonNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
    
        self.addChild(bgNode)
        self.addChild(exitButtonNode)
    }
    func makeGrid()
    {
        let offsetX:CGFloat = 10, offsetY:CGFloat = -30;
        self.gridCellController = GridCellController(
            width: self.frame.width - 2 * offsetX,
            numberOfRow: 9,
            scene: self,
            x: offsetX,
            y: offsetY,
            d: self.difficulty);
    }
    func makeNumberButtons()
    {
        let xoffset:CGFloat = 10;
        let bottomPadding:CGFloat = 45
        var yoffset:CGFloat = -1 * ( self.frame.height - bannerHeight - bottomPadding);
        let p:CGFloat = 5.0;
        let numberOfColumnPerRow = frame.height <= 480 ? 9.0 : 3.0;
        let numberOfRows:CGFloat = 9 / CGFloat(numberOfColumnPerRow);
        
        if(numberOfRows>1){
            var clearButton = ClearButton()
            clearButton.gridCellControllerDelegation = gridCellController
            addChild(clearButton)
            clearButton.position = CGPointMake(xoffset,yoffset)
        }
        
        yoffset += CGFloat(numberOfRows) * (NumberButton.width + p*2)
        for(var i=1; i<10; i++){
            let _i = CGFloat(i);
            var button = NumberButton(buttonIndex: i);
            button.gridCellControllerDelegation = gridCellController
            var w:CGFloat = CGFloat(NumberButton.width)
            var newY = yoffset - (w+p) * floor((_i-1)/CGFloat(numberOfColumnPerRow))
            button.position = CGPointMake(
                xoffset + ((_i-1) % CGFloat(numberOfColumnPerRow)) * (w+p), newY);
            self.addChild(button)
        }
    }
    func makeColorButtons()
    {
        var xoffset:CGFloat = 120;
        let bottomPadding:CGFloat = 45
        var yoffset:CGFloat = -1 * ( self.frame.height - bannerHeight - bottomPadding);
        let p:CGFloat = 5.0;
        let numberOfColumnPerRow = frame.height <= 480 ? 9.0 : 3.0;
        let numberOfRows:CGFloat = 9 / CGFloat(numberOfColumnPerRow);
        
        if(numberOfRows>1){
            var clearButton = ClearColorButton()
            clearButton.gridCellControllerDelegation = gridCellController
            addChild(clearButton)
            clearButton.position = CGPointMake(xoffset,yoffset)
        }else{
            xoffset = 10
            yoffset += NumberButton.width + p*2
        }
        
        yoffset += CGFloat(numberOfRows) * (NumberButton.width + p)
        for(var i=1; i<10; i++){
            let _i = CGFloat(i);
            var button = ColorButton(index: i)
            button.gridCellControllerDelegation = gridCellController
            var w:CGFloat = CGFloat(NumberButton.width)
            var newY = yoffset - (w+p) * floor((_i-1)/CGFloat(numberOfColumnPerRow))
            button.position = CGPointMake(
                xoffset + ((_i-1) % CGFloat(numberOfColumnPerRow)) * (w+p), newY);
            self.addChild(button)
        }

    }
    func userSetNumber(i: Int) {
        self.gridCellController?.setNumber(i)
    }
    func complete() {
        completeEffect = CompleteEffect.complete(self,score:1234)
        UserProfile.exp += difficulty.expGain
    }
}
class CompleteEffect: SKNode
{
    var score: Int
    let gameScene:GameScene
    let label:SKLabelNode
    let background: SKShapeNode
    let overlay: SKShapeNode
    let exitButtonNode: SKLabelNode, replayButtonNode:SKLabelNode
    let titleFont = "AvenirNextCondensed-HeavyItalic"
    let utilFont = "GillSans-Bold"
    let overlayColor = SKColor(red: 0.8, green: 0.36, blue: 0.36, alpha: 1);
    
    class func complete(scene:GameScene,score:Int) -> CompleteEffect
    {
        let node = CompleteEffect(score: score,scene: scene);
        scene.addChild(node)
        node.zPosition = 5;
        node.play()
        return node
    }
    init(score:Int,scene:GameScene)
    {
        self.score = score
        self.gameScene = scene
        
        label = SKLabelNode(fontNamed: titleFont)
        background = SKShapeNode(rect: CGRectMake(0, 0, self.gameScene.frame.width, self.gameScene.frame.height));
        overlay = SKShapeNode(rect: CGRectMake(0, 0, self.gameScene.frame.width, 100));
        exitButtonNode = SKLabelNode(fontNamed: utilFont)
        replayButtonNode = SKLabelNode(fontNamed: utilFont)

        super.init()
        createTitle()
        createBackground()
        createOverlay()
        createUtil()

        self.addChild(background)
        self.addChild(overlay)
        self.addChild(label)

    }
    func createUtil()
    {
        let padding:CGFloat = 10
        exitButtonNode.text = "Back to menu"
        exitButtonNode.fontSize = 15
        exitButtonNode.fontColor = SKColor.whiteColor()
        exitButtonNode.position = CGPointMake(
            overlay.position.x + overlay.frame.width - padding,
            overlay.position.y + padding
        )
        exitButtonNode.zPosition = 2
        exitButtonNode.alpha = 0
        exitButtonNode.name = "exit-button"
        exitButtonNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        replayButtonNode.text = "Replay"
        replayButtonNode.fontSize = 15
        replayButtonNode.fontColor = SKColor.whiteColor()
        replayButtonNode.position = CGPointMake(
            overlay.position.x + overlay.frame.width - padding - 130,
            overlay.position.y + padding
        )
        replayButtonNode.zPosition = 3
        replayButtonNode.alpha = 0
        replayButtonNode.name = "replay-button"
        replayButtonNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        
        self.addChild(exitButtonNode)
        self.addChild(replayButtonNode)
    }
    func createOverlay()
    {
        overlay.fillColor = overlayColor
        overlay.strokeColor = SKColor.clearColor()
        overlay.position = CGPointMake(0, -1 * ((gameScene.frame.height + overlay.frame.height) / 2))
        overlay.alpha = 0
    }
    func createBackground()
    {
        background.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.4);
        background.strokeColor = SKColor.clearColor()
        background.position = CGPointMake(0, -1 * background.frame.height)
        background.alpha = 0

    }
    func createTitle()
    {
        label.fontColor = SKColor.whiteColor()
        label.text = "Congratulations!!";
        label.fontSize = 20;
        label.alpha = 0
        label.position = CGPointMake(CGFloat(gameScene.frame.width/2), CGFloat(-1*self.gameScene.frame.height/2));
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
    }
    func play()
    {
        background.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.3), completion: {
            self.overlay.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.3))
            self.label.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.3),completion:{
                self.exitButtonNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.6))
                self.replayButtonNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.6))
            })
        })
    }
    func dismiss()
    {
        background.runAction(SKAction.fadeAlphaTo(0.0, duration: 0.1), completion: {
            self.overlay.runAction(SKAction.fadeAlphaTo(0.0, duration: 0.3))
            self.label.runAction(SKAction.fadeAlphaTo(0.0, duration: 0.3),completion:{
                self.exitButtonNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.3))
                self.replayButtonNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.7), completion:{
                    self.removeFromParent()
                })
            })
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class NumberButton: SKNode
{
    var i:Int
    let bgNode:SKShapeNode
    let numberNode:SKLabelNode
    class var width:CGFloat {
        return 28.9
    }
    let fontSize:CGFloat = 18
    var gridCellControllerDelegation:GridCellDelegation?
    init(buttonIndex:Int)
    {
        self.bgNode = SKShapeNode(path: CGPathCreateWithRoundedRect(
            CGRectMake(0, 0, CGFloat(NumberButton.width), CGFloat(NumberButton.width)), 4, 4, nil));
        self.bgNode.strokeColor = SKColor.clearColor()
        self.bgNode.fillColor = SKColor.whiteColor()
        self.bgNode.position = CGPointMake(0, CGFloat(-1.0 * NumberButton.width));
        
        self.numberNode = SKLabelNode(fontNamed: GameScene.systemFont);
        self.numberNode.fontSize = fontSize;
        self.numberNode.fontColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        
        self.numberNode.position = CGPointMake(CGFloat(NumberButton.width/2), CGFloat(-1*NumberButton.width/2));
        self.numberNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.numberNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        self.numberNode.text = NSString(format: "%d", buttonIndex)
        self.i = buttonIndex
        
        super.init();
        self.userInteractionEnabled = true;
        self.addChild(bgNode)
        self.addChild(numberNode)
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.gridCellControllerDelegation?.setNumber(self.i,isAnnotation: false)
        bgNode.fillColor = GridCellColor.gray.color
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        bgNode.fillColor = SKColor.whiteColor()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class ClearButton:SKNode
{
    let bgNode:SKShapeNode
    let labelNode:SKLabelNode
    let width = 100.0
    let height = 30.0
    let fontSize:CGFloat = 18
    var gridCellControllerDelegation:GridCellDelegation?
    override init()
    {
        self.bgNode = SKShapeNode(path: CGPathCreateWithRoundedRect(
            CGRectMake(0, 0, CGFloat(width), CGFloat(height)), 4, 4, nil));
        self.bgNode.strokeColor = SKColor.clearColor()
        self.bgNode.fillColor = GridCellColor.orange.color
        self.bgNode.position = CGPointMake(0, CGFloat(-1.0 * height));
        
        self.labelNode = SKLabelNode(fontNamed: GameScene.systemFont);
        self.labelNode.fontSize = fontSize;
        self.labelNode.fontColor = SKColor.whiteColor()
        
        self.labelNode.position = CGPointMake(CGFloat(width/2), CGFloat(-1*height/2));
        self.labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        self.labelNode.text = "CLEAR"
        
        super.init();
        self.userInteractionEnabled = true;
        self.addChild(bgNode)
        self.addChild(labelNode)
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.gridCellControllerDelegation?.clearNumber()
        bgNode.runAction(SKAction.fadeAlphaTo(0.2, duration: 0.3),withKey:"touchDown")
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        bgNode.removeActionForKey("touchDown")
        bgNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.1))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class ColorButton:SKNode
{
    var color:GridCellColor
    let bgNode:SKShapeNode
    var gridCellControllerDelegation:GridCellDelegation?
    init(index:Int)
    {
        color = GridCellColor(rawValue: index)!
        self.bgNode = SKShapeNode(path: CGPathCreateWithRoundedRect(
            CGRectMake(0, 0, CGFloat(NumberButton.width), CGFloat(NumberButton.width)), 4, 4, nil));
        self.bgNode.strokeColor = SKColor.clearColor()
        self.bgNode.fillColor = color.color
        self.bgNode.position = CGPointMake(0, CGFloat(-1.0 * NumberButton.width));
        
        super.init();
        self.userInteractionEnabled = true;
        self.addChild(bgNode)
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.gridCellControllerDelegation?.setColor(color,isAnnotation:false)
        bgNode.runAction(SKAction.fadeAlphaTo(0.2, duration: 0.3),withKey:"touchDown")
    }
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        bgNode.removeActionForKey("touchDown")
        bgNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.1))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class ClearColorButton:ClearButton
{
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.gridCellControllerDelegation?.clearColor()
        bgNode.runAction(SKAction.fadeAlphaTo(0.2, duration: 0.3),withKey:"touchDown")
    }
}
