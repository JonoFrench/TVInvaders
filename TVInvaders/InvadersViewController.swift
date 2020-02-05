//
//  ViewController.swift
//  TVInvaders
//
//  Created by Jonathan French on 02/04/2019.
//  Copyright © 2019 Jaypeeff. All rights reserved.
//

import UIKit
import GameController
import UISpritesTV
import UIHighScoresTV
import UIAlphaNumericTV


class InvadersViewController: UIViewController, ReactToMotionEvents {

    @IBOutlet weak var baseLine: UIView?
    @IBOutlet weak var coverView: UIView?
    @IBOutlet weak var scoreBox: UIView?
    @IBOutlet weak var levelBox: UIView?
    @IBOutlet weak var livesBox: UIView?
    @IBOutlet weak var gameView: UIView!
    
    var introView:UIView?
    var gameoverView:UIView?
    var levelView:UIView?
    var livesView:UIView?
    
    var model:InvadersModel = InvadersModel()
    var base:Base?
    var motherShip:MotherShip?
    var baseLineY: CGFloat = 0
    var viewWidth: CGFloat = 0
    var viewHeight: CGFloat = 0
    var bullet:Bullet?
    var invaders:[Invader] = []
    var bombs:[Bomb] = []
    var silos:[Silo] = []
    var soundFX:SoundFX = SoundFX()
    var scoreView:StringViewArray = StringViewArray()
    var previousX: Double = 0
    var prevPoints: [CGPoint]?
    var lastPoints: [CGPoint]?
    var highScore:UIHighScores = UIHighScores()
    var highScoreYpos:CGFloat = 192
     var highScoreHeight:CGFloat = 300

    
    var invaderPosY = 300
    var invaderFinishY = 600
    var invaderStride = 60
    var invaderSize = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.viewController = self
        self.view.backgroundColor = .black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setScore()
        setLevel()
        setLives()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.bringSubviewToFront(coverView!)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.motionDelegate = self
        prevPoints = [CGPoint]()
        lastPoints = [CGPoint]()
        let displayLink:CADisplayLink = CADisplayLink(target: self, selector: #selector(refreshDisplay))
        displayLink.preferredFramesPerSecond = 30
        displayLink.add(to: .main, forMode: .common)
    }
    
