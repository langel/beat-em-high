; CAMERA HANDLER

; TO DO:
;	- don't scroll outside of map data
;	- scroll repsonds to player(s) movement
;	- scroll can lock when in phase state
;	- scroll both ways

state_level_cam_update: subroutine

; SCROOOLLLLL
	; scroll_dir = amount to increase scroll_x
        ; positive number goes right
        ; negative number goes left
	lda scroll_dir
        lda #$01
        lda wtf
        and #$01
        beq .scroll_update_done
        inc scroll_x
        lda scroll_x
        ; cmp #$ff ; for right-to-left
        bne .scroll_update_done
        inc scroll_ms
        lda scroll_ms
        and #$03
        sta scroll_ms
.scroll_update_done
	rts
