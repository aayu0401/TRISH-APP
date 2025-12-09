FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN ./mvnw -v || true
# To build locally, user should run: mvn -DskipTests package
CMD ["java", "-jar", "/app/target/trish-backend-0.0.1-SNAPSHOT.jar" ]
