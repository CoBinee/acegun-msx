; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Player.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; スプライトの初期化
    xor     a
    ld      (playerSpriteRotate), a

    ; レイの作成
    call    PlayerBuildRay

    ; 処理の設定
    ld      hl, #PlayerPlayRotate
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_player + PLAYER_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; ダメージの更新
    ld      hl, #(_player + PLAYER_DAMAGE)
    ld      a, (hl)
    or      a
    jr      z, 29$
    ld      de, #(_player + PLAYER_LIFE)
    ld      a, (de)
    sub     (hl)
    jr      nc, 20$
    xor     a
20$:
    ld      (de), a
    ld      (hl), #0x00
    or      a
    jr      nz, 21$
    ld      hl, #PlayerOver
    ld      (_player + PLAYER_PROC_L), hl
    ld      (_player + PLAYER_STATE), a
21$:
    ld      a, #PLAYER_FLASH_FRAME
    ld      (_player + PLAYER_FLASH), a
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySe
29$:

    ; フラッシュの更新
    ld      hl, #(_player + PLAYER_FLASH)
    ld      a, (hl)
    or      a
    jr      z, 30$
    dec     (hl)
    ld      a, #((APP_COLOR_TABLE + 0x0040) >> 6)
    jr      39$
30$:
    ld      a, #((APP_COLOR_TABLE + 0x0000) >> 6)
;   jr      39$
39$:
    ld      (_videoRegister + VDP_R3), a

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    inc     (hl)

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; スプライトの取得
    ld      a, (playerSpriteRotate)
    ld      l, a

    ; 長さの取得
    ld      a, (_player + PLAYER_R)
    add     a, #0x0f
    and     #0xf0
    jp      z, 180$
    rrca
    rrca
    rrca
    rrca
    ld      h, a

    ; スプライトの描画
    ld      a, (_player + PLAYER_ANGLE_H)
    ld      b, a
    rrca
    and     #0x0f
    ld      c, a
    ld      a, b
    and     #0xe0
    jr      z, 100$
    ld      e, #0x20
    sub     e
    jr      z, 110$
    sub     e
    jp      z, 120$
    sub     e
    jp      z, 130$
    sub     e
    jp      z, 140$
    sub     e
    jp      z, 150$
    sub     e
    jp      z, 160$
    jp      170$

    ;   0 -  45
100$:
    ld      a, #((APP_SPRITE_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      de, #((((GAME_O_Y - 0x01) - 0x01) << 8) | (GAME_O_X + 0x00))
    ld      a, c
    add     a, a
    add     a, a
    add     a, #0x80
    ld      b, a
;   ld      h, #0x08
101$:
    push    hl
    push    de
    ld      h, #0x00
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    add     hl, de
    pop     de
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), #VDP_COLOR_LIGHT_YELLOW
;   inc     hl
    ld      a, e
    add     a, #0x10
    ld      e, a
    ld      a, d
    add     a, c
    ld      d, a
    pop     hl
    ld      a, l
    add     a, #0x04
    and     #0x1f
    ld      l, a
    dec     h
    jr      nz, 101$
    jp      190$

    ;  45 - 90
110$:
    ld      a, #((APP_SPRITE_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      de, #((((GAME_O_Y - 0x00) - 0x01) << 8) | (GAME_O_X + 0x00))
    ld      a, c
    add     a, a
    add     a, a
    add     a, #0xc0
    ld      b, a
    ld      a, #0x0f
    sub     c
    ld      c, a
;   ld      h, #0x08
111$:
    push    hl
    push    de
    ld      h, #0x00
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    add     hl, de
    pop     de
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), #VDP_COLOR_LIGHT_YELLOW
;   inc     hl
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    add     a, #0x10
    ld      d, a
    pop     hl
    ld      a, l
    add     a, #0x04
    and     #0x1f
    ld      l, a
    dec     h
    jr      nz, 111$
    jp      190$

    ;  90 - 135
120$:
    ld      a, #((APP_SPRITE_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      de, #((((GAME_O_Y - 0x00) - 0x01) << 8) | (GAME_O_X - 0x0f + 0x20))
    ld      a, c
    add     a, a
    add     a, a
    add     a, #0x80
    ld      b, a
;   ld      h, #0x08
121$:
    push    hl
    push    de
    ld      h, #0x00
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    add     hl, de
    pop     de
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), #(VDP_COLOR_LIGHT_YELLOW | 0x80)
;   inc     hl
    ld      a, e
    sub     c
    ld      e, a
    ld      a, d
    add     a, #0x10
    ld      d, a
    pop     hl
    ld      a, l
    add     a, #0x04
    and     #0x1f
    ld      l, a
    dec     h
    jr      nz, 121$
    jp      190$

    ; 135 - 180
