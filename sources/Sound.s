; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgmGame_0, soundBgmGame_1, soundBgmGame_2
    .dw     soundBgmTitle_0, soundBgmTitle_1, soundBgmTitle_2

; ゲーム
soundBgmGame_0:

    .ascii  "T3@0"
    .ascii  "L1V15,1O6DFGV14,1DFGV13,1DFGV12,1DFGV11,1DFG3R9"
    .ascii  "L1L1V15,1O6DFGV14,1DFGV13,1DFGV12,1DFGV11,1DFG3V15,4R7R5RO5DFD"
    .ascii  "L3O5FGGGO6C4O5B-1R5R7R5R1D1F1D1"
    .ascii  "L3O5FGGGO6C4O5B-1R5R7R5R1D1F1D1"
    .ascii  "L3O5FGGGO6C4O5B-1R5R3L1O6CO5A-A-FDCL0O3B-O4CO3B-O4CDFDFL1B-O5CDF"
    .ascii  "L3O5RGGGO6C4O5B-1RO6DR1D1DR5R7"
    .ascii  "L3R7O4B-O5CDE-5E-B-5R7"
    .ascii  "L3O5C5O5AA5GFD6R5R5DF"
    .ascii  "L3O5C5O4B-5O5C5O4B-5O5DF5D5RDF"
    .ascii  "L3O5G5F5DCO4B-O5D5RE-DRE-D5R9"
    .ascii  "L3R7O4B-O5CDE-5E-B-5R7"
    .ascii  "L3O5C5O5AA5GFD6R5R5DF"
    .ascii  "L3O5C5O4B-5O5C5O4B-5O5DF5D5RDF"
    .ascii  "L3O5G5G5A3F5G5RFGRFG5R9"
    .ascii  "L3R7O5RGGG6F5DCO4B-O5D7R"
    .ascii  "L3O5RFFF6D5C5DO4B-7R"
    .ascii  "L3O5RGGG6F5DCO4B-O5F7R"
    .ascii  "L3O5RFF5F5DF5A5G6R5"
    .ascii  "L3O5GFE-F5FD7R5"
    .ascii  "L3R7O5GFE-F5FD7DE-6"
    .ascii  "L3O5DE-5RFG6FG5RGA9R"
    .ascii  "L5O5B-AB-AB-3AB-3A7R9"
    .ascii  "L3O5D5F5G6B-5AAGG5R5"
    .ascii  "L3O5D5F5G5RB-5AAGG5R5"
    .ascii  "L3O5D5F5G5RB-5AAGG5R5"
    .ascii  "L3O5D5F5G5RB-5AAGG5"
    .ascii  "L3V15,4O5FG5RV13,4O5FG4R1RV15,4O5FG5RV13,4O5GF4R1RV15,4O5FG5RR5R7"
    .ascii  "L3R7R5V15,4O5FG5RV13,4O5FG4R1RV15,4O5FG5RV13,4O5GF4R1RV15,4O5B-G5RR5V13,9O4B-7"
    .ascii  "L9O5D"
    .ascii  "V15,4L3O5D5F5G6B-5AAGG5R5"
    .ascii  "L3O5D5F5G5RB-5AAGG5R5"
    .ascii  "L3O5D5F5G5RB-5AAGG5R5"
    .ascii  "L3O5D5F5G5RB-5AAGG5"
    .ascii  "L3V15,4O5FG5RV13,4O5FG4R1RV15,4O5FG5RV13,4O5GF4R1RV15,4O5FG5RR5R7"
    .ascii  "L3R7R5V15,4O5FG5RV13,4O5FG4R1RV15,4O5FG5RV13,4O5GF4R1RV15,4O5B-G5RR5R7"
    .ascii  "L3R5O5FG4R1RR5"
    .db     0x00

