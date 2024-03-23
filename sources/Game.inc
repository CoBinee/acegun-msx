; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER              =   0x50
GAME_SPRITE_ENEMY               =   0x10
GAME_SPRITE_BOSS                =   0x00
GAME_SPRITE_BOMB                =   0x70

; ゲーム
GAME_PROC_L                     =   0x00
GAME_PROC_H                     =   0x01
GAME_STATE                      =   0x02
GAME_FLAG                       =   0x03
GAME_FRAME                      =   0x04
GAME_COUNT                      =   0x05
GAME_SCORE_L                    =   0x06
GAME_SCORE_H                    =   0x07
GAME_SCORE_10000                =   0x08
GAME_SCORE_01000                =   0x09
GAME_SCORE_00100                =   0x0a
GAME_SCORE_00010                =   0x0b
GAME_SCORE_00001                =   0x0c
GAME_LENGTH                     =   0x0d

; 処理
GAME_PROC_NULL                  =   0x00

; 状態
GAME_STATE_NULL                 =   0x00

; フラグ
GAME_FLAG_NULL                  =   0x00

; フレーム
GAME_FRAME_NULL                 =   0x00

; カウント
GAME_COUNT_NULL                 =   0x00

; スコア
GAME_SCORE_NULL                 =   0x00
GAME_SCORE_MAXIMUM              =   9999

;　中心
GAME_O_X                        =   0x80
GAME_O_Y                        =   0x80

; ヒット
GAME_HIT_SIZE_O                 =   0x0c

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GameAddScore
    
; 外部変数宣言
;

    .globl  _game
