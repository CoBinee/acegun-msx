; Generator.s : ジェネレータ
;


; モジュール宣言
;
    .module Generator

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include	"Generator.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ジェネレータを初期化する
;
_GeneratorInitialize::
    
    ; レジスタの保存
    
    ; ジェネレータの初期化
    ld      hl, #generatorDefault
    ld      de, #_generator
    ld      bc, #GENERATOR_LENGTH
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; ジェネレータを更新する
;
_GeneratorUpdate::
    
    ; レジスタの保存

    ; 種類別の処理
    ld      hl, (_generator + GENERATOR_PROC_L)
    ld      de, #10$
    push    de
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ジェネレータを選択する
;
GeneratorSelect:

    ; レジスタの保存

    ; フレームの更新
    ld      hl, #(_generator + GENERATOR_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      90$
10$:

    ; 選択の開始
    call    _EnemyGetRest
    cp      #GENERATOR_COUNT_ONE
    jr      c, 90$

    ; 選択の更新
    ld      hl, #(_generator + GENERATOR_SELECT)
    ld      de, #(_generator + GENERATOR_GROUP_SIZE)
    inc     (hl)
    ld      a, (hl)
    cp      #0x10
    jr      nz, 20$
    ld      a, (de)
    cp      #GENERATOR_GROUP_SIZE_2
    jr      nc, 29$
    ld      a, #GENERATOR_GROUP_SIZE_2
    jr      28$
20$:
    cp      #0x20
    jr      nz, 29$
    ld      a, (de)
    cp      #GENERATOR_GROUP_SIZE_3
    jr      nc, 29$
    ld      a, #GENERATOR_GROUP_SIZE_3
;   jr      28$
28$:
    ld      (de), a
;   jr      29$
29$:

    ; ジェネレータの選択
    ld      a, (_generator + GENERATOR_SELECT)
    ld      c, a
    and     #0x3f
    jr      nz, 30$
    ld      hl, #GeneratorBoss
    jr      39$
30$:
    ld      a, c
    and     #0x0f
    jr      nz, 31$
    ld      hl, #GeneratorLeader
    jr      39$
31$:
    call    _SystemGetRandom
    and     #0x38
    jr      nz, 32$
    ld      hl, #GeneratorFall
    jr      39$
32$:
    and     #0x20
    jr      z, 33$
    ld      hl, #GeneratorRouteSingle
    jr      39$
33$:
    ld      hl, #GeneratorRouteDouble
;   jr      39$
39$:
    ld      (_generator + GENERATOR_PROC_L), hl
    xor     a
    ld      (_generator + GENERATOR_STATE), a

    ; 選択の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 落下エネミーを生成する
;
GeneratorFall:

    ; レジスタの保存

    ; 初期化
    ld      a, (_generator + GENERATOR_STATE)
    or      a
    jr      nz, 09$

    ; 落下を混ぜる
    ld      de, #(_generator + GENERATOR_FALL_0)
    ld      b, #GENERATOR_FALL_LENGTH
00$:
    push    bc
    call    _SystemGetRandom
    and     #0x07
    ld      c, a
    ld      b, #0x00
    ld      hl, #(_generator + GENERATOR_FALL_0)
    add     hl, bc
    ld      c, (hl)
    ld      a, (de)
    ld      (hl), a
    ld      a, c
    ld      (de), a
    inc     de
    pop     bc
    djnz    00$
    
    ; 落下の設定
    ld      hl, #(_generator + GENERATOR_FALL_0)
    ld      (_generator + GENERATOR_ENEMY_L), hl
    ld      a, #GENERATOR_FRAME_FALL
    ld      (_generator + GENERATOR_FRAME), a
    call    _SystemGetRandom
    and     #0x03
    add     a, #0x05
    ld      (_generator + GENERATOR_COUNT), a
    sub     #0x04
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    call    _SystemGetRandom
    and     #GENERATOR_GROUP_SIZE_MASK
    cp      #GENERATOR_GROUP_SIZE_3
    jr      c, 01$
    ld      a, #GENERATOR_GROUP_SIZE_1
01$:
    add     a, e
    ld      e, a
    ld      hl, #generatorGroupZako
    add     hl, de
    ld      (_generator + GENERATOR_GROUP_L), hl

    ; 初期化の完了
    ld      hl, #(_generator + GENERATOR_STATE)
    inc     (hl)
