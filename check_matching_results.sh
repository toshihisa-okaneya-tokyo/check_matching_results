#!/bin/bash

set -euo pipefail

S3_PREFIX="s3://techkitchen-cuisine-development2/matching/batch/"
WORK_DIR_BASE="/tmp/check_matching_results"

# 日付を引数から取得、未指定なら前日の日付を設定
get_target_date() {
    local input_date="${1:-}"
    if [ -n "${input_date}" ]; then
        # 引数がある場合（MMDD形式）、今年の年を付ける
        TARGET_DATE="$(date +%Y)${1:-}"
    else
        # 引数がない場合は前日の日付を取得（YYYYMMDD形式）
        TARGET_DATE=$(date -d "yesterday" +%Y%m%d)
    fi
    echo "$TARGET_DATE"
}

get_work_dir() {
    local target_date="$1"

    echo "${WORK_DIR_BASE:?}/${target_date:?}"
}

get_prefix() {
    local target_date="$1"
    local prefix_date
    prefix_date=$(aws s3 ls --profile=dev2 "${S3_PREFIX}${target_date}"_ | awk '{print $2}')

    echo "${S3_PREFIX}${prefix_date}"
}

download_succeeded_json() {
    local target_date="$1"
    local work_dir="$2"
    local prefix
    prefix=$(get_prefix "${target_date}")
    aws s3 sync --profile=dev2 "${prefix}result/" "${work_dir}" --exclude "*" --include "*SUCCEEDED_0.json"

    find "${work_dir}" -name 'SUCCEEDED_0.json' | while read -r file; do
        # 親ディレクトリのパスとUUID部分を取得
        parent_dir=$(dirname "${file}")

        if grep -q "enterpriseIds" "${file}"; then
            new_dir="enterprise"
        elif grep -q "candidateIds" "${file}"; then
            new_dir="candidate"
        else
            echo "No matching keywords in ${file}, skipping..."
            continue
        fi

        new_path=$(dirname "${parent_dir}")/${new_dir}

        # すでにディレクトリが存在しない場合のみ移動
        if [ ! -d "${new_path}" ]; then
            mv "${parent_dir}" "${new_path}"
            echo "Renamed ${parent_dir} to ${new_path}"
        else
            echo "Directory ${new_path} already exists, skipping..."
        fi
    done
}

parse_json() {
    local work_dir="$1"

    find "${work_dir}" -name SUCCEEDED_0.json -print0 | while IFS= read -r -d '' file; do
        resource_type=$(basename "$(dirname "${file}")")

        count=$(jq . "${file}" | grep 'status\\":500' | sed 's/^ *"Output": *"//' | wc -l || true)
        # status: 500のログを抽出し、resource_type ごとのファイルに出力
        output_file="${work_dir}/${resource_type}_${target_date}.log"
        jq . "${file}" | grep 'status\\":500' | sed 's/^ *"Output": *"//' | sed 's/",$//' | sed 's#\\##g' | jq . >"${output_file}" || echo "{}" >"${output_file}"

        printf "%-10s - Number of status 500 data: %d\n" "${resource_type}" "${count}"
    done
}

main() {
    local target_date
    target_date=$(get_target_date "${1:-}")

    local formatted_date="${target_date:0:4}/${target_date:4:2}/${target_date:6:2}"
    echo "Start download and parse daily batch result of ${formatted_date}"

    local work_dir
    work_dir=$(get_work_dir "${target_date}")
    rm -rf "${work_dir}"
    mkdir -p "${work_dir}"
    cd "${work_dir}"
    download_succeeded_json "${target_date}" "${work_dir}"
    parse_json "${work_dir}"

    echo "End download and parse daily batch result successfully."
    echo "Detailed result is under ${work_dir}/"
}

main "$@"
