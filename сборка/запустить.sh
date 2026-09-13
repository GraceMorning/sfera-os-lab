#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image_file="$project_root/образе/сфера-ос-лаборатория.img"

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "Не найден QEMU. Сначала установите qemu-system-x86_64." >&2
    exit 1
fi

if [[ ! -f "$image_file" ]]; then
    echo "Образ ещё не собран. Запустите ./сборка/собрать.sh." >&2
    exit 1
fi

echo "Запускаю «Сфера ОС Лаб» в QEMU."
echo "Для остановки нажмите Ctrl+C."

qemu-system-x86_64 \
    -drive "format=raw,file=$image_file" \
    -serial stdio \
    -display none \
    -no-reboot \
    -no-shutdown
