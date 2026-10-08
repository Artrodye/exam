#!/bin/sh
# Вариант 4: вычисления через expr
LOG="${HOME:-/tmp}/calc_errors.log"
fail() {
    printf '%s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG"
    printf 'Ошибка: %s\n' "$1" >&2
    exit 1
}
[ "$#" -eq 3 ] || fail 'Требуются 3 аргумента'
printf '%s\n' "$1" "$3" | grep -Eqv '^-?[0-9]+$' && fail 'Аргументы должны быть целыми числами'
a=$1; b=$3
case "$2" in
    '+') res=$(expr "$a" + "$b" 2>/dev/null); rc=$? ;;
    '-') res=$(expr "$a" - "$b" 2>/dev/null); rc=$? ;;
    '*') res=$(expr "$a" \* "$b" 2>/dev/null); rc=$? ;;
    '/') [ "$b" -ne 0 ] || fail 'Деление на ноль'; res=$(expr "$a" / "$b" 2>/dev/null); rc=$? ;;
    '%') [ "$b" -ne 0 ] || fail 'Деление на ноль'; res=$(expr "$a" % "$b" 2>/dev/null); rc=$? ;;
    '^')
        [ "$b" -ge 0 ] && [ "$b" -le 100 ] || fail 'Степень должна быть от 0 до 100'
        res=1; i=0; rc=0
        while [ "$i" -lt "$b" ]; do
            res=$(expr "$res" \* "$a" 2>/dev/null)
            rc=$?
            [ "$rc" -le 1 ] || fail 'Ошибка вычисления или переполнение expr'
            i=$((i + 1))
        done
        ;;
    *) fail 'Неизвестная операция' ;;
esac
# У expr статус 1 означает корректный результат 0; статус 2 — ошибку.
[ "$rc" -le 1 ] || fail 'Ошибка вычисления или переполнение expr'
printf '%s\n' "$res"