09$:

    ; エネミーの生成
    ld      hl, #(_generator + GENERATOR_FRAME)
    dec     (hl)
    jr      nz, 19$
    ld      (hl), #GENERATOR_FRAME_FALL
    call    _SystemGetRandom
    and     #0x10
    ld      hl, (_generator + GENERATOR_ENEMY_L)
    add     a, (hl)
    add     a, #0x08
    ld      e, a
    ld      d, #0x00
    inc     hl
    ld      (_generator + GENERATOR_ENEMY_L), hl
    ld      hl, (_generator + GENERATOR_GROUP_L)
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl
    ld      (_generator + GENERATOR_GROUP_L), hl
    call    _EnemyFallBorn
    ld      hl, #(_generator + GENERATOR_COUNT)
    dec     (hl)
    jr      nz, 19$
    ld      hl, #GeneratorSelect
    ld      (_generator + GENERATOR_PROC_L), hl
    xor     a
    ld      (_generator + GENERATOR_STATE), a
    ld      a, #GENERATOR_FRAME_SELECT
    ld      (_generator + GENERATOR_FRAME), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 経路エネミーを生成する
;
GeneratorRouteSingle:

    ; レジスタの保存

    ; 初期化
    ld      a, (_generator + GENERATOR_STATE)
    or      a
    jr      nz, 09$

    ; 経路の設定
    call    _SystemGetRandom
    and     #0x3e
    ld      e, a
    ld      d, #0x00
    ld      hl, #generatorRoute
    add     hl, de
    ld      (_generator + GENERATOR_ENEMY_L), hl
    ld      a, #GENERATOR_FRAME_ROUTE
    ld      (_generator + GENERATOR_FRAME), a
    call    _SystemGetRandom
    and     #0x03
    add     a, #0x05
    ld      (_generator + GENERATOR_COUNT), a
    sub     #0x04
    ld      e, #0x00
    srl     a
    rr      e
    srl     a
    rr      e
    ld      d, a
    ld      a, (_generator + GENERATOR_GROUP_SIZE)
    add     a, #GENERATOR_GROUP_SIZE_ONE
    ld      c, a
    call    _SystemGetRandom
    and     #GENERATOR_GROUP_SIZE_MASK
    cp      c
    jr      c, 01$
    ld      a, #GENERATOR_GROUP_SIZE_1
01$:
    add     a, e
    ld      e, a
    ld      hl, #generatorGroupZako
    add     hl, de
    ld      (_generator + GENERATOR_GROUP_L), hl

    ; 初期化の完了
    ld      hl, #(_generator + GENERATOR_STATE)
    inc     (hl)
09$:

    ; エネミーの生成
    ld      hl, #(_generator + GENERATOR_FRAME)
    dec     (hl)
    jr      nz, 19$
    ld      (hl), #GENERATOR_FRAME_ROUTE
    ld      hl, (_generator + GENERATOR_ENEMY_L)
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      hl, (_generator + GENERATOR_GROUP_L)
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl
    ld      (_generator + GENERATOR_GROUP_L), hl
    call    _EnemyRouteBorn
    ld      hl, #(_generator + GENERATOR_COUNT)
    dec     (hl)
    jr      nz, 19$
    ld      hl, #GeneratorSelect
    ld      (_generator + GENERATOR_PROC_L), hl
    xor     a
    ld      (_generator + GENERATOR_STATE), a
    ld      a, #GENERATOR_FRAME_SELECT
    ld      (_generator + GENERATOR_FRAME), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

GeneratorRouteDouble:

    ; レジスタの保存

    ; 初期化
    ld      a, (_generator + GENERATOR_STATE)
    or      a
    jr      nz, 09$

    ; 経路の設定
    call    _SystemGetRandom
    and     #0x3c
    ld      e, a
    ld      d, #0x00
    ld      hl, #generatorRoute
    add     hl, de
    ld      (_generator + GENERATOR_ENEMY_L), hl
    ld      a, #GENERATOR_FRAME_ROUTE
    ld      (_generator + GENERATOR_FRAME), a
    ld      a, #GENERATOR_COUNT_ROUTE_DOUBLE
    ld      (_generator + GENERATOR_COUNT), a
    ld      a, (_generator + GENERATOR_GROUP_SIZE)
    add     a, #GENERATOR_GROUP_SIZE_ONE
    ld      c, a
    call    _SystemGetRandom
    and     #GENERATOR_GROUP_SIZE_MASK
    cp      c
    jr      c, 01$
    ld      a, #GENERATOR_GROUP_SIZE_1