130$:
    ld      a, #((APP_SPRITE_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      de, #((((GAME_O_Y - 0x01) - 0x01) << 8) | (GAME_O_X - 0x0f + 0x20))
    ld      a, c
    add     a, a
    add     a, a
    add     a, #0xc0
    ld      b, a
    ld      a, #0x0f
    sub     c
    ld      c, a
;   ld      h, #0x08
131$:
    push    hl
    push    de
    ld      h, #0x00
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    add     hl, de
    pop     de
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), #(VDP_COLOR_LIGHT_YELLOW | 0x80)
;   inc     hl
    ld      a, e
    sub     #0x10
    ld      e, a
    ld      a, d
    add     a, c
    ld      d, a
    pop     hl
    ld      a, l
    add     a, #0x04
    and     #0x1f
    ld      l, a
    dec     h
    jr      nz, 131$
    jp      190$

    ; 180 - 225
140$:
    ld      a, #((APP_SPRITE_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      de, #((((GAME_O_Y - 0x01) - 0x01) << 8) | (GAME_O_X - 0x0f + 0x20))
    ld      a, d
    sub     c
    ld      d, a
    ld      a, c
    add     a, a
    add     a, a
    add     a, #0x80
    ld      b, a
;   ld      h, #0x08
141$:
    push    hl
    push    de
    ld      h, #0x00
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    add     hl, de
    pop     de
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), #(VDP_COLOR_LIGHT_YELLOW | 0x80)
;   inc     hl
    ld      a, e
    sub     #0x10
    ld      e, a
    ld      a, d
    sub     c
    ld      d, a
    pop     hl
    ld      a, l
    add     a, #0x04
    and     #0x1f
    ld      l, a
    dec     h
    jr      nz, 141$
    jp      190$

    ; 225 - 270
150$:
    ld      a, #((APP_SPRITE_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      de, #((((GAME_O_Y - 0x10) - 0x01) << 8) | (GAME_O_X - 0x01 + 0x20))
    ld      a, #0x0f
    sub     c
    sub     e
    neg
    ld      e, a
    ld      a, c
    add     a, a
    add     a, a
    add     a, #0xc0
    ld      b, a
    ld      a, #0x0f
    sub     c
    ld      c, a
;   ld      h, #0x08
151$:
    push    hl
    push    de
    ld      h, #0x00
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    add     hl, de
    pop     de
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), #(VDP_COLOR_LIGHT_YELLOW | 0x80)
;   inc     hl
    ld      a, e
    sub     c
    ld      e, a
    ld      a, d
    sub     #0x10
    ld      d, a
    pop     hl
    ld      a, l
    add     a, #0x04
    and     #0x1f
    ld      l, a
    dec     h
    jr      nz, 151$
    jp      190$

    ; 270 - 315
160$:
    ld      a, #((APP_SPRITE_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      de, #((((GAME_O_Y - 0x10) - 0x01) << 8) | (GAME_O_X - 0x0e))
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, c
    add     a, a
    add     a, a
    add     a, #0x80
    ld      b, a
;   ld      h, #0x08
161$:
    push    hl
    push    de
    ld      h, #0x00
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    add     hl, de
    pop     de
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), #VDP_COLOR_LIGHT_YELLOW
;   inc     hl
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    sub     #0x10
    ld      d, a
    pop     hl
    ld      a, l
    add     a, #0x04
    and     #0x1f
    ld      l, a
    dec     h
    jr      nz, 161$
    jr      190$

    ; 315 - 360
170$:
    ld      a, #((APP_SPRITE_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R6), a
    ld      de, #((((GAME_O_Y - 0x01) - 0x01) << 8) | (GAME_O_X - 0x00))
    ld      a, #0x0f
    sub     c
    sub     d
    neg
    ld      d, a
    ld      a, c
    add     a, a
    add     a, a
    add     a, #0xc0
    ld      b, a
    ld      a, #0x0f
    sub     c
    ld      c, a
;   ld      h, #0x08
171$:
    push    hl
    push    de
    ld      h, #0x00
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    add     hl, de
    pop     de
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), #VDP_COLOR_LIGHT_YELLOW
;   inc     hl
    ld      a, e
    add     a, #0x10
    ld      e, a
    ld      a, d
    sub     c
    ld      d, a
    pop     hl
    ld      a, l
    add     a, #0x04
    and     #0x1f
    ld      l, a
    dec     h
    jr      nz, 171$
    jr      190$

    ; 発射準備
