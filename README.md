# herokuへのSendGridのアドオン追加できない
以下実行時のエラーの対処
```
$ heroku addons:create sendgrid:starter
```
https://diver.diveintocode.jp/questions/3895
# 注意点
本番環境でのletter_openerの使用する際、[routes.rb]と[Gemfile]の記述に注意
# テキスト修正
- root設定をしないとherokuでエラーが起こる
