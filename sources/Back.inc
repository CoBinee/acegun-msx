; Back.inc : 背景
;


; マクロの定義
;

; 背景
BACK_STATE                      =   0x00
BACK_FRAME                      =   0x01
BACK_LENGTH                     =   0x02

; 状態
BACK_STATE_NULL                 =   0x00

; フレーム
BACK_FRAME_NULL                 =   0x00

; 外部関数宣言
;

    .globl  _BackInitialize
    .globl  _BackUpdate
    .globl  _BackRender
    .globl  _BackPrintStart
    .globl  _BackPrintPlay
    .globl  _BackPrintOver
    .globl  _BackPrintResultLow
    .globl  _BackPrintResultTop

; 外部変数宣言
;

    .globl  _back