180$:
    ld      a, (_player + PLAYER_LIFE)
    or      a
    jr      z, 189$
    ld      a, (_player + PLAYER_ANIMATION)
    and     #0x18
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerSpritePrepare
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    ld      bc, #0x0004
    ldir
189$:
;   jr      190$

    ; スプライト描画の完了
190$:

    ; スプライトの更新
    ld      hl, #playerSpriteRotate
    ld      a, (hl)
    add     a, #0x04
    and     #0x1f
    ld      (hl), a

    ; ライフの描画
    ld      hl, #(_patternName + 0x0022)
    ld      a, (_player + PLAYER_LIFE)
    ld      c, a
    and     #0xf8
    jr      z, 21$
    rrca
    rrca
    rrca
    ld      b, a
    ld      a, #0x0f
20$:
    ld      (hl), a
    inc     hl
    djnz    20$
21$:
    ld      a, c
    and     #0x07
    jr      z, 22$
    add     a, #(0x08 - 0x01)
    ld      (hl), a
    inc     hl
22$:
    ld      a, #PLAYER_LIFE_MAXIMUM
    sub     c
    and     #0xf8
    jr      z, 29$
    rrca
    rrca
    rrca
    ld      b, a
    xor     a
23$:
    ld      (hl), a
    inc     hl
    djnz    23$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlayRotate:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 速度と半径の更新
100$:
    ld      hl, (_player + PLAYER_SPEED_L)
    ld      de, #PLAYER_SPEED_ACCEL
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 110$
    or      a
    sbc     hl, de
    jp      p, 101$
    ld      a, h
    cp      #(-PLAYER_SPEED_MAXIMUM + 0x01)
    jr      nc, 101$
    ld      hl, #-(PLAYER_SPEED_MAXIMUM << 8)
101$:
    jr      140$
110$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 120$
    or      a
    adc     hl, de
    jp      m, 111$
    ld      a, h
    cp      #PLAYER_SPEED_MAXIMUM
    jr      c, 111$
    ld      hl, #(PLAYER_SPEED_MAXIMUM << 8)
111$:
    jr      140$
120$:
    ld      de, #PLAYER_SPEED_BRAKE
    ld      a, h
    or      a
    jp      p, 130$
    or      a
    adc     hl, de
    jp      m, 121$
    ld      hl, #0x0000
121$:
    jr      150$
130$:
    or      a
    sbc     hl, de
    jp      p, 131$
    ld      hl, #0x0000
131$:
    jr      150$
140$:
    ld      de, #(_player + PLAYER_R)
    ld      a, (de)
    add     a, #PLAYER_R_SPEED
    cp      #PLAYER_R_MAXIMUM
    jr      c, 141$
    ld      a, #PLAYER_R_MAXIMUM
141$:
    ld      (de), a
    jr      190$
150$:
    ld      de, #(_player + PLAYER_R)
    ld      a, (de)
    sub     #PLAYER_R_SPEED
    jr      nc, 151$
    xor     a
151$:
    ld      (de), a
;   jr      190$
190$:
    ld      (_player + PLAYER_SPEED_L), hl

    ; 角度の更新
;   ld      hl, (_player + PLAYER_SPEED_L)
    ld      de, (_player + PLAYER_ANGLE_L)
    add     hl, de
    ld      (_player + PLAYER_ANGLE_L), hl

    ; レジスタの復帰

    ; 終了
    ret

PlayerPlayTarget:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 照準と半径の更新
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 10$
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    ld      a, #0xa0
    jr      nz, 13$
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    ld      a, #0xe0
    jr      nz, 13$
    ld      a, #0xc0
    jr      13$
10$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 11$
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    ld      a, #0x60
    jr      nz, 13$
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    ld      a, #0x20
    jr      nz, 13$
    ld      a, #0x40
    jr      13$
11$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 12$
    ld      a, #0x80
    jr      13$
12$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 17$
    xor     a
;   jr      13$
13$:
    ld      (_player + PLAYER_TARGET_H), a
    ld      hl, #(_player + PLAYER_R)
    ld      a, (hl)
    or      a
    jr      nz, 14$
    ld      de, (_player + PLAYER_TARGET_L)
    ld      (_player + PLAYER_ANGLE_L), de
