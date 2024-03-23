; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "Math.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存
    
    ; エネミーの初期化
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_LENGTH * ENEMY_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 空きの数の初期化
    ld      a, #ENEMY_ENTRY
    ld      (enemyRest), a

    ; スプライトの初期化
    xor     a
    ld      (enemySpriteRotate), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; 種類別の処理
    ld      l, ENEMY_PROC_L(ix)
    ld      h, ENEMY_PROC_H(ix)
    ld      a, h
    or      l
    jr      z, 190$
    ld      de, #101$
    push    de
    jp      (hl)
;   pop     hl
101$:

    ; フラッシュの更新
    ld      a, ENEMY_FLASH(ix)
    or      a
    jr      z, 110$
    dec     ENEMY_FLASH(ix)
110$:

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      a, (enemySpriteRotate)
    ld      e, a
    ld      d, #0x00
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; 描画の確認
    ld      a, ENEMY_PROC_H(ix)
    or      ENEMY_PROC_L(ix)
    jp      z, 190$

    ; スプライトの描画（x1）
110$:
    bit     #ENEMY_FLAG_x2_BIT, ENEMY_FLAG(ix)
    jr      nz, 120$
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    ld      a, ENEMY_POSITION_Y_H(ix)
    add     a, ENEMY_SPRITE_Y(ix)
    ld      (hl), a
    inc     hl
    ld      c, #0x00
    ld      a, ENEMY_POSITION_X_H(ix)
    or      a
    jp      m, 111$
    add     a, #0x20
    ld      c, #0x80
111$:
    add     a, ENEMY_SPRITE_X(ix)
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_DIRECTION(ix)
    add     #0x10
    and     #0xe0
    rrca
    rrca
    rrca
    add     a, ENEMY_SPRITE_PATTERN(ix)
    ld      (hl), a
    inc     hl
    ld      a, ENEMY_FLASH(ix)
    or      a
    jr      z, 112$
    ld      a, #VDP_COLOR_MEDIUM_RED
    jr      113$
112$:
    ld      a, ENEMY_SPRITE_COLOR(ix)
    or      a
    jr      nz, 113$
    call    _SystemGetRandom
    and     #0x0f
;   jr      113$
113$:
    or      c
    ld      (hl), a
;   inc     hl

    ; スプライトのローテート
    ld      a, e
    add     a, #0x04
    and     #(ENEMY_ENTRY * 0x04 - 0x01)
    ld      e, a
    jr      190$

    ; スプライトの描画（x2）
120$:
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_BOSS)
    ld      a, ENEMY_POSITION_X_H(ix)
    add     a, #-0x10
    ld      e, a
    ld      a, ENEMY_POSITION_Y_H(ix)
    add     a, #-0x10
    ld      d, a
    ld      b, ENEMY_SPRITE_PATTERN(ix)
    ld      a, ENEMY_SPRITE_COLOR(ix)
    or      a
    jr      nz, 121$
    call    _SystemGetRandom
    and     #0x0f
121$:
    ld      c, a
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #0x80
    jr      nc, 122$
    ld      a, e
    add     a, #0x20
    ld      e, a
    ld      a, c
    add     a, #0x80
    ld      c, a
122$:
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    ld      a, e
    add     a, #0x10
    ld      e, a
    ld      a, b
    add     a, #0x04
    ld      b, a
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    ld      a, e
    add     a, #-0x10
    ld      e, a
    ld      a, d
    add     a, #0x10
    ld      d, a
    ld      a, b
    add     a, #0x04
    ld      b, a
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
    inc     hl
    ld      a, e
    add     a, #0x10
    ld      e, a
    ld      a, b
    add     a, #0x04
    ld      b, a
    ld      (hl), d
    inc     hl
    ld      (hl), e
    inc     hl
    ld      (hl), b
    inc     hl
    ld      (hl), c
;   inc     hl
    pop     de
