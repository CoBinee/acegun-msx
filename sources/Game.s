; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Generator.inc"
    .include    "Enemy.inc"
    .include    "Back.inc"
    .include    "Bomb.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName
    
    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; ジェネレータの初期化
    call    _GeneratorInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; 背景の初期化
    call    _BackInitialize

    ; 爆発の初期化
    call    _BombInitialize

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 処理の設定
    ld      hl, #GameStart
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a

    ; 状態の設定
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_game + GAME_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを待機する
;
GameIdle:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フレームの設定
    xor     a
    ld      (_game + GAME_FRAME), a

    ; 開始の表示
    call    GamePrintStart

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; BGM の再生
    ld      a, #SOUND_BGM_GAME
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; プレイの表示
    call    GamePrintPlay

    ; 処理の更新
    ld      hl, #GamePlay
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; 転送の設定
    ld      hl, #GameTransfer
    ld      (_transfer), hl

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ヒットの判定
    call    GameHit

    ; プレイヤの更新
    call    _PlayerUpdate

    ; ジェネレータの更新
    call    _GeneratorUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 背景の更新
    call    _BackUpdate

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 背景の描画
    call    _BackRender

    ; スコアの表示
    call    GamePrintScore

    ; ゲームクリアの判定
    call    _SoundIsPlayBgm
    jr      c, 90$
    ld      hl, #GameClear
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
    jr      99$
90$:

    ; ゲームオーバーの判定
    call    _PlayerIsOver
    jr      nc, 99$
    ld      hl, #GameOver
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
;   jr      99$
99$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0xff
    ld      (_game + GAME_FRAME), a

    ; 転送の設定
    ld      hl, #GameTransfer
    ld      (_transfer), hl

    ; BGM の停止
    call    _SoundStop

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 0x01 : 待機
10$:
    ld      a, (_game + GAME_STATE)
    dec     a
    jr      nz, 20$

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 11$

    ; ゲームオーバーの表示
    call    GamePrintOver

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
    jr      19$
11$:

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 背景の更新
    call    _BackUpdate

    ; 爆発の更新
    call    _BombUpdate

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 背景の描画
    call    _BackRender

    ; 爆発の描画
    call    _BombRender

    ; スコアの表示
    call    GamePrintScore
19$:
    jr      90$

    ; 0x02 : ゲームオーバー
20$:
    dec     a
    jr      nz, 30$

    ; SPACE キーの入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 29$

    ; フレームの設定
    ld      a, #0x30
    ld      (_game + GAME_FRAME), a

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
29$:
    jr      90$

    ; 0x03 : 終了待ち
30$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 39$

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
39$:
;   jr      90$

    ; ゲームオーバーの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; エネミーの爆発
    call    _EnemyBombAll

    ; フレームの設定
    ld      a, #0x60
    ld      (_game + GAME_FRAME), a

    ; 転送の設定
    ld      hl, #GameTransfer
    ld      (_transfer), hl

    ; BGM の停止
    call    _SoundStop

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 背景の更新
    call    _BackUpdate

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 背景の描画
    call    _BackRender

    ; スコアの表示
    call    GamePrintScore

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 処理の更新
    ld      hl, #GameBonus
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ボーナスを加える
;
GameBonus:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; カウントの設定
    xor     a
    ld      (_game + GAME_FRAME), a

    ; フレームの設定
    ld      a, #0x60
    ld      (_game + GAME_FRAME), a

    ; 転送の設定
    ld      hl, #GameTransfer
    ld      (_transfer), hl

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ボーナスの加算
    call    _PlayerCountLife
    or      a
    jr      z, 10$
    ld      de, #0x000a
    call    _GameAddScore
    ld      hl, #(_game + GAME_COUNT)
    inc     (hl)
    ld      a, (hl)
    rrca
    ld      a, #SOUND_SE_COUNT
    call    c, _SoundPlaySe
    jr      19$
