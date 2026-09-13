#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image_file="$project_root/образе/сфера-ос-лаборатория.img"
serial_file="$(mktemp)"
qemu_pid=""

cleanup_temp_file() {
    if [[ -n "$qemu_pid" ]] && kill -0 "$qemu_pid" 2>/dev/null; then
        kill -TERM "$qemu_pid" 2>/dev/null || true
        wait "$qemu_pid" 2>/dev/null || true
    fi
    rm -f "$serial_file"
}

trap cleanup_temp_file EXIT

if [[ ! -f "$image_file" ]]; then
    echo "Образ ещё не собран. Сначала запустите ./сборка/собрать.sh." >&2
    exit 1
fi

qemu-system-x86_64 \
    -boot order=c \
    -drive "format=raw,file=$image_file" \
    -serial "file:$serial_file" \
    -display none \
    -no-reboot \
    -no-shutdown &
qemu_pid=$!

message_found=0
for attempt in $(seq 1 30); do
    if grep -a -q "Сфера ОС Лаб: загрузчик работает!" "$serial_file"; then
        message_found=1
        break
    fi
    sleep 0.1
done

if [[ "$message_found" != "1" ]]; then
    echo "Ошибка: QEMU не получил ожидаемое сообщение загрузчика." >&2
    exit 1
fi

echo "Проверка запуска прошла: загрузчик вывел русское сообщение в QEMU."
