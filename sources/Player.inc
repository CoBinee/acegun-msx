; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_PROC_L                   =   0x00
PLAYER_PROC_H                   =   0x01
PLAYER_STATE                    =   0x02
PLAYER_FLAG                     =   0x03
PLAYER_LIFE                     =   0x04
PLAYER_DAMAGE                   =   0x05
PLAYER_ANGLE_L                  =   0x06
PLAYER_ANGLE_H                  =   0x07
PLAYER_SPEED_L                  =   0x08
PLAYER_SPEED_H                  =   0x09
PLAYER_TARGET_L                 =   0x0a
PLAYER_TARGET_H                 =   0x0b
PLAYER_R                        =   0x0c
PLAYER_ANIMATION                =   0x0d
PLAYER_FLASH                    =   0x0e
PLAYER_LENGTH                   =   0x0f

; 処理
PLAYER_PROC_NULL                =   0x00

; 状態
PLAYER_STATE_NULL               =   0x00

; フラグ
PLAYER_FLAG_NULL                =   0x00

; ライフ
PLAYER_LIFE_NULL                =   0x00
PLAYER_LIFE_MAXIMUM             =   0xe0

; ダメージ
PLAYER_DAMAGE_NULL              =   0x00

; 角度
PLAYER_ANGLE_NULL               =   0x00

; 速度
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_ACCEL              =   0x0018
PLAYER_SPEED_BRAKE              =   0x0020
PLAYER_SPEED_MAXIMUM            =   0x02

; 照準
PLAYER_TARGET_NULL              =   0x00

; 半径
PLAYER_R_NULL                   =   0x00
PLAYER_R_SPEED                  =   0x08
PLAYER_R_MAXIMUM                =   0x80

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00

; フラッシュ
PLAYER_FLASH_NULL               =   0x00
PLAYER_FLASH_FRAME              =   0x04

; 幅
PLAYER_WIDE_HALF                =   0x03

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerIsOver
    .globl  _PlayerTakeDamage
    .globl  _PlayerGetRay
    .globl  _PlayerGetAngle
    .globl  _PlayerCountLife
    
; 外部変数宣言
;

    .globl  _player
