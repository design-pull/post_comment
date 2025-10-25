# 1. ビルドステージ: MavenとJava 21を使ってWARファイルを作成する
FROM maven:3.9.6-eclipse-temurin-21 AS build

# Jetty Runner (アプリケーションを起動するための実行可能JAR) をダウンロード
# 実行ステージで利用するために、このステージでダウンロードします
RUN wget -q https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-runner/9.4.51.v20230217/jetty-runner-9.4.51.v20230217.jar -O /jetty-runner.jar

# プロジェクトファイルをコンテナにコピーし、ビルド
COPY . /app
WORKDIR /app
RUN mvn clean install -DskipTests

# ----------------------------------------------------------------------

# 2. 実行ステージ: 軽量なJRE 21イメージに切り替える
FROM eclipse-temurin:21-jre-alpine

# ビルドステージから必要なファイルだけをコピー
# A. ビルドされたWARファイルをROOT.warとしてコピー
COPY --from=build /app/target/post_comment.war /ROOT.war
# B. Jetty RunnerのJARファイルをコピー
COPY --from=build /jetty-runner.jar /jetty-runner.jar

# Renderが指定する環境変数PORT（通常8080）をDockerポートに公開
ENV PORT 8080
EXPOSE 8080

# 3. アプリケーションの起動コマンド: Jetty Runnerを使い、ルートコンテキストを指定して実行
# $PORT変数を使ってRenderの要求に合わせます
CMD ["java", "-Djetty.port=$PORT", "-jar", "/jetty-runner.jar", "/ROOT.war", "/"]
