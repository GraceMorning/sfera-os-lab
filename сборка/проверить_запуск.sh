#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image_file="$project_root/образе/сфера-ос-лаборатория.img"
serial_file="$(mktemp)"
qemu_error_file="$(mktemp)"
qemu_pid=""

cleanup_temp_file() {
    if [[ -n "$qemu_pid" ]] && kill -0 "$qemu_pid" 2>/dev/null; then
        kill -TERM "$qemu_pid" 2>/dev/null || true
        wait "$qemu_pid" 2>/dev/null || true
    fi
    rm -f "$serial_file"
    rm -f "$qemu_error_file"
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
    -no-shutdown \
    2>"$qemu_error_file" &
qemu_pid=$!

# Файловый последовательный backend QEMU дописывает данные при закрытии.
# Поэтому сначала даём загрузчику выполниться, затем закрываем QEMU и читаем
# полностью сброшенный файл.
for attempt in $(seq 1 30); do
    if ! kill -0 "$qemu_pid" 2>/dev/null; then
        break
    fi
    sleep 0.1
done

if kill -0 "$qemu_pid" 2>/dev/null; then
    kill -TERM "$qemu_pid" 2>/dev/null || true
fi
wait "$qemu_pid" 2>/dev/null || true
qemu_pid=""

if ! grep -a -q "Сфера ОС Лаб: загрузчик работает!" "$serial_file"; then
    echo "Ошибка: QEMU не получил ожидаемое сообщение загрузчика." >&2
    if [[ -s "$qemu_error_file" ]]; then
        cat "$qemu_error_file" >&2
    fi
    exit 1
fi

echo "Проверка запуска прошла: загрузчик вывел русское сообщение в QEMU."
