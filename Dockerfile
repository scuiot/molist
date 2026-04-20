# 使用官方轻量镜像，避免漏洞
FROM alpine:3.18

# 安装必要工具
RUN apk add --no-cache curl ca-certificates

# 下载 OpenList 最新版
RUN curl -L https://github.com/OpenListTeam/OpenList/releases/latest/download/openlist-linux-amd64.tar.gz -o openlist.tar.gz && \
    tar -zxvf openlist.tar.gz && \
    rm openlist.tar.gz && \
    chmod +x openlist

# 创建数据目录
RUN mkdir -p /opt/openlist/data

# 设置工作目录
WORKDIR /opt/openlist

# 暴露端口
EXPOSE 5244

# 设置环境变量
ENV PORT=5244

# 启动命令
CMD ["./openlist", "server"]
