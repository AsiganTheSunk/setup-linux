#!/usr/bin/env bash

RESET="\e[0m"
BOLD="\e[1m"

echo -e "${BOLD}=== STANDARD FOREGROUND COLORS ===${RESET}"
declare -A colors=(
  [BLACK]="30" [RED]="31" [GREEN]="32" [YELLOW]="33" [BLUE]="34"
  [MAGENTA]="35" [CYAN]="36" [LIGHT_GRAY]="37"
  [DARK_GRAY]="90" [LIGHT_RED]="91" [LIGHT_GREEN]="92" [LIGHT_YELLOW]="93"
  [LIGHT_BLUE]="94" [LIGHT_MAGENTA]="95" [LIGHT_CYAN]="96" [WHITE]="97"
)

for name in "${!colors[@]}"; do
  code=${colors[$name]}
  echo -e "\e[${code}m$name (\e[${code}m\\e[${code}m${RESET})"
done

echo -e "\n${BOLD}=== BACKGROUND COLORS ===${RESET}"
for i in {40..47} {100..107}; do
  echo -e "\e[${i}mBG_$i (\e[${i}m\\e[${i}m${RESET})"
done

echo -e "\n${BOLD}=== 256 COLOR PALETTE ===${RESET}"
for i in {0..255}; do
  printf "\e[38;5;%sm%3s " "$i" "$i"
  if (( (i+1) % 16 == 0 )); then
    echo -e "${RESET}"
  fi
done

echo -e "\n${BOLD}=== TRUECOLOR DEMO ===${RESET}"
for r in 0 128 255; do
  for g in 0 128 255; do
    for b in 0 128 255; do
      printf "\e[38;2;%s;%s;%smRGB(%3s,%3s,%3s) " "$r" "$g" "$b" "$r" "$g" "$b"
    done
    echo -e "${RESET}"
  done
done

echo -e "\nDone."
