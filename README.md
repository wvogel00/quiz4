# quiz4
マーク式の資格試験の勉強などを想定した，4択クイズアプリケーション．
(今は亡きセンター試験勉強ツールとしても使えたかもしれない．)
servantによりweb APIとして提供

## 動作環境
MacOS Catalina 10.15.6
Ubuntu 10.xx

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

## 導入手順
### mac
install mysql  
```brew install mysql```  