14$:
    add     a, #(PLAYER_R_SPEED)
    cp      #PLAYER_R_MAXIMUM
    jr      c, 15$
    ld      a, #PLAYER_R_MAXIMUM
15$:
    ld      (hl), a
    jr      19$
17$:
    ld      hl, #(_player + PLAYER_R)
    ld      a, (hl)
    sub     #(PLAYER_R_SPEED)
    jr      nc, 18$
    xor     a
18$:
    ld      (hl), a
;   jr      19$
19$:

    ; 速度の更新
    ld      hl, (_player + PLAYER_ANGLE_L)
    ld      de, (_player + PLAYER_TARGET_L)
    or      a
    sbc     hl, de
    jr      z, 220$
    jp      m, 210$
200$:
    ld      hl, (_player + PLAYER_SPEED_L)
    ld      de, #PLAYER_SPEED_ACCEL
    or      a
    sbc     hl, de
    jp      p, 201$
    ld      a, h
    cp      #(-PLAYER_SPEED_MAXIMUM + 0x01)
    jr      nc, 201$
    ld      hl, #-(PLAYER_SPEED_MAXIMUM << 8)
201$:
    jr      290$
210$:
    ld      hl, (_player + PLAYER_SPEED_L)
    ld      de, #PLAYER_SPEED_ACCEL
    or      a
    adc     hl, de
    jp      m, 211$
    ld      a, h
    cp      #PLAYER_SPEED_MAXIMUM
    jr      c, 211$
    ld      hl, #(PLAYER_SPEED_MAXIMUM << 8)
211$:
    jr      290$
220$:
    ld      hl, (_player + PLAYER_SPEED_L)
    ld      de, #PLAYER_SPEED_BRAKE
    ld      a, h
    or      a
    jp      p, 230$
    or      a
    adc     hl, de
    jp      m, 221$
    ld      hl, #0x0000
221$:
    jr      290$
230$:
    or      a
    sbc     hl, de
    jp      p, 231$
    ld      hl, #0x0000
231$:
;   jr      290$
290$:
    ld      (_player + PLAYER_SPEED_L), hl

    ; 角度の更新
    ld      hl, (_player + PLAYER_TARGET_L)
    ld      de, (_player + PLAYER_ANGLE_L)
    or      a
    sbc     hl, de
    jr      z, 39$
    ld      de, (_player + PLAYER_SPEED_L)
    jp      p, 30$
    bit     #0x07, d
    jr      z, 38$
    or      a
    sbc     hl, de
    jr      c, 38$
    jr      37$
30$:
    ld      de, (_player + PLAYER_SPEED_L)
    bit     #0x07, d
    jr      nz, 38$
    or      a
    sbc     hl, de
    jr      nc, 38$
;   jr      37$
37$:
    ld      hl, (_player + PLAYER_TARGET_L)
    ld      (_player + PLAYER_ANGLE_L), hl
    jr      39$
38$:
    ld      hl, (_player + PLAYER_ANGLE_L)
    ld      de, (_player + PLAYER_SPEED_L)
    add     hl, de
    ld      (_player + PLAYER_ANGLE_L), hl
;   jr      39$
39$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがゲームオーバになる
;
PlayerOver:

    ; レジスタの保存
    
    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 半径の更新
    ld      hl, #(_player + PLAYER_R)
    ld      a, (hl)
    or      a
    jr      z, 10$
    sub     #PLAYER_R_SPEED
    ld      (hl), a
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがゲームオーバーになったかどうかを判定する
;
_PlayerIsOver::

    ; レジスタの保存

    ; cf > 1 = ゲームオーバー

    ; ライフの確認
    ld      a, (_player + PLAYER_LIFE)
    or      a
    jr      nz, 19$
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがダメージを食らう
;
_PlayerTakeDamage::

    ; レジスタの保存
    push    hl

    ; a < ダメージ

    ; ダメージの設定
    ld      hl, #(_player + PLAYER_DAMAGE)
    add     a, (hl)
    ld      (hl), a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; レイを作成する
;
PlayerBuildRay:

    ; レジスタの保存

    ; レイの作成
    ld      hl, #playerRay
    ld      de, #playerRayOffset
    ld      b, #0x10
10$:
    push    bc
    ld      c, #0x00
    ld      a, #0x08
11$:
    push    af
    ld      a, (de)
    ld      b, #0x08
12$:
    rlca
    jr      nc, 13$
    inc     c
13$:
    ld      (hl), c
    inc     hl
    djnz    12$
    inc     de
    ld      a, (de)
    ld      b, #0x08
