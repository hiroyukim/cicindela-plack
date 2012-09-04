# Cicindela

Livedoorのcicindelaをplackで動作するようにするものです。
githubにあるならforkしたかったんだけどないから作成してます。

コードの大本は以下のURLになります。

<http://labs.edge.jp/cicindela/>

現状Demoのテストデータを生成して取得するところまでは確認しています。

http://code.google.com/p/cicindela2/wiki/Demos

## 変更点

+ Handler/Recommend.pmを app_recommend.psgiにした
+ on memoryだとしょぼい環境だと動かないので innnodbへかえた