01$:
    ld      e, a
    ld      d, #0x00
    ld      hl, #generatorGroupZako
    add     hl, de
    ld      (_generator + GENERATOR_GROUP_L), hl

    ; 初期化の完了
    ld      hl, #(_generator + GENERATOR_STATE)
    inc     (hl)
09$:

    ; エネミーの生成
    ld      hl, #(_generator + GENERATOR_FRAME)
    dec     (hl)
    jr      nz, 19$
    ld      (hl), #GENERATOR_FRAME_ROUTE
    ld      hl, (_generator + GENERATOR_GROUP_L)
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl
    ld      (_generator + GENERATOR_GROUP_L), hl
    ld      hl, (_generator + GENERATOR_ENEMY_L)
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    call    _EnemyRouteBorn
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    call    _EnemyRouteBorn
    ld      hl, #(_generator + GENERATOR_COUNT)
    dec     (hl)
    jr      nz, 19$
    ld      hl, #GeneratorSelect
    ld      (_generator + GENERATOR_PROC_L), hl
    xor     a
    ld      (_generator + GENERATOR_STATE), a
    ld      a, #GENERATOR_FRAME_SELECT
    ld      (_generator + GENERATOR_FRAME), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; リーダーエネミーを生成する
;
GeneratorLeader:

    ; レジスタの保存

    ; 初期化
    ld      a, (_generator + GENERATOR_STATE)
    or      a
    jr      nz, 09$

    ; 経路の設定
    call    _SystemGetRandom
    and     #0x3e
    ld      e, a
    ld      d, #0x00
    ld      hl, #generatorRoute
    add     hl, de
    ld      (_generator + GENERATOR_ENEMY_L), hl
    ld      a, #GENERATOR_FRAME_ROUTE
    ld      (_generator + GENERATOR_FRAME), a
    ld      a, #0x08
    ld      (_generator + GENERATOR_COUNT), a
    ld      hl, #generatorGroupLeader
    ld      (_generator + GENERATOR_GROUP_L), hl

    ; 初期化の完了
    ld      hl, #(_generator + GENERATOR_STATE)
    inc     (hl)
09$:

    ; エネミーの生成
    ld      hl, #(_generator + GENERATOR_FRAME)
    dec     (hl)
    jr      nz, 19$
    ld      (hl), #GENERATOR_FRAME_ROUTE
    ld      hl, (_generator + GENERATOR_ENEMY_L)
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      hl, (_generator + GENERATOR_GROUP_L)
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl
    ld      (_generator + GENERATOR_GROUP_L), hl
    call    _EnemyRouteBorn
    ld      hl, #(_generator + GENERATOR_COUNT)
    dec     (hl)
    jr      nz, 19$
    ld      hl, #GeneratorSelect
    ld      (_generator + GENERATOR_PROC_L), hl
    xor     a
    ld      (_generator + GENERATOR_STATE), a
    ld      a, #GENERATOR_FRAME_SELECT
    ld      (_generator + GENERATOR_FRAME), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ボスエネミーを生成する
;
GeneratorBoss:

    ; レジスタの保存

    ; 初期化
    ld      a, (_generator + GENERATOR_STATE)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_generator + GENERATOR_STATE)
    inc     (hl)
09$:

    ; エネミーの生成
    call    _PlayerGetAngle
    ld      c, #0x18
    cp      #0x40
    jr      c, 10$
    cp      #0xc0
    jr      c, 10$
    jr      nc, 10$
    ld      c, #0xa8
10$:
    call    _SystemGetRandom
    and     #0x3f
    add     a, c
    ld      e, a
    ld      d, #0x00
    ld      bc, #generatorGroupTypeBoss
    call    _EnemyBossBorn
    ld      hl, #GeneratorSelect
    ld      (_generator + GENERATOR_PROC_L), hl
    xor     a
    ld      (_generator + GENERATOR_STATE), a
    ld      a, #GENERATOR_FRAME_SELECT
    ld      (_generator + GENERATOR_FRAME), a

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; ジェネレータの初期値
;
generatorDefault:

    .dw     GeneratorSelect ; GENERATOR_PROC_NULL    
    .db     GENERATOR_STATE_NULL
    .db     GENERATOR_FLAG_NULL
    .db     0x60 ; GENERATOR_FRAME_NULL
    .db     GENERATOR_COUNT_NULL
    .db     GENERATOR_SELECT_NULL
    .dw     GENERATOR_ENEMY_NULL
    .dw     GENERATOR_GROUP_NULL
    .db     GENERATOR_GROUP_SIZE_1 ; GENERATOR_GROUP_SIZE_NULL
    .db     0x00 ; GENERATOR_FALL_NULL
    .db     0x20 ; GENERATOR_FALL_NULL
    .db     0x40 ; GENERATOR_FALL_NULL
    .db     0x60 ; GENERATOR_FALL_NULL
    .db     0x80 ; GENERATOR_FALL_NULL
    .db     0xa0 ; GENERATOR_FALL_NULL
    .db     0xc0 ; GENERATOR_FALL_NULL
    .db     0xe0 ; GENERATOR_FALL_NULL

