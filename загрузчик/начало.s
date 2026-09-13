.code16
.section .text
.global начало
.type начало, @function

/*
 * Первый загрузочный сектор «Сфера ОС Лаб».
 *
 * Здесь используются имена внешнего инструмента только потому, что это
 * граница с процессором и загрузочным форматом. Все метки и сообщение,
 * принадлежащие лаборатории, русскоязычные.
 */
начало:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0x7c00, %sp
    sti

    call настроить_последовательный_порт

    movw $сообщение, %si
вывести_сообщение:
    lodsb
    testb %al, %al
    jz остановиться
    call вывести_символ
    jmp вывести_сообщение

остановиться:
    cli
ждать:
    hlt
    jmp ждать

настроить_последовательный_порт:
    /* Скорость 38400, 8 бит данных, без проверки чётности, один стоп-бит. */
    movw $0x3f9, %dx
    movb $0, %al
    outb %al, (%dx)

    movw $0x3fb, %dx
    movb $0x80, %al
    outb %al, (%dx)

    movw $0x3f8, %dx
    movb $3, %al
    outb %al, (%dx)

    movw $0x3f9, %dx
    movb $0, %al
    outb %al, (%dx)

    movw $0x3fb, %dx
    movb $3, %al
    outb %al, (%dx)

    movw $0x3fc, %dx
    movb $3, %al
    outb %al, (%dx)
    ret

вывести_символ:
    pushw %ax
ожидать_порт:
    movw $0x3fd, %dx
    inb (%dx), %al
    testb $0x20, %al
    jz ожидать_порт
    popw %ax
    movw $0x3f8, %dx
    outb %al, (%dx)
    ret

сообщение:
    .ascii "Сфера ОС Лаб: загрузчик работает!\r\n"
    .ascii "Следующий шаг: передать управление ядру на Сфере.\r\n"
    .byte 0

    /* Подпись загрузочного сектора: последние два байта должны быть AA 55. */
    .org 510
    .word 0xaa55