soundBgmGame_1:

    .ascii  "T3@0"
    .ascii  "L1O6V13,1DD3DD3V12,1DD3DD3D3V11,1DDR3D4V10,1DD3DD3V9,1DD3DD"
    .ascii  "L1O6V13,1DD3DD3V12,1DD3DD3D3V11,1DDR3D4V10,1DD3DD3V9,1DD3DD"
    .ascii  "V13,3L3O5DDDDF4G1R5R7R5R1O4B-1O5D1O4B-1"
    .ascii  "L3O5E-E-E-E-G4G1R5R7R5R1O4B-1O5D1O4B-1"
    .ascii  "L3O5CCCCE-4E-1R5RL1AFCCO4AAL0O3B-B-B-CDFDCL1FGAO5C"
    .ascii  "L3O5RDDDG4G1RAR1A1AR5R7"
    .ascii  "V13,8L9O5DO4E-7R3O5E-6"
    .ascii  "L9O4AB-6O5D5D6"
    .ascii  "L9O5CD"
    .ascii  "L3O5E-7D7D5E-DRE-V13,1L0RE-FGAB-O6CDV13,4L3E-DRE-D5R5"
    .ascii  "V13,8L9O5DE-"
    .ascii  "L9O5FD6O4B-5O5D6"
    .ascii  "L9O5CD"
    .ascii  "L3O5G7F7G5FGRFV13,1L0RFGAB-O6CDE-V13,4L3FGRFG5R5"
    .ascii  "L9RR"
    .ascii  "L9RR"
    .ascii  "L9RR"
    .ascii  "L9RR"
    .ascii  "V13,4L1O5RGG3G3FGV15,4L3O5E-DCD5DO4B-7R5"
    .ascii  "V13,4L1O5RGG3G3FGV15,4L3O5E-DCD5DO4B-7R5"
    .ascii  "L3R9R7R5O5GG9R"
    .ascii  "L5O5F+F+F+F+F+3F+F+3F+7R9"
    .ascii  "V13,4L3O4D5F5G6B-5AAGG5R5"
    .ascii  "L3O4D5F5G5RB-5AAGG5R5"
    .ascii  "L3O4D5F5G5RB-5AAGG5R5"
    .ascii  "L3O4D5F5G5RB-5AAGG5"
    .ascii  "L3O4FG5RFG4R1RFG5RGF4R1RFG5RR5R7"
    .ascii  "L3R7R5O4FG5RFG4R1RFG5RGF4R1RB-GV13,9O4G7O5D7"
    .ascii  "L9O5G"
    .ascii  "V13,4L3O4D5F5G6B-5AAGG5R5"
    .ascii  "L3O4D5F5G5RB-5AAGG5R5"
    .ascii  "L3O4D5F5G5RB-5AAGG5R5"
    .ascii  "L3O4D5F5G5RB-5AAGG5"
    .ascii  "L3O4FG5RFG4R1RFG5RGF4R1RFG5RR5R7"
    .ascii  "L3R7R5O4FG5RFG4R1RFG5RGF4R1RB-G5O5GFDCDO4F1F+1G"
    .ascii  "V15,4L3O5R5CD4R1RR5"
    .db     0x00