; 経路
;
generatorRoute:

    .dw     generatorRoute_3_1_0
    .dw     generatorRoute_3_1_1
    .dw     generatorRoute_3_2
    .dw     generatorRoute_3_3
    .dw     generatorRoute_7_1_0
    .dw     generatorRoute_7_1_1
    .dw     generatorRoute_7_2_0
    .dw     generatorRoute_7_2_1
    .dw     generatorRoute_11_1_0
    .dw     generatorRoute_11_1_1
    .dw     generatorRoute_11_2_0
    .dw     generatorRoute_11_2_1
    .dw     generatorRoute_15_1_0
    .dw     generatorRoute_15_1_1
    .dw     generatorRoute_15_2
    .dw     generatorRoute_15_3
    .dw     generatorRoute_19_1
    .dw     generatorRoute_19_5
    .dw     generatorRoute_19_2
    .dw     generatorRoute_19_3
    .dw     generatorRoute_23_1
    .dw     generatorRoute_23_4
    .dw     generatorRoute_23_2_0
    .dw     generatorRoute_23_2_1
    .dw     generatorRoute_27_1
    .dw     generatorRoute_27_4
    .dw     generatorRoute_27_2
    .dw     generatorRoute_27_3
    .dw     generatorRoute_31_1_0
    .dw     generatorRoute_31_1_1
    .dw     generatorRoute_31_2
    .dw     generatorRoute_31_3

; X, Y, DIRECTION
; FRAME, SPEED, FORWARD, ROTATE
;   :
; 0x00

; Stage 3-1,4,5
generatorRoute_3_1_0:

    .db     0x70, 0x00, 0x40
    .db     0x38, 0x02, 0x28, -0x01
    .db     0x80, 0x02, 0x88, -0x03
    .db     0x00

generatorRoute_3_1_1:

    .db     0x90, 0x00, 0x40
    .db     0x38, 0x02, 0x58, +0x01
    .db     0x80, 0x02, 0xf8, +0x03
    .db     0x00

; Stage 3-2
generatorRoute_3_2:

    .db     0x00, 0xb0, 0x00
    .db     0x58, 0x02, 0xfc, -0x01
    .db     0x38, 0x02, 0xc0, -0x04
    .db     0x38, 0x02, 0x40, -0x08
    .db     0x30, 0x02, 0xd8, -0x08
    .db     0x00

; Stage 3-3
generatorRoute_3_3:

    .db     0xff, 0xb0, 0x80
    .db     0x58, 0x02, 0x84, +0x01
    .db     0x38, 0x02, 0xc0, +0x04
    .db     0x38, 0x02, 0x40, +0x08
    .db     0x30, 0x02, 0xa8, +0x08
    .db     0x00

; Stage 7-1,4,5
generatorRoute_7_1_0:

    .db     0x60, 0x00, 0x40
    .db     0x10, 0x02, 0x40,  0x00
    .db     0x24, 0x02, 0x30, -0x01
    .db     0x10, 0x00, 0xb0, -0x08
    .db     0x24, 0x02, 0xb0, -0x00
    .db     0x0c, 0x02, 0xc0, +0x01
    .db     0x00

generatorRoute_7_1_1:

    .db     0xa0, 0x00, 0x40
    .db     0x10, 0x02, 0x40,  0x00
    .db     0x24, 0x02, 0x50, +0x01
    .db     0x10, 0x00, 0xd0, +0x08
    .db     0x24, 0x02, 0xd0, +0x00
    .db     0x0c, 0x02, 0xc0, -0x01
    .db     0x00

