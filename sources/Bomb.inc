; Bomb.inc : 爆発
;


; マクロの定義
;

; 爆発
BOMB_STATE                      =   0x00
BOMB_POSITION_X                 =   0x01
BOMB_POSITION_Y                 =   0x02
BOMB_ANIMATION                  =   0x03
BOMB_LENGTH                     =   0x04

; 状態
BOMB_STATE_NULL                 =   0x00

; 位置
BOMB_POSITION_NULL              =   0x00

; アニメーション
BOMB_ANIMATION_NULL             =   0x00

; エントリ
BOMB_ENTRY                      =   0x04

; フレーム
BOMB_FRAME_INTERVAL             =   0x04

; 外部関数宣言
;

    .globl  _BombInitialize
    .globl  _BombUpdate
    .globl  _BombRender

; 外部変数宣言
;

    .globl  _bomb
