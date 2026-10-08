#!/bin/sh
# Вариант 1: case + арифметика POSIX sh
LOG="${HOME:-/tmp}/calc_errors.log"
fail() {
    printf '%s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG"
    printf 'Ошибка: %s\n' "$1" >&2
    exit 1
}
valid() {
    case "$1" in -*) n=${1#-} ;; *) n=$1 ;; esac
    case "$n" in ''|*[!0-9]*) return 1 ;; esac
    return 0
}
normalize() {
    n=$1; sign=
    case "$n" in -*) sign=-; n=${n#-} ;; esac
    while [ "${n#0}" != "$n" ]; do n=${n#0}; done
    [ -n "$n" ] || n=0
    printf '%s%s\n' "$sign" "$n"
}
[ "$#" -eq 3 ] || fail 'Нужно 3 аргумента: число операция число'
valid "$1" && valid "$3" || fail 'Оба числа должны быть целыми'
a=$(normalize "$1")
b=$(normalize "$3")
case "$2" in
    '+') result=$((a + b)) ;;
    '-') result=$((a - b)) ;;
    '*') result=$((a * b)) ;;
    '/') [ "$b" -ne 0 ] || fail 'Деление на ноль'; result=$((a / b)) ;;
    '%') [ "$b" -ne 0 ] || fail 'Деление на ноль'; result=$((a % b)) ;;
    '^')
        [ "$b" -ge 0 ] && [ "$b" -le 100 ] || fail 'Степень должна быть от 0 до 100'
        result=1; i=0
        while [ "$i" -lt "$b" ]; do result=$((result * a)); i=$((i + 1)); done
        ;;
    *) fail 'Неизвестная операция' ;;
esac
printf '%s\n' "$result"
