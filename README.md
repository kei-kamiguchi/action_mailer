# herokuへのSendGridのアドオン追加できない
以下実行時のエラーの対処
```
$ heroku addons:create sendgrid:starter
```
https://diver.diveintocode.jp/questions/3895
# テキスト修正
- root設定をしないとherokuでエラーが起こる
