import SwiftUI

struct ContentView: View {
    @State private var ballPosition: CGPoint = CGPoint(x: 200, y: 400)
    @State private var ballVelocity: CGVector = CGVector(dx: 2, dy: -2)
    @State private var paddlePosition: CGFloat = UIScreen.main.bounds.width / 2
    @State private var bricks: [Brick] = []
    @State private var score: Int = 0
    @State private var gameOver: Bool = false
    @State private var timer: Timer?
    
    let ballRadius: CGFloat = 15
    let paddleWidth: CGFloat = 100
    let paddleHeight: CGFloat = 20
    let brickWidth: CGFloat = 60
    let brickHeight: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            // Ball
            Circle()
                .fill(Color.white)
                .frame(width: ballRadius * 2, height: ballRadius * 2)
                .position(ballPosition)
            
            // Paddle
            Rectangle()
                .fill(Color.blue)
                .frame(width: paddleWidth, height: paddleHeight)
                .position(x: paddlePosition, y: paddlePositionY) // Use updated paddle position
            
            // Bricks
            ForEach(bricks) { brick in
                Rectangle()
                    .fill(brick.color)
                    .frame(width: brickWidth, height: brickHeight)
                    .position(brick.position)
            }
            
            // Game Over Screen
            if gameOver {
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Score: \(score)")
                        .font(.title)
                        .foregroundColor(.white)
                    Button(action: resetGame) {
                        Text("Restart")
                            .font(.title2)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onAppear(perform: startGame)
        .gesture(DragGesture().onChanged { value in
            // Update the paddle position based on drag gesture
            paddlePosition = min(max(value.location.x, paddleWidth / 2), UIScreen.main.bounds.width - paddleWidth / 2)
        })
    }
    
    // MARK: - Game Logic
    
    func startGame() {
        resetBricks()
        score = 0
        ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 300) // Ball starts above the bottom
        ballVelocity = CGVector(dx: 2, dy: -2) // Initial velocity
        gameOver = false
        
        // Start the game loop
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            updateGame()
        }
    }
    
    func updateGame() {
        if gameOver { return }
        
        // Update the ball position
        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy
        
        // Ball collision with walls
        if ballPosition.x <= ballRadius || ballPosition.x >= UIScreen.main.bounds.width - ballRadius {
            ballVelocity.dx = -ballVelocity.dx
        }
        
        if ballPosition.y <= ballRadius {
            ballVelocity.dy = -ballVelocity.dy
        }
        
        // Ball collision with paddle
        if ballPosition.y + ballRadius >= paddlePositionY - paddleHeight / 2 &&
            ballPosition.y - ballRadius <= paddlePositionY + paddleHeight / 2 &&
            ballPosition.x >= paddlePosition - paddleWidth / 2 &&
            ballPosition.x <= paddlePosition + paddleWidth / 2 {
            ballVelocity.dy = -ballVelocity.dy
        }
        
        // Ball collision with bricks
        for i in 0..<bricks.count {
            let brick = bricks[i]
            if ballPosition.y - ballRadius <= brick.position.y + brickHeight / 2 &&
                ballPosition.y + ballRadius >= brick.position.y - brickHeight / 2 &&
                ballPosition.x >= brick.position.x - brickWidth / 2 &&
                ballPosition.x <= brick.position.x + brickWidth / 2 {
                // Remove the brick
                bricks.remove(at: i)
                score += 10
                ballVelocity.dy = -ballVelocity.dy
                break
            }
        }
        
        // Check if the ball falls below the screen (Game Over)
        if ballPosition.y >= UIScreen.main.bounds.height - ballRadius {
            gameOver = true
            timer?.invalidate()
        }
    }
    
    func resetBricks() {
        bricks = []
        let rows = 5
        let columns = 7
        let startX: CGFloat = 40
        let startY: CGFloat = 100
        
        for row in 0..<rows {
            for col in 0..<columns {
                let x = startX + CGFloat(col) * (brickWidth + 10)
                let y = startY + CGFloat(row) * (brickHeight + 5)
                let color = row % 2 == 0 ? Color.red : Color.green
                bricks.append(Brick(position: CGPoint(x: x, y: y), color: color))
            }
        }
    }
    
    func resetGame() {
        startGame()
    }
    
    // MARK: - Paddle Position
    
    // Adjusted paddle position (above the screen bottom)
    private var paddlePositionY: CGFloat {
        return UIScreen.main.bounds.height - 80
    }
}

struct Brick: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

