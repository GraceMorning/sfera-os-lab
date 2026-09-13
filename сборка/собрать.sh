#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_files="$project_root/временные"
image_directory="$project_root/образе"
object_file="$temporary_files/начало.o"
executable_file="$temporary_files/начало.elf"
image_file="$image_directory/сфера-ос-лаборатория.img"

mkdir -p "$temporary_files" "$image_directory"

echo "Собираю загрузчик «Сфера ОС Лаб»..."
as --32 "$project_root/загрузчик/начало.s" -o "$object_file"
ld -m elf_i386 -Ttext 0x7c00 -e начало \
    "$object_file" -o "$executable_file"
objcopy -O binary -j .text "$executable_file" "$image_file"

image_size="$(wc -c < "$image_file")"
if [[ "$image_size" != "512" ]]; then
    echo "Ошибка: загрузчик занимает $image_size байт вместо 512." >&2
    exit 1
fi

signature="$(od -An -tx1 -j 510 -N 2 "$image_file" | tr -d ' \n')"
if [[ "$signature" != "55aa" ]]; then
    echo "Ошибка: неверная подпись загрузочного сектора: $signature." >&2
    exit 1
fi

echo "Готово."
echo "Образ: $image_file"
echo "Размер: $image_size байт"
echo "Подпись загрузочного сектора: 55aa"
