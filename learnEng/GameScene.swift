// MARK: - GameViewController
import UIKit
import SpriteKit


// MARK: - Menu Scene
import SpriteKit

class MenuScene: SKScene {
    // Constants
    private enum Constants {
        static let titleFontSize: CGFloat = 44
        static let titlePositionY: CGFloat = 0.7
        static let buttonSize = CGSize(width: 200, height: 60)
        static let buttonPositionY: CGFloat = 0.4
        static let buttonLabelFontSize: CGFloat = 24
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .systemBlue
        
        // Title
        let titleLabel = SKLabelNode(text: "English Archery")
        titleLabel.fontSize = Constants.titleFontSize
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * Constants.titlePositionY)
        addChild(titleLabel)
        
        // Start Button
        let startButton = SKSpriteNode(color: .systemRed, size: Constants.buttonSize)
        startButton.position = CGPoint(x: size.width / 2, y: size.height * Constants.buttonPositionY)
        startButton.name = "startButton"
        
        let startLabel = SKLabelNode(text: "Start Game")
        startLabel.fontSize = Constants.buttonLabelFontSize
        startLabel.fontColor = .white
        startLabel.fontName = "HelveticaNeue-Medium"
        startLabel.verticalAlignmentMode = .center
        startButton.addChild(startLabel)
        
        addChild(startButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "startButton" {
                startGame()
                break
            }
        }
    }
    
    private func startGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .aspectFill
        view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}

// MARK: - Game Scene

class GameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Properties
    private var player: SKSpriteNode!
    private var bow: SKSpriteNode!
    private var arrow: SKSpriteNode?
    private var balloons: [SKShapeNode] = []
    
    private var currentScore = 0
    private var questionCounter = 0
    private var scoreLabel: SKLabelNode!
    private var questionLabel: SKLabelNode!
    private var currentWordLabel: SKLabelNode!
    private var attemptsLabel: SKLabelNode!
    
    private var currentWord: WordPair!
    private let maxAttempts = 4
    private var attempts = 0
    private var totalQuestion = 10
    // Category BitMasks
    private let arrowCategory: UInt32 = 0x1 << 0
    private let balloonCategory: UInt32 = 0x1 << 1
    
    // Word Database
    private let wordDatabase: [WordPair] = [
        WordPair(english: "Hello", hebrew: "שלום"),
        WordPair(english: "Goodbye", hebrew: "להתראות"),
        WordPair(english: "Thank you", hebrew: "תודה"),
        WordPair(english: "Please", hebrew: "בבקשה"),
        WordPair(english: "Sky", hebrew: "שמים"),
        WordPair(english: "Yellow", hebrew: "צהוב"),
        WordPair(english: "Red", hebrew: "אדום"),
        WordPair(english: "Left", hebrew: "שמאל"),
        WordPair(english: "Right", hebrew: "ימין"),
        WordPair(english: "Background", hebrew: "רקע"),
        WordPair(english: "Question", hebrew: "שאלה"),
        WordPair(english: "Select", hebrew: "בחירה"),
        WordPair(english: "Gravity", hebrew: "כח כבידה"),
        WordPair(english: "Title", hebrew: "כותרת"),
        WordPair(english: "Forever", hebrew: "לתמיד"),
        WordPair(english: "Duration", hebrew: "משך הזמן"),
        WordPair(english: "To move", hebrew: "לזוז"),
        WordPair(english: "Angle", hebrew: "זווית"),
        WordPair(english: "Group", hebrew: "קבוצה"),
        WordPair(english: "Touch", hebrew: "נגיעה"),
        WordPair(english: "Menu", hebrew: "תפריט"),
        WordPair(english: "Arrow", hebrew: "חץ"),
        WordPair(english: "Rectangle", hebrew: "ריבוע"),
        WordPair(english: "Pair", hebrew: "זוג"),
        WordPair(english: "Word", hebrew: "מילה"),
        WordPair(english: "Question", hebrew: "שאלה"),
        WordPair(english: "Clear", hebrew: "נקי"),
        WordPair(english: "Current", hebrew: "נוכחי"),
        WordPair(english: "Counter", hebrew: "מונה"),
        WordPair(english: "Attempt", hebrew: "לנסות")



    ]
    // Question Clear Current Counter Attempt

    
    private var gameWords: [WordPair] = []
    
    // MARK: - Scene Lifecycle
    override func didMove(to view: SKView) {
        setupPhysics()
        setupBackground()
        setupPlayer()
        setupUI()
        selectGameWords()
        startNewQuestion()
    }
    
    // MARK: - Setup Methods
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -4.0)
    }
    
    private func setupBackground() {
        let ground = SKSpriteNode(color: .red, size: CGSize(width: size.width, height: 100))
        ground.position = CGPoint(x: size.width / 2, y: 50)
        addChild(ground)
    }
    
    private func setupPlayer() {
        player = SKSpriteNode(color: .brown, size: CGSize(width: 40, height: 80))
        player.position = CGPoint(x: 100, y: 140)
        addChild(player)
        
        bow = SKSpriteNode(color: .brown, size: CGSize(width: 10, height: 60))
        bow.position = CGPoint(x: player.position.x + 30, y: player.position.y)
        addChild(bow)
    }
    