; Stage 7-2,3
generatorRoute_7_2_0:

    .db     0x00, 0xa0, 0x00
    .db     0x44, 0x02, 0x00,  0x00
    .db     0x18, 0x02, 0xe0, -0x02
    .db     0x18, 0x02, 0xc0, -0x02
    .db     0x18, 0x02, 0xa0, -0x02
    .db     0x18, 0x02, 0x80, -0x02
    .db     0x18, 0x02, 0x60, -0x02
    .db     0x18, 0x02, 0x40, -0x02
    .db     0x18, 0x02, 0x20, -0x02
    .db     0x40, 0x02, 0x00, -0x02
    .db     0x00

generatorRoute_7_2_1:

    .db     0xff, 0xa0, 0x80
    .db     0x44, 0x02, 0x80,  0x00
    .db     0x18, 0x02, 0xa0, +0x02
    .db     0x18, 0x02, 0xc0, +0x02
    .db     0x18, 0x02, 0xe0, +0x02
    .db     0x18, 0x02, 0x00, +0x02
    .db     0x18, 0x02, 0x20, +0x02
    .db     0x18, 0x02, 0x40, +0x02
    .db     0x18, 0x02, 0x60, +0x02
    .db     0x40, 0x02, 0x80, +0x02
    .db     0x00

; Stage 11-1,4,5
generatorRoute_11_1_0:

    .db     0x80, 0x00, 0x40
    .db     0x20, 0x02, 0x40,  0x00
    .db     0x10, 0x02, 0x20, -0x02
    .db     0x28, 0x02, 0x20,  0x00
    .db     0x10, 0x00, 0xa0, -0x08
    .db     0x28, 0x02, 0xa0,  0x00
    .db     0x10, 0x02, 0xc0, +0x02
    .db     0x14, 0x02, 0xc0,  0x00
    .db     0x00

generatorRoute_11_1_1:

    .db     0x80, 0x00, 0x40
    .db     0x20, 0x02, 0x40,  0x00
    .db     0x10, 0x02, 0x60, +0x02
    .db     0x28, 0x02, 0x60,  0x00
    .db     0x10, 0x00, 0xe0, +0x08
    .db     0x28, 0x02, 0xe0,  0x00
    .db     0x10, 0x02, 0xc0, -0x02
    .db     0x14, 0x02, 0xc0,  0x00
    .db     0x00

; Stage 11-2,3
generatorRoute_11_2_0:

    .db     0x00, 0xa0, 0x00
    .db     0x30, 0x02, 0x00,  0x00
    .db     0x08, 0x00, 0x80, -0x10
    .db     0x10, 0x02, 0x80,  0x00
    .db     0x20, 0x02, 0xc0, +0x02
    .db     0x20, 0x02, 0xc0,  0x00
    .db     0x58, 0x02, 0x40, +0x02
    .db     0x08, 0x00, 0x80, +0x08
    .db     0x28, 0x02, 0x80,  0x00
    .db     0x00

generatorRoute_11_2_1:

    .db     0xff, 0xa0, 0x80
    .db     0x30, 0x02, 0x00,  0x00
    .db     0x08, 0x00, 0x00, +0x10
    .db     0x10, 0x02, 0x00,  0x00
    .db     0x20, 0x02, 0xc0, -0x02
    .db     0x20, 0x02, 0xc0,  0x00
    .db     0x58, 0x02, 0x40, -0x02
    .db     0x08, 0x00, 0x00, -0x08
    .db     0x28, 0x02, 0x00,  0x00
    .db     0x00

; Stage 15-1,4,5
generatorRoute_15_1_0:

    .db     0x80, 0x00, 0x40
    .db     0x08, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x00, -0x08
    .db     0x40, 0x02, 0x80, +0x02
    .db     0x40, 0x02, 0x00, -0x02
    .db     0x40, 0x02, 0x80, -0x02
    .db     0x40, 0x02, 0x00, +0x02
    .db     0x00

generatorRoute_15_1_1:

    .db     0x80, 0x00, 0x40
    .db     0x08, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x80, +0x08
    .db     0x40, 0x02, 0x00, -0x02
    .db     0x40, 0x02, 0x80, +0x02
    .db     0x40, 0x02, 0x00, +0x02
    .db     0x40, 0x02, 0x80, -0x02
    .db     0x00

; Stage 15-2
generatorRoute_15_2:

    .db     0x00, 0xa0, 0x00
    .db     0x48, 0x02, 0xcc, -0x02
    .db     0x30, 0x02, 0x90, +0x04
    .db     0x38, 0x02, 0x10, +0x04
    .db     0x20, 0x02, 0x90, +0x04
    .db     0x38, 0x02, 0x10, +0x04
    .db     0x20, 0x02, 0x90, +0x04
    .db     0x38, 0x02, 0x10, +0x04
    .db     0x00

