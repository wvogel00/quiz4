# quiz4
マーク式の資格試験の勉強などを想定した，4択クイズアプリケーション．
(今は亡きセンター試験勉強ツールとしても使えたかもしれない．)
servantにを使ってweb APIとして提供

## 動作環境
- MacOS Catalina 10.15.6
- Ubuntu 16.04.6 LTS
CORS対策をしているはずだが，動作未検証

## API
- ```/quiz4```  
topページを返す．hogehoge.comで運用する場合，hogehoge.com/quiz4 で呼ばれる
- ```/quiz4/get```  
登録されているクイズの中の一つをJSON形式で返す
- ```/quiz4/make```  
新しくクイズを登録する．
- ~~```/quiz4/answer```~~
削除されました

クイズのJSONは，次の値を持つ
- statement ... 問題文
- a ... 選択肢A
- b ... 選択肢B
- c ... 選択肢C
- d ... 選択肢D
- answer ... 解答のなる選択肢の値を入力する ({'a'..'d'}のフィールドではなく，その内容を渡す)
- explanation ... 解説文．なくても良い

例えば，次のような形式で渡す．  
```
{
    "statement" : "このクイズは何択クイズ？"
    "a" : "1"
    "b" : "2"
    "c" : "3"
    "d" : "4"
    "answer" : "4"
    explanation : "4択クイズを楽しもう"
}
```

## スクリーンショット
下の画像はどれもhtml/cssで書かれており，servantの提供するAPIとは関係がない．動作検証のために作成した．  
全てをCUIアプリケーションで完結させることもできる．

```/quiz4``` で得られるhtml．webアプリとして運用する場合には必要なAPIだが，CUI上で使用する分には不要である．
<img width="568" alt="1" src="https://user-images.githubusercontent.com/991030/90571509-db89e400-e1ec-11ea-8e8a-c115a3fb5f57.png">

```/quiz4/get``` で取得した問題を表示するための画面．いわばゲーム画面．
<img width="538" alt="2" src="https://user-images.githubusercontent.com/991030/90571524-e5134c00-e1ec-11ea-9bc9-8e47835ffc64.png">

```/quiz4/make``` で問題をサーバーにpostする画面．今回の場合，jsで解説文以外に空白があるときはpostしないようにしているが，その状態でpostしたとしても，Servantコードではクイズを登録する際の結果を```RegisterResult```型で管理しており，その中の```LackAnyValue Text```から取り出された文字列が返ってくる．
<img width="486" alt="3" src="https://user-images.githubusercontent.com/991030/90571541-ee9cb400-e1ec-11ea-8e28-502fd215914b.png">

## memo
UbuntuにHDBC-postgreSQLをインストールするには先に次のコマンドで必要なパッケージを導入し，
環境を整えておく必要がある．
```
sudo apt-get install -y libghc-haskelldb-hdbc-postgresql-dev
```