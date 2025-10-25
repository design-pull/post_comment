# 1. ベースイメージとしてJava実行環境とTomcat/Jettyの実行環境を持つMavenイメージを使用
FROM maven:3.9.4-eclipse-temurin-21-full AS build

# 2. プロジェクトファイルをコンテナにコピー
COPY . /app
WORKDIR /app

# 3. Mavenを使ってプロジェクトをビルドし、WARファイルを生成 (RenderのBuild Commandに相当)
RUN mvn clean install -DskipTests

# 4. 実行用の軽量なベースイメージに切り替える
FROM eclipse-temurin:21-jre-alpine

# 5. WARファイルを実行するために必要なWebサーバー（JettyやTomcat）を実行可能な状態にする

# Renderは自動でWARファイルを検出して実行しようとするため、
# WARファイルをWEBAPPSフォルダに配置する設定が最もシンプルです。
# ただし、Java Web AppのデプロイはRender上で複雑なため、Jettyで直接実行する構成を推奨します。

# Jetty Runnerを使ってWARを実行する場合
# Jetty Runner JARをダウンロードし、WARを実行する
# RUN wget -q https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-runner/9.4.44.v20210927/jetty-runner-9.4.44.v20210927.jar
# ENV PORT 8080
# EXPOSE 8080
# CMD java -jar jetty-runner-9.4.44.v20210927.jar /app/target/*.war

# 暫定的に、WARを配置するシンプルな構成 (Renderが自動で実行することを期待)
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# デフォルトのポートを使用
ENV PORT 8080

# 必要なコマンドの起動（Renderの環境によって異なるため、この部分はトライ＆エラーが必要です）
# CMD ["java", "-jar", "tomcat-runner.jar"]