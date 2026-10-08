#!/bin/sh
# Вариант 3: функции для операций
LOG="${HOME:-/tmp}/calc_errors.log"
fail() {
    printf '%s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG"
    printf 'Ошибка: %s\n' "$1" >&2
    exit 1
}
check_number() {
    case "$1" in -*) digits=${1#-} ;; *) digits=$1 ;; esac
    case "$digits" in ''|*[!0-9]*) return 1 ;; esac
}
decimal() {
    digits=$1; sign=
    case "$digits" in -*) sign=-; digits=${digits#-} ;; esac
    while [ "${digits#0}" != "$digits" ]; do digits=${digits#0}; done
    [ -n "$digits" ] || digits=0
    printf '%s%s\n' "$sign" "$digits"
}
add() { echo $((a + b)); }
sub() { echo $((a - b)); }
mul() { echo $((a * b)); }
div() { [ "$b" -ne 0 ] || fail 'Деление на ноль'; echo $((a / b)); }
mod() { [ "$b" -ne 0 ] || fail 'Деление на ноль'; echo $((a % b)); }
pow() {
    [ "$b" -ge 0 ] && [ "$b" -le 100 ] || fail 'Степень должна быть от 0 до 100'
    result=1; i=0
    while [ "$i" -lt "$b" ]; do result=$((result * a)); i=$((i + 1)); done
    echo "$result"
}
[ "$#" -eq 3 ] || fail 'Укажите 3 аргумента'
check_number "$1" && check_number "$3" || fail 'Числа должны быть целыми'
a=$(decimal "$1"); b=$(decimal "$3")
case "$2" in
    '+') add ;; '-') sub ;; '*') mul ;;
    '/') div ;; '%') mod ;; '^') pow ;;
    *) fail 'Неизвестная операция' ;;
esac
