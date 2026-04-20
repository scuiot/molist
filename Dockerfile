# 第一阶段：下载文件（临时用，不会留在最终镜像里）
FROM alpine:3.18 AS downloader

# 安装下载工具
RUN apk add --no-cache curl

# 下载 OpenList
RUN curl -L -o /tmp/openlist.tar.gz \
    https://github.com/OpenListTeam/OpenList/releases/latest/download/openlist-linux-amd64.tar.gz && \
    tar -xzf /tmp/openlist.tar.gz -C /tmp/ && \
    chmod +x /tmp/openlist

# 第二阶段：最终镜像（干净的，没有下载工具）
FROM alpine:3.18

# ========== 创建普通用户（Choreo 要求的！）==========
# 创建用户组，编号 10014
RUN addgroup -g 10014 openlistgroup

# 创建用户，编号 10014，加入刚才的组
RUN adduser -u 10014 -G openlistgroup -s /bin/sh -D openlistuser
# =====================================================

# 从第一阶段复制 OpenList 文件
COPY --from=downloader /tmp/openlist /usr/local/bin/openlist

# 创建数据目录
RUN mkdir -p /opt/openlist/data

# 把数据目录的权限给普通用户
RUN chown -R 10014:10014 /opt/openlist

# 设置工作目录
WORKDIR /opt/openlist

# ========== 切换到普通用户（必须在最后！）==========
USER 10014
# =====================================================

# 暴露端口
EXPOSE 5244

# 环境变量
ENV PORT=5244

# 启动命令
CMD ["openlist", "server"]
