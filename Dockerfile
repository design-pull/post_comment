# build stage: Maven + Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# リポジトリ全体をコピー（.dockerignore を尊重）
COPY . .

# Mavenビルド（テストスキップ）
RUN mvn -B -DskipTests package

# 静的webapp を確保（存在する場合）
RUN mkdir -p /app/build_webapp \
 && if [ -d /app/src/main/webapp ]; then cp -r /app/src/main/webapp /app/build_webapp/; fi

# runtime stage: full JRE 21
FROM eclipse-temurin:21-jre
ENV PORT 8080
EXPOSE 8080

COPY --from=build /app/target/*-SNAPSHOT*.jar /app.jar
COPY --from=build /app/build_webapp /webapp

CMD ["java", "-jar", "/app.jar"]
