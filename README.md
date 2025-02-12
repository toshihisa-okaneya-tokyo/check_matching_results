# check_matching_results

dailyで自動実行されるstep functionの全件マッチング処理結果に含まれるstatus 500の数を集計するscript

## 使用方法

- 事前準備
  - このgit repositoryをgit clone
  - git cloneした先の`check_matching_results.sh`が存在するディレクトリにパスを通す
- 結果取得
  - 前日分取得
    - `check_matching_results.sh`
      - 出力例(2025/02/12実行時)

          ```txt
          ~ check_matching_results.sh
          Start download and parse daily batch result of 2025/02/11
          download: s3://techkitchen-cuisine-development2/matching/batch/20250211_150347/result/0eda4d91-061f-4fed-aacc-48207b0ba4b3/SUCCEEDED_0.json to ../../tmp/check_matching_results/0eda4d91-061f-4fed-aacc-48207b0ba4b3/SUCCEEDED_0.json
          download: s3://techkitchen-cuisine-development2/matching/batch/20250211_150347/result/d7ef12e1-1408-4248-b927-ebe946cdb611/SUCCEEDED_0.json to ../../tmp/check_matching_results/d7ef12e1-1408-4248-b927-ebe946cdb611/SUCCEEDED_0.json
          UUID: 0eda4d91-061f-4fed-aacc-48207b0ba4b3 - Number of status 500 data: 4
          UUID: d7ef12e1-1408-4248-b927-ebe946cdb611 - Number of status 500 data: 260
          End download and parse daily batch result successfully
          Result detail is under /tmp/check_matching_results
          ```

      - status 500のログを抽出したものは`/tmp/check_matching_results/`配下の`result_{uuid}_{YYYYMMDD}.log`に出力される
        - ファイル名の例
          - `result_d7ef12e1-1408-4248-b927-ebe946cdb611_20250211.log`
  - 日付指定で取得（年は実行時と同じ。去年の物が必要な場合はソースを見て修正）
    - 実行コマンド(`{MMDD}`部分は置き換え)
      - `check_matching_results.sh {MMDD}`
      - 例
        - `check_matching_results.sh 0210`
      - 日付指定以外はオプションなしの場合と同様の挙動
