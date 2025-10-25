# 1. ベースイメージとしてJava実行環境を持つMavenイメージを使用
FROM maven:3.9.6-eclipse-temurin-21

# 2. プロジェクトファイルをコンテナにコピー
COPY . /app
WORKDIR /app

# 3. Mavenを使ってプロジェクトをビルドし、WARファイルを生成
# ビルドが完了すると、/app/target/post_comment.war が生成されます。
# RenderがこのWARファイルを自動で検出して、起動することを期待します。
RUN mvn clean install -DskipTests

# 4. Renderの環境変数（PORT）を設定
ENV PORT 8080

# 5. 起動コマンド: 何も指定せず、Renderのデフォルトランナーに依存する
# Jetty Runnerを使わない構成に戻します。
# CMD ["java", "-jar", "...") などの記述はすべて削除します。
# RenderはWARファイルがあれば、自動的に起動を試みます。
# --------------------------------------------------------
# 起動コマンドは Render の環境に依存するため、ここでは空欄にする
CMD ["/bin/true"] 
# または CMD ["/usr/bin/dumb-init", "--"] 
# 一時的に/bin/trueを設定して、Dockerのビルドを終了させます。
# RenderはここでWARファイルを見つけるはずです。
