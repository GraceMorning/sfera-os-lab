#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
missing=()

for command_name in as ld objcopy; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        missing+=("$command_name")
    fi
done

if ((${#missing[@]} > 0)); then
    echo "Не найдены обязательные команды: ${missing[*]}" >&2
    echo "Установите набор инструментов сборки и повторите проверку." >&2
    exit 1
fi

if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "QEMU найден: $(command -v qemu-system-x86_64)"
else
    echo "Предупреждение: QEMU не найден."
    echo "Образ можно собрать, но запустить его пока нельзя."
fi

echo "Окружение сборки проверено: $project_root"
