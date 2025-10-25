# 1. ビルドステージ: MavenとJDK 21を使用
FROM maven:3.9.6-eclipse-temurin-21 AS build

# 2. アプリケーションコードをコンテナ内の作業ディレクトリにコピー
COPY . /app
WORKDIR /app

# 3. Mavenを使ってプロジェクトをビルドし、WARファイルを生成
RUN mvn clean install -DskipTests

# 4. 実行ステージ: 軽量なJRE 21イメージに切り替え
# TomcatやJettyなどのWebコンテナの実行環境を含める必要があります。
# ここでは、WARを実行するためにJetty Runnerを使用する構成にします。
FROM eclipse-temurin:21-jre-alpine

# Jetty Runner JARをダウンロード
# Renderが環境変数で指定するPORTを使用できるように-Djetty.port=$PORTを設定
RUN wget -q https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-runner/9.4.51.v20230217/jetty-runner-9.4.51.v20230217.jar -O /jetty-runner.jar

# ビルドステージで作成されたWARファイルをコピー
COPY --from=build /app/target/post_comment.war /post_comment.war

# Renderが設定するポートを待ち受ける
ENV PORT 8080
EXPOSE 8080

# 5. アプリケーションの起動コマンド
# Jetty Runnerを使って、コピーしたWARファイルを起動する
CMD java -Djetty.port=$PORT -jar /jetty-runner.jar /post_comment.war
