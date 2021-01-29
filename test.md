1d1bee68154bb7d9
<!---- deploy info ---->
# SMTPサーバの構築

## 目的
- メール送信機能を自分の手で実装できるようになる

## 今回のテーマ
- 本番環境にメール送信機能を実装しましょう。

## 復習:ActionMailerとは
Railsには、メールを送信するために、 **ActionMailer** という仕組みがあります。
 **ActionMailer** は、これまで作成してきた **コントローラ** や **ビュー** と同じ要領でメールを送信させることができます。
HTMLやCSSは、HTTPを使用してレスポンスを送信してきましたが、 **ActionMailer** はSMTPという方式でメールを送信します。

### SMTP(Simple Mail Transfer Protocol)
SMTPはメール送信処理に使用するメール転送方式です。SMTPではメール送信用のサーバ（SMTPサーバ）を利用してメール転送処理を実行します。
そのため、Webアプリケーションにメール送信処理を実装するためにSMTPサーバを用意する必要があります。
[![https://diveintocode.gyazo.com/5f37dfef66242296553c3022dbb9e827](https://t.gyazo.com/teams/diveintocode/5f37dfef66242296553c3022dbb9e827.png)](https://diveintocode.gyazo.com/5f37dfef66242296553c3022dbb9e827)

### SendGridの利用
自前でSMTPサーバーを用意すると、手間がかかってしまいます。
そのため今回はクラウドメール送信サービスのひとつである **SendGrid** を使用します。

[![https://diveintocode.gyazo.com/a82cb128609b41da27e248fd6faa0d0a](https://t.gyazo.com/teams/diveintocode/a82cb128609b41da27e248fd6faa0d0a.png)](https://diveintocode.gyazo.com/a82cb128609b41da27e248fd6faa0d0a)

**SendGrid** を利用する方法は色々ありますが、今回はもっとも手軽に導入できるHerokuのアドオンを活用して導入していきます。

## Heroku（本番環境）のメール設定

### 1. Herokuの準備

今回使うのはHerokuのアドオンなので、その前段階としてHerokuが必要になります。
ここに至るまでに開発したアプリケーションを「Heroku入門3【herokuにデプロイするための方法について】」を参考にデプロイまでを必ず完了させてください。
**デブロイしていない状態で以降の作業を進めた場合、初めからアプリケーションを作り直さなくてはならなくなる可能性があるので、必ずHerokuへのデプロイが完了していることを確認しましょう。**

以下のコマンドを実行し、アプリケーションが表示されれば問題ございません。

```
$ heroku open
```

Windowsの場合は、以下のコマンドでHerokuドメインを確認し、ブラウザからアクセスしましょう。

```
$ heroku domains
```

### 2. プラグインの導入

Herokuを操作するためのソフトウェアをインストールし、次にプラグインの導入コマンドを打ちます。

```bash
$ heroku addons:create sendgrid:starter
# 略
```

下記のようにメッセージが表示され、処理が完了したことを確認しましょう。

[![https://diveintocode.gyazo.com/246335ea6eb399fdb9bb348e66e8aec7](https://t.gyazo.com/teams/diveintocode/246335ea6eb399fdb9bb348e66e8aec7.png)](https://diveintocode.gyazo.com/246335ea6eb399fdb9bb348e66e8aec7)

以下のようなエラーが表示された場合は、自分のHerokuアカウントにクレジットカード情報を登録してください。

**クレジットカードがない場合、もしくは登録をどうしてもしたく無い場合** 、このテキストの実装はしなくて構いません。一読した後、次のカリキュラムに進みましょう。
**letter_opener** まで使えるようにしておきましょう

[![https://diveintocode.gyazo.com/f3ab69307e5b0e077ce8fc2a064f760b](https://t.gyazo.com/teams/diveintocode/f3ab69307e5b0e077ce8fc2a064f760b.png)](https://diveintocode.gyazo.com/f3ab69307e5b0e077ce8fc2a064f760b)

また、その他にもHerokuの運用サービスのチェックの関係で `$ heroku addons:create sendgrid:starter` 実行時に以下のようなエラーが出るときがあります。

```ruby
The account "sample@gmail.com" is not permitted to install the
sendgrid add-on at this time. If you believe this is an error please
contact support and reference ID 2804e7a5-b3fa-4099-a763-2177d7386f3a when
opening an ticket.
```

平たく言うと、addonsを使わせて良いアカウントなのか判定ができなかったので、どうしてもこのアカウントでaddonsを使いたい場合は一度サポートセンターに問い合わせてほしいと言う意味の内容です。もしメールアドレスを複数所有しているのであればサポートに連絡する前にアカウントに登録しているメールアドレスを変更すると回避できる可能性があります。

このような場合も、無理にこのカリキュラムを実装する必要はありません。一読した後、次のカリキュラムに進みましょう。

サポートセンターに問い合わせると以下のような返信が来てサービスが使えるようになる可能性があります。
[Sendgrid](https://sendgrid.kke.co.jp/)

> It looks like your account was flagged by our anti-spam protections by mistake. This blocked your ability to add email add-ons your apps. That happens sometimes with new accounts. I have unblocked your account.

日本語訳：あなたのアカウントは誤って迷惑メール防止機能によってフラグが立てられたようです。これにより、あなたのアプリケーションに電子メールアドオンを追加する機能がブロックされました。それは時には新しいアカウントで発生します。あなたのアカウントのブロックを解除しました。

ここから下は、addonsが成功したという前提で進めていきます。

### 3. SendGridのアカウント登録

[SendGridのホームページ](https://sendgrid.com/pricing/)にアクセスし、「Start for free」をクリックします。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/19d058f71ed374f9d625fdcdc5258b2f.png)](https://diveintocode.gyazo.com/19d058f71ed374f9d625fdcdc5258b2f)

以下の画面が表示されるので、メールアドレスとパスワードを入力します。"私はロボットではありません"と"I accept the Terms of Service and have read the Services Privact Policy"にチェックを入れ、「Create Account」をクリックします。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/5784ac351d6d45accfa9e14b848550aa.png)](https://diveintocode.gyazo.com/5784ac351d6d45accfa9e14b848550aa)

SendGridから「Welcome to SendGrid! Confirm Your Email」というタイトルのメールが届くので、「Confirm Email Address」をクリックします。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/4f27ca2a845f1ff262e8a24ef3327783.png)](https://diveintocode.gyazo.com/4f27ca2a845f1ff262e8a24ef3327783)

アカウント登録フォームが表示されますので、必須項目を入力し、「Get Started!」をクリックします。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/f7e5ccf931a5730d758ee8f25a1bd0cd.png)](https://diveintocode.gyazo.com/f7e5ccf931a5730d758ee8f25a1bd0cd)

以下のように、ダッシュボードが表示されればアカウント登録完了です。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/5fc3aa877fc8232be12cd2425f284f24.png)](https://diveintocode.gyazo.com/5fc3aa877fc8232be12cd2425f284f24)

### 3. メールの差出人情報の登録

続いて、SendGridのメール機能を使用する上で必要となる、差出人情報の登録を行なっていきます。
差出人情報とはメールの送信元となるユーザ情報を指します。

画面の中央に表示されている、「Create a Single Sender」をクリックします。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/5fc3aa877fc8232be12cd2425f284f24.png)](https://diveintocode.gyazo.com/5fc3aa877fc8232be12cd2425f284f24)

登録フォームが表示されるので、画像例を参考に入力してください。
[参考リンク](https://sendgrid.kke.co.jp/docs/Tutorials/B_Marketing_Mail/marketing_campaigns1.html)
＊ 参考リンクをもとに後ほど編集を行う

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/9a8d47e79fd2f6b9a285392792b3afa0.png)](https://diveintocode.gyazo.com/9a8d47e79fd2f6b9a285392792b3afa0)

**なお、ここで設定するメールアドレスはアプリケーションの`app/mailers/application_mailer.rb`の`from`に設定したメールアドレスと同一のものを使用する必要があります。必ず同じメールアドレスを指定するようにしてください。**

入力が完了したら「Create」をクリックします。

SendGridから「Please Verify Your Sender Identity」というタイトルのメールが届くので、「Verify Sender Identity」をクリックします

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/d6c3e9c6181b63e02a3ebe2dde6f32bc.png)](https://diveintocode.gyazo.com/d6c3e9c6181b63e02a3ebe2dde6f32bc)

以上で、ユーザ情報（メールの差出人情報）の登録は完了です。

### 4. API Keyの作成

続いて、アプリケーションからSendGridを利用できるようにするために、API Keyの作成を行っていきます。
API Keyとは、外部サービスの利用許可を証明するための許可書のような役割を担います。ここでは、開発したアプリケーションから外部のメール送信サービスであるSendGridを利用するために、許可書を取得する作業だと解釈してください。

まず、サイドバーの「Setting」をクリックし、「API Keys」をクリックします。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/796222a54bb730c4daa9cf26efedecfd.png)](https://diveintocode.gyazo.com/796222a54bb730c4daa9cf26efedecfd)

画面に表示されている「Create API Key」をクリックします。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/b0b06343170f89edb0d7c3f0886a8522.png)](https://diveintocode.gyazo.com/b0b06343170f89edb0d7c3f0886a8522)

「API Key Name」にKeyの名前を入力します（Keyの名前は任意で構いません）。「API key Permissions」は、ここでは「Full Access」を選択し、「Create & View」をクリックします。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/8cd2912fa4449dc8dcb9b9cc126365a0.png)](https://diveintocode.gyazo.com/8cd2912fa4449dc8dcb9b9cc126365a0)

以下のように、画面にKeyが表示されます。ここで表示されているKeyは2度と確認することができないので、コピーしてメモ帳などに残しておきましょう。Keyが表示されている箇所をクリックすることでKeyがコピーされ、「Done」がクリックできるようになります。コピーできたら、「Done」をクリックします。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/d761ef58e04d8d73ff0fe5861059c467.png)](https://diveintocode.gyazo.com/d761ef58e04d8d73ff0fe5861059c467)

以下のように、API Keyが作成されていることが画面から確認できます。

[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/2f71dee944a7d2f18655976f9f9cd946.png)](https://diveintocode.gyazo.com/2f71dee944a7d2f18655976f9f9cd946)

以上でAPI Keyの作成は完了です。

### 5. アプリケーションからAPI Keyを利用できるようにする

API Keyの作成ができましたので、ターミナルに戻って、作成したAPI Keyの設定を行なっていきます。

SendGridのAPI Keyは重要な個人情報ですので、外部から閲覧できないようHeroku上の環境変数としてセットします。`heroku config:set`コマンドを使用することで、Heokuの環境変数を設定することができます。以下のコマンドを順に実行しましょう。
1つ目のコマンドは、変更せずにそのまま実行してください。2つ目のコマンドでは、"作成したAPI Key"の部分を、メモしておいたAPI Keyに置き換えて実行してください。

```
$ heroku config:set SENDGRID_USERNAME=apikey
$ heroku config:set SENDGRID_PASSWORD=作成したAPI Key
```

環境変数が正しく設定されたか確認してみましょう。

```
$ heroku config
# 略
SENDGRID_USERNAME: apikey
SENDGRID_PASSWORD: 設定された値
```

これで、Heroku側が **SENDGRID_USERNAME** と **SENDGRID_PASSWORD** の値を保持することができ、この値を用いてSendGridとの接続ができるようになります。

続いて、アプリケーション側の設定を行なっていきます。

`config/environments/production.rb`に以下のコードを追記してください。
**`https://hogehoge-fugafuga.herokuapp.com`の部分は、自分のアプリケーションのHerokuドメインに置き換えてください。**
Herokuドメインは、`heroku domains`コマンドを実行することで確認できます。

```ruby
Rails.application.configure do
  # 省略

  # 追記
  config.action_mailer.default_url_options = { host: 'hogehoge-fugafuga.herokuapp.com' }
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    domain: "heroku.com",
    address: "smtp.sendgrid.net",
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }
end
```

以上で、アプリケーションからAPI Keyを利用する設定は完了です。

### 6. Herokuへ変更内容を反映

これまでに変更したコードをHerokuのリモートリポジトリに反映していきます。
下記の手順に従ってコマンドを実行していきましょう。

```
# ワーキング・ツリーの中で変更されたコンテンツ(新規、編集、削除したファイル)を見つけてインデックス(Git管理の対象)に追加
$ git add -A
# 開発環境でコンテンツの修正・追加・削除等を行い、ローカルリポジトリに変更履歴を記録
$ git commit -m "任意のコメント"
# Herokuのアプリにローカルリポジトリにある変更履歴をアップロード
$ git push heroku master
# Herokuのサーバ上にアプリケーションのテーブルを作成、マイグレーション実行（すでに実行済みであれば不要）
$ heroku run rails db:migrate
```

### お問い合わせをしてみましょう。

今までの実装が上手くできているか、 `/contacts/new` にアクセスをして、お問い合わせをして確認しましょう。

[![https://diveintocode.gyazo.com/2636fc7ef3521cf3d9cbeef9fd900b89](https://t.gyazo.com/teams/diveintocode/2636fc7ef3521cf3d9cbeef9fd900b89.png)](https://diveintocode.gyazo.com/2636fc7ef3521cf3d9cbeef9fd900b89)

`contact_mailer.rb` で設定したメールアドレスにお問い合わせ完了メールが届いているか、確認をしましょう。

**確認**

[![https://diveintocode.gyazo.com/82dc1961967a963b1fa6c3d7d49db7d0](https://t.gyazo.com/teams/diveintocode/82dc1961967a963b1fa6c3d7d49db7d0.png)](https://diveintocode.gyazo.com/82dc1961967a963b1fa6c3d7d49db7d0)

## SendGridでメールが届かない場合のチェックリスト
どうしてもメールが届かない場合には、以下の内容をチェックしてみてください。

### 1、herokuへのSendGridのアドオン追加ができているか

```bash
$ heroku addons:create sendgrid:starter
```

コマンドで追加ができていますか？
herokuに対してクレジットカード登録をしておくことが前提です。

### 2、herokuにSENDGRID_USERNAMEやSENDGRID_PASSWORDが登録されているか

```bash
$ heroku config
```

で登録の有無や内容確認ができます。

### 3、config/environments/production.rbファイルに設定が記載されているか
※ HerokuにデプロイしたアプリケーションのURLが `https://hogehoge-fugafuga.herokuapp.com/` であると仮定します

`config/environments/production.rb`

```ruby
config.action_mailer.default_url_options = { host: 'hogehoge-fugafuga.herokuapp.com' }
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings =
{
 user_name: ENV['SENDGRID_USERNAME'],
 password: ENV['SENDGRID_PASSWORD'],
 domain: "heroku.com",
 address: "smtp.sendgrid.net",
 port: 587,
 authentication: :plain,
 enable_starttls_auto: true
}
```

### 4、herokuはメールを送る動きをしているか

```bash
$ heroku logs -t
```

上記のコマンドを実行してログを抽出し、メール送信を実行しているか調べてみましょう。
もしかすると、ログの中にエラーを発見できるかもしれません。

### 5、メイラーやメール送信メソッドの設定は正しいか
これまでに行ったことを見直しましょう。

### 6、SendGridのアカウントが停止になっていないか
[こちら](https://app.sendgrid.com/login) のサイトにアクセスし、SendGridのUSERNAMEとPASSWORDでログインができるか確認して下さい。

アクセス後、以下のようなメッセージが出ている場合、SendGridアカウントが凍結されていることになります。
[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/48bedf8e6962c7e40f04e422605c1f30.png)](https://diveintocode.gyazo.com/48bedf8e6962c7e40f04e422605c1f30)
その場合は、SendGridのサポート窓口へ解除依頼をしてください。

**解除依頼方法**
1. [こちら](https://app.sendgrid.com/login) のサイトにアクセスし、SendGridのUSERNAMEとPASSWORDでログインする
1. 画面右下のSupportをクリック
[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/d496dfbf6462c6b5cc1f318122ca7050.png)](https://diveintocode.gyazo.com/d496dfbf6462c6b5cc1f318122ca7050)
1. Contact Supprtをクリック
[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/45b3c2a1f59942b99881788263e44fbd.png)](https://diveintocode.gyazo.com/45b3c2a1f59942b99881788263e44fbd)
1. suspendedと入力しContinueをクリック
[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/beba43910d889ccc56f359d4dd94a051.png)](https://diveintocode.gyazo.com/beba43910d889ccc56f359d4dd94a051)
1. .画面下のOpen a Support Requestをクリック
[![Image from Gyazo](https://t.gyazo.com/teams/diveintocode/e83b948b1a8c29ed7b91acc0a90ddaeb.png)](https://diveintocode.gyazo.com/e83b948b1a8c29ed7b91acc0a90ddaeb)
1. 入力画面が出るので、以下のように入力。
`Subject`
```
Request for unfreezing account
```
`Description`
```
Hello, SendGrid Support Team
This is ご自身のお名前 from Japan.
I am using SendGrid for my Web application with Heroku add on now.
But somehow my account has been suspended.
I am not sure why it happened.
Could you please suggest any solutions or tell me why my account has been suspended?
I appreciate your help in advance.
Thanks,
```
1. Submitをクリックして完了です。メールでの返答を待ちましょう。

## 2回目以降に作成したメール機能つきのアプリケーションをHerokuにデプロイする手順

### Herokuにログイン

以下のコマンドでHerokuにログイン

```bash
$ heroku login
```

### Heroku appを作成

以下のコマンドでHeroku appを作成

```bash
$ heroku create
```

### SendGridの情報をHeroku appに登録

```bash
$ heroku config:set SENDGRID_API_KEY=SendGridのAPI_KEY
$ heroku config:set SENDGRID_USERNAME=取得したSENDGRID_USERNAME
$ heroku config:set SENDGRID_PASSWORD=取得したSENDGRID_PASSWORD
```

### SendGrid 登録情報の確認方法

SendGridはブラウザから **取得したSENDGRID_PASSWORD** 、 **API_KEY** を確認することができません。
そのため以下のような確認方法になります。

- 以前に作成したアプリケーションの **.env** ファイルから確認する
- 以前に作成したアプリケーションのHeroku環境変数から確認する
  1. 以前に作成したアプリケーションのディレクトリに、ターミナルで移動
  1. Herokuにログイン `$ heroku login`
  1. 環境変数を確認 `$ heroku config`
- PCのメモから確認する

#### 注意

**SendGridアドオンのプロビジョニングはしません** （以下のコマンドは打たないでください。）

```bash
$ heroku addons:create sendgrid:starter
```

### Herokuにデプロイ

```bash
$ git add .
$ git commit -m '任意のコメント'
$ git push heroku master
$ heroku run rails db:migrate
$ heroku open
```

## まとめ

- SMTPでメールを送信する場合には、SMTP認証が必須となる。
- Herokuのアドオンを用いることで、手軽にメール送信機能を実装できる。

## お疲れ様でした。
