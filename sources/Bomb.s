; Bomb.s : 爆発
;


; モジュール宣言
;
    .module Bomb

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Bomb.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 爆発を初期化する
;
_BombInitialize::
    
    ; レジスタの保存
    
    ; 爆発の初期化
    ld      hl, #(_bomb + 0x0000)
    ld      de, #(_bomb + 0x0001)
    ld      bc, #(BOMB_LENGTH * BOMB_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; フレームの初期化
    ld      a, #BOMB_FRAME_INTERVAL
    ld      (bombFrame), a

    ; スプライトの初期化
    xor     a
    ld      (bombSpriteRotate), a

    ; レジスタの復帰
    
    ; 終了
    ret

; 爆発を更新する
;
_BombUpdate::
    
    ; レジスタの保存

    ; 爆発の生成
    ld      hl, #bombFrame
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      19$
10$:
    ld      (hl), #BOMB_FRAME_INTERVAL
    ld      hl, #_bomb
    ld      de, #BOMB_LENGTH
    ld      b, #BOMB_ENTRY
11$:
    ld      a, (hl)
    or      a
    jr      z, 12$
    add     hl, de
    djnz    11$
    jr      19$
12$:
    inc     (hl)
    inc     hl
13$:
    call    _SystemGetRandom
    cp      #0xf1
    jr      nc, 13$
    ld      (hl), a
    inc     hl
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x68
    ld      (hl), a
    inc     hl
    ld      (hl), #0x00
;   inc     hl
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySe
;   jr      19$
19$:

    ; 爆発の走査
    ld      ix, #_bomb
    ld      b, #BOMB_ENTRY
20$:
    push    bc

    ; 爆発の存在
    ld      a, BOMB_STATE(ix)
    or      a
    jr      z, 29$

    ; アニメーションの更新
    inc     BOMB_ANIMATION(ix)
    ld      a, BOMB_ANIMATION(ix)
    cp      #(0x04 * 0x04)
    jr      c, 29$

    ; 爆発の削除
    ld      BOMB_STATE(ix), #BOMB_STATE_NULL

    ; 次の爆発へ
29$:
    ld      bc, #BOMB_LENGTH
    add     ix, bc
    pop     bc
    djnz    20$

    ; レジスタの復帰
    
    ; 終了
    ret

; 爆発を描画する
;
_BombRender::

    ; レジスタの保存

    ; 爆発の走査
    ld      ix, #_bomb
    ld      a, (bombSpriteRotate)
    ld      e, a
    ld      d, #0x00
    ld      b, #BOMB_ENTRY
10$:
    push    bc

    ; 描画の確認
    ld      a, BOMB_STATE(ix)
    or      a
    jr      z, 19$

    ; スプライトの描画
    ld      hl, #(_sprite + GAME_SPRITE_BOMB)
    add     hl, de
    ld      a, BOMB_POSITION_Y(ix)
    ld      (hl), a
    inc     hl
    ld      a, BOMB_POSITION_X(ix)
    ld      (hl), a
    inc     hl
    ld      a, BOMB_ANIMATION(ix)
    and     #0xfc
    add     #0x10
    ld      (hl), a
    inc     hl
    ld      (hl), #VDP_COLOR_DARK_YELLOW
;   inc     hl

    ; スプライトのローテート
    ld      a, e
    add     a, #0x04
    and     #(BOMB_ENTRY * 0x04 - 0x01)
    ld      e, a

    ; 次の爆発へ
19$:
    ld      bc, #BOMB_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      a, (bombSpriteRotate)
    add     a, #0x04
    and     #(BOMB_ENTRY * 0x04 - 0x01)
    ld      (bombSpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 爆発
;
_bomb::
    
    .ds     BOMB_LENGTH * BOMB_ENTRY

; フレーム
;
bombFrame:

    .ds     0x01

; スプライト
;
bombSpriteRotate:

    .ds     0x01