14$:
    rlca
    jr      nc, 15$
    inc     c
15$:
    ld      (hl), c
    inc     hl
    djnz    14$
    dec     de
    pop     af
    dec     a
    jr      nz, 11$
    inc     de
    inc     de
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのレイを取得する
;
_PlayerGetRay::

    ; レジスタの保存
    push    hl

    ; de > レイ
    ; b  > 長さ
    ; c  > 角度

    ; 角度の取得
    ld      a, (_player + PLAYER_ANGLE_H)
    ld      c, a

    ; レイの取得
    and     #0xe0
    jr      z, 100$
    ld      e, #0x20
    sub     e
    jr      z, 110$
    sub     e
    jr      z, 120$
    sub     e
    jr      z, 130$
    sub     e
    jr      z, 140$
    sub     e
    jr      z, 150$
    sub     e
    jr      z, 160$
    jr      170$
100$:
    ld      a, c
    jr      180$
110$:
    ld      a, #0x3f
    sub     c
    jr      180$
120$:
    ld      a, c
    sub     #0x40
    jr      180$
130$:
    ld      a, #0x7f
    sub     c
    jr      180$
140$:
    ld      a, c
    sub     #0x80
    jr      180$
150$:
    ld      a, #0xbf
    sub     c
    jr      180$
160$:
    ld      a, c
    sub     #0xc0
    jr      180$
170$:
    ld      a, #0xff
    sub     c
;   jr      180$
180$:
    and     #0x1e
    ld      e, #0x00
    srl     a
    srl     a
    rr      e
    ld      d, a
    ld      hl, #playerRay
    add     hl, de
    ex      de, hl

    ; 長さの取得
    ld      a, (_player + PLAYER_R)
    add     a, #0x0f
    and     #0xf0
    ld      b, a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; プレイヤの角度を取得する
;
_PlayerGetAngle::

    ; レジスタの保存

    ; a > 角度

    ; 角度の取得
    ld      a, (_player + PLAYER_ANGLE_H)

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのライフをカウントする
;
_PlayerCountLife::

    ; レジスタの保存
    push    hl

    ; a > 1 = ライフをカウントした

    ; 角度の取得
    ld      hl, #(_player + PLAYER_LIFE)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    ld      a, #0x01
10$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; プレイヤの初期値
;
playerDefault:

    .dw     PLAYER_PROC_NULL
    .db     PLAYER_STATE_NULL
    .db     PLAYER_FLAG_NULL
    .db     PLAYER_LIFE_MAXIMUM ; PLAYER_LIFE_NULL
    .db     PLAYER_DAMAGE_NULL
    .dw     0xc000 ; PLAYER_ANGLE_NULL
    .dw     0x0000 ; PLAYER_SPEED_NULL
    .dw     0xc000 ; PLAYER_TARGET_NULL
    .db     PLAYER_R_NULL
    .db     PLAYER_ANIMATION_NULL
    .db     PLAYER_FLASH_NULL

; スプライト
;
playerSpritePrepare:

    .db     0x80 - 0x08 - 0x01, 0x80 - 0x08, 0x30, VDP_COLOR_LIGHT_YELLOW
    .db     0x80 - 0x08 - 0x01, 0x80 - 0x08, 0x34, VDP_COLOR_LIGHT_YELLOW
    .db     0x80 - 0x08 - 0x01, 0x80 - 0x08, 0x38, VDP_COLOR_LIGHT_YELLOW
    .db     0x80 - 0x08 - 0x01, 0x80 - 0x08, 0x3c, VDP_COLOR_LIGHT_YELLOW

; レイ
;
playerRayOffset:

    .db     0b00000000, 0b00000000
    .db     0b00000000, 0b10000000
    .db     0b00000100, 0b00010000
    .db     0b00001000, 0b10001000
    .db     0b00010010, 0b00100100
    .db     0b00100100, 0b10010010
    .db     0b00100101, 0b01010010
    .db     0b00101010, 0b10101010
    .db     0b01010101, 0b01010101
    .db     0b01010110, 0b10110101
    .db     0b01011011, 0b01101101
    .db     0b01011101, 0b11011101
    .db     0b01101111, 0b01111011
    .db     0b01110111, 0b11110111
    .db     0b01111111, 0b01111111
    .db     0b01111111, 0b11111111


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH

; スプライト
;
playerSpriteRotate:

    .ds     0x01

; レイ
;
playerRay:

    .ds     0x10 * 0x80