; Stage 15-3
generatorRoute_15_3:

    .db     0xff, 0xa0, 0x80
    .db     0x48, 0x02, 0xb4, +0x02
    .db     0x30, 0x02, 0xf0, -0x04
    .db     0x38, 0x02, 0x70, -0x04
    .db     0x20, 0x02, 0xf0, -0x04
    .db     0x38, 0x02, 0x70, -0x04
    .db     0x20, 0x02, 0xf0, -0x04
    .db     0x38, 0x02, 0x70, -0x04
    .db     0x00

; Stage 19-1,4
generatorRoute_19_1:

    .db     0x80, 0x00, 0x58
    .db     0x30, 0x02, 0x58,  0x00
    .db     0x18, 0x02, 0x40, -0x02
    .db     0x18, 0x02, 0x20, -0x02
    .db     0x18, 0x02, 0x00, -0x02
    .db     0x18, 0x02, 0xe0, -0x02
    .db     0x10, 0x02, 0xc0, -0x02
    .db     0x18, 0x02, 0xa0, -0x02
    .db     0x10, 0x02, 0x80, -0x02
    .db     0x10, 0x02, 0x60, -0x02
    .db     0x10, 0x02, 0x40, -0x02
    .db     0x10, 0x02, 0x20, -0x02
    .db     0x08, 0x02, 0x00, -0x02
    .db     0x20, 0x02, 0x80, -0x04
    .db     0x20, 0x02, 0x00, -0x04
    .db     0x20, 0x02, 0x80, -0x04
    .db     0x08, 0x00, 0x90, +0x02
    .db     0x40, 0x02, 0x90,  0x00
    .db     0x00

; Stage 19-5
generatorRoute_19_5:

    .db     0x80, 0x00, 0x28
    .db     0x30, 0x02, 0x28,  0x00
    .db     0x18, 0x02, 0x40, +0x02
    .db     0x18, 0x02, 0x60, +0x02
    .db     0x18, 0x02, 0x80, +0x02
    .db     0x18, 0x02, 0xa0, +0x02
    .db     0x10, 0x02, 0xc0, +0x02
    .db     0x18, 0x02, 0xe0, +0x02
    .db     0x10, 0x02, 0x00, +0x02
    .db     0x10, 0x02, 0x20, +0x02
    .db     0x10, 0x02, 0x40, +0x02
    .db     0x10, 0x02, 0x60, +0x02
    .db     0x08, 0x02, 0x80, +0x02
    .db     0x20, 0x02, 0x00, +0x04
    .db     0x20, 0x02, 0x80, +0x04
    .db     0x20, 0x02, 0x00, +0x04
    .db     0x08, 0x00, 0xf0, -0x02
    .db     0x40, 0x02, 0xf0,  0x00
    .db     0x00

; Stage 19-2
generatorRoute_19_2:

    .db     0x00, 0x80, 0x00
    .db     0x20, 0x02, 0x00,  0x00
    .db     0x30, 0x02, 0xe0, -0x01
    .db     0x5c, 0x02, 0xa0, +0x03
    .db     0x5c, 0x02, 0xe0, -0x03
    .db     0x54, 0x02, 0x20, -0x03
    .db     0x28, 0x02, 0x00, -0x01
    .db     0x00

; Stage 19-3
generatorRoute_19_3:

    .db     0xff, 0x80, 0x80
    .db     0x20, 0x02, 0x00,  0x00
    .db     0x30, 0x02, 0xa0, +0x01
    .db     0x5c, 0x02, 0xe0, -0x03
    .db     0x5c, 0x02, 0xa0, +0x03
    .db     0x54, 0x02, 0x60, +0x03
    .db     0x28, 0x02, 0x80, +0x01
    .db     0x00

; Stage 23-1,5
generatorRoute_23_1:

    .db     0x80, 0x00, 0x40
    .db     0x12, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x00, -0x08
    .db     0x12, 0x02, 0x00,  0x00
    .db     0x08, 0x00, 0x40, +0x08
    .db     0x12, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x00, -0x08
    .db     0x12, 0x02, 0x00,  0x00
    .db     0x08, 0x00, 0x40, +0x08
    .db     0x12, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x00, -0x08
    .db     0x12, 0x02, 0x00,  0x00
    .db     0x00

