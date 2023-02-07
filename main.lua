
push = require 'push'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 250

Class = require 'class'

require 'Paddle'
require 'Ball'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong!')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    bigFont = love.graphics.newFont('font.ttf', 16)

    love.graphics.setFont(smallFont)

    sound = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static')

    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- Player
    p1 = Paddle(10, 30, 5, 40)
    p2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 40)
    
    -- Ball
    ball = Ball(VIRTUAL_WIDTH / 2 -2, VIRTUAL_HEIGHT / 2 -2, 4, 4)

    serves = math.random(2)
    winner = 0

    gameState = 'start'
end

function love.update(dt)

    if gameState == 'play' then
        
        if ball:collides(p1) then
            sound.paddle_hit:play()
            ball.dx = ball.dx * -1.05
            ball.x = p1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        
        if ball:collides(p2) then
            sound.paddle_hit:play()
            ball.dx = ball.dx * -1.05
            ball.x = p2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end
        
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sound.wall_hit:play()
        end
        
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sound.wall_hit:play()
        end
        
        if ball.x < 0 then
            serves = 1
            p2.score = p2.score + 1
            
            if p2.score >= 10 then
                winner = 2
                gameState = 'done'
                sound.victory:play()
            else
                sound.score:play()
                ball:reset()
                gameState = 'serve'
            end
        end
        
        if ball.x > VIRTUAL_WIDTH then
            serves = 2
            p1.score = p1.score + 1
            
            if p1.score >= 10 then
                winner = 1
                gameState = 'done'
                sound.victory:play()
            else
                sound.score:play()
                ball:reset()
                gameState = 'serve'
            end        
        end

        ball:update(dt)
    end

    if love.keyboard.isDown('w') then
        p1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        p1.dy = PADDLE_SPEED
    else
        p1.dy = 0
    end

    if love.keyboard.isDown('up') then
        p2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then    
        p2.dy = PADDLE_SPEED
    else
        p2.dy = 0
    end

    p1:update(dt)
    p2:update(dt)
end

function love.keypressed(key)
    
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'play' then
            gameState = 'serve'
            ball:reset()
        elseif gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'done' then
            
            serves = winner == 1 and 2 or 1
            gameState = 'serve'
            p1.score = 0
            p2.score = 0    
            ball:reset()
        end
    elseif key == 'space' then
        gameState = 'start'
        p1.score = 0
        p2.score = 0
        ball:reset() 
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)
    
    if gameState == 'start' then
        love.graphics.printf('Welcome, press enter to start', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf('player ' .. serves .. ' to serve', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.printf('', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(bigFont)
        love.graphics.printf('Congratulation! Player '  .. winner .. ' Wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press enter to play again', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(p1.score), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(p2.score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)
    
    displayFPS()

    p1:render()
    p2:render()
    
    ball:render()
    push:apply('end')

end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS : ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end