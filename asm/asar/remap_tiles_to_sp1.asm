;;
;; Bounce Sprites
;;

; Note block
org $0291F2 : db $0A                ; tile number
org $02878A : db $02                ; YXPPCCCT value

; Sideways turn block
org $0291F4 : db $40                ; tile number
org $02878C : db $00                ; YXPPCCCT value

; Glass block
org $0291F5 : db $20                ; tile number
org $02878D : db $00                ; YXPPCCCT value

; ON/OFF block
org $0291F6 : db $4A                ; tile number
org $02878E : db $06                ; YXPPCCCT value

;;
;; Yoshi Bits
;;

; Yoshi's tongue, end
org $01F48C : db $7E                ; tile number 
org $01F494 : db $08                ; YXPPCCCT value

; Yoshi's tongue, middle
org $01F488 : db $7F                ; tile number
org $01F494 : db $08                ; YXPPCCCT value

; Yoshi's throat
org $01F08B : db $38                ; tile number
org $01F097 : db $0A                ; YXPPCCCT value


;;
;; Lava Splashes
;;

; Dying in Lava splashes
org $029E82 : db $33,$23,$32,$22    ; tile numbers
org $029ED5 : db $04                ; YXPPCCCT value

; Podoboo lava splashes
org $028F2B : db $33,$23,$32,$22    ; tile numbers
org $028F76 : db $04                ; YXPPCCCT value
