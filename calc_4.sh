#!/bin/sh
# Вариант 2: if/elif + grep и арифметика sh
LOG="${HOME:-/tmp}/calc_errors.log"
fail() {
    printf '%s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG"
    printf 'Ошибка: %s\n' "$1" >&2
    exit 1
}
[ "$#" -eq 3 ] || fail 'Ожидаются ровно три аргумента'
printf '%s\n' "$1" "$3" | grep -Eqv '^-?[0-9]+$' && fail 'Ожидаются целые числа'
# Удаляем ведущие нули: sh может считать 010 восьмеричным числом.
norm() {
    x=$1; s=
    case "$x" in -*) s=-; x=${x#-} ;; esac
    while [ "${x#0}" != "$x" ]; do x=${x#0}; done
    [ -n "$x" ] || x=0
    printf '%s%s\n' "$s" "$x"
}
a=$(norm "$1"); b=$(norm "$3"); op=$2
if [ "$op" = '+' ]; then
    answer=$((a + b))
elif [ "$op" = '-' ]; then
    answer=$((a - b))
elif [ "$op" = '*' ]; then
    answer=$((a * b))
elif [ "$op" = '/' ] || [ "$op" = '%' ]; then
    [ "$b" -ne 0 ] || fail 'Деление на ноль'
    if [ "$op" = '/' ]; then answer=$((a / b)); else answer=$((a % b)); fi
elif [ "$op" = '^' ]; then
    [ "$b" -ge 0 ] && [ "$b" -le 100 ] || fail 'Степень должна быть от 0 до 100'
    answer=1
    while [ "$b" -gt 0 ]; do answer=$((answer * a)); b=$((b - 1)); done
else
    fail 'Недопустимый оператор'
fi
printf 'Результат: %s\n' "$answer"
