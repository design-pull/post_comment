# 1. ビルドステージ: Maven + Java 21でアーティファクトと静的ファイルを確実に作る
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# ソースをコピーしてビルド
COPY pom.xml mvnw* ./
COPY .mvn .mvn
COPY src src
RUN mvn -B -DskipTests package

# ビルド成果物と静的ファイルを明示的に用意
RUN mkdir -p /app/build_webapp \
 && if [ -d /app/src/main/webapp ]; then cp -r /app/src/main/webapp /app/build_webapp/; fi

# 2. 実行ステージ: フルJREを使用
FROM eclipse-temurin:21-jre
ENV PORT 8080
EXPOSE 8080

# 最終イメージへ JAR と静的ファイルをコピー
# ワイルドカードでjar名の差分を吸収
COPY --from=build /app/target/*-SNAPSHOT.jar /app.jar
COPY --from=build /app/build_webapp /webapp

# 環境変数 PORT をアプリへ渡す場合は TomcatRunner 側で参照すること
CMD ["java", "-jar", "/app.jar"]