;   jr      190$

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    dec     b
    jp      nz, 100$

    ; スプライトの更新
    ld      a, (enemySpriteRotate)
    add     a, #0x04
    and     #(ENEMY_ENTRY * 0x04 - 0x01)
    ld      (enemySpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
EnemyNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_FREE を処理する
;
_EnemyFreeBorn::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置

    ; エネミーの取得
    call    EnemyGetEmpty
    jr      nc, 19$

    ; エネミーの生成
    ld      ENEMY_LIFE(ix), #0x80
    ld      ENEMY_ATTACK(ix), #0x01
    ld      ENEMY_POSITION_X_H(ix), e
    ld      ENEMY_POSITION_Y_H(ix), d
    ld      ENEMY_SPEED_H(ix), #0x01
    ld      ENEMY_DIRECTION(ix), #0x40
    ld      ENEMY_R(ix), #ENEMY_R_x1
    ld      ENEMY_SPRITE_Y(ix), #(-0x08 - 0x01)
    ld      ENEMY_SPRITE_X(ix), #(-0x08)
    ld      ENEMY_SPRITE_PATTERN(ix), #0x40
    ld      ENEMY_SPRITE_COLOR(ix), #VDP_COLOR_LIGHT_GREEN
    ld      hl, #EnemyFree
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      hl, #enemyRest
    dec     (hl)
;   jr      19$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

EnemyFree:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 速度の更新
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$
    ld      a, ENEMY_SPEED_H(ix)
    inc     a
    cp      #0x05
    jr      c, 10$
    ld      a, #0x01
10$:
    ld      ENEMY_SPEED_H(ix), a
19$:

    ; 移動
    ld      a, (_input + INPUT_BUTTON_SHIFT)
    or      a
    jr      z, 29$
    ld      a, (_input + INPUT_KEY_UP)
    or      a
    jr      z, 21$
    ld      b, ENEMY_SPEED_H(ix)
20$:
    dec     ENEMY_POSITION_Y_H(ix)
    djnz    20$
21$:
    ld      a, (_input + INPUT_KEY_DOWN)
    or      a
    jr      z, 23$
    ld      b, ENEMY_SPEED_H(ix)
22$:
    inc     ENEMY_POSITION_Y_H(ix)
    djnz    22$
23$:
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      z, 25$
    ld      b, ENEMY_SPEED_H(ix)
24$:
    dec     ENEMY_POSITION_X_H(ix)
    djnz    24$
25$:
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      z, 27$
    ld      b, ENEMY_SPEED_H(ix)
26$:
    inc     ENEMY_POSITION_X_H(ix)
    djnz    26$
27$:
29$:

    ; ライフの復帰
    ld      a, ENEMY_LIFE(ix)
    cp      #0x80
    adc     a, #0x00
    ld      ENEMY_LIFE(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_FALL を処理する
;
_EnemyFallBorn::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; bc < ライフ(1), スコア(2), パターン(1), カラー(1)

    ; エネミーの取得
    call    EnemyGetEmpty
    jr      nc, 19$

    ; エネミーの生成
    ld      a, (bc)
    ld      ENEMY_LIFE(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_ATTACK(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_SCORE_L(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_SCORE_H(ix), a
    inc     bc
    ld      ENEMY_POSITION_X_H(ix), e
    ld      ENEMY_POSITION_Y_H(ix), d
    ld      ENEMY_DIRECTION(ix), #0x40
    ld      ENEMY_R(ix), #ENEMY_R_x1
    ld      ENEMY_SPRITE_Y(ix), #(-0x08 - 0x01)
    ld      ENEMY_SPRITE_X(ix), #(-0x08)
    ld      a, (bc)
    ld      ENEMY_SPRITE_PATTERN(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_SPRITE_COLOR(ix), a
;   inc     bc
    ld      hl, #EnemyFall
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      hl, #enemyRest
    dec     (hl)
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

EnemyFall:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 向きの設定
    ld      ENEMY_FORWARD(ix), #0x40
    ld      a, ENEMY_DIRECTION(ix)
    cp      #0x40
    jr      c, 00$
    cp      #0xc0
    jr      nc, 00$
    ld      ENEMY_ROTATE(ix), #-0x02
    jr      01$
00$:
    ld      ENEMY_ROTATE(ix), #0x02
01$:

    ; 速度の設定
    xor     a
    ld      ENEMY_SPEED_L(ix), a
    ld      ENEMY_SPEED_H(ix), a

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 向きの更新
    ld      a, ENEMY_DIRECTION(ix)
    cp      #0x40
    call    nz, EnemyRotate

    ; 速度の更新
    ld      l, ENEMY_SPEED_L(ix)
    ld      h, ENEMY_SPEED_H(ix)
    ld      a, ENEMY_FLASH(ix)
    or      a
    jr      nz, 20$
    ld      a, h
    cp      #ENEMY_SPEED_MAXIMUM
    jr      nc, 29$
    ld      de, #ENEMY_SPEED_GRAVITY
    add     hl, de
    jr      28$
20$:
    ld      de, #ENEMY_SPEED_DAMAGE
    or      a
    sbc     hl, de
    jr      nc, 28$
    ld      hl, #0x0000
;   jr      28$
28$:
    ld      ENEMY_SPEED_L(ix), l
    ld      ENEMY_SPEED_H(ix), h
29$:

    ; 移動
    ld      e, ENEMY_POSITION_Y_L(ix)
    ld      d, ENEMY_POSITION_Y_H(ix)
    ld      a, d
    cp      #ENEMY_POSITION_ATTACK
    jr      nc, 30$
    add     hl, de
    ld      ENEMY_POSITION_Y_L(ix), l
    ld      ENEMY_POSITION_Y_H(ix), h
    jr      39$
30$:

    ; 攻撃
;   ld      a, ENEMY_LIFE(ix)
    ld      a, ENEMY_ATTACK(ix)
    call    _PlayerTakeDamage
    ld      hl, #EnemyBomb
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    xor     a
    ld      ENEMY_STATE(ix), a
    ld      ENEMY_LIFE(ix), a
    ld      ENEMY_SPRITE_COLOR(ix), #VDP_COLOR_DARK_YELLOW
;   jr      39$
39$:

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_ROUTE を処理する
;
_EnemyRouteBorn::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; de < 経路
    ; bc < ライフ(1), スコア(2), パターン(1), カラー(1)

    ; エネミーの取得
    call    EnemyGetEmpty
    jr      nc, 19$

    ; エネミーの生成
    ld      a, (bc)
    ld      ENEMY_LIFE(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_ATTACK(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_SCORE_L(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_SCORE_H(ix), a
    inc     bc
    ld      a, (de)
    ld      ENEMY_POSITION_X_H(ix), a
    inc     de
    ld      a, (de)
    ld      ENEMY_POSITION_Y_H(ix), a
    inc     de
    ld      a, (de)
    ld      ENEMY_DIRECTION(ix), a
    ld      ENEMY_FORWARD(ix), a
    inc     de
    ld      ENEMY_MOVE_L(ix), e
    ld      ENEMY_MOVE_H(ix), d
    ld      ENEMY_MOVE_FRAME(ix), #0x00
    ld      ENEMY_R(ix), #ENEMY_R_x1
    ld      ENEMY_SPRITE_Y(ix), #(-0x08 - 0x01)
    ld      ENEMY_SPRITE_X(ix), #(-0x08)
    ld      a, (bc)
    ld      ENEMY_SPRITE_PATTERN(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_SPRITE_COLOR(ix), a
;   inc     bc
    ld      hl, #EnemyRoute
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      hl, #enemyRest
    dec     (hl)
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

EnemyRoute:

    ; レジスタの保存

;   ; 初期化
;   ld      a, ENEMY_STATE(ix)
;   or      a
;   jr      nz, 09$
;
;   ; 初期化の完了
;   inc     ENEMY_STATE(ix)
;09$:

    ; 経路の設定
    ld      a, ENEMY_MOVE_FRAME(ix)
    or      a
    jr      nz, 19$
    ld      l, ENEMY_MOVE_L(ix)
    ld      h, ENEMY_MOVE_H(ix)
    ld      a, (hl)
    ld      ENEMY_MOVE_FRAME(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_SPEED_H(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_FORWARD(ix), a
    inc     hl
    ld      a, (hl)
    ld      ENEMY_ROTATE(ix), a
    inc     hl
    ld      ENEMY_MOVE_L(ix), l
    ld      ENEMY_MOVE_H(ix), h
19$:

    ; 移動
    call    EnemyRotate
    call    EnemyMove
    dec     ENEMY_MOVE_FRAME(ix)
    jr      nz, 29$
    ld      l, ENEMY_MOVE_L(ix)
    ld      h, ENEMY_MOVE_H(ix)
    ld      a, (hl)
    or      a
    jr      nz, 29$

    ; 処理の更新
    ld      hl, #EnemyFall
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
29$:

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_BOSS を処理する
;
_EnemyBossBorn::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < Y/X 位置
    ; bc < ライフ(1), スコア(2), パターン(1), カラー(1)

    ; エネミーの取得
    call    EnemyGetEmpty
    jr      nc, 19$

    ; エネミーの生成
    ld      ENEMY_FLAG(ix), #ENEMY_FLAG_x2
    ld      a, (bc)
    ld      ENEMY_LIFE(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_ATTACK(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_SCORE_L(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_SCORE_H(ix), a
    inc     bc
    ld      ENEMY_POSITION_X_H(ix), e
    ld      ENEMY_POSITION_Y_H(ix), d
    ld      ENEMY_DIRECTION(ix), #0x40
    ld      ENEMY_R(ix), #ENEMY_R_x2
    ld      ENEMY_SPRITE_Y(ix), #(-0x08 - 0x01)
    ld      ENEMY_SPRITE_X(ix), #(-0x08)
    ld      a, (bc)
    ld      ENEMY_SPRITE_PATTERN(ix), a
    inc     bc
    ld      a, (bc)
    ld      ENEMY_SPRITE_COLOR(ix), a
;   inc     bc
    ld      hl, #EnemyBoss
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      hl, #enemyRest
    dec     (hl)
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

EnemyBoss:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 速度の更新
    ld      l, ENEMY_SPEED_L(ix)
    ld      h, ENEMY_SPEED_H(ix)
    ld      a, ENEMY_FLASH(ix)
    or      a
    jr      nz, 10$
    ld      a, h
    cp      #0x01
    jr      nc, 19$
    ld      de, #ENEMY_SPEED_GRAVITY
    add     hl, de
    jr      18$
10$:
    ld      de, #ENEMY_SPEED_DAMAGE
    or      a
    sbc     hl, de
    jr      nc, 18$
    ld      hl, #0x0000
;   jr      18$
18$:
    ld      ENEMY_SPEED_L(ix), l
    ld      ENEMY_SPEED_H(ix), h
19$:

    ; 移動
    ld      e, ENEMY_POSITION_Y_L(ix)
    ld      d, ENEMY_POSITION_Y_H(ix)
    ld      a, d
    cp      #ENEMY_POSITION_ATTACK
    jr      nc, 20$
    add     hl, de
    ld      ENEMY_POSITION_Y_L(ix), l
    ld      ENEMY_POSITION_Y_H(ix), h
    jr      29$
20$:

    ; 攻撃
;   ld      a, ENEMY_LIFE(ix)
    ld      a, ENEMY_ATTACK(ix)
    call    _PlayerTakeDamage
    ld      hl, #EnemyBomb
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    xor     a
    ld      ENEMY_STATE(ix), a
    ld      ENEMY_LIFE(ix), a
    ld      ENEMY_SPRITE_COLOR(ix), #VDP_COLOR_DARK_YELLOW
;   jr      29$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; ENEMY_TYPE_BOMB を処理する
;
EnemyBomb:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの設定
    res     #ENEMY_FLAG_x2_BIT, ENEMY_FLAG(ix)

    ; 向きの設定
    ld      ENEMY_DIRECTION(ix), #0x00

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #0x00

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; アニメーションの更新
    inc     ENEMY_ANIMATION(ix)
    ld      a, ENEMY_ANIMATION(ix)
    cp      #(0x04 * 0x04)
    jr      nc, 18$
    and     #0xfc
    add     a, #0x10
    ld      ENEMY_SPRITE_PATTERN(ix), a
    jr      19$

    ; エネミーの削除
18$:
    xor     a
    ld      ENEMY_PROC_L(ix), a
    ld      ENEMY_PROC_H(ix), a
    ld      hl, #enemyRest
    inc     (hl)
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーの空きを取得する
;
EnemyGetEmpty:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix > エネミー
    ; cf > 1 = エネミーの取得

    ; エネミーの検索
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_PROC_L(ix)
    or      ENEMY_PROC_H(ix)
    jr      z, 11$
    add     ix, de
    djnz    10$
    or      a
    jr      19$
11$:
    push    ix
    pop     hl
    ld      e, l
    ld      d, h
    inc     de
    ld      bc, #(ENEMY_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; エネミーを回転させる
;
EnemyRotate:

    ; レジスタの保存

    ; 向きの更新
    ld      d, ENEMY_DIRECTION(ix)
    ld      e, ENEMY_FORWARD(ix)
    ld      a, d
    cp      e
    jr      z, 19$
    ld      a, ENEMY_ROTATE(ix)
    or      a
    jr      z, 19$
    jp      p, 10$
    neg
    ld      c, a
    ld      a, d
    sub     e
    cp      c
    jr      c, 18$
    ld      a, d
    sub     c
    ld      ENEMY_DIRECTION(ix), a
    jr      19$
10$:
    ld      c, a
    ld      a, e
    sub     d
    cp      c
    jr      c, 18$
    ld      a, d
    add     a, c
    ld      ENEMY_DIRECTION(ix), a
    jr      19$
18$:
    ld      ENEMY_DIRECTION(ix), e
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを移動させる
;
EnemyMove:

    ; レジスタの保存

    ; 位置の更新
    ld      a, ENEMY_SPEED_H(ix)
    or      a
    jr      z, 19$
    ld      c, a
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      a, ENEMY_DIRECTION(ix)
    call    _MathGetCos
    ld      b, c
10$:
    add     hl, de
    djnz    10$
    ld      ENEMY_POSITION_X_L(ix), l
    ld      ENEMY_POSITION_X_H(ix), h
    ld      l, ENEMY_POSITION_Y_L(ix)
    ld      h, ENEMY_POSITION_Y_H(ix)
    ld      a, ENEMY_DIRECTION(ix)
    call    _MathGetSin
    ld      b, c
11$:
    add     hl, de
    djnz    11$
    ld      ENEMY_POSITION_Y_L(ix), l
    ld      ENEMY_POSITION_Y_H(ix), h
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーがダメージを食らう
;
_EnemyTakeDamage::

    ; レジスタの保存
    push    hl

    ; ライフの減少
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 19$
    dec     ENEMY_LIFE(ix)
    jr      z, 10$
    ld      ENEMY_FLASH(ix), #ENEMY_FLASH_FRAME
    jr      19$

    ; 爆発
10$:
    ld      e, ENEMY_SCORE_L(ix)
    ld      d, ENEMY_SCORE_H(ix)
    call    _GameAddScore
    ld      hl, #EnemyBomb
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #ENEMY_STATE_NULL
    ld      ENEMY_SPRITE_COLOR(ix), #VDP_COLOR_LIGHT_RED

;   ; SE の再生
;   ld      a, #SOUND_SE_HIT
;   call    _SoundPlaySe
;   jr      19$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; すべてのエネミーを爆発させる
;
_EnemyBombAll::

    ; レジスタの保存

    ; エネミーの爆発
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, ENEMY_PROC_L(ix)
    or      ENEMY_PROC_H(ix)
    jr      z, 19$
    ld      a, ENEMY_LIFE(ix)
    or      a
    jr      z, 19$
    ld      hl, #EnemyBomb
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    xor     a
    ld      ENEMY_STATE(ix), a
    ld      ENEMY_LIFE(ix), a
    ld      ENEMY_SPRITE_COLOR(ix), #VDP_COLOR_LIGHT_RED
;   jr      19$
19$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; エネミーの空きの数を取得する
;
_EnemyGetRest::

    ; レジスタの保存

    ; a > 空きの数

    ; 空きの取得
    ld      a, (enemyRest)

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

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; 空きの数
;
enemyRest:

    .ds     0x01

; スプライト
;
enemySpriteRotate:

    .ds     0x01

