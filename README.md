# Action Mailer
## 導入
1. Mailerに必要なファイルを生成
```
$ rails generate mailer クラス名 メソッド名
# メソッド名は省略できます

# サンプル
$ rails g mailer ContactMailer
```
2. メソッドを定義
[app/mailers/クラス名.rb]

[app/mailers/contact_mailer.rb]
```
class ContactMailer < ApplicationMailer
  def contact_mail(contact)
    @contact = contact
    mail to: "自分のメールアドレス", subject: "お問い合わせの確認メール"
  end
end
```
3. [app/views/クラス名/メソッド名.html.erb]を作成し、Viewの内容を記述

[app/views/contact_mailer/contact_mail.html.erb]
```
<h1>お問い合わせが完了しました！</h1>
<h4>name: <%= @contact.name %></h4>
<h4>お問い合わせ内容の確認</h4>
<p>content: <%= @contact.content %></p>
```
4. メイラーを呼び出したい箇所に、以下を追記
```
クラス名.メソッド名(引数).deliver

# サンプル
ContactMailer.contact_mail(@contact).deliver
```
## 本番環境におけるメール設定
＊herokuへのデプロイが完了しているものとする

1. sendgridアドオンを追加
<br>＊アドオンとは、ソフトウェアに後から追加できる拡張機能のことで、プラグインとは拡張機能そのものを指す
```
$ heroku addons:create sendgrid:starter
```
2. ドメインの確認(~.herokuapp.comがドメイン)
```
$ heroku domains
```
3. [config/environments/production.rb]に以下を追記
```
Rails.application.configure do
  # 省略
  # 追記
  config.action_mailer.default_url_options = { host: 'アプリのドメイン' }
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    domain: "heroku.com",
    address: "smtp.SendGrid.net",
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }
end
```
4. SendGridのUSERNAMEとPASSWORDを、Heroku上に環境変数として設定
```
$ heroku config:get SENDGRID_USERNAME
# USERNAMEが表示される
$ heroku config:get SENDGRID_PASSWORD
# PASSWORDが表示される

$ heroku config:set SENDGRID_USERNAME="取得したSENDGRID_USERNAME"
$ heroku config:set SENDGRID_PASSWORD="取得したSENDGRID_PASSWORD"
```
5. コミットする
6. herokuにpush
```
$ git push heroku master 
```
## letter_opener_webの設定
### 開発環境
1. gem'letter_opener_web'をインストール
2. [config/environments/development.rb]に追記
```
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
config.action_mailer.delivery_method = :letter_opener_web
```
3. [config/routes.rb]の設定
```
if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
```
4. [http://localhost:3000/letter_opener]にアクセスすることで、メールの内容を確認することができる
### 本番環境
1. [config/environments/production.rb]に以下を追記
```
config.action_mailer.delivery_method = :letter_opener_web
```
2. [routes.rb]の設定(すでに開発環境で使用していた場合は、ifによる条件定義を以下のように削除)
```
mount LetterOpenerWeb::Engine, at: "/letter_opener"
```
＊gem'letter_opener_web'の記述位置に注意

# herokuへのSendGridのアドオン追加できない
以下実行時のエラーの対処
```
$ heroku addons:create sendgrid:starter
```
https://diver.diveintocode.jp/questions/3895


##sendgridへの解除依頼
`heroku config`の`SENDGRID_PASSWORD`と`SENDGRID_USERNAME`の内容で以下のurlからログイン
https://app.sendgrid.com/login

1.画面右下のSupportをクリック

2.Contact Supprtをクリック

3.「suspended」と入力し「Continue」をクリック

4.画面下の「Open a Support Request」をクリック

5.入力画面が出るので、以下のように入力。

「Subject」
Request for unfreezing account

「Description」
Hello, SendGrid Support Team

This is ご自身のお名前 from Japan.
I am using SendGrid for my Web application with Heroku add on now.
But somehow my account has been suspended.
I am not sure why it happened.
Could you please suggest any solutions or tell me why my account has been suspended?
I appreciate your help in advance.
　
Thanks,

6.Submitをクリックして完了です。メールでの返答を待ちましょう。
