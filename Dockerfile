# 1. ビルドステージ: MavenとJDK 21を使用
FROM maven:3.9.6-eclipse-temurin-21 AS build

# 2. アプリケーションコードをコンテナ内の作業ディレクトリにコピー
COPY . /app
WORKDIR /app

# 3. Mavenを使ってプロジェクトをビルドし、WARファイルを生成
RUN mvn clean install -DskipTests

# 4. 実行ステージ: 軽量なJRE 21イメージに切り替え
FROM eclipse-temurin:21-jre-alpine

# Jetty Runner JARをダウンロード (Jetty Runnerのバージョンは安定版を使用)
RUN wget -q https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-runner/9.4.51.v20230217/jetty-runner-9.4.51.v20230217.jar -O /jetty-runner.jar

# ----------------------------------------------------
# 修正点: WARファイル名を /ROOT.war に変更
# ----------------------------------------------------
COPY --from=build /app/target/post_comment.war /ROOT.war

# Renderが設定するポートを待ち受ける
ENV PORT 8080
EXPOSE 8080

# 5. アプリケーションの起動コマンド
# Jetty Runnerを使って、ROOT.warファイルを起動する
CMD java -Djetty.port=$PORT -jar /jetty-runner.jar /ROOT.war
