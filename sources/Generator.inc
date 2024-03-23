; Generator.inc : ジェネレータ
;


; マクロの定義
;

; ジェネレータ
GENERATOR_PROC_L                =   0x00
GENERATOR_PROC_H                =   0x01
GENERATOR_STATE                 =   0x02
GENERATOR_FLAG                  =   0x03
GENERATOR_FRAME                 =   0x04
GENERATOR_COUNT                 =   0x05
GENERATOR_SELECT                =   0x06
GENERATOR_ENEMY_L               =   0x07
GENERATOR_ENEMY_H               =   0x08
GENERATOR_GROUP_L               =   0x09
GENERATOR_GROUP_H               =   0x0a
GENERATOR_GROUP_SIZE            =   0x0b
GENERATOR_FALL_0                =   0x0c
GENERATOR_FALL_1                =   0x0d
GENERATOR_FALL_2                =   0x0e
GENERATOR_FALL_3                =   0x0f
GENERATOR_FALL_4                =   0x10
GENERATOR_FALL_5                =   0x11
GENERATOR_FALL_6                =   0x12
GENERATOR_FALL_7                =   0x13
GENERATOR_LENGTH                =   0x14

; 処理
GENERATOR_PROC_NULL             =   0x00

; 状態
GENERATOR_STATE_NULL            =   0x00
GENERATOR_STATE_FALL            =   0x01
GENERATOR_STATE_ROUTE           =   0x02

; フラグ
GENERATOR_FLAG_NULL             =   0x00

; フレーム
GENERATOR_FRAME_NULL            =   0x00
GENERATOR_FRAME_SELECT          =   0x08
GENERATOR_FRAME_FALL            =   0x10
GENERATOR_FRAME_ROUTE           =   0x08

; カウント
GENERATOR_COUNT_NULL            =   0x00
GENERATOR_COUNT_ONE             =   0x08
GENERATOR_COUNT_ROUTE_DOUBLE    =   0x04

; 選択
GENERATOR_SELECT_NULL           =   0x00

; エネミー
GENERATOR_ENEMY_NULL            =   0x00

; グループ
GENERATOR_GROUP_NULL            =   0x00
GENERATOR_GROUP_SIZE_NULL       =   0x00
GENERATOR_GROUP_SIZE_0          =   0x00
GENERATOR_GROUP_SIZE_1          =   0x10
GENERATOR_GROUP_SIZE_2          =   0x20
GENERATOR_GROUP_SIZE_3          =   0x30
GENERATOR_GROUP_SIZE_ONE        =   0x10
GENERATOR_GROUP_SIZE_MASK       =   0x30
GENERATOR_GROUP_TYPE_NULL       =   0x00
GENERATOR_GROUP_TYPE_ZAKO_0     =   0x01
GENERATOR_GROUP_TYPE_ZAKO_1     =   0x02
GENERATOR_GROUP_TYPE_ZAKO_2     =   0x03
GENERATOR_GROUP_TYPE_ZAKO_3     =   0x04
GENERATOR_GROUP_TYPE_ZAKO_4     =   0x05
GENERATOR_GROUP_TYPE_LEADER_0   =   0x06
GENERATOR_GROUP_TYPE_LEADER_1   =   0x07
GENERATOR_GROUP_TYPE_LEADER_2   =   0x08
GENERATOR_GROUP_TYPE_LEADER_3   =   0x09
GENERATOR_GROUP_TYPE_LEADER_4   =   0x0a
GENERATOR_GROUP_TYPE_BOSS       =   0x0b

; 落下
GENERATOR_FALL_NULL             =   0x00
GENERATOR_FALL_LENGTH           =   0x08

; 外部関数宣言
;

    .globl  _GeneratorInitialize
    .globl  _GeneratorUpdate

; 外部変数宣言
;

    .globl  _generator