//    private func setupUI() {
//        scoreLabel = SKLabelNode(text: "Score: 0")
//        scoreLabel.fontName = "HelveticaNeue-Light"
//        scoreLabel.fontSize = 20
//        scoreLabel.position = CGPoint(x: 100, y: size.height - 90)
//
//        addChild(scoreLabel)
//        
//        questionLabel = SKLabelNode(text: "Question: 1/10")
//        questionLabel.fontName = "HelveticaNeue-Light"
//        questionLabel.position = CGPoint(x: size.width - 100, y: size.height - 90)
//
//        questionLabel.fontSize = 20
//
//        addChild(questionLabel)
//        
//        currentWordLabel = SKLabelNode(text: "")
//        currentWordLabel.position = CGPoint(x: size.width / 2, y: size.height - 160)
//        currentWordLabel.fontName = "Baskerville-SemiBold"
//        currentWordLabel.fontSize = 32
//
//        addChild(currentWordLabel)
//        
//        attemptsLabel = SKLabelNode(text: "Arrows: \(maxAttempts)")
//        attemptsLabel.position = CGPoint(x: 100, y: size.height - 120)
//        attemptsLabel.fontName = "HelveticaNeue-Light"
//        attemptsLabel.fontSize = 20
//        addChild(attemptsLabel)
//    }
    
    private func setupUI() {
        // Constants for UI layout
         enum Constants {
            static let topMargin: CGFloat = 100
            static let sideMargin: CGFloat = 20
            static let verticalSpacing: CGFloat = 30
            static let labelFontSize: CGFloat = 24
            static let titleFontSize: CGFloat = 32
            static let scoreColor: UIColor = .white
            static let attemptsColor: UIColor = .yellow
            static let questionColor: UIColor = .green
            static let translateLabelFontSize: CGFloat = 28
            static let wordLabelFontSize: CGFloat = 32
        }
        
        // Score Label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontSize = Constants.labelFontSize
        scoreLabel.fontColor = Constants.scoreColor
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: Constants.sideMargin, y: size.height - Constants.topMargin)
        scoreLabel.fontName = "HelveticaNeue-Light"
        addChild(scoreLabel)
        
        // Attempts Label
        attemptsLabel = SKLabelNode(text: "Arrows: \(maxAttempts)")
        attemptsLabel.fontSize = Constants.labelFontSize
        attemptsLabel.fontColor = Constants.attemptsColor
        attemptsLabel.horizontalAlignmentMode = .left
        attemptsLabel.position = CGPoint(
            x: Constants.sideMargin,
            y: scoreLabel.position.y - Constants.verticalSpacing
        )
        attemptsLabel.fontName = "HelveticaNeue-Light"

        addChild(attemptsLabel)
        
        // Question Counter Label
        questionLabel = SKLabelNode(text: "Question: 1/10")
        questionLabel.fontSize = Constants.labelFontSize
        questionLabel.fontColor = Constants.questionColor
        questionLabel.horizontalAlignmentMode = .right
        questionLabel.position = CGPoint(
            x: size.width - Constants.sideMargin,
            y: size.height - Constants.topMargin
        )
        questionLabel.fontName = "HelveticaNeue-Light"
        addChild(questionLabel)
        
        // Translate Label
