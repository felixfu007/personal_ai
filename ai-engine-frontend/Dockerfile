# AI Engine 前端 Dockerfile
# 多階段構建：構建階段
FROM openjdk:21-jdk-slim AS builder

# 安裝 Maven
RUN apt-get update && apt-get install -y maven curl && rm -rf /var/lib/apt/lists/*

# 設定工作目錄
WORKDIR /app

# 複製 pom.xml 和 Maven wrapper
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# 賦予執行權限
RUN chmod +x mvnw

# 下載依賴（利用 Docker 快取）
RUN ./mvnw dependency:go-offline -B

# 複製源代碼
COPY src src

# 構建應用程式
RUN ./mvnw clean package -DskipTests -B

# 運行階段
FROM openjdk:21-jdk-slim

# 安裝運行時依賴
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 創建應用用戶
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 設定工作目錄
WORKDIR /app

# 從構建階段複製 JAR 文件（使用可執行的 JAR）
COPY --from=builder /app/target/*-exec.jar app.jar

# 設定文件權限
RUN chown -R appuser:appuser /app

# 切換到應用用戶
USER appuser

# 設定環境變數
ENV JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC -XX:+UseStringDeduplication -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 暴露端口
EXPOSE 8080

# 健康檢查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# 啟動命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]