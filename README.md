# check_matching_results

dailyで自動実行されるstep functionの全件マッチング処理結果に含まれるstatus 500の数を集計するscript

## 使用方法

- 事前準備
  - このgit repositoryをgit clone
  - git cloneした先の`check_matching_results.sh`が存在するディレクトリにパスを通す
- 結果取得
  - 前日分取得
    - `check_matching_results.sh`
      - 注意点
        - 関連ファイルが出力される作業用ディレクトリ(`/tmp/check_matching_results/{YYYYMMDD}`)配下で実行すると正常動作しない
      - 出力例

          ```txt
          /tmp/check_matching_results check_matching_results.sh
          Start download and parse daily batch result of 2025/02/11
          download: s3://techkitchen-cuisine-development2/matching/batch/20250211_150347/result/0eda4d91-061f-4fed-aacc-48207b0ba4b3/SUCCEEDED_0.json to 20250211/0eda4d91-061f-4fed-aacc-48207b0ba4b3/SUCCEEDED_0.json
          download: s3://techkitchen-cuisine-development2/matching/batch/20250211_150347/result/d7ef12e1-1408-4248-b927-ebe946cdb611/SUCCEEDED_0.json to 20250211/d7ef12e1-1408-4248-b927-ebe946cdb611/SUCCEEDED_0.json
          Renamed /tmp/check_matching_results/20250211/0eda4d91-061f-4fed-aacc-48207b0ba4b3 to /tmp/check_matching_results/20250211/candidate
          Renamed /tmp/check_matching_results/20250211/d7ef12e1-1408-4248-b927-ebe946cdb611 to /tmp/check_matching_results/20250211/enterprise
          candidate  - Number of status 500 data: 4
          enterprise - Number of status 500 data: 260
          End download and parse daily batch result successfully.
          Detailed result is under /tmp/check_matching_results/20250211/
          ```

      - status 500のログを抽出したものは`/tmp/check_matching_results/{YYYYMMDD}`配下の`{resource_type}_{YYYYMMDD}.log`に出力される
        - ファイル名の例
          - `candidate_20250211.log`
  - 日付指定で取得（年は実行時と同じ。去年の物が必要な場合はソースを見て修正）
    - 実行コマンド(`{MMDD}`部分は置き換え)
      - `check_matching_results.sh {MMDD}`
      - 例
        - `check_matching_results.sh 0210`
      - 日付指定以外はオプションなしの場合と同様の挙動
