CONST true = -1, false = 0
RANDOMIZE TIMER
SCREEN _NEWIMAGE(400, 400, 32)
DO UNTIL _SCREENEXISTS: LOOP
_TITLE "Genius"

TYPE blocks
    AS INTEGER x, y, w, h
    AS _UNSIGNED LONG low, high
    AS STRING note
END TYPE

DIM SHARED block(1 TO 4) AS blocks
DIM SHARED gameOver AS _BYTE

FOR i = 1 TO 4
    block(i).w = _WIDTH \ 2
    block(i).h = _HEIGHT \ 2
NEXT

i = 0
i = i + 1: block(i).x = 0: block(i).y = 0
block(i).note = "o2c#" 'yellow
block(i).high = _RGB32(194, 194, 0)
block(i).low = _RGB32(161, 116, 0)

i = i + 1: block(i).x = _WIDTH \ 2: block(i).y = 0
block(i).note = "o2e" 'blue
block(i).high = _RGB32(0, 105, 233)
block(i).low = _RGB32(0, 0, 78)

i = i + 1: block(i).x = 0: block(i).y = _HEIGHT \ 2
block(i).note = "o2a" 'red
block(i).high = _RGB32(227, 0, 0)
block(i).low = _RGB32(78, 0, 0)

i = i + 1: block(i).x = _WIDTH \ 2: block(i).y = _HEIGHT \ 2
block(i).note = "o1e" 'green
block(i).high = _RGB32(0, 155, 0)
block(i).low = _RGB32(0, 78, 0)

drawBoard
_DISPLAY
_DELAY 1

DIM SHARED sequence$
DO
    resetSequence
    gameOver = false
    DO 'main game
        addNote
        playSequence
        getSequence
    LOOP UNTIL gameOver
LOOP

SUB getSequence STATIC
    index = 0
    mouseIsDown = false
    mouseDownOn = 0
    DO
        drawBoard
        WHILE _MOUSEINPUT: WEND
        mx = _MOUSEX: my = _MOUSEY
        IF _MOUSEBUTTON(1) THEN
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
                                EXIT DO
                            END IF
                        END IF
                        EXIT FOR
                    END IF
                NEXT
            ELSE
            END IF
            mouseIsDown = false
        END IF
        _DISPLAY
    LOOP
END SUB

SUB addNote
    i = _CEIL(RND * 4)
    sequence$ = sequence$ + MKI$(i)
END SUB

SUB playSequence
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
    sequence$ = ""

    PLAY "T240l16aebcbedfcl4"
    'animation
    FOR j = 1 TO 8
        i = i + 1
        IF i = 5 THEN i = 1
        drawBoard
        drawSquare i, 2
        _DISPLAY
        _LIMIT 10
    NEXT
    PLAY "T120"
    drawBoard
    _DISPLAY
    _DELAY .5
END SUB

SUB drawBoard
    STATIC board AS LONG
    IF board = 0 THEN
        board = _NEWIMAGE(_WIDTH, _HEIGHT, 32)
        _DEST board
        FOR i = 1 TO 4
            drawSquare i, 1
        NEXT
        _DEST 0
    END IF
    _PUTIMAGE , board
END SUB

SUB drawSquare (i AS INTEGER, c AS INTEGER)
    DIM thisColor AS _UNSIGNED LONG
    IF c = 1 THEN thisColor = block(i).low ELSE thisColor = block(i).high
    LINE (block(i).x, block(i).y)-STEP(block(i).w - 1, block(i).h - 1), thisColor, BF
END SUB