10$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
19$:

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 背景の更新
    call    _BackUpdate

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 背景の描画
    call    _BackRender

    ; スコアの表示
    call    GamePrintScore

    ; 処理の更新
    ld      a, (_game + GAME_FRAME)
    or      a
    jr      nz, 29$
    ld      hl, #GameResult
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
29$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの結果を示す
;
GameResult:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; スコアの更新
    ld      de, (_game + GAME_SCORE_L)
    call    _AppSetScore
    jr      c, 00$
    call    GamePrintResultLow
    jr      01$
00$:
    call    GamePrintResultTop
;   jr      01$
01$:

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 0x01 : キー入力待ち
10$:
    ld      a, (_game + GAME_STATE)
    dec     a
    jr      nz, 20$

    ; SPACE キーの入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; フレームの設定
    ld      a, #0x30
    ld      (_game + GAME_FRAME), a

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の更新
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
19$:
    jr      90$

    ; 0x02 : 終了待ち
20$:
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 29$

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
29$:
;   jr      90$

    ; 結果の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; VRAM へ転送する
;
GameTransfer:

    ; レジスタの保存

    ; d < ポート #0
    ; e < ポート #1

    ; ライフの転送　
    ld      hl, #0x0022
    ld      b, #0x1e
    call    GameTransferPatternName

    ; スコアの転送　
    ld      hl, #0x006d
    ld      b, #0x05
    call    GameTransferPatternName

    ; デバッグの転送　
    ld      hl, #0x02e0
    ld      b, #0x20
    call    GameTransferPatternName

    ; レジスタの復帰

    ; 終了
    ret

GameTransferPatternName:

    ; レジスタの保存
    push    de

    ; d  < ポート #0
    ; e  < ポート #1
    ; hl < 相対アドレス
    ; b  < 転送バイト数

    ; パターンネームテーブルの取得    
    ld      a, (_videoRegister + VDP_R2)
    add     a, a
    add     a, a
    add     a, h

    ; VRAM アドレスの設定
    ld      c, e
    out     (c), l
    or      #0b01000000
    out     (c), a

    ; パターンネームテーブルの転送
    ld      c, d
    ld      de, #_patternName
    add     hl, de
10$:
    outi
    jp      nz, 10$

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; ヒットの判定を行う
;
GameHit:

    ; レジスタの保存

    ; プレイヤの取得
    call    _PlayerGetRay
    ld      a, b
    or      a
    jp      z, 190$
    ld      a, c
    ld      c, b
    inc     c

    ; エネミーとの判定
    and     #0xe0
    jr      z, 100$
    ld      b, #0x20
    sub     b
    jr      z, 110$
    sub     b
    jp      z, 120$
    sub     b
    jp      z, 130$
    sub     b
    jp      z, 140$
    sub     b
    jp      z, 150$
    sub     b
    jp      z, 160$
    jp      170$

    ;   0 -  45
100$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
101$:
    push    bc
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 109$
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #(GAME_O_X - GAME_HIT_SIZE_O)
    jr      c, 109$
    cp      #(GAME_O_X + GAME_HIT_SIZE_O)
    jr      nc, 102$
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      #(GAME_O_Y - GAME_HIT_SIZE_O)
    jr      c, 109$
    cp      #(GAME_O_Y + GAME_HIT_SIZE_O)
    jr      nc, 109$
    jr      108$
102$:
    sub     #(GAME_O_X + 0x00)
    cp      c
    jr      nc, 109$
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      a, ENEMY_POSITION_Y_H(ix)
    sub     #(GAME_O_Y + 0x00)
    sub     (hl)
    jp      p, 103$
    neg
103$:
    cp      ENEMY_R(ix)
    jr      nc, 109$
;   jr      108$
108$:
    call    _EnemyTakeDamage
109$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    101$
    jp      190$

    ;  45 -  90
