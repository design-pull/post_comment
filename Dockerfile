# 1. ビルドステージ: MavenとJava 21を使って実行可能JARを作成する
FROM maven:3.9.6-eclipse-temurin-21 AS build

# プロジェクトファイルをコンテナにコピーし、ビルドを実行
# pom.xmlとTomcatRunner.javaを使ってpost_comment-1.0-SNAPSHOT.jarが作成されます。
COPY . /app
WORKDIR /app
RUN mvn clean install -DskipTests

# ----------------------------------------------------------------------

# 2. 実行ステージ: 安定したJRE 21イメージに切り替える
# JNIエラーを回避するため、alpineベースではないフルバージョンのJREを使用
FROM eclipse-temurin:21-jre

# Renderが指定する環境変数PORT（通常8080）をDockerポートに公開
ENV PORT 8080
EXPOSE 8080

# ビルドステージから作成した実行可能JARファイルをコピー
COPY --from=build /app/target/post_comment-1.0-SNAPSHOT.jar /app.jar
COPY --from=build /app/src/main/webapp /webapp  # 静的ファイル (JSP/HTML) をコピー

# 3. アプリケーションの起動コマンド: 実行可能JARを起動
# $PORT変数を使ってTomcatRunnerを起動します
CMD ["java", "-jar", "/app.jar"]
