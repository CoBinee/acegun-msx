; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include	"Title.inc"

; 外部変数宣言
;

    .globl  _logoColorTable
    .globl  _logoPatternGenerator
    .globl  _logoPatternName

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; カラーテーブルの転送
    ld      hl, #(APP_COLOR_TABLE + 0x0000)
    ld      a, #((VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK)
    ld      bc, #0x0010
    call    FILVRM
    ld      hl, #_logoColorTable
    ld      de, #(APP_COLOR_TABLE + 0x0010)
    ld      bc, #0x000f
    call    LDIRVM

    ; パターンジェネレータの転送
    ld      hl, #_logoPatternGenerator
    ld      de, #(APP_PATTERN_GENERATOR_TABLE + 0x0800 + 0x0080 * 0x0008)
    ld      bc, #(0x0078 * 0x0008)
    call    LDIRVM
    
    ; タイトルの初期化
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 処理の設定
    ld      hl, #TitleIdle
    ld      (_title + TITLE_PROC_L), hl
    xor     a
    ld      (_title + TITLE_STATE), a

    ; 状態の設定
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_title + TITLE_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; タイトルを待機する
;
TitleIdle:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    or      a
    jr      nz, 09$

    ; アニメーションの設定
    xor     a
    ld      (_title + TITLE_ANIMATION), a

    ; 背景の表示
    call    TitlePrintBack

    ; BGM の再生
    ld      a, #SOUND_BGM_TITLE
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; SPACE キーの入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; 処理の更新
    ld      hl, #TitleStart
    ld      (_title + TITLE_PROC_L), hl
    xor     a
    ld      (_title + TITLE_STATE), a
19$:

    ; アニメーションの更新
    ld      hl, #(_title + TITLE_ANIMATION)
    inc     (hl)

    ; HIT SPACE BAR の表示
    call    TitlePrintHitSpaceBar

    ; レジスタの復帰

    ; 終了
    ret

; タイトルを開始する
;
TitleStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    or      a
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x60
    ld      (_title + TITLE_FRAME), a

    ; BGM の停止
    call    _SoundStop

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
19$:

    ; アニメーションの更新
    ld      hl, #(_title + TITLE_ANIMATION)
    ld      a, (hl)
    add     a, #0x08
    ld      (hl), a

    ; HIT SPACE BAR の表示
    call    TitlePrintHitSpaceBar

    ; レジスタの復帰

    ; 終了
    ret

; 背景を表示する
;
TitlePrintBack:

    ; レジスタの保存

;   ; 画面のクリア
;   xor     a
;   call    _SystemClearPatternName

    ; ロゴの描画
    ld      hl, #_logoPatternName
    ld      de, #(_patternName + 0x00e0)
    ld      bc, #0x0120
    ldir

    ; スコアの描画
    ld      hl, #titleScoreString
    ld      de, #(_patternName + 0x002a)
    call    TitlePrintString
    call    _AppGetScoreString
    ex      de, hl
    ld      de, #(_patternName + 0x0030)
    call    TitlePrintValue

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0000) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; レジスタの復帰

    ; 終了
    ret

; HIT SPACE BAR を表示する
;
TitlePrintHitSpaceBar:

    ; レジスタの保存

    ; HIT SPACE BAR の描画
    ld      a, (_title + TITLE_ANIMATION)
    and     #0x20
    jr      nz, 10$
    ld      hl, #titleHitSpaceBarString
    ld      de, #(_patternName + 0x0269)
    call    TitlePrintString
    jr      19$
10$:
    ld      hl, #(_patternName + 0x0269 + 0x0000)
    ld      de, #(_patternName + 0x0269 + 0x0001)
    ld      bc, #(0x000d - 0x0001)
    ld      (hl), #0x00
    ldir
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 文字列を表示する
;
TitlePrintString:

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
TitlePrintValue:

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

; タイトルの初期値
;
titleDefault:

    .dw     TITLE_PROC_NULL
    .db     TITLE_STATE_NULL
    .db     TITLE_FLAG_NULL
    .db     TITLE_FRAME_NULL
    .db     TITLE_COUNT_NULL
    .db     TITLE_ANIMATION_NULL

; スコア
;
titleScoreString:

    .ascii  "TOP"
    .db     0x00

; HIT SPACE BAR
;
titleHitSpaceBarString:

    .ascii  "HIT SPACE BAR"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::

    .ds     TITLE_LENGTH