110$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
111$:
    push    bc
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 119$
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      #(GAME_O_Y - GAME_HIT_SIZE_O)
    jr      c, 119$
    cp      #(GAME_O_Y + GAME_HIT_SIZE_O)
    jr      nc, 112$
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #(GAME_O_X - GAME_HIT_SIZE_O)
    jr      c, 119$
    cp      #(GAME_O_X + GAME_HIT_SIZE_O)
    jr      nc, 119$
    jr      118$
112$:
    sub     #(GAME_O_Y + 0x00)
    cp      c
    jr      nc, 119$
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      a, ENEMY_POSITION_X_H(ix)
    sub     #(GAME_O_X + 0x00)
    sub     (hl)
    jp      p, 113$
    neg
113$:
    cp      ENEMY_R(ix)
    jr      nc, 119$
;   jr      118$
118$:
    call    _EnemyTakeDamage
119$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    111$
    jp      190$

    ;  90 - 135
120$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
121$:
    push    bc
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 129$
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      #(GAME_O_Y - GAME_HIT_SIZE_O)
    jr      c, 129$
    cp      #(GAME_O_Y + GAME_HIT_SIZE_O)
    jr      nc, 122$
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #(GAME_O_X - GAME_HIT_SIZE_O)
    jr      c, 129$
    cp      #(GAME_O_X + GAME_HIT_SIZE_O)
    jr      nc, 129$
    jr      128$
122$:
    sub     #(GAME_O_Y + 0x00)
    cp      c
    jr      nc, 129$
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      a, ENEMY_POSITION_X_H(ix)
    sub     #(GAME_O_X - 0x01)
    add     a, (hl)
    jp      p, 123$
    neg
123$:
    cp      ENEMY_R(ix)
    jr      nc, 129$
;   jr      128$
128$:
    call    _EnemyTakeDamage
129$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    121$
    jp      190$

    ; 135 - 180
130$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
131$:
    push    bc
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 139$
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #(GAME_O_X + GAME_HIT_SIZE_O)
    jr      nc, 139$
    cp      #(GAME_O_X - GAME_HIT_SIZE_O)
    jr      c, 132$
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      #(GAME_O_Y - GAME_HIT_SIZE_O)
    jr      c, 139$
    cp      #(GAME_O_Y + GAME_HIT_SIZE_O)
    jr      nc, 139$
    jr      138$
132$:
    sub     #(GAME_O_X - 0x01)
    neg
    cp      c
    jr      nc, 139$
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      a, ENEMY_POSITION_Y_H(ix)
    sub     #(GAME_O_Y + 0x00)
    sub     (hl)
    jp      p, 133$
    neg
133$:
    cp      ENEMY_R(ix)
    jr      nc, 139$
;   jr      138$
138$:
    call    _EnemyTakeDamage
139$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    131$
    jp      190$

    ; 180 - 225
140$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
141$:
    push    bc
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 149$
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #(GAME_O_X + GAME_HIT_SIZE_O)
    jr      nc, 149$
    cp      #(GAME_O_X - GAME_HIT_SIZE_O)
    jr      c, 142$
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      #(GAME_O_Y - GAME_HIT_SIZE_O)
    jr      c, 149$
    cp      #(GAME_O_Y + GAME_HIT_SIZE_O)
    jr      nc, 149$
    jr      148$
142$:
    sub     #(GAME_O_X - 0x01)
    neg
    cp      c
    jr      nc, 149$
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      a, ENEMY_POSITION_Y_H(ix)
    sub     #(GAME_O_Y + 0x00)
    add     a, (hl)
    jp      p, 143$
    neg
143$:
    cp      ENEMY_R(ix)
    jr      nc, 149$
;   jr      148$
148$:
    call    _EnemyTakeDamage
149$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    141$
    jp      190$

    ; 225 - 270