; Stage 23-4
generatorRoute_23_4:

    .db     0x80, 0x00, 0x40
    .db     0x12, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x80, +0x08
    .db     0x12, 0x02, 0x80,  0x00
    .db     0x08, 0x00, 0x40, -0x08
    .db     0x12, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x80, +0x08
    .db     0x12, 0x02, 0x80,  0x00
    .db     0x08, 0x00, 0x40, -0x08
    .db     0x12, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x80, +0x08
    .db     0x12, 0x02, 0x80,  0x00
    .db     0x00

; Stage 23-2,3
generatorRoute_23_2_0:

    .db     0x00, 0xb0, 0x00
    .db     0x5f, 0x02, 0x00,  0x00
    .db     0x40, 0x02, 0x88, -0x08
    .db     0x28, 0x02, 0xf8, +0x08
    .db     0x16, 0x02, 0x88, -0x08
    .db     0x0e, 0x02, 0xf8, +0x08
    .db     0x0c, 0x02, 0x88, -0x08
    .db     0x08, 0x02, 0xc0, +0x08
    .db     0x00

generatorRoute_23_2_1:

    .db     0xff, 0xb0, 0x80
    .db     0x5d, 0x02, 0x80,  0x00
    .db     0x40, 0x02, 0xf8, +0x08
    .db     0x28, 0x02, 0x88, -0x08
    .db     0x16, 0x02, 0xf8, +0x08
    .db     0x0e, 0x02, 0x88, -0x08
    .db     0x0c, 0x02, 0xf8, +0x08
    .db     0x08, 0x02, 0xc0, -0x08
    .db     0x00

; Stage 27-1,5
generatorRoute_27_1:

    .db     0x80, 0x00, 0x40
    .db     0x10, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x80, +0x08
    .db     0x38, 0x02, 0x80,  0x00
    .db     0x10, 0x00, 0x16, -0x08
    .db     0x80, 0x02, 0x16,  0x00
    .db     0x10, 0x00, 0x80, +0x08
    .db     0x68, 0x02, 0x80,  0x00
    .db     0x00

; Stage 27-4
generatorRoute_27_4:

    .db     0x80, 0x00, 0x40
    .db     0x10, 0x02, 0x40,  0x00
    .db     0x08, 0x00, 0x00, -0x08
    .db     0x38, 0x02, 0x00,  0x00
    .db     0x10, 0x00, 0x6a, +0x08
    .db     0x80, 0x02, 0x6a,  0x00
    .db     0x10, 0x00, 0x00, -0x08
    .db     0x68, 0x02, 0x00,  0x00
    .db     0x00

; Stage 27-2
generatorRoute_27_2:

    .db     0x00, 0xa0, 0x00
    .db     0x10, 0x02, 0x00,  0x00
    .db     0x38, 0x02, 0xc0, -0x02
    .db     0x20, 0x02, 0x40, +0x04
    .db     0x20, 0x02, 0xc0, -0x04
    .db     0x38, 0x02, 0x40, +0x04
    .db     0x20, 0x02, 0x00, -0x02
    .db     0x00

; Stage 27-3
generatorRoute_27_3:

    .db     0xff, 0xa0, 0x80
    .db     0x10, 0x02, 0x00,  0x00
    .db     0x38, 0x02, 0xc0, +0x02
    .db     0x20, 0x02, 0x40, -0x04
    .db     0x20, 0x02, 0xc0, +0x04
    .db     0x38, 0x02, 0x40, -0x04
    .db     0x20, 0x02, 0x80, +0x02
    .db     0x00

; Stage 31-1,4,5
generatorRoute_31_1_0:

    .db     0x70, 0x00, 0x40
    .db     0x18, 0x02, 0x40,  0x00
    .db     0x20, 0x02, 0xc0, +0x04
    .db     0x20, 0x02, 0x40, +0x04
    .db     0x30, 0x02, 0x20, -0x01
    .db     0x20, 0x02, 0xa0, -0x04
    .db     0x20, 0x02, 0x20, -0x04
    .db     0x28, 0x02, 0x00, -0x01
    .db     0x00

generatorRoute_31_1_1:

    .db     0x90, 0x00, 0x40
    .db     0x18, 0x02, 0x40,  0x00
    .db     0x20, 0x02, 0xc0, -0x04
    .db     0x20, 0x02, 0x40, -0x04
    .db     0x30, 0x02, 0x60, +0x01
    .db     0x20, 0x02, 0xe0, +0x04
    .db     0x20, 0x02, 0x60, +0x04
    .db     0x28, 0x02, 0x80, +0x01
    .db     0x00

