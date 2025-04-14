import random, terminal, strutils, os, times

const 
    Width = 20
    Height = 10
    Empty = ' '
    Wall = '#'
    SnakeHead = '@'
    SnakeBody = 'o'
    Apple = "*"

type
    Direction = enum Up, Down, Left, Right
    Position = tuple[x: int, y: int]

var 
    snake: seq[Position] = @[(x: Width div 2, y: Height div 2)]
    dir: Direction = Right
    lastDir: Direction = Right
    food: Position
    gameOver = false
    score = 0
    speed = 200
    lastUpdate = 0.0

proc placeFood() = 
    while true:
        food = (x: rand(1..Width-2), y: rand(1..Height-2))

        var valid = true

        for segment in snake:
            if segment.x == food.x and segment.y == food.y:
                valid = false
                break

        if valid:
            break

proc initGame() = 
    snake = @[(x: Width div 2, y: Height div 2)]
    dir = Right
    lastDir = Right
    gameOver = false
    score = 0
    speed = 200
    lastUpdate = epochTime()
    placeFood()

proc draw() = 
    eraseScreen()
    setCursorPos(0, 0)

    echo repeat(Wall, Width + 2)

    for y in 0..<Height:
        stdout.write(Wall)

        for x in 0..<Width:
            let pos = (x, y)

            if pos == snake[0]:
                stdout.write(SnakeHead) 
            elif pos in snake[1..^1]:
                stdout.write(SnakeBody)
            elif pos == food:
                stdout.write(Apple) 
            else:
                stdout.write(Empty) 
        echo Wall

    echo repeat(Wall, Width + 2)
    echo "Score: ", score

    if gameOver:
        echo "Game Over! Press 'R' to restart, 'Q' to quit."

proc update() =
    if gameOver:
        return

    var newHead: Position
    case dir
    of Up:    newHead = (x: snake[0].x, y: snake[0].y - 1)
    of Down:  newHead = (x: snake[0].x, y: snake[0].y + 1)
    of Left:  newHead = (x: snake[0].x - 1, y: snake[0].y)
    of Right: newHead = (x: snake[0].x + 1, y: snake[0].y)

    if newHead.x <= 0 or newHead.x >= Width - 1 or newHead.y < 0 or newHead.y > Height - 1:
        gameOver = true
        return

    for segment in snake[1..^1]:
        if segment == newHead:
            gameOver = true
            return

    if newHead == food:
        snake.insert(newHead, 0)
        placeFood()
        score += 1
        speed = max(50, speed - 5)
    else:
        snake.insert(newHead, 0)
        discard snake.pop()

proc handleInput() =

    case getch():
    of 'w': 
        if lastDir != Down: 
            dir = Up
    of 's': 
        if lastDir != Up: 
            dir = Down
    of 'a': 
        if lastDir != Right:
            dir = Left
    of 'd': 
        if lastDir != Left: 
            dir = Right
    of 'r': 
        if gameOver: 
            initGame()
    of 'q': 
        quit(0)
    else: 
        discard

    lastDir = dir

when isMainModule:
    randomize()
    initGame()
    hideCursor()


    while true:
        let curTime = epochTime()

        if curTime - lastUpdate >= speed / 1000:
            update()
            draw()
            lastUpdate = curTime
        handleInput()
        sleep(10)





