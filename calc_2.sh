#!/bin/sh
# Вариант 5: вычисления через awk
LOG="${HOME:-/tmp}/calc_errors.log"
fail() {
    printf '%s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG"
    printf 'Ошибка: %s\n' "$1" >&2
    exit 1
}
[ "$#" -eq 3 ] || fail 'Ожидаются 3 аргумента'
printf '%s\n' "$1" "$3" | grep -Eqv '^-?[0-9]+$' && fail 'Введите два целых числа'
case "$2" in '+'|'-'|'*'|'/'|'%'|'^') ;; *) fail 'Неизвестная операция' ;; esac
# Ноль может быть записан как 0, -0 или 000.
case "$2" in
    '/'|'%') case "$3" in *[1-9]*) ;; *) fail 'Деление на ноль' ;; esac ;;
    '^') case "$3" in -*) case "$3" in *[1-9]*) fail 'Отрицательная степень не поддерживается' ;; esac ;; esac ;;
esac
result=$(awk -v a="$1" -v b="$3" -v op="$2" 'BEGIN {
    if (op == "+") r = a + b
    else if (op == "-") r = a - b
    else if (op == "*") r = a * b
    else if (op == "/") { printf "%.6f\n", a / b; exit }
    else if (op == "%") r = (a + 0) % (b + 0)
    else if (op == "^") r = a ^ b
    printf "%.0f\n", r
}') || fail 'Ошибка awk'
printf '%s\n' "$result"