150$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
151$:
    push    bc
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 159$
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      #(GAME_O_Y + GAME_HIT_SIZE_O)
    jr      nc, 159$
    cp      #(GAME_O_Y - GAME_HIT_SIZE_O)
    jr      c, 152$
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #(GAME_O_X - GAME_HIT_SIZE_O)
    jr      c, 159$
    cp      #(GAME_O_X + GAME_HIT_SIZE_O)
    jr      nc, 159$
    jr      158$
152$:
    sub     #(GAME_O_Y - 0x01)
    neg
    cp      c
    jr      nc, 159$
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      a, ENEMY_POSITION_X_H(ix)
    sub     #(GAME_O_X - 0x01)
    add     a, (hl)
    jp      p, 153$
    neg
153$:
    cp      ENEMY_R(ix)
    jr      nc, 159$
;   jr      158$
158$:
    call    _EnemyTakeDamage
159$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    151$
    jp      190$

    ; 270 - 315
160$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
161$:
    push    bc
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 169$
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      #(GAME_O_Y + GAME_HIT_SIZE_O)
    jr      nc, 169$
    cp      #(GAME_O_Y - GAME_HIT_SIZE_O)
    jr      c, 162$
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #(GAME_O_X - GAME_HIT_SIZE_O)
    jr      c, 169$
    cp      #(GAME_O_X + GAME_HIT_SIZE_O)
    jr      nc, 169$
    jr      168$
162$:
    sub     #(GAME_O_Y - 0x01)
    neg
    cp      c
    jr      nc, 169$
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      a, ENEMY_POSITION_X_H(ix)
    sub     #(GAME_O_X + 0x00)
    sub     (hl)
    jp      p, 163$
    neg
163$:
    cp      ENEMY_R(ix)
    jr      nc, 169$
;   jr      168$
168$:
    call    _EnemyTakeDamage
169$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    161$
    jr      190$

    ; 315 - 360
170$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
171$:
    push    bc
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 179$
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #(GAME_O_X - GAME_HIT_SIZE_O)
    jr      c, 179$
    cp      #(GAME_O_X + GAME_HIT_SIZE_O)
    jr      nc, 172$
    ld      a, ENEMY_POSITION_Y_H(ix)
    cp      #(GAME_O_Y - GAME_HIT_SIZE_O)
    jr      c, 179$
    cp      #(GAME_O_Y + GAME_HIT_SIZE_O)
    jr      nc, 179$
    jr      178$
172$:
    sub     #(GAME_O_X + 0x00)
    cp      c
    jr      nc, 179$
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      a, ENEMY_POSITION_Y_H(ix)
    sub     #(GAME_O_Y - 0x01)
    add     a, (hl)
    jp      p, 173$
    neg
173$:
    cp      ENEMY_R(ix)
    jr      nc, 179$
;   jr      178$
178$:
    call    _EnemyTakeDamage
179$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    171$
;   jr      190$

    ; エネミーとの判定の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; スコアを加算する
;
_GameAddScore::

    ; レジスタの保存
    push    hl
    push    de

    ; de < 加算するスコア

    ; スコアの加算
    ld      hl, (_game + GAME_SCORE_L)
    add     hl, de
    ld      de, #GAME_SCORE_MAXIMUM
    or      a
    sbc     hl, de
    jr      nc, 10$
    add     hl, de
    jr      19$
10$:
    ex      de, hl
;   jr      19$
19$:
    ld      (_game + GAME_SCORE_L), hl

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; スコアを表示する
;
GamePrintScore:

    ; レジスタの保存
    
    ; スコアの描画
    ld      hl, (_game + GAME_SCORE_L)
    ld      de, #(_game + GAME_SCORE_10000)
    call    _AppGetDecimal16
    ld      hl, #(_game + GAME_SCORE_10000)
    ld      de, #(_patternName + 0x006d)
    call    GamePrintValue

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの開始を表示する
;
GamePrintStart:

    ; レジスタの保存

    ; 背景の描画
    call    _BackPrintStart

    ; 開始の描画
    ld      hl, #gameStartString
    ld      de, #(_patternName + 0x00161)
    call    GamePrintString

    ; レジスタの復帰

    ; 終了
    ret

