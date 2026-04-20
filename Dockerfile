# 第一阶段：使用国内镜像加速
FROM alpine:3.18 AS downloader

# 使用国内 APK 镜像
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --no-cache curl

# 使用 GitHub 代理加速下载
RUN curl -L -o /tmp/openlist.tar.gz \
    https://ghproxy.com/https://github.com/OpenListTeam/OpenList/releases/latest/download/openlist-linux-amd64.tar.gz && \
    tar -xzf /tmp/openlist.tar.gz -C /tmp/ && \
    chmod +x /tmp/openlist

# 第二阶段：最终镜像
FROM alpine:3.18
COPY --from=downloader /tmp/openlist /usr/local/bin/openlist
RUN mkdir -p /opt/openlist/data
WORKDIR /opt/openlist
EXPOSE 5244
ENV PORT=5244
CMD ["openlist", "server"]