//        let translateLabel = SKLabelNode(text: "Translate:")
//        translateLabel.fontSize = Constants.translateLabelFontSize
//        translateLabel.fontColor = .white
//        translateLabel.horizontalAlignmentMode = .center
//        translateLabel.position = CGPoint(
//            x: size.width / 2 - 60,
//            y: size.height - Constants.topMargin - Constants.verticalSpacing * 2
//        )
//        translateLabel.fontName = "Baskerville-SemiBold"
//        addChild(translateLabel)
        
        // Current Word Label
        currentWordLabel = SKLabelNode(text: "")
        currentWordLabel.fontSize = Constants.wordLabelFontSize
        currentWordLabel.fontColor = #colorLiteral(red: 0.7968178391, green: 0.9805445075, blue: 0.9974589944, alpha: 1)
        currentWordLabel.horizontalAlignmentMode = .center
        currentWordLabel.position = CGPoint(
            x: size.width / 2,
            y: size.height - Constants.topMargin - Constants.verticalSpacing * 2
        )
        currentWordLabel.fontName = "Baskerville-SemiBold"
        addChild(currentWordLabel)
    }
    
    // MARK: - Game Logic
    private func selectGameWords() {
        gameWords = Array(wordDatabase.shuffled().prefix(10))
    }
    
    
    private func startNewQuestion() {
        clearBalloons()
        if questionCounter < totalQuestion {
            currentWord = gameWords[questionCounter]
            setupBalloons()
            currentWordLabel.text = "\(currentWord.english)"
            attempts = 0
            attemptsLabel.text = "Arrows: \(maxAttempts)"
        } else {
            gameOver()
        }
    }
    
    private func clearBalloons() {
        balloons.forEach { $0.removeFromParent() }
        balloons.removeAll()
    }
    
    private func setupBalloons() {
        let balloonColors: [UIColor] = [.red, .blue, .orange, .purple]
        var answers = [currentWord.hebrew]
        
        // Add random incorrect answers
        while answers.count < 4 {
            if let randomWord = wordDatabase.randomElement() {
                if !answers.contains(randomWord.hebrew) {
                    answers.append(randomWord.hebrew)
                }
            }
        }
        
        answers.shuffle()
        
        for (index, answer) in answers.enumerated() {
            // Create a circular balloon
            let balloonRadius: CGFloat = 40
            let balloon = SKShapeNode(circleOfRadius: balloonRadius)
            balloon.fillColor = balloonColors[index]
            balloon.strokeColor = .black
            balloon.lineWidth = 2
            
            // Position the balloon
            var xPos = (size.width / 5 * CGFloat(index + 1))
            xPos =  xPos + CGFloat((index-1) * 10)
            balloon.position = CGPoint(x: xPos, y: size.height - 250)
            
            // Add physics body
            balloon.physicsBody = SKPhysicsBody(circleOfRadius: balloonRadius)
            balloon.physicsBody?.categoryBitMask = balloonCategory
            balloon.physicsBody?.contactTestBitMask = arrowCategory
            balloon.physicsBody?.isDynamic = false
            
            // Add label for the answer
            let label = SKLabelNode(text: answer)
            label.fontSize = 18
            label.fontColor = .white
            label.fontName = "Arial"
            label.verticalAlignmentMode = .center
            balloon.addChild(label)
            
            balloons.append(balloon)
            addChild(balloon)
            
            // Animate the balloon
            animateBalloon(balloon, index: index)
        }
    }
    
    // MARK: - Balloon Animations