; ゲームのプレイを表示する
;
GamePrintPlay:

    ; レジスタの保存

    ; 背景の描画
    call    _BackPrintPlay

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーを表示する
;
GamePrintOver:

    ; レジスタの保存

    ; 背景の描画
    call    _BackPrintOver

    ; ゲームオーバーの描画
    ld      hl, #gameOverString
    ld      de, #(_patternName + 0x0016b)
    call    GamePrintString

    ; レジスタの復帰

    ; 終了
    ret

; 結果を表示する
;
GamePrintResultLow:

    ; レジスタの保存

    ; 背景の描画
    call    _BackPrintResultLow

    ; スコアの描画
    ld      hl, #gameResultStringScore
    ld      de, #(_patternName + 0x008a)
    call    GamePrintString
    ld      hl, (_game + GAME_SCORE_L)
    ld      de, #(_game + GAME_SCORE_10000)
    call    _AppGetDecimal16
    ld      hl, #(_game + GAME_SCORE_10000)
    ld      de, #(_patternName + 0x0090)
    call    GamePrintValue

    ; メッセージの描画
    ld      hl, #gameResultStringLow
    ld      de, #(_patternName + 0x0268)
    call    GamePrintString

    ; レジスタの復帰

    ; 終了
    ret

GamePrintResultTop:

    ; レジスタの保存

    ; 背景の描画
    call    _BackPrintResultTop

    ; スコアの描画
    ld      hl, #gameResultStringScore
    ld      de, #(_patternName + 0x008a)
    call    GamePrintString
    ld      hl, (_game + GAME_SCORE_L)
    ld      de, #(_game + GAME_SCORE_10000)
    call    _AppGetDecimal16
    ld      hl, #(_game + GAME_SCORE_10000)
    ld      de, #(_patternName + 0x0090)
    call    GamePrintValue

    ; メッセージの描画
    ld      hl, #gameResultStringTop
    ld      de, #(_patternName + 0x0268)
    call    GamePrintString

    ; レジスタの復帰

    ; 終了
    ret

; 文字列を表示する
;
GamePrintString:

    ; レジスタの保存

    ; hl < 文字列
    ; de < パターンネーム

    ; 文字列の描画
10$:
    ld      a, (hl)
    or      a
    jr      z, 19$
    sub     #0x20
    ld      (de), a
    inc     hl
    inc     de
    jr      10$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 数値を表示する
;
GamePrintValue:

    ; レジスタの保存

    ; hl < 数値
    ; de < パターンネーム

    ; 数値の描画
    ld      b, #(0x05 - 0x01)
10$:
    ld      a, (hl)
    or      a
    jr      nz, 11$
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$
11$:
    inc     b
12$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    12$

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; ゲームの初期値
;
gameDefault:

    .dw     GAME_PROC_NULL
    .db     GAME_STATE_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_FRAME_NULL
    .db     GAME_COUNT_NULL
    .dw     GAME_SCORE_NULL
    .db     GAME_SCORE_NULL
    .db     GAME_SCORE_NULL
    .db     GAME_SCORE_NULL
    .db     GAME_SCORE_NULL
    .db     GAME_SCORE_NULL

; ゲームの開始
;
gameStartString:

    .ascii  "PLEASE!! TIME ENOUGH FOR LOVE!"
    .db     0x00

; ゲームオーバー
;
gameOverString:

    .ascii  "GAME  OVER"
    .db     0x00

; 結果
;
gameResultStringScore:

    .ascii  "SCORE"
    .db     0x00

gameResultStringLow:

    .ascii  "AIM FOR THE TOP!"
    .db     0x00

gameResultStringTop:

    .ascii  "YOU ARE THE TOP!"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::

    .ds     GAME_LENGTH

