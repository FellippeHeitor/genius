OPTION _EXPLICIT
 
CONST true = -1, false = 0
 
DIM SHARED AS LONG boardX, boardY
boardX = 0
boardY = _FONTHEIGHT
 
RANDOMIZE TIMER
 
TYPE blocks
    AS INTEGER x, y, w, h
    AS _UNSIGNED LONG low, high
    AS STRING note
END TYPE
 
DIM SHARED AS blocks block(1 TO 4)
DIM SHARED AS LONG canvas, gameScreen
 
DIM i AS LONG
 
gameScreen = _NEWIMAGE(400, 400 + _FONTHEIGHT, 32)
canvas = _NEWIMAGE(400, 400, 32)
 
SCREEN gameScreen
DO UNTIL _SCREENEXISTS: LOOP
_TITLE "Genius"
 
FOR i = 1 TO 4
    block(i).w = _WIDTH(canvas) \ 2
    block(i).h = _HEIGHT(canvas) \ 2
NEXT
 
i = 0
i = i + 1: block(i).x = 0: block(i).y = 0
block(i).note = "o3c" 'green
block(i).high = _RGB32(0, 155, 0)
block(i).low = _RGB32(0, 78, 0)
 
i = i + 1: block(i).x = 0: block(i).y = _HEIGHT(canvas) \ 2
block(i).note = "o2e" 'red
block(i).high = _RGB32(227, 0, 0)
block(i).low = _RGB32(78, 0, 0)
 
i = i + 1: block(i).x = _WIDTH(canvas) \ 2: block(i).y = 0
block(i).note = "o2g" 'yellow
block(i).high = _RGB32(194, 194, 0)
block(i).low = _RGB32(161, 116, 0)
 
i = i + 1: block(i).x = _WIDTH(canvas) \ 2: block(i).y = _HEIGHT(canvas) \ 2
block(i).note = "o2b" 'blue
block(i).high = _RGB32(0, 105, 233)
block(i).low = _RGB32(0, 0, 78)
 
 
DIM SHARED AS _BYTE gameOver, inGame
DIM SHARED sequence$, goal AS INTEGER
CONST initialGoal = 3
goal = initialGoal
 
DO
    IF gameOver THEN
        gameOver = false
        inGame = false
        goal = initialGoal
    END IF
 
    IF inGame THEN
        resetSequence
        DO 'main game
            DIM AS INTEGER x, y
 
            IF LEN(sequence$) \ 2 = goal THEN
                COLOR _RGB32(0, 222, 0)
                _PRINTSTRING (x, y), STRING$(goal, 1)
                _DISPLAY
                goal = goal + 2
                EXIT DO
            END IF
 
            CLS
            addNote
            y = boardY - _FONTHEIGHT
            x = (_WIDTH - _PRINTWIDTH(STRING$(goal, 254))) \ 2
            COLOR _RGB32(78)
            _PRINTSTRING (x, y), STRING$(goal, 254)
            COLOR _RGB32(255)
            _PRINTSTRING (x, y), STRING$(LEN(sequence$) \ 2, 254)
            playSequence
            getSequence
        LOOP UNTIL gameOver
        IF gameOver THEN resetSequence
    ELSE
        showMenu
    END IF
LOOP
 
SUB showMenu
    DIM m$
    DIM AS LONG x, y, mx, my
    DIM AS _BYTE mouseIsDown, mouseDownOnStart, startButtonHovered
 
    m$ = "< Start >"
    y = boardY - _FONTHEIGHT
    x = (_WIDTH - _PRINTWIDTH(m$)) \ 2
    DO
        CLS
        drawBoard
 
        WHILE _MOUSEINPUT: WEND
        mx = _MOUSEX: my = _MOUSEY
 
        startButtonHovered = (mx >= x AND mx <= x + _PRINTWIDTH(m$) AND my >= y AND my <= y + _FONTHEIGHT)
 
        IF startButtonHovered THEN
            COLOR _RGB32(0), _RGB32(255)
        ELSE
            COLOR _RGB32(255), _RGB32(0)
        END IF
 
        _PRINTSTRING (x, y), m$
        COLOR , _RGB32(0)
 
        IF _MOUSEBUTTON(1) THEN
            IF mouseIsDown = false THEN
                mouseIsDown = true
                mouseDownOnStart = false
                IF startButtonHovered THEN mouseDownOnStart = true
            ELSE
            END IF
        ELSE
            IF mouseIsDown THEN
                IF mouseDownOnStart AND startButtonHovered THEN
                    inGame = true
                    CLS
                    EXIT SUB
                END IF
            END IF
            mouseIsDown = false
        END IF
        _DISPLAY
        _LIMIT 30
    LOOP UNTIL _KEYHIT
END SUB
 
