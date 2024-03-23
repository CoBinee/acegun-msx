; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_PROC_L                    =   0x00
ENEMY_PROC_H                    =   0x01
ENEMY_STATE                     =   0x02
ENEMY_FLAG                      =   0x03
ENEMY_LIFE                      =   0x04
ENEMY_ATTACK                    =   0x05
ENEMY_SCORE_L                   =   0x06
ENEMY_SCORE_H                   =   0x07
ENEMY_POSITION_X_L              =   0x08
ENEMY_POSITION_X_H              =   0x09
ENEMY_POSITION_Y_L              =   0x0a
ENEMY_POSITION_Y_H              =   0x0b
ENEMY_SPEED_L                   =   0x0c
ENEMY_SPEED_H                   =   0x0d
ENEMY_DIRECTION                 =   0x0e
ENEMY_FORWARD                   =   0x0f
ENEMY_ROTATE                    =   0x10
ENEMY_MOVE_L                    =   0x11
ENEMY_MOVE_H                    =   0x12
ENEMY_MOVE_FRAME                =   0x13
ENEMY_R                         =   0x14
ENEMY_ANIMATION                 =   0x15
ENEMY_FLASH                     =   0x16
ENEMY_SPRITE_Y                  =   0x17
ENEMY_SPRITE_X                  =   0x18
ENEMY_SPRITE_PATTERN            =   0x19
ENEMY_SPRITE_COLOR              =   0x1a
ENEMY_LENGTH                    =   0x1b

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_FREE                 =   0x01
ENEMY_TYPE_FALL                 =   0x02
ENEMY_TYPE_ROUTE                =   0x03
ENEMY_TYPE_BOSS                 =   0x04
ENEMY_TYPE_BOMB                 =   0x10

; 処理
ENEMY_PROC_NULL                 =   0x00

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_x2_BIT               =   0x00
ENEMY_FLAG_x2                   =   (1 << ENEMY_FLAG_x2_BIT)

; ライフ
ENEMY_LIFE_NULL                 =   0x00
ENEMY_LIFE_EASY                 =   0x01
ENEMY_LIFE_NORMAL               =   0x01
ENEMY_LIFE_HARD                 =   0x01

; 攻撃力
ENEMY_ATTACK_NULL               =   0x00

; スコア
ENEMY_SCORE_NULL                =   0x00

; 位置
ENEMY_POSITION_NULL             =   0x00
ENEMY_POSITION_ATTACK           =   0xc0

; 速度
ENEMY_SPEED_NULL                =   0x00
ENEMY_SPEED_MAXIMUM             =   0x04
ENEMY_SPEED_GRAVITY             =   0x0008
ENEMY_SPEED_DAMAGE              =   0x0020

; 向き
ENEMY_DIRECTION_NULL            =   0x00

; 前方向
ENEMY_FORWARD_NULL              =   0x00

; 回転
ENEMY_ROTATE_NULL               =   0x00

; 移動
ENEMY_MOVE_NULL                 =   0x00

; 半径
ENEMY_R_NULL                    =   0x00
ENEMY_R_x1                      =   0x08
ENEMY_R_x2                      =   0x10

; フレーム
ENEMY_FRAME_NULL                =   0x00

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00

; フラッシュ
ENEMY_FLASH_NULL                =   0x00
ENEMY_FLASH_FRAME               =   0x02

; スプライト
ENEMY_SPRITE_NULL               =   0x00

; エントリ
ENEMY_ENTRY                     =   0x10

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyFreeBorn
    .globl  _EnemyFallBorn
    .globl  _EnemyRouteBorn
    .globl  _EnemyBossBorn
    .globl  _EnemyTakeDamage
    .globl  _EnemyBombAll
    .globl  _EnemyGetRest

; 外部変数宣言
;

    .globl  _enemy
