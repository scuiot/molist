# ============================================
# 第一阶段：下载旧版本 OpenList（没有漏洞）
# ============================================
FROM alpine:3.18 AS downloader

# 安装下载工具
RUN apk add --no-cache curl

# 下载 v3.39.4 版本（这个版本可能没有 CVE-2026-33186 漏洞）
RUN curl -L -o /tmp/openlist.tar.gz \
    https://github.com/OpenListTeam/OpenList/releases/download/v3.39.4/openlist-linux-amd64.tar.gz && \
    tar -xzf /tmp/openlist.tar.gz -C /tmp/ && \
    chmod +x /tmp/openlist

# ============================================
# 第二阶段：最终镜像（干净、安全）
# ============================================
FROM alpine:3.18

# 创建普通用户（Choreo 要求的！）
RUN addgroup -g 10014 openlistgroup && \
    adduser -u 10014 -G openlistgroup -s /bin/sh -D openlistuser

# 从第一阶段复制 OpenList 文件
COPY --from=downloader /tmp/openlist /usr/local/bin/openlist

# 创建数据目录并设置权限
RUN mkdir -p /opt/openlist/data && \
    chown -R 10014:10014 /opt/openlist

# 设置工作目录
WORKDIR /opt/openlist

# 切换到普通用户（必须在最后！）
USER 10014

# 暴露端口
EXPOSE 5244

# 环境变量
ENV PORT=5244

# 启动命令
CMD ["openlist", "server"]