    override func viewDidLayoutSubviews() {
        super .viewDidLayoutSubviews()
        if !model.layoutSet { // only want to do this once.
            model.layoutSet = true
            baseLineY = ((baseLine?.center.y)!) - 15
            viewWidth = gameView.frame.width
            viewHeight = gameView.frame.height
            //setControls()
            setStars()
            setIntro()
        }
    }
   
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if (press.type == .select) {
                fire()
            }  else {
                super.pressesEnded(presses, with: event)
            }
        }
    }
    
  
    func motionUpdate(motion: GCMotion) {
        let x = self.angleOfRotation(motion: motion)
        if x < -30 {
            self.model.leftMove = self.model.baseSpeed
            self.model.rightMove = 0
        } else if x > 30 {
            self.model.rightMove = self.model.baseSpeed
            self.model.leftMove = 0
        } else {
            self.model.rightMove = 0
            self.model.leftMove = 0
        }
        self.previousX = x
        
    }
    
    func angleOfRotation(motion: GCMotion) -> Double {
        var prevPoints = self.prevPoints!
        var lastPoints = self.lastPoints!
        if (prevPoints.count <= 10) {
            prevPoints.append(CGPoint(x: motion.gravity.x * 1000, y: motion.gravity.y * 1000))
        } else {
            prevPoints.removeFirst()
            prevPoints.append(lastPoints[0])
        }
        if (lastPoints.count <= 10) {
            lastPoints.append(CGPoint(x: motion.gravity.x * 1000, y: motion.gravity.y * 1000))
        } else {
            lastPoints.removeFirst()
            lastPoints.append(CGPoint(x: motion.gravity.x * 1000, y: motion.gravity.y * 1000));
        }
        
        var previousAvgX = 0.0, previousAvgY = 0.0, lastAvgX = 0.0, lastAvgY = 0.0
        
        for i in 0 ..< prevPoints.count {
            let previousPoint = prevPoints[i]
            let lastPoint = lastPoints[i]
            previousAvgX = (previousAvgX + Double(previousPoint.x)) / 2;
            previousAvgY = (previousAvgY + Double(previousPoint.y)) / 2;
            lastAvgX = Double(lastPoint.x) / 2
        }
        
        let deltaY = lastAvgY - previousAvgY;
        let deltaX = lastAvgX - previousAvgX;
         let angleInDegrees = atan2(deltaY, deltaX) * 180 / Double.pi;
        self.prevPoints = prevPoints
        self.lastPoints = lastPoints
        return angleInDegrees
    }
    
    
    fileprivate func setIntro(){
        introView = UIView(frame: CGRect(x: 0, y: 0, width: (coverView?.frame.width)!, height: (coverView?.frame.height)!))
        highScore = UIHighScores.init(xPos: 0, yPos: highScoreYpos, width: (introView?.frame.width)!, height: ((coverView?.frame.height)!) - (highScoreHeight))

        if let introView = introView, let coverView = coverView {
            let w = coverView.frame.width
            let h = coverView.frame.height
            coverView.backgroundColor = UIColor.black.withAlphaComponent(0.10)
            coverView.addSubview(introView)
            introView.backgroundColor = .clear
            highScore.drawScoreView()
                    
            let alpha:UIAlphaNumeric = UIAlphaNumeric()
            
            let title = UIView(frame: CGRect(x: 0, y: 20, width: w, height: 90))
            title.addSubview(alpha.get(string: "RETRO TV", size: (title.frame.size), fcol: .orange, bcol:.green ))
            title.backgroundColor = .clear
            introView.addSubview(title)
            
            let subTitle = UIView(frame: CGRect(x: 0, y: 130, width: w, height: 60))
            subTitle.addSubview(alpha.get(string: "INVADERS", size: (subTitle.frame.size), fcol: .green, bcol:.red ))
            subTitle.backgroundColor = .clear
            introView.addSubview(subTitle)
            
            let subTitle2 = UIView(frame: CGRect(x: 20, y: h-160, width: w - 40, height: 50))
            subTitle2.addSubview(alpha.get(string: "PRESS FIRE", size: (subTitle2.frame.size), fcol: .red, bcol:.yellow ))
            subTitle2.backgroundColor = .clear
            introView.addSubview(subTitle2)
            
            let subTitle3 = UIView(frame: CGRect(x: 20, y: h - 80, width: w - 40, height: 50))
            subTitle3.addSubview(alpha.get(string: "TO START", size: (subTitle3.frame.size), fcol: .red, bcol:.yellow ))
            subTitle3.backgroundColor = .clear
            introView.addSubview(subTitle3)
            introView.layoutIfNeeded()
            introView.addSubview(highScore.highScoreView)
                     highScore.animateIn()
                  
        }
        setIntroInvaders2()
        self.view.bringSubviewToFront(coverView!)
    }
    
    fileprivate func setIntroInvaders() {
        var invaderType = 0
        let step = viewWidth / 6
        for i in stride(from: step, to: step * 6, by: step) {
            for z in stride(from: 300, to: 600, by: 60){
                let invader:Invader = Invader(pos: CGPoint(x: viewWidth / 2, y: 20), height: 40, width: 40,invaderType:invaderType)
                invader.spriteView?.alpha = 0
                invader.spriteView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.gameView.addSubview(invader.spriteView!)
                invaders.append(invader)
                invader.animate()
                UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
                    invader.spriteView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    invader.spriteView?.alpha = 1
                    invader.spriteView?.center = CGPoint(x: i, y: CGFloat(z))
                    invader.position = CGPoint(x: i, y: CGFloat(z))
                }, completion: { (finished: Bool) in
                })
            }
            invaderType += 1
        }
    }
    
    fileprivate func setIntroInvaders2() {
        var invaderType = 0
        let step = viewWidth / 6
        for i in stride(from: step + gameView.frame.minX, to: (step * 6) + gameView.frame.minX, by: step) {
            invaderType = 0
            for z in stride(from: invaderPosY, to: invaderFinishY, by: invaderStride){
                let invader:Invader = Invader(pos: CGPoint(x: viewWidth / 2, y: 20), height: invaderSize, width: invaderSize, invaderType:invaderType)
                invader.spriteView?.alpha = 0
                invader.spriteView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.view.addSubview(invader.spriteView!)
                invaders.append(invader)
                invader.animate()
                UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
                    invader.spriteView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    invader.spriteView?.alpha = 1
                    invader.spriteView?.center = CGPoint(x: i, y: CGFloat(z))
                    invader.position = CGPoint(x: i, y: CGFloat(z))
                }, completion: { (finished: Bool) in
                })
                invaderType += 1
            }
            
        }
    }
    
    fileprivate func removeIntroInvaders(){
        for invader in invaders {
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
                invader.spriteView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                invader.spriteView?.alpha = 1
                invader.spriteView?.center = CGPoint(x: self.viewWidth / 2, y: 20)
            }, completion: { (finished: Bool) in
                invader.spriteView?.removeFromSuperview()
                invader.stopAnimating = true
            })
        }
    }
    
    fileprivate func setGameOverView(){
        for b in bombs {
            b.spriteView?.removeFromSuperview()
        }
        let alpha:UIAlphaNumeric = UIAlphaNumeric()
        gameoverView = UIView(frame: CGRect(x: 0, y: viewHeight / 2, width: (coverView?.frame.width)!, height: 40))
        if let gameoverView = gameoverView {
            let gov = UIView(frame: CGRect(x: 0, y: 0, width: gameoverView.frame.width, height: gameoverView.frame.height))
            gov.addSubview(alpha.get(string: "GAME OVER", size: (gov.frame.size), fcol: .red, bcol:.yellow ))
            gov.backgroundColor = .clear
            gameoverView.alpha = 0
            gameoverView.addSubview(gov)
            gameoverView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).rotated(by: CGFloat.pi)
            self.gameView.addSubview(gameoverView)
            UIView.animate(withDuration: 0.5, delay: 0.25, options: [], animations: {
                gameoverView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0).rotated(by: 0)
                gameoverView.alpha = 1
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.5, delay: 3.0, options: [], animations: {
                    gameoverView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).rotated(by: CGFloat.pi)
                    gameoverView.alpha = 0
                }, completion: { (finished: Bool) in
                    self.coverView?.alpha = 1
                    self.model.gameState = .starting
                    gameoverView.removeFromSuperview()
                    self.setIntro()
                })
            })
        }
    }
    
    // reset the UI
    fileprivate func resetGame() {
        setGameOverView()
        for i in invaders {
            if let isv = i.spriteView {
                isv.removeFromSuperview()
            }
        }
        invaders.removeAll()
        
        for s in silos {
            if let ssv = s.spriteView {
                ssv.removeFromSuperview()
            }
        }
        silos.removeAll()
        
        for b in bombs {
            if let bsv = b.spriteView {
                bsv.removeFromSuperview()
            }
        }
        bombs.removeAll()
        
        base?.spriteView?.removeFromSuperview()
        base = nil
        
        if let msv = motherShip?.spriteView {
            msv.removeFromSuperview()
            motherShip = nil
        }
    }
    
    fileprivate func nextLevel() {
        model.gameState = .loading
        for s in silos {
            if let ssv = s.spriteView {
                ssv.removeFromSuperview()
            }
        }
        silos.removeAll()
        //No silos after level 5
        if model.level < 5 {
            setSilos()
        }
        setInvaders()
    }
    
    fileprivate func cleanUpBeforeNextLevel(){
        for b in bombs {
            if let bsv = b.spriteView {
                bsv.removeFromSuperview()
            }
        }
        bombs.removeAll()
        if motherShip != nil {
            motherShip?.spriteView?.removeFromSuperview()
            motherShip = nil
        }
    }
    
    fileprivate func startGame() {
        self.removeIntroInvaders()
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.coverView!.alpha = 0
        }, completion: { (finished: Bool) in
            self.introView?.removeFromSuperview()
            self.model.reset()
            self.setSilos()
            self.setInvaders()
            self.setBase()
        })
    }
    
    fileprivate func setScore() {
        let scoreString = String(format: "%06d", model.score)
        let alpha:UIAlphaNumeric = UIAlphaNumeric()
        scoreView = alpha.getStringView(string: scoreString, size: (scoreBox?.frame.size)!, fcol: .white, bcol: .red)
        scoreBox?.addSubview(scoreView.charView!)
        
    }
    
    func updateScore() {
        let alpha:UIAlphaNumeric = UIAlphaNumeric()
        let scoreString = String(format: "%06d", model.score)
        for (index, char) in scoreString.enumerated() {
            alpha.updateChar(char: char, viewArray: scoreView.charViewArray[index], fcol: .white, bcol: .red)
        }
    }
    
    func setLevel() {
        if levelView != nil {
            levelView?.removeFromSuperview()
        }
        let levelString = "LEVEL\(model.level)"
        let alpha:UIAlphaNumeric = UIAlphaNumeric()
        let lv = alpha.getStringView(string: levelString, size: (levelBox?.frame.size)!, fcol: .white, bcol: .red)
        levelView = lv.charView
        levelBox?.addSubview(levelView!)
    }
    
    func setLives() {
        if livesView != nil {
            livesView?.removeFromSuperview()
        }
        let levelString = "Lives\(model.lives)"
        let alpha:UIAlphaNumeric = UIAlphaNumeric()
        let lv = alpha.getStringView(string: levelString, size: (livesBox?.frame.size)!, fcol: .white, bcol: .red)
        livesView = lv.charView
        livesBox?.addSubview(livesView!)
    }
    
    fileprivate func setStars() {
        let w = Int(self.view.frame.width)
        let h = Int((baseLine?.frame.minY)!)
        for _ in 1...500 {
            let x = Int.random(in: 0...w)
            let y = Int.random(in: 0...h)
            let star = UIView(frame: CGRect(x: x, y: y, width: 1, height: 1))
            star.backgroundColor = .white
            self.view.addSubview(star)
        }
    }
    
    fileprivate func setSilos() {
        let sy = baseLineY - 120
        let sx = self.gameView.frame.width / 6
        for i in 1...3 {
            let s = Silo(pos: CGPoint(x: sx * CGFloat(i*2) - (sx) - 40, y: sy), height: 60, width: 80)
            self.gameView.addSubview(s.spriteView!)
            silos.append(s)
        }
    }
    
    fileprivate func setBase() {
        if let base = base {
            base.spriteView?.removeFromSuperview()
        }
        model.leftMove = 0
        model.rightMove = 0
        base = Base(pos: CGPoint(x: 150, y: baseLineY), height: 30, width: 45)
        if let base = base {
            base.position = CGPoint(x: self.gameView.frame.width / 2, y: self.gameView.frame.height)
            base.spriteView?.alpha = 0
            base.spriteView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.gameView.addSubview((base.spriteView)!)
            base.animate()
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
                base.spriteView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                base.spriteView?.alpha = 1
                base.spriteView?.center = CGPoint(x: self.gameView.frame.width / 2, y: self.baseLineY)
            }, completion: { (finished: Bool) in
                self.model.gameState = .playing
                base.position = CGPoint(x: self.gameView.frame.width / 2, y: self.baseLineY)
            })
        }
    }
    
    
    fileprivate func setInvaders() {
        invaders.removeAll()
        var invaderType = 0
        var delay:Double = 0.0
        let step = viewWidth / 6
        let levelPos = model.level < 5 ? model.level * 20 : 100
        for i in stride(from: step, to: step * 6, by: step) {
            for z in stride(from: 100 + levelPos, to: 400 + levelPos, by: 60){
                let invader:Invader = Invader(pos: CGPoint(x: viewWidth / 2, y: 20), height: 40, width: 40,invaderType:invaderType)
                model.numInvaders += 1
                invader.spriteView?.alpha = 0
                invader.spriteView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.gameView.addSubview(invader.spriteView!)
                invaders.append(invader)
                invader.animate()
                UIView.animate(withDuration: 1.0, delay: delay, options: [], animations: {
                    invader.spriteView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                    invader.spriteView?.alpha = 1
                    invader.spriteView?.center = CGPoint(x: i, y: CGFloat(z))
                    invader.position = CGPoint(x: i, y: CGFloat(z))
                }, completion: { (finished: Bool) in
                })
                delay += 0.020
            }
            invaderType += 1
        }
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0)  {
            self.model.gameState = .playing
            self.invaderSound()
        }
    }
    
    func invaderSound() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.25) {
            self.soundFX.invaderSound()
            if self.model.gameState == .playing || self.model.gameState == .loading || self.model.gameState == .starting {
                self.invaderSound()
            }
        }
    }
    
    fileprivate func checkMothership()
    {
        let yPos = (scoreBox?.center.y)! + 30
        if motherShip == nil {
            // random add a new mothership
            if Int.random(in: 0...300) == 1 {
                motherShip = MotherShip(pos: CGPoint(x: self.gameView.frame.width + 10, y: yPos), height: 30, width: 45)
                self.gameView.addSubview(motherShip!.spriteView!)
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
                    self.motherSound()
                }
                motherShip?.animate()
            }
        } else {
            let x = (motherShip?.position.x)!
            if x < -20 {
                motherShip?.spriteView?.removeFromSuperview()
                motherShip = nil
            } else {
                motherShip?.position = CGPoint(x: x - 1, y: yPos)
            }
        }
    }
    
    fileprivate func motherSound(){
        self.soundFX.motherSound()
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.25) {
            if self.motherShip != nil {
                if !(self.motherShip?.isDead)! {
                    self.motherSound()
                }
            }
        }
    }
    
    fileprivate func moveBase() {
        if let base = base {
            let x = base.position.x
            let y = base.position.y
            if model.leftMove > 0 && x > 0 {
                base.position = CGPoint(x: x - model.baseSpeed, y: y)
            } else if model.rightMove > 0 && x < self.gameView.frame.width {
                base.position = CGPoint(x: x + model.baseSpeed, y: y)
            }
        }
    }
    
    fileprivate func checkBullets() {
        if model.bulletFired {
            if let bullet = bullet, let spriteView = bullet.spriteView {
                let pos = bullet.position
                if pos.y <= 0 {
                    model.bulletFired = false
                    bullet.spriteView?.removeFromSuperview()
                } else {
                    bullet.position = CGPoint(x: pos.x, y: pos.y - 8)
                    for inv in invaders {
                        if inv.checkHit(pos: spriteView.center) == true {
                            self.soundFX.hitSound()
                            spriteView.removeFromSuperview()
                            model.bulletFired = false
                            model.score += 10
                            model.deadCount += 1
                        }
                    }
                }
                
                for s in silos {
                    if (s.checkHit(pos:bullet.position)) {
                        spriteView.removeFromSuperview()
                        model.bulletFired = false
                    }
                }
                
                if motherShip != nil {
                    if motherShip!.checkHit(pos:spriteView.center) == true {
                        soundFX.hitSound()
                        spriteView.removeFromSuperview()
                        model.bulletFired = false
                        model.score += 100
                    }
                }
            }
        }
    }
    
    fileprivate func checkBombs() {
        for bomb in bombs {
            if bomb.isDying || bomb.isDead {continue}
            
            if bomb.position.y > baseLineY {
                bomb.isDying = true
                continue
            }
            bomb.move(x: 0, y: model.bombSpeed)
            if model.gameState == .playing {
                if let b = base {
                    if b.checkHit(pos:bomb.position) {
                        bomb.isDying = true
                        model.gameState = .ending
                        self.soundFX.baseHitSound()
                        self.model.lives -= 1
                        if self.model.lives == 0 {
                            self.model.gameState = .gameOver
                        }
                        
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
                            //self.model.lives -= 1
                            if self.model.lives == 0 {
                                //self.model.gameState = .gameOver
                                self.resetGame()
                                
                            } else {
                                self.setBase()
                            }
                        }
                        continue
                    }
                }
            }
            for s in silos {
                if (s.checkHit(pos:bomb.position)) {
                    bomb.isDying = true
                }
            }
        }
    }
    
    fileprivate func checkIntroInvaders(){
        for inv in invaders {
            // rotate the odd one
            if Int.random(in: 0...1000) == 1 {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                    inv.spriteView!.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }, completion: nil)
                UIView.animate(withDuration: 0.5, delay: 0.25, options: [], animations: {
                    inv.spriteView!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
                }, completion: nil)
            }
            
            if model.invaderXSpeed > 0 {
                if inv.position.x > gameView.frame.minX + viewWidth - 10 {
                    model.invaderXSpeed = -2
                }
            } else {
                if inv.position.x < gameView.frame.minX + 10 {
                    model.invaderXSpeed = 2
                }
            }
        }
    }
    
    fileprivate func checkInvaders() {
        for inv in invaders {
            if inv.isDead {continue}
            if Int.random(in: 0...model.bombRandomiser) == 1 && model.gameState == .playing {
                dropBomb(pos: inv.position)
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                    inv.spriteView!.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }, completion: nil)
                UIView.animate(withDuration: 0.5, delay: 0.25, options: [], animations: {
                    inv.spriteView!.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
                }, completion: nil)
            }
            // use the amount of dead invaders to increase the speed of the remaining
            // so the game gets harder.
            
            if model.invaderXSpeed > 0 {
                if inv.position.x > viewWidth - 10 {
                    model.invaderXSpeed = -2 - (model.deadCount / 6)
                    model.invaderYSpeed = 5 + (model.deadCount / 6)
                    break
                }
            } else {
                if inv.position.x < 10 {
                    model.invaderXSpeed = 2 + (model.deadCount / 6)
                    model.invaderYSpeed = 5 + (model.deadCount / 6)
                    break
                }
            }
            if model.gameState != .ending {
                if let b = base, let i = inv.spriteView {
                    if i.frame.minY > baseLineY - 40 {
                        model.gameState = .ending
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
                            //game over They've landed
                            self.model.gameState = .gameOver
                            self.resetGame()
                        }
                        break
                    }
                    if b.checkHit(pos: (i.frame)) {
                        model.gameState = .ending
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
                            //game over sunshine!
                            self.soundFX.baseHitSound()
                            self.model.gameState = .gameOver
                            self.resetGame()
                        }
                        break
                    }
                }
            }
            for s in silos {
                if let isv = inv.spriteView {
                    _ = (s.checkHit(pos: isv.frame))
                }
            }
        }
    }
    
    func moveInvaders() {
        for inv in invaders {
            if inv.isDead {continue}
            inv.move(x: model.invaderXSpeed, y: model.invaderYSpeed)
        }
        if model.invaderYSpeed > 0 { model.invaderYSpeed = 0}
    }
    
    
    func dropBomb(pos:CGPoint) {
        guard model.gameState == .playing else {
            return
        }
        let bomb = Bomb(pos: pos, height: 24, width: 8)
        bomb.position = pos
        self.gameView.addSubview(bomb.spriteView!)
        bombs.append(bomb)
        bomb.startAnimating()
    }
    
    // refreshDisplay is called from the runloop and should be called every screen refresh cycle
    
    @objc func refreshDisplay() {
        //let time: Date = Date()
        switch model.gameState {
        case .starting:
            moveInvaders()
            checkIntroInvaders()
            break
        case .loading:
            break
        case.nextLevel:
            self.model.gameState = .loading
            cleanUpBeforeNextLevel()
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
                self.nextLevel()
            }
            break
        case .ending:
            checkBullets()
            checkBombs()
            checkInvaders()
            moveInvaders()
            checkMothership()
            break
        case .playing:
           
            //print("Start Time \(time.timeIntervalSinceNow)")
            self.moveBase()
            self.moveInvaders()
            self.checkBullets()
            self.checkInvaders()
            self.checkBombs()
            self.checkMothership()
            //print("End Time \(time.timeIntervalSinceNow)")
            
            break
        case .gameOver:
            break
        case .hiScore:
            break
        }
    }
    
//    func leftPressed(gesture:UILongPressGestureRecognizer) {
//        guard model.gameState == .playing else {
//            return
//        }
//        if gesture.state == .began {
//            model.leftMove = model.baseSpeed
//        } else if gesture.state == .ended {
//            model.leftMove = 0
//        }
//
//    }
//
//    func rightPressed(gesture:UILongPressGestureRecognizer) {
//        guard model.gameState == .playing else {
//            return
//        }
//        if gesture.state == .began {
//            model.rightMove = model.baseSpeed
//        } else if gesture.state == .ended {
//            model.rightMove = 0
//        }
//    }
    
    func fire() {
        print("\(model.gameState)")
        guard model.bulletFired == false && model.gameState != .loading else {
            return
        }
        
        
        if model.gameState == .starting || model.gameState == .gameOver {
            model.gameState = .loading
            startGame()
        } else if model.gameState != .ending {
            if let bsv = base?.spriteView {
                bullet = Bullet(pos: bsv.center, height: 24, width: 8)
                bullet?.position = bsv.center
                self.gameView.addSubview(bullet!.spriteView!)
                model.bulletFired = true
                soundFX.shootSound()
            }
        }
    }

}