; Stage 31-2
generatorRoute_31_2:

    .db     0x00, 0xa0, 0x00
    .db     0x10, 0x02, 0x00,  0x00
    .db     0x40, 0x02, 0xe0, -0x01
    .db     0x20, 0x02, 0x60, -0x04
    .db     0x50, 0x02, 0xe0, -0x04
    .db     0x00

; Stage 31-3
generatorRoute_31_3:
generatorRouteDebug:

    .db     0xff, 0xa0, 0x80
    .db     0x10, 0x02, 0x80,  0x00
    .db     0x40, 0x02, 0xa0, +0x01
    .db     0x20, 0x02, 0x20, +0x04
    .db     0x50, 0x02, 0xa0, +0x04
    .db     0x00

; グループ
;

; ザコ
generatorGroupZako:

    ; x4 - 0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x4 - 1
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x4 - 2
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x4 - 3
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeZako4
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x5 - 0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x5 - 1
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x5 - 2
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x5 - 3
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeZako4
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x6 - 0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x6 - 1
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x6 - 2
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x6 - 3
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeZako4
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    ; x7 - 0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeNull
    ; x7 - 1
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeNull
    ; x7 - 2
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeNull
    ; x7 - 3
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeZako4
    .dw     generatorGroupTypeNull
    ; x8 - 0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    ; x8 - 1
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    ; x8 - 2
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeZako3
    ; x8 - 3
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako0
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako1
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako2
    .dw     generatorGroupTypeZako3
    .dw     generatorGroupTypeZako4

; リーダー
generatorGroupLeader:

    .dw     generatorGroupTypeLeader0
    .dw     generatorGroupTypeLeader0
    .dw     generatorGroupTypeLeader1
    .dw     generatorGroupTypeLeader1
    .dw     generatorGroupTypeLeader2
    .dw     generatorGroupTypeLeader2
    .dw     generatorGroupTypeLeader3
    .dw     generatorGroupTypeLeader4

; ボス
generatorGroupBoss:

    .dw     generatorGroupTypeBoss
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull
    .dw     generatorGroupTypeNull

; なし
generatorGroupTypeNull:

    .db     0
    .db     0
    .dw     0
    .db     0x00
    .db     VDP_COLOR_TRANSPARENT

; ザコ 0
generatorGroupTypeZako0:

    .db     1
    .db     1
    .dw     1
    .db     0x40
    .db     VDP_COLOR_LIGHT_GREEN

; ザコ 1
generatorGroupTypeZako1:

    .db     2
    .db     2
    .dw     2
    .db     0x40
    .db     VDP_COLOR_CYAN

; ザコ 2
generatorGroupTypeZako2:

    .db     4
    .db     4
    .dw     5
    .db     0x40
    .db     VDP_COLOR_LIGHT_BLUE

; ザコ 3
generatorGroupTypeZako3:

    .db     7
    .db     7
    .dw     10
    .db     0x40
    .db     VDP_COLOR_MAGENTA

; ザコ 4
generatorGroupTypeZako4:

    .db     10
    .db     10
    .dw     20
    .db     0x40
    .db     VDP_COLOR_MEDIUM_RED

; リーダー 0
generatorGroupTypeLeader0:

    .db     2
    .db     2
    .dw     3
    .db     0x60
    .db     VDP_COLOR_DARK_GREEN

; リーダー 1
generatorGroupTypeLeader1:

    .db     4
    .db     4
    .dw     6
    .db     0x60
    .db     VDP_COLOR_DARK_BLUE

; リーダー 2
generatorGroupTypeLeader2:

    .db     7
    .db     7
    .dw     12
    .db     0x60
    .db     VDP_COLOR_MAGENTA

; リーダー 3
generatorGroupTypeLeader3:

    .db     12
    .db     12
    .dw     30
    .db     0x60
    .db     VDP_COLOR_DARK_RED

; リーダー 4
generatorGroupTypeLeader4:

    .db     25
    .db     25
    .dw     100
    .db     0x60
    .db     VDP_COLOR_DARK_YELLOW

; ボス
generatorGroupTypeBoss:

    .db     100
    .db     100
    .dw     1000
    .db     0x20
    .db     VDP_COLOR_TRANSPARENT


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ジェネレータ
;
_generator::
    
    .ds     GENERATOR_LENGTH
