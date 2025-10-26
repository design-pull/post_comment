# build stage: Maven + Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN mvn -B -DskipTests package

RUN mkdir -p /app/build_webapp \
 && if [ -d /app/src/main/webapp ]; then cp -r /app/src/main/webapp/* /app/build_webapp/; fi \
 && mkdir -p /app/build_webapp/WEB-INF/lib \
 && cp /app/target/*-SNAPSHOT-shaded.jar /app/build_webapp/WEB-INF/lib/post_comment.jar || true

FROM eclipse-temurin:21-jre
ENV PORT 8080
EXPOSE 8080
COPY --from=build /app/target/*-SNAPSHOT*.jar /app.jar
COPY --from=build /app/build_webapp /webapp
CMD ["java", "-jar", "/app.jar"]
