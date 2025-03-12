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
          ~/ghq/github.com/toshihisa-okaneya-tokyo/check_matching_results git:(main) check_matching_results.sh
          Start download and parse daily batch result of 2025/03/11
          download: s3://techkitchen-cuisine-development2/matching/batch/20250311_150345/result/523ba50e-3b8b-4bfe-aa75-025d0f1ba3de/manifest.json to 523ba50e-3b8b-4bfe-aa75-025d0f1ba3de/manifest.json
          download: s3://techkitchen-cuisine-development2/matching/batch/20250311_150345/result/e3488f56-7c81-4b0a-8a2c-5985b16ca6b5/manifest.json to e3488f56-7c81-4b0a-8a2c-5985b16ca6b5/manifest.json
          download: s3://techkitchen-cuisine-development2/matching/batch/20250311_150345/result/523ba50e-3b8b-4bfe-aa75-025d0f1ba3de/SUCCEEDED_0.json to 523ba50e-3b8b-4bfe-aa75-025d0f1ba3de/SUCCEEDED_0.json
          download: s3://techkitchen-cuisine-development2/matching/batch/20250311_150345/result/e3488f56-7c81-4b0a-8a2c-5985b16ca6b5/SUCCEEDED_0.json to e3488f56-7c81-4b0a-8a2c-5985b16ca6b5/SUCCEEDED_0.json
          Renamed /tmp/check_matching_results/20250311/e3488f56-7c81-4b0a-8a2c-5985b16ca6b5 to /tmp/check_matching_results/20250311/enterprise
          Renamed /tmp/check_matching_results/20250311/523ba50e-3b8b-4bfe-aa75-025d0f1ba3de to /tmp/check_matching_results/20250311/candidate
          candidate  - Number of status 500 data: 0
          enterprise - Number of status 500 data: 1
          End download and parse daily batch result successfully.
          Detailed result is under /tmp/check_matching_results/20250311/
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
- 目検での確認手順(status 500があった場合)
  - 当該matchingResourceのデータ構造が異常でないか確認
    - candidatesの場合
      - rawSkill回答しているのに、WorkStyle未回答で0Hopも未設定
      - desiredWorkPrefecturesが空
    - enterpriseの場合
      - workPrefecturesが東京都以外
  - 上記で確認出来ない場合
    - `s3://techkitchen-cuisine-development2/matching/batch/(日付)/root_jobs.json`をダウンロード
    - 例
      - `s3://techkitchen-cuisine-development2/matching/batch/20250227_150345/root_jobs.json`
    - fail後にデータが変更されていないことを確認
      - root_jobs.jsonとdev2 mongo上の当該matchingResourceのrevisionに差分がないことを確認
    - 担当者に当該matchingResourceのexpandedデータを連携して確認依頼
      - [cuisine.gitのtest_create_expand_resource.py](https://github.com/gachapin-pj/cuisine/blob/develop-day2/matching-processor/tests/test_create_expand_resource.py)を適宜編集してexpandedデータ出力

## 関連情報

- jsonを出力するstep functionのログが必要な場合はaws console参照
  - `https://ap-northeast-1.console.aws.amazon.com/states/home?region=ap-northeast-1#/statemachines/view/arn%3Aaws%3Astates%3Aap-northeast-1%3A009160044068%3AstateMachine%3Acuisine_batch_step_functions?type=standard`
