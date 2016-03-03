//
//  ViewController.swift
//  my-little-monster
//
//  Created by Vyacheslav Horbach on 28/02/16.
//  Copyright © 2016 Vyacheslav Horbach. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var monsterImg: MonsterImg!
    @IBOutlet weak var rockMonsterImg: RockMonsterImg!
    @IBOutlet weak var foodImg: DragImg!
    @IBOutlet weak var heartImg: DragImg!
    @IBOutlet weak var drinkImg: DragImg!
    @IBOutlet weak var livesPanel: UIImageView!

    @IBOutlet weak var penalty1: UIImageView!
    @IBOutlet weak var penalty2: UIImageView!
    @IBOutlet weak var penalty3: UIImageView!
    
    @IBOutlet weak var restartBtn: UIButton!
    
    @IBOutlet weak var childMonsterBtn: UIButton!
    @IBOutlet weak var adultMonsterBtn: UIButton!
    
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var penalties = 0
    var timer: NSTimer!
    var monsterHappy = true
    var currentItem: UInt32 = 0
    var monsterType = 0
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    var sfxDrinking: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        penalty1.alpha = DIM_ALPHA
        penalty2.alpha = DIM_ALPHA
        penalty3.alpha = DIM_ALPHA
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "itemDroppedOnCharacter:", name: "onTargetDropped", object: nil)
        
        do {
            let resourcePath = NSBundle.mainBundle().pathForResource("cave-music", ofType: "mp3")!
            let url = NSURL(fileURLWithPath: resourcePath)
            try musicPlayer = AVAudioPlayer(contentsOfURL: url)
            
            try sfxBite = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!))
            
            try sfxHeart = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!))
            
            try sfxDeath = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "wav")!))
            
            try sfxSkull = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!))
            
            try sfxDrinking = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("drinking", ofType: "mp3")!))
            
            
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
            sfxBite.prepareToPlay()
            sfxHeart.prepareToPlay()
            sfxDeath.prepareToPlay()
            sfxSkull.prepareToPlay()
            sfxDrinking.prepareToPlay()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        hideThingsBeginingGame()
        
        
        
        
    }
    
    func itemDroppedOnCharacter(notif: AnyObject) {
        monsterHappy = true
        startTimer()
        
        petInteractionDisabled()
        
        if currentItem == 0 {
            sfxHeart.play()
        } else if currentItem == 1 {
            sfxBite.play()
        } else {
            sfxDrinking.play()
        }
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "changeGameState", userInfo: nil, repeats: true)
        
    }
    
    
    func changeGameState() {
        
        if !monsterHappy {
            
            penalties++
            
            sfxSkull.play()
            
            if penalties == 1 {
                penalty1.alpha = OPAQUE
                penalty2.alpha = DIM_ALPHA
                
            } else if penalties == 2 {
                penalty2.alpha = OPAQUE
                penalty3.alpha = DIM_ALPHA
                
            } else if penalties >= 3 {
                penalty3.alpha = OPAQUE
                
            } else {
                penalty1.alpha = DIM_ALPHA
                penalty2.alpha = DIM_ALPHA
                penalty3.alpha = DIM_ALPHA
            }
            
            if penalties >= MAX_PENALTIES {
                gameOver()
            }
        }
        
        let rand = arc4random_uniform(3)
        
        if rand == 0 {
            foodImg.alpha = DIM_ALPHA
            foodImg.userInteractionEnabled = false
            
            drinkImg.alpha = DIM_ALPHA
            drinkImg.userInteractionEnabled = false
            
            heartImg.alpha = OPAQUE
            heartImg.userInteractionEnabled = true
        } else if rand == 1 {
            heartImg.alpha = DIM_ALPHA
            heartImg.userInteractionEnabled = false
            
            drinkImg.alpha = DIM_ALPHA
            drinkImg.userInteractionEnabled = false
            
            foodImg.alpha = OPAQUE
            foodImg.userInteractionEnabled = true
        } else {
            heartImg.alpha = DIM_ALPHA
            heartImg.userInteractionEnabled = false
            
            drinkImg.alpha = OPAQUE
            drinkImg.userInteractionEnabled = true
            
            foodImg.alpha = DIM_ALPHA
            foodImg.userInteractionEnabled = false
            
        }
        
        currentItem = rand
        monsterHappy = false
    }
    
    func gameOver() {
        timer.invalidate()
        if monsterType == 0 {
            monsterImg.playDeathAnimation()
        } else {
            rockMonsterImg.playDeathAnimation()
        }
        
        sfxDeath.play()
        
        petInteractionDisabled()
        
        restartBtn.hidden = false
        
    }
    
    func petInteractionDisabled() {
        foodImg.alpha = DIM_ALPHA
        foodImg.userInteractionEnabled = false
        
        drinkImg.alpha = DIM_ALPHA
        drinkImg.userInteractionEnabled = false
        
        heartImg.alpha = DIM_ALPHA
        heartImg.userInteractionEnabled = false

    }
    
    @IBAction func onTappedRestartGame(sender: AnyObject) {
        
        if monsterType == 0 {
            monsterImg.playIdleAnimation()
        } else {
            rockMonsterImg.playIdleAnimation()
        }
        
        penalties = 0
        monsterHappy = true
        petInteractionDisabled()
        startTimer()
        
        penalty1.alpha = DIM_ALPHA
        penalty2.alpha = DIM_ALPHA
        penalty3.alpha = DIM_ALPHA
        
        restartBtn.hidden = true
    }
    
    @IBAction func startGameWithAdultMontster(sender: AnyObject) {
        monsterType = 0
        foodImg.dropTarget = monsterImg
        heartImg.dropTarget = monsterImg
        drinkImg.dropTarget = monsterImg
        
        monsterImg.hidden = false
        IconsShow()
        
        hideCharacterSelecetionBtns()
        
        startGame()
    }
    
  
    @IBAction func startGameWithChildMonster(sender: AnyObject) {
        monsterType = 1
        foodImg.dropTarget = rockMonsterImg
        heartImg.dropTarget = rockMonsterImg
        drinkImg.dropTarget = rockMonsterImg
        
        rockMonsterImg.hidden = false
        IconsShow()
        
        hideCharacterSelecetionBtns()
        
        startGame()
    }
    
    func hideThingsBeginingGame() {
        monsterImg.hidden = true
        drinkImg.hidden = true
        rockMonsterImg.hidden = true
        restartBtn.hidden = true
        foodImg.hidden = true
        heartImg.hidden = true
        penalty1.hidden = true
        penalty2.hidden = true
        penalty3.hidden = true
        livesPanel.hidden = true
        
    }
    
    func startGame() {
        petInteractionDisabled()
        startTimer()
    }
    func IconsShow() {
        foodImg.hidden = false
        drinkImg.hidden = false
        heartImg.hidden = false
        penalty1.hidden = false
        penalty2.hidden = false
        penalty3.hidden = false
        livesPanel.hidden = false
    }
    
    func hideCharacterSelecetionBtns() {
        childMonsterBtn.hidden = true
        adultMonsterBtn.hidden = true
    }

}

