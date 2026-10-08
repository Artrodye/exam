#!/bin/sh
LOG=errors.log
OP=
WORDS=
SEEN_O=0; SEEN_W=0; SEEN_L=0
fail() { echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: $1" >> "$LOG" 2>/dev/null; echo "Ошибка: $1" >&2; exit 1; }
valid() { case "$1" in -*) v=${1#-};; *) v=$1;; esac; case "$v" in ''|*[!0-9]*) return 1;; esac; }
normal() { v=$1; sign=; case "$v" in -*) sign=-; v=${v#-};; esac; while [ "${v#0}" != "$v" ]; do v=${v#0}; done; [ -n "$v" ] || v=0; printf '%s%s\n' "$sign" "$v"; }
while getopts ':o:w:l:' opt; do
 case "$opt" in
 o) [ "$SEEN_O" -eq 0 ] || fail 'Повтор -o'; OP=$OPTARG; SEEN_O=1;;
 w) [ "$SEEN_W" -eq 0 ] || fail 'Повтор -w'; WORDS=$OPTARG; SEEN_W=1;;
 l) [ "$SEEN_L" -eq 0 ] || fail 'Повтор -l'; LOG=$OPTARG; SEEN_L=1;;
 :) fail "Нет значения для -$OPTARG";;
 ?) fail "Неизвестный флаг: -$OPTARG";; esac
done
shift $((OPTIND - 1))
[ "$#" -eq 0 ] || fail 'Лишние аргументы'
[ "$SEEN_O" -eq 1 ] && [ "$SEEN_W" -eq 1 ] && [ "$SEEN_L" -eq 1 ] || fail 'Нужны -o, -w и -l'
[ -n "$LOG" ] || { LOG=errors.log; fail 'Пустой путь лога'; }
case "$OP" in sum|sub|mul|div|pow) ;; *) fail "Неизвестная операция: $OP";; esac
set -f
set -- $WORDS
[ "$#" -ge 2 ] || fail 'Требуется минимум два числа'
for x do valid "$x" || fail "Не целое число: $x"; done
# Проверка нулевых делителей до запуска awk
if [ "$OP" = div ]; then first=1; for x do if [ "$first" -eq 1 ]; then first=0; else [ "$(normal "$x")" -ne 0 ] || fail 'Деление на ноль'; fi; done; fi
if [ "$OP" = pow ]; then first=1; for x do if [ "$first" -eq 1 ]; then first=0; else nx=$(normal "$x"); [ "$nx" -ge 0 ] && [ "$nx" -le 63 ] || fail 'Показатель степени вне 0..63'; fi; done; fi
awk -v op="$OP" 'BEGIN { r=ARGV[1]+0; for(i=2;i<ARGC;i++){ x=ARGV[i]+0; if(op=="sum")r+=x; else if(op=="sub")r-=x; else if(op=="mul")r*=x; else if(op=="div")r=int(r/x); else if(op=="pow")r=r^x; } printf "%.0f\n",r; }' "$@" || fail 'Ошибка awk'
