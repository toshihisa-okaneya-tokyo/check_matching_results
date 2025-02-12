#!/bin/bash

set -euo pipefail

S3_PREFIX="s3://techkitchen-cuisine-development2/matching/batch/"
WORK_DIR="/tmp/check_matching_results"

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

get_prefix() {
    local target_date="$1"
    local prefix_date
    prefix_date=$(aws s3 ls --profile=dev2 "${S3_PREFIX}${target_date}"_ | awk '{print $2}')

    echo "${S3_PREFIX}${prefix_date}"
}

download_succeeded_json() {
    local target_date="$1"
    rm -rf ${WORK_DIR}
    mkdir -p ${WORK_DIR}

    local prefix
    prefix=$(get_prefix "${target_date}")
    aws s3 sync --profile=dev2 "${prefix}result/" ${WORK_DIR} --exclude "*" --include "*SUCCEEDED_0.json"
}

main() {
    local target_date
    target_date=$(get_target_date "${1:-}")

    local formatted_date="${target_date:0:4}/${target_date:4:2}/${target_date:6:2}"
    echo "Start download and parse daily batch result of ${formatted_date}"

    download_succeeded_json "${target_date}"
    find ${WORK_DIR} -name SUCCEEDED_0.json -print0 | while IFS= read -r -d '' file; do
        # 親ディレクトリ名（UUID）を抽出
        uuid=$(basename "$(dirname "${file}")")

        count=$(jq . "${file}" | grep 'status\\":500' | sed 's/^ *"Output": *"//' | wc -l)
        # jq と grep の結果を UUID ごとのファイルに出力
        jq . "${file}" | grep 'status\\":500' | sed 's/^ *"Output": *"//' | sed 's/",$//' | sed 's#\\##g' | jq . >"${WORK_DIR}/result_${uuid}_${target_date}.log"

        echo "UUID: ${uuid} - Number of status 500 data: ${count}"
    done
    echo "End download and parse daily batch result successfully"
    echo "Result detail is under ${WORK_DIR}"
}

main "$@"
