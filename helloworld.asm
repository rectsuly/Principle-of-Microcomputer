;data segment
;    buf db 0ah, 0dh,"Hello world!$"
;data ends                         
;code segment
;    assume cs:code,ds:data
;start:
;    mov ax,data
;    mov ds,ax
;    lea dx,buf
;    mov ah,9
;    int 21h
;    mov ah,4ch
;    int 21h
;code ends
;    end start   
.model small
.data
    string db "Hello world!$"
.code
.startup
    mov dx,offset string
    mov ah,9h
    int 21h
.exit 0
end