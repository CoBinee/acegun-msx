; Back.s : 背景
;


; モジュール宣言
;
    .module Back

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Back.inc"

; 外部変数宣言
;

    .globl  _busterColorTable
    .globl  _busterPatternGenerator
    .globl  _busterPatternName
    .globl  _coach0ColorTable
    .globl  _coach0PatternGenerator
    .globl  _coach0PatternName
    .globl  _coach1ColorTable
    .globl  _coach1PatternGenerator
    .globl  _coach1PatternName

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 背景を初期化する
;
_BackInitialize::

    ; レジスタの保存

    ; 背景の初期化
    ld      hl, #backDefault
    ld      de, #_back
    ld      bc, #BACK_LENGTH
    ldir

    ; カラーテーブルの初期化
    call    BackBuildColorTable
    ld      hl, #(backColorTable + 0x0000)
    ld      de, #(APP_COLOR_TABLE + 0x0000)
    ld      bc, #0x0020
    call    LDIRVM
    ld      hl, #(backColorTable + 0x0020)
    ld      de, #(APP_COLOR_TABLE + 0x0040)
    ld      bc, #0x0020
    call    LDIRVM
    ld      hl, #(backColorTable + 0x0040)
    ld      de, #(APP_COLOR_TABLE + 0x0080)
    ld      bc, #0x0020
    call    LDIRVM
    ld      hl, #(backColorTable + 0x0060)
    ld      de, #(APP_COLOR_TABLE + 0x00c0)
    ld      bc, #0x0020
    call    LDIRVM

    ; パターンジェネレータの転送
    ld      hl, #_busterPatternGenerator
    ld      de, #(APP_PATTERN_GENERATOR_TABLE + 0x0000 + 0x0020 * 0x0008)
    ld      bc, #(0x00e0 * 0x0008)
    call    LDIRVM
    ld      hl, #_coach0PatternGenerator
    ld      de, #(APP_PATTERN_GENERATOR_TABLE + 0x0800 + 0x0080 * 0x0008)
    ld      bc, #(0x0078 * 0x0008)
    call    LDIRVM
    ld      hl, #_coach1PatternGenerator
    ld      de, #(APP_PATTERN_GENERATOR_TABLE + 0x1000 + 0x0080 * 0x0008)
    ld      bc, #(0x0078 * 0x0008)
    call    LDIRVM

    ; レジスタの復帰

    ; 終了
    ret

; 背景を更新する
;
_BackUpdate::

    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; 背景を描画する
;
_BackRender::
    
    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; カラーテーブルを作成する
;
BackBuildColorTable:

    ; レジスタの保存

    ; カラーテーブルの作成／ゲーム（ノーマル）
    ld      hl, #_busterColorTable
    ld      de, #(backColorTable + 0x0004)
    ld      bc, #0x001c
    ldir
    ld      hl, #((VDP_COLOR_MEDIUM_GREEN << 12) | (VDP_COLOR_BLACK << 8) | (VDP_COLOR_WHITE << 4) | (VDP_COLOR_BLACK))
    ld      (backColorTable + 0x0000), hl
    ld      hl, #((VDP_COLOR_WHITE << 12) | (VDP_COLOR_BLACK << 8) | (VDP_COLOR_WHITE << 4) | (VDP_COLOR_BLACK))
    ld      (backColorTable + 0x0002), hl

    ; カラーテーブルの作成／ゲーム（ダメージ）
    ld      hl, #(backColorTable + 0x0000)
    ld      de, #(backColorTable + 0x0020)
    ld      b, #0x20
20$:
    ld      c, (hl)
    ld      a, c
    and     #0xf0
    cp      #(VDP_COLOR_DARK_BLUE << 4)
    jr      nz, 21$
    ld      a, c
    and     #0x0f
    or      #(VDP_COLOR_MEDIUM_RED << 4)
    jr      23$
21$:
    ld      a, c
    and     #0x0f
    cp      #VDP_COLOR_DARK_BLUE
    jr      nz, 22$
    ld      a, c
    and     #0xf0
    or      #VDP_COLOR_MEDIUM_RED
    jr      23$
22$:
    ld      a, c
;   jr      22$
23$:
    ld      (de), a
    inc     hl
    inc     de
    djnz    20$
    ld      a, #((VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_BLACK)
    ld      (backColorTable + 0x0021), a

    ; カラーテーブルの作成／（結果その１）
    ld      hl, #(backColorTable + 0x0040)
    ld      de, #(backColorTable + 0x0041)
    ld      bc, #(0x0010 - 0x0001)
    ld      (hl), #((VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK)
    ldir
    ld      hl, #_coach0ColorTable
    ld      de, #(backColorTable + 0x0050)
    ld      bc, #0x000f
    ldir

    ; カラーテーブルの作成／（結果その２）
    ld      hl, #(backColorTable + 0x0060)
    ld      de, #(backColorTable + 0x0061)
    ld      bc, #(0x0010 - 0x0001)
    ld      (hl), #((VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK)
    ldir
    ld      hl, #_coach1ColorTable
    ld      de, #(backColorTable + 0x0070)
    ld      bc, #0x000f
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 背景を表示する
;
_BackPrintStart:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0080) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; レジスタの復帰

    ; 終了
    ret

_BackPrintPlay:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; ガンバスターの描画
    ld      hl, #_busterPatternName
    ld      de, #(_patternName + 0x0180)
    ld      bc, #0x0180
    ldir

    ; 星の描画
    ld      hl, #_patternName
    ld      d, #0x00
    ld      b, #(0x0c * 0x04)
20$:
    push    hl
    call    _SystemGetRandom
    and     #0x07
    ld      e, a
    add     hl, de
    ld      (hl), #0x01
    pop     hl
    ld      e, #0x08
    add     hl, de
    djnz    20$

    ; メータの描画
    ld      hl, #(_patternName + 0x0002)
    ld      de, #(_patternName + 0x0042)
    ld      a, #0x07
    ld      bc, #((0x1c << 8) | 0x06)
30$:
    ld      (hl), c
    ld      (de), a
    inc     hl
    inc     de
    djnz    30$
    ld      a, #0x04
    ld      (_patternName + 0x0021), a
    ld      a, #0x05
    ld      (_patternName + 0x003e), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0000) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; レジスタの復帰

    ; 終了
    ret

_BackPrintOver:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0080) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; レジスタの復帰

    ; 終了
    ret

_BackPrintResultLow:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; コーチの描画
    ld      hl, #_coach0PatternName
    ld      de, #(_patternName + 0x0100)
    ld      bc, #0x0100
    ldir

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0080) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; レジスタの復帰

    ; 終了
    ret

_BackPrintResultTop:

    ; レジスタの保存

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; コーチの描画
    ld      hl, #_coach1PatternName
    ld      de, #(_patternName + 0x0100)
    ld      bc, #0x0100
    ldir

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x00c0) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x1000) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 背景の初期値
;
backDefault:

    .db     BACK_STATE_NULL
    .db     BACK_FRAME_NULL


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 背景
;
_back::
    
    .ds     BACK_LENGTH

; カラーテーブル
;
backColorTable:

    .ds     0x04 * 0x20
