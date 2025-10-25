# 1. ビルドステージ: MavenとJava 21を使ってアプリケーションの実行可能JARを作成する
FROM maven:3.9.6-eclipse-temurin-21 AS build

# プロジェクトファイルをコンテナにコピーし、ビルド（実行可能JARがtargetディレクトリに生成される）
COPY . /app
WORKDIR /app
# ビルド時にTomcat Embeddedの設定が適用され、すべての依存関係が組み込まれる
RUN mvn clean install -DskipTests

# ----------------------------------------------------------------------

# 2. 実行ステージ: 軽量なJRE 21イメージに切り替える
FROM eclipse-temurin:21-jre-alpine

# ビルドステージから実行可能JARファイルだけをコピー
# ファイル名はpom.xmlの<artifactId>-<version>.jarに従う
COPY --from=build /app/target/post_comment-1.0-SNAPSHOT.jar /app.jar

# Renderが指定する環境変数PORT（通常8080）をDockerポートに公開
ENV PORT 8080
EXPOSE 8080

# 3. アプリケーションの起動コマンド: 実行可能JARを直接起動
# TomcatRunner.java内でPORT変数を読み込み、Tomcatを起動します。
CMD ["java", "-jar", "/app.jar"]