//    private func animateBalloon(_ balloon: SKShapeNode, index: Int) {
//        let floatDuration = TimeInterval(1.0 + Double(index) * 0.2)
//        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: floatDuration)
//        moveUp.timingMode = .easeInEaseOut
//        let moveDown = moveUp.reversed()
//        let floatingSequence = SKAction.sequence([moveUp, moveDown])
//        let floatingForever = SKAction.repeatForever(floatingSequence)
//        
//        balloon.run(floatingForever)
//    }

    private func animateBalloon(_ balloon: SKShapeNode, index: Int) {
        // Vertical floating motion
        let floatDuration = TimeInterval(1.0 + Double(index) * 0.2)
        let moveUp = SKAction.moveBy(x: 0, y: 40, duration: floatDuration)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = moveUp.reversed()
        let floatingSequence = SKAction.sequence([moveUp, moveDown])
        let floatingForever = SKAction.repeatForever(floatingSequence)
        
        // Horizontal swaying motion
        let swayDistance = CGFloat(25 + index * 10) // Adjust sway distance based on index
        let swayDuration = TimeInterval(4.0 + Double(index) * 0.5)
        let moveRight = SKAction.moveBy(x: swayDistance, y: 0, duration: swayDuration)
        moveRight.timingMode = .easeInEaseOut
        let moveLeft = moveRight.reversed()
        let swaySequence = SKAction.sequence([moveRight, moveLeft])
        let swayForever = SKAction.repeatForever(swaySequence)
        
        // Combine vertical and horizontal motions
        let group = SKAction.group([floatingForever, swayForever])
        balloon.run(group)
        
        // Add a slight rotation effect for more realism
        let rotateAngle = CGFloat.pi / 8 // Rotate by 22.5 degrees
        let rotateDuration = TimeInterval(2.0 + Double(index) * 0.3)
        let rotateRight = SKAction.rotate(byAngle: rotateAngle, duration: rotateDuration)
        rotateRight.timingMode = .easeInEaseOut
        let rotateLeft = SKAction.rotate(byAngle: -rotateAngle, duration: rotateDuration)
        rotateLeft.timingMode = .easeInEaseOut
        let rotateSequence = SKAction.sequence([rotateRight, rotateLeft])
        let rotateForever = SKAction.repeatForever(rotateSequence)
        
        balloon.run(rotateForever)
    }
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "menuButton" {
                backToMenu()
                return
            }
        }
        
        if attempts < maxAttempts && arrow == nil {
            shootArrow(toward: location)
        }
    }
    
    private func shootArrow(toward location: CGPoint) {
        arrow = SKSpriteNode(color: .brown, size: CGSize(width: 40, height: 5))
        arrow?.position = bow.position
        
        let direction = CGPoint(x: location.x - bow.position.x, y: location.y - bow.position.y)
        let angle = atan2(direction.y, direction.x)
        arrow?.zRotation = angle
        
        arrow?.physicsBody = SKPhysicsBody(rectangleOf: arrow!.size)
        arrow?.physicsBody?.categoryBitMask = arrowCategory
        arrow?.physicsBody?.contactTestBitMask = balloonCategory
        arrow?.physicsBody?.collisionBitMask = 0
        
        addChild(arrow!)
        
        let speed: CGFloat = 900
        let velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
        arrow?.physicsBody?.velocity = velocity
    }
    
    // MARK: - Game Over
    private func gameOver() {
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        gameOverLabel.fontSize = 48
        addChild(gameOverLabel)
        
        let finalScoreLabel = SKLabelNode(text: "Final Score: \(currentScore)")
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(finalScoreLabel)
        
        let menuButton = SKSpriteNode(color: .red, size: CGSize(width: 200, height: 60))
        menuButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        menuButton.name = "menuButton"
        
        let menuLabel = SKLabelNode(text: "Back to Menu")
        menuLabel.fontSize = 24
        menuLabel.fontColor = .white
        menuLabel.fontName = "HelveticaNeue-Medium"
        menuLabel.verticalAlignmentMode = .center
        menuButton.addChild(menuLabel)
        
        addChild(menuButton)
    }
    
    private func backToMenu() {
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let firstNode = contact.bodyA.node
        let secondNode = contact.bodyB.node
        
        let balloon: SKShapeNode?
        if firstNode?.physicsBody?.categoryBitMask == balloonCategory {
            balloon = firstNode as? SKShapeNode
        } else if secondNode?.physicsBody?.categoryBitMask == balloonCategory {
            balloon = secondNode as? SKShapeNode
        } else {
            balloon = nil
        }
        
        if let balloon = balloon {
            handleBalloonHit(balloon)
        }
    }
    
    private func handleBalloonHit(_ balloon: SKShapeNode) {
        guard let label = balloon.children.first as? SKLabelNode else { return }
        
        attempts += 1
        attemptsLabel.text = "Arrows: \(maxAttempts - attempts)"
        
        if label.text == currentWord.hebrew {
            currentScore += 100
            scoreLabel.text = "Score: \(currentScore)"
            explodeBalloon(balloon)
            
            run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run { [weak self] in
                    self?.questionCounter += 1
                    self?.startNewQuestion()
                }
            ]))
        } else {
            explodeBalloon(balloon)
            
            if attempts >= maxAttempts {
                if let correctBalloon = balloons.first(where: { ($0.children.first as? SKLabelNode)?.text == currentWord.hebrew }) {
                    run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.5),
                        SKAction.run { [weak self] in
                            self?.explodeBalloon(correctBalloon)
                        },
                        SKAction.wait(forDuration: 1.0),
                        SKAction.run { [weak self] in
                            self?.questionCounter += 1
                            self?.startNewQuestion()
                        }
                    ]))
                }
            }
        }
        
        arrow?.removeFromParent()
        arrow = nil
    }
    
    private func explodeBalloon(_ balloon: SKShapeNode) {
        balloon.removeAllActions()
        
        for _ in 0...10 {
            let particle = SKShapeNode(circleOfRadius: 5)
            particle.fillColor = balloon.fillColor
            particle.strokeColor = balloon.strokeColor
            particle.position = balloon.position
            addChild(particle)
            
            let angle = CGFloat.random(in: 0...CGFloat.pi * 2)
            let distance = CGFloat.random(in: 30...60)
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance
            
            let moveAction = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            let group = SKAction.group([moveAction, fadeAction])
            let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
            particle.run(sequence)
        }
        
        balloon.removeFromParent()
    }
    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        if let arrow = arrow {
            if arrow.position.x < 0 || arrow.position.x > size.width ||
               arrow.position.y < 0 || arrow.position.y > size.height {
                arrow.removeFromParent()
                self.arrow = nil
            }
        }
    }
}

// MARK: - Word Pair Structure
struct WordPair {
    let english: String
    let hebrew: String
}
