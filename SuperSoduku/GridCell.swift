//
//  GridCell.swift
//  SuperSoduku
//
//  Created by BIINGYANN HSIUNG on 1/12/15.
//  Copyright (c) 2015 BIINGYANN HSIUNG. All rights reserved.
//

import Foundation
import SpriteKit

class GridCell:SKNode
{
    var controllerDelegate:GridCellDelegation?
    let numberNode:SKLabelNode,bgNode:SKShapeNode
    let x:Int,y:Int,width:Float
    let fontSize:CGFloat = 13
    var annotationLabels:[SKLabelNode]
    var colorFlagNode:SKShapeNode
    let colorFlagPadding:Float = 4
    var color:GridCellColor = GridCellColor.clear
    
    let errorFontColor:SKColor = SKColor.redColor()
    let normalFontColor:SKColor = SKColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    let definedFontColor:SKColor = SKColor.blackColor()
    
    let isFixed:Bool,isFixedColor:Bool
    
    var number:Int?{
        didSet{
            self.numberNode.text = String(format: "%d", number!);
        }
    }
    init(x:Int,y:Int,width:Float,isFixed:Bool,backgroundColor: SKColor,isFixedColor:Bool)
    {
        self.bgNode = SKShapeNode(rect: CGRectMake(0, 0, CGFloat(width), CGFloat(width)))
        self.bgNode.fillColor = backgroundColor
        self.bgNode.strokeColor = SKColor.clearColor()
        self.bgNode.position = CGPointMake(0, CGFloat(-1.0 * width));
        
        self.colorFlagNode = SKShapeNode(path: CGPathCreateWithRoundedRect(
            CGRectMake(0, 0, CGFloat(width - colorFlagPadding * Float(2)), CGFloat(width - colorFlagPadding * Float(2))),
            3, 3, nil));
        self.colorFlagNode.fillColor = SKColor.clearColor()
        self.colorFlagNode.strokeColor = SKColor.clearColor()
        self.colorFlagNode.position = CGPointMake(CGFloat(colorFlagPadding), CGFloat(colorFlagPadding - width));
        
        self.numberNode = SKLabelNode(fontNamed: GameScene.systemFont);
        self.numberNode.fontSize = fontSize;
        if(isFixed){
            self.numberNode.fontColor = definedFontColor;
        }else{
            self.numberNode.fontColor = normalFontColor;
        }
        self.numberNode.position = CGPointMake(CGFloat(width/2), CGFloat(-1*width/2));
        self.numberNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        self.numberNode.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        self.numberNode.text = ""
        self.annotationLabels = Array<SKLabelNode>()
        
        self.x = x
        self.y = y
        self.width = width
        self.isFixed = isFixed
        self.isFixedColor = isFixedColor
        super.init();
        makeAnnotation()
        
        self.userInteractionEnabled = true;
        self.addChild(bgNode)
        self.addChild(numberNode)
        self.addChild(colorFlagNode)
    }
    func setBackgroundColor(newColor:GridCellColor)
    {
        color = newColor
        colorFlagNode.fillColor = color.color
    }
    func makeAnnotation()
    {
        let xOffset:Float = 5
        let yOffset:Float = -6
        self.annotationLabels = Array(count: 9, repeatedValue: SKLabelNode())
        for i in 0...8{
            if(i == 4){
                continue
            }
            var x = Float(i%3)
            var y = Float(floor(Double(i)/3))
            annotationLabels[i] = SKLabelNode(fontNamed: GameScene.systemFont);
            annotationLabels[i].fontSize = 6;
            annotationLabels[i].fontColor = definedFontColor;
            annotationLabels[i].position = CGPointMake(CGFloat(xOffset+x*width/3), CGFloat(yOffset-1*y*width/3));
            annotationLabels[i].text = ""
            annotationLabels[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            annotationLabels[i].verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            //self.addChild(annotationLabels[i])
        }
    }
    func annotate(number:Int)
    {
        var found:Bool = false
        for i in 0...8{
            if(i == 4){
                continue
            }
            if(annotationLabels[i].parent == nil){
                self.addChild(annotationLabels[i])
            }
            
            if(annotationLabels[i].text == String(number)){
                found = true
            }
            if(!found){
                if(annotationLabels[i].text == ""){
                    annotationLabels[i].text = String(number)
                    break
                }else{
                    continue
                }
            }else{
                if(i<8){
                    if(i == 3){
                        annotationLabels[i].text = annotationLabels[i+2].text
                    }else{
                        annotationLabels[i].text = annotationLabels[i+1].text
                    }
                }
            }
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if(!self.isFixed){
            self.controllerDelegate?.moveCursor(Pos(x:self.x,y:self.y));
        }
    }
    func startFlashing()
    {
        self.stopFlashing()
        self.runAction(SKAction.repeatActionForever(SKAction.sequence(
            [SKAction.fadeAlphaTo(0.5, duration: 0.5),SKAction.fadeAlphaTo(1, duration: 0.2)]
            )), withKey: "flash")
    }
    func stopFlashing()
    {
        removeActionForKey("flash");
        self.alpha = 1
    }
    func error()
    {
        if(!self.isFixed){
            self.numberNode.fontColor = errorFontColor;
        }
    }
    func unerror()
    {
        if(!self.isFixed){
            self.numberNode.fontColor = normalFontColor;
        }
    }
    func errorColor()
    {
        if(!self.isFixed){
            //todo
            //self.numberNode.fontColor = errorFontColor;
        }
    }
    func unerrorColor()
    {
        if(!self.isFixed){
            //todo
            //self.numberNode.fontColor = normalFontColor;
        }
    }
}

class GridCellController:GridCellDelegation
{
    let width:Int, numberOfRow: Int, scene: SKScene
    var cells:[[GridCell]];
    var gameSceneDelegation:GameSceneDelegation
    let difficulty:GameDifficulty
    
    var currentPos:Pos{
        willSet{
            println("\(self.currentPos.x),\(newValue.x)")
            cells[self.currentPos.x][self.currentPos.y].stopFlashing()
            cells[newValue.x][newValue.y].startFlashing()
        }
    }
    
    init(width:Int,numberOfRow:Int,scene:GameScene,x:Float,y:Float,d:GameDifficulty)
    {
        self.width = width
        self.numberOfRow = numberOfRow
        self.scene = scene
        self.currentPos = Pos(x: 0,y: 0)
        var cellWidth:Float = Float(width/numberOfRow);
        self.cells = Array<Array<GridCell>>()
        self.difficulty = d
        self.gameSceneDelegation = scene
        var padding:Float = 1
        let xOffset = x+padding
        let yOffset = y+padding
        var cellBackgroundColor:SKColor
        for _x in 0...numberOfRow-1 {
            self.cells.append(Array(count: numberOfRow, repeatedValue: GridCell(x:0,y:0,width:cellWidth,isFixed: true,backgroundColor: SKColor.whiteColor(),isFixedColor: true)));
            for _y in 0...numberOfRow-1{
                if(cellGourpNumberFromPosition(_x,y:_y) % 2 == 0){
                    cellBackgroundColor = SKColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
                }else{
                    cellBackgroundColor = SKColor.whiteColor()
                }
                var gridCell:GridCell = GridCell(
                    x: _x, y: _y, width: cellWidth - padding,
                    isFixed: self.difficulty.cellShouldBeFixed,
                    backgroundColor:cellBackgroundColor,
                    isFixedColor: self.difficulty.cellShouldBeFixed
                );
                gridCell.controllerDelegate = self;
                var xMovement = Float(_x)*cellWidth;
                var yMovement = Float(_y)*cellWidth;
                gridCell.position = CGPointMake(CGFloat(xOffset+xMovement), CGFloat(yOffset-yMovement));
                scene.addChild(gridCell)
                self.cells[_x][_y] = gridCell;
            }
        }
        self.assignCellNumbers();
    }
    func cellGourpNumberFromPosition(x:Int,y:Int)->Int
    {
        var w = sqrtf(Float(numberOfRow))
        var i = floor(Float(x)/w)
        i += w*floor(Float(y)/w)
        return Int(i)
    }
    func setNumber(number:Int,isAnnotation:Bool = false)
    {
        let currentCell:GridCell = self.cells[self.currentPos.x][self.currentPos.y];
        if(isAnnotation){
            currentCell.annotate(number)
        }else{
            currentCell.number = number;
            if(self.isBoardComplete()){
                if(self.completeValidate()){
                    return self.gameSceneDelegation.complete()
                }
            }
            if(self.validate(self.currentPos)){
                currentCell.unerror();
            }else{
                currentCell.error();
            }
        }
    }
    func setColor(color:GridCellColor,isAnnotation:Bool = false)
    {
        let currentCell:GridCell = self.cells[self.currentPos.x][self.currentPos.y];
        if(isAnnotation){
            //currentCell.annotate(number)
        }else{
            currentCell.setBackgroundColor(color)
            if(self.isBoardComplete()){
                if(self.completeValidate()){
                    return self.gameSceneDelegation.complete()
                }
            }
            if(self.validate(self.currentPos)){
                currentCell.unerror();
            }else{
                currentCell.error();
            }
        }
    }
    func isBoardComplete() ->Bool
    {
        for x in 0...numberOfRow-1 {
            for y in 0...numberOfRow-1{
                if(cells[x][y].number == nil){
                    return false
                }
            }
        }
        if(difficulty.dimension >= 2){
            for x in 0...numberOfRow-1 {
                for y in 0...numberOfRow-1{
                    if(cells[x][y].color == GridCellColor.clear){
                        return false
                    }
                }
            }
        }
        return true;
    }
    func completeValidate() ->Bool
    {
        for x in 0 ... numberOfRow-1{
            for y in 0 ... numberOfRow-1{
                if(!validate(Pos(x: x,y:y))){
                    return false;
                }
            }
        }
        if(difficulty.dimension >= 2){
            // todo combination duplication checking
        }
        return true;
    }
    func validate(pos:Pos)->Bool
    {
        cells[pos.x][pos.y].error()
        if(!validateRow(pos.x,y:pos.y)){
            return false
        }
        if(!validateCol(pos.x,y:pos.y)){
            return false
        }
        if(!validateGroup(pos.x,y:pos.y)){
            return false
        }
        cells[pos.x][pos.y].unerror()
        
        if(difficulty.dimension >= 2){
            cells[pos.x][pos.y].errorColor()
            if(!validateRow(pos.x,y:pos.y,isColor: true)){
                return false
            }
            if(!validateCol(pos.x,y:pos.y,isColor: true)){
                return false
            }
            if(!validateGroup(pos.x,y:pos.y,isColor: true)){
                return false
            }
            cells[pos.x][pos.y].unerrorColor()
        }
        return true;
    }
    func validateRow(x:Int,y:Int,isColor:Bool = false)->Bool
    {
        
        for _x in 0 ... numberOfRow-1{
            if(!isColor && _x != x && cells[x][y].number == cells[_x][y].number){
                return false
            }else if(isColor && x != x && cells[x][y].color == cells[_x][y].color){
                return false
            }
        }
        return true;
    }
    func validateCol(x:Int,y:Int, isColor:Bool = false)->Bool
    {
        for _y in 0 ... numberOfRow-1{
            if(!isColor && _y != y && cells[x][y].number == cells[x][_y].number){
                return false
            }else if(isColor && _y != y && cells[x][y].color == cells[x][_y].color){
                return false
            }
        }
        return true;
    }
    func validateGroup(x:Int,y:Int,isColor:Bool = false)->Bool
    {
        let groupSize = sqrtf(Float(numberOfRow))
        let xStart = Int(floorf(Float(x)/groupSize)*groupSize);
        let xEnd = xStart+Int(groupSize)-1
        let yStart = Int(floorf(Float(y)/groupSize)*groupSize);
        let yEnd = yStart+Int(groupSize)-1
        //println("(\(xStart)...\(xEnd)),(\(yStart)...\(yEnd)) pos:(\(x),\(y)), num: \(cells[x][y].number)")
        for(var _x=xStart; _x<=xEnd; _x++){
            for(var _y=yStart; _y<=yEnd; _y++){
                if(!isColor && _y != y && _x != x && cells[x][y].number == cells[_x][_y].number){
                    return false
                }else if(isColor && _y != y && _x != x && cells[x][y].color == cells[_x][_y].color){
                    return false
                }
            }
        }
        return true;
    }
    func assignCellNumbers()
    {
        var sample:[[Int]] = [
            [1,2,3,4,5,6,7,8,9],
            [7,8,9,1,2,3,4,5,6],
            [4,5,6,7,8,9,1,2,3],
            [2,3,1,5,6,4,8,9,7],
            [8,9,7,2,3,1,5,6,4],
            [5,6,4,8,9,7,2,3,1],
            [3,1,2,6,4,5,9,7,8],
            [9,7,8,3,1,2,6,4,5],
            [6,4,5,9,7,8,3,1,2]];
        var shuffleMapping:Array<Int> = [1,2,3,4,5,6,7,8,9];
        shuffleMapping.shuffle()
        for x in 0 ... numberOfRow-1{
            for y in 0 ... numberOfRow-1{
                if(cells[x][y].isFixed){
                    cells[x][y].number = shuffleMapping[sample[x][y]-1];
                }
            }
        }
        
        if(difficulty.dimension>1){
            var sampleColor:[[Int]] = [
                [1,7,4,2,8,5,3,9,6],
                [2,8,5,3,9,6,1,7,4],
                [3,9,6,1,7,4,2,8,5],
                [4,1,7,5,2,8,6,3,9],
                [5,2,8,6,3,9,4,1,7],
                [6,3,9,4,1,7,5,2,8],
                [7,4,1,8,5,2,9,6,3],
                [8,5,2,9,6,3,7,4,1],
                [9,6,3,7,4,1,8,5,2]];
            var shuffleColorMapping:Array<Int> = [1,2,3,4,5,6,7,8,9];
            shuffleColorMapping.shuffle()
            for x in 0 ... numberOfRow-1{
                for y in 0 ... numberOfRow-1{
                    if(cells[x][y].isFixedColor){
                        var colorNumber:Int = shuffleColorMapping[sampleColor[x][y]-1]
                        var cellColor = GridCellColor(rawValue: colorNumber)
                        cells[x][y].setBackgroundColor(cellColor!)
                        
                    }
                }
            }
            
        }
        
        
    }
    func moveCursor(pos:Pos)
    {
        self.currentPos = pos;
    }
}