SUB getSequence STATIC
    DIM AS LONG i, index, mouseDownOn, mx, my, check
    DIM AS INTEGER x, y
    DIM AS _BYTE mouseIsDown
    DIM start!
 
    x = (_WIDTH - _PRINTWIDTH(STRING$(goal, 254))) \ 2
    y = boardY - _FONTHEIGHT
    index = 0
    mouseIsDown = false
    mouseDownOn = 0
    start! = TIMER
    DO
        IF timeElapsedSince(start!) > 3 THEN
            gameOver = true
            COLOR _RGB32(127, 0, 0)
            _PRINTSTRING (x, y), STRING$(goal, 254)
            EXIT DO
        END IF
 
        drawBoard
        WHILE _MOUSEINPUT: WEND
        mx = _MOUSEX - boardX: my = _MOUSEY - boardY
        IF _MOUSEBUTTON(1) THEN
            start! = TIMER
            IF mouseIsDown = false THEN
                mouseIsDown = true
                FOR i = 1 TO 4
                    IF mx >= block(i).x AND mx <= block(i).x + block(i).w AND my >= block(i).y AND my <= block(i).y + block(i).h THEN
                        mouseDownOn = i
                        EXIT FOR
                    END IF
                NEXT
            ELSE
                FOR i = 1 TO 4
                    IF mx >= block(i).x AND mx <= block(i).x + block(i).w AND my >= block(i).y AND my <= block(i).y + block(i).h THEN
                        IF mouseDownOn = i THEN drawSquare mouseDownOn, 2
                        EXIT FOR
                    END IF
                NEXT
            END IF
        ELSE
            IF mouseIsDown = true THEN
                FOR i = 1 TO 4
                    IF mx >= block(i).x AND mx <= block(i).x + block(i).w AND my >= block(i).y AND my <= block(i).y + block(i).h THEN
                        IF i = mouseDownOn THEN
                            'click
                            index = index + 1
                            IF index < LEN(sequence$) \ 2 THEN
                                COLOR _RGB32(238, 166, 0)
                            ELSE
                                COLOR _RGB32(0, 166, 238)
                            END IF
                            _PRINTSTRING (x, y), STRING$(index, 254)
 
                            check = CVI(MID$(sequence$, index * 2 - 1, 2))
                            drawBoard
                            drawSquare i, 2
                            PLAY "l16" + block(i).note + "l4"
                            _DISPLAY
                            IF i = check THEN
                                IF index = LEN(sequence$) \ 2 THEN
                                    drawBoard
                                    _DISPLAY
                                    _DELAY .5
                                    EXIT DO
                                END IF
                            ELSE
                                'error - restart
                                gameOver = true
                                COLOR _RGB32(127, 0, 0)
                                _PRINTSTRING (x, y), STRING$(goal, 254)
                                EXIT DO
                            END IF
                        END IF
                        EXIT FOR
                    END IF
                NEXT
            ELSE
                'hover
                FOR i = 1 TO 4
                    IF mx >= block(i).x AND mx <= block(i).x + block(i).w AND my >= block(i).y AND my <= block(i).y + block(i).h THEN
                        LINE (boardX + block(i).x, boardY + block(i).y)-STEP(block(i).w - 1, block(i).h - 1), _RGB32(255, 50), BF
                        EXIT FOR
                    END IF
                NEXT
            END IF
            mouseIsDown = false
        END IF
        _DISPLAY
    LOOP
END SUB
 
SUB addNote
    DIM i AS LONG
    i = _CEIL(RND * 4)
    sequence$ = sequence$ + MKI$(i)
END SUB
 
SUB playSequence
    DIM AS LONG j, i
    FOR j = 1 TO LEN(sequence$) \ 2
        drawBoard
        _DISPLAY
        _DELAY .05
        i = CVI(MID$(sequence$, j * 2 - 1, 2))
        drawSquare i, 2
        _DISPLAY
        _DELAY .2
        PLAY block(i).note
    NEXT
END SUB
 
SUB resetSequence
    DIM AS LONG j, i
    sequence$ = ""
 
    IF NOT gameOver THEN
        PLAY "mbT240l16aebcbedfcaebl4"
        'animation
        FOR j = 1 TO 12
            i = i + 1
            IF i = 5 THEN i = 1
            drawBoard
            drawSquare i, 2
            _DISPLAY
            _LIMIT 20
        NEXT
        PLAY "T120mf"
    ELSE
        FOR i = 1 TO 4
            drawSquare i, 2
        NEXT
        _DISPLAY
        PLAY "t120mfl2o1cl4"
    END IF
    drawBoard
    _DISPLAY
    _DELAY .5
END SUB
 
SUB drawBoard
    STATIC board AS LONG
    DIM AS LONG i
 
    IF board = 0 THEN
        board = _NEWIMAGE(_WIDTH(canvas), _HEIGHT(canvas), 32)
        FOR i = 1 TO 4
            drawSquare i, 1
        NEXT
        _PUTIMAGE (0, 0), , board, (boardX, boardY)-STEP(_WIDTH(canvas) - 1, _HEIGHT(canvas) - 1)
    ELSE
        _PUTIMAGE (boardX, boardY), board
    END IF
 
END SUB
 
SUB drawSquare (this AS INTEGER, c AS INTEGER)
    DIM thisColor AS _UNSIGNED LONG
    IF c = 1 THEN thisColor = block(this).low ELSE thisColor = block(this).high
    LINE (boardX + block(this).x, boardY + block(this).y)-STEP(block(this).w - 1, block(this).h - 1), thisColor, BF
END SUB
 
FUNCTION timeElapsedSince! (startTime!)
    IF startTime! > TIMER THEN startTime! = startTime! - 86400
    timeElapsedSince! = TIMER - startTime!
END FUNCTION
 