soundBgmGame_2:

    .ascii  "T3@0"
    .ascii  "V14,4L9RR"
    .ascii  "L9RR"
    .ascii  "L1O2G4GG5R5CDFGG4DO1GO2G4R5D3DO1F"
    .ascii  "L1O2G4O3GO2G5R5CGDFG3DDG5DO3DE-3O2F3G3"
    .ascii  "L1O2G4GG5R5CDFGG3C3C3C3CC3DB-3A3"
    .ascii  "L1O2G3DDO1G3O2G3DD4G3E-3RE-E-3R5R5D5"
    .ascii  "L1O2G3O3GGO2G3O3G3R5O2GB-O3FGO2G3O3GGO2G3O3G3R5O2FAO3CD"
    .ascii  "L1O2F3O3FFO2F3O3F3R5O2FGO3DFO2G3O3GGO2G3O3G3O2GGG3G5"
    .ascii  "L1O3C3CO2B-O3CO4C4O3CCO2B-3O3C3O2GO3CD3DCDO4D4O3D3DCD3O2GO3C"
    .ascii  "L3O3E-E-E-E-O2B-B-B-O3D5RDDRDD5DDRDD5O4D5"
    .ascii  "L1O2G3O3GGO2G3O3G3R5O2GB-O3FGO2G3O3GGO2G3O3G3R5O2FAO3CD"
    .ascii  "L1O2F3O3FFO2F3O3F3R5O2FGO3DFO2G3O3GGO2G3O3G3O2GGG3G5"
    .ascii  "L1O3C3CO2B-O3CO4C4O3CCO2B-3O3C3O2GO3CD3DCDO4D4O3D3DCD3O2GO3C"
    .ascii  "L3O3GGGGF1F1FFG5O4GO3GGGO4GO3GGGGRGG5R5"
    .ascii  "L3O3E-E-5O2B-O3E-E-5O2B-O3E-6E-R5O2B-O3E-"
    .ascii  "L3O3DD5O2B-O2DD5O2B-O3D6DR5RO2B-"
    .ascii  "L3O3E-E-5O2B-O3E-E-5O2B-E-6E-R5O2B-O3E-"
    .ascii  "L3O3DD5O2B-O3DD5O2B-O3D7RO2B-O3E-5"
    .ascii  "L3O3E-E-E-E-E-E-E-E-DDDDDDDD"
    .ascii  "L3O3E-E-E-E-E-E-E-E-DDDDDDDC6"
    .ascii  "L3O3CCC1O4C1O3CCD-5D-D-D-D-1O4D-1O3D-D-D5DDDD1O4D1O3ODD"
    .ascii  "L3O3DDDDDDDDDD5DD7RO4C1DO3F1GD1DF1G1A1C1O2B-1"
    .ascii  "L3O2GGGGG1O3D4O2GG1G1FFFFF1O3CD1DF"
    .ascii  "L3O3E-E-E-E-O2G1GO3E-1O2B-B-1O3C1FF5F5F5F"
    .ascii  "L3O2GGGGG1O3D4O2GG1G1FFFFF1O3CD1DF"
    .ascii  "L3O3E-E-E-E-O2G1GO3E-1O2B-B-1O3C1FF5F5F5F"
    .ascii  "L1O3E-3E-3E-5E-B-FGGDE-FF3F3F5FB-FGGDFGGG4G5G3GGGGG3"
    .ascii  "L1O3G3O4CD3O3B-O4C3O3GGG3G3E-3E-3E-3E-5E-B-FGGDE-FF3F3F5FB-FGGDFGG3GGG5G3GGG5"
    .ascii  "L1O3FGO4CD3O3FG3O2GGG3G3GG"
    .ascii  "L3O2GGGGG1O3D4O2GG1G1FFFFF1O3CD1DF"
    .ascii  "L3O3E-E-E-E-O2G1GO3E-1O2B-B-1O3C1FF5F5F5F"
    .ascii  "L3O2GGGGG1O3D4O2GG1G1FFFFF1O3CD1DF"
    .ascii  "L3O3E-E-E-E-O2G1GO3E-1O2B-B-1O3C1FF5F5F5F"
    .ascii  "L1O3E-3E-3E-5E-B-FGGDE-FF3F3F5FB-FGGDFGGG4G5G3GGGGG3"
    .ascii  "L1O3G3O4CD3O3B-O4C3O3GGG3G3E-3E-3E-3E-5E-B-FGGDE-FF3F3F5FB-FGGDFGRGFDCDO2F1F+1G"
    .ascii  "V15,4L3O2R5FG4R1RR5"
    .db     0x00

; タイトル
soundBgmTitle_0:

    .ascii  "T3@0V15,4"
    .ascii  "L5O5F+GF+GF+F+3G6F+"
    .ascii  "L5O5F+GF+GF+F+3G6F+"
    .ascii  "L5O5EFEFEE3F6E"
    .ascii  "L5O5EFEFEE3F6O6D3D3"
    .db     0x00

soundBgmTitle_1:

    .ascii  "T3@0V13,4"
    .ascii  "L5O5DDDDDD3D6D"
    .ascii  "L5O5DDDDDD3D6D"
    .ascii  "L5O5CCCCCC3C6C"
    .ascii  "L5O5CCCCCC3C6A3A3"
    .db     0x00

soundBgmTitle_2:

    .ascii  "T3@0V14,4"
    .ascii  "L3O3DDDDDDDDDDDDDDDD"
    .ascii  "L3O3DDDDDDDDDDDDDO4DO3DO2A"
    .ascii  "L3O3CCCCCCCCCO4CO3CO4CO3CCCC"
    .ascii  "L3O3CCCCCCO2GAO3CCCC6O4DD"
    .db     0x00

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeCount
    .dw     soundSeHit
    .dw     soundSeBomb

; ブート
soundSeBoot:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; カウント
soundSeCount:

    .ascii  "T1@0V13O5B0"
    .db     0x00

; ヒット
soundSeHit:

    .ascii  "T1@0L1O3V13CV12CV11CV10C"
    .db     0x00

; 爆発
soundSeBomb:

    .ascii  "T1@0V13L0O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-O3CO2D-O3D-O2CO3CO2D-O3D-O2CO3CO2D-O3D-O2CO3CO2D-O3D-O2C"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
