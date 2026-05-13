#!/bin/bash
set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  iTrade.icu Docker 自动化部署脚本              ${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""

# ==========================================
# 1. 自动识别设备 (OS & 架构)
# ==========================================
echo -e "${BLUE}=> [1/6] 正在检测系统环境...${NC}"
OS="$(uname -s)"
ARCH="$(uname -m)"

echo "   - 操作系统: ${OS}"
echo "   - 系统架构: ${ARCH}"

PLATFORM=""
case "$OS" in
    Linux)
        case "$ARCH" in
            x86_64) PLATFORM="linux-amd64" ;;
            aarch64|arm64) PLATFORM="linux-arm64" ;;
            *) 
                echo -e "   ${RED}[错误] 不支持的架构: $ARCH${NC}"
                exit 1 
                ;;
        esac
        ;;
    Darwin)
        case "$ARCH" in
            x86_64) PLATFORM="macos-amd64" ;;
            arm64) PLATFORM="macos-arm64" ;;
            *) 
                echo -e "   ${RED}[错误] 不支持的架构: $ARCH${NC}"
                exit 1 
                ;;
        esac
        ;;
    *)
        echo -e "   ${RED}[错误] 不支持的操作系统: $OS${NC}"
        exit 1
        ;;
esac

echo -e "   ${GREEN}- 目标平台标识: $PLATFORM${NC}"
echo ""

# ==========================================
# 2. 检查 Python 环境
# ==========================================
echo -e "${BLUE}=> [2/6] 检查 Python 运行环境...${NC}"
if command -v python3 &>/dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo -e "   ${GREEN}- Python3 已就绪: $PYTHON_VERSION${NC}"
else
    echo -e "   ${RED}[错误] 未检测到 Python3，请先安装 Python3。${NC}"
    exit 1
fi
echo ""

# ==========================================
# 3. 检查并优先安装 uv
# ==========================================
echo -e "${BLUE}=> [3/6] 检查包管理工具 uv...${NC}"
if ! command -v uv &>/dev/null; then
    echo -e "   ${YELLOW}- 未检测到 uv，正在优先安装 uv...${NC}"
    
    # 下载并安装 uv
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # 尝试加载环境变量以使 uv 立即生效
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi
    
    # 确保 PATH 包含 uv 的安装路径
    export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
    
    # 验证 uv 是否可用
    if command -v uv &>/dev/null; then
        UV_VERSION=$(uv --version)
        echo -e "   ${GREEN}- uv 安装成功: $UV_VERSION${NC}"
    else
        echo -e "   ${RED}[错误] uv 环境变量配置失败，请手动执行 'source \$HOME/.cargo/env' 后重新运行本脚本。${NC}"
        exit 1
    fi
else
    UV_VERSION=$(uv --version)
    echo -e "   ${GREEN}- uv 已安装: $UV_VERSION${NC}"
fi
echo ""

# ==========================================
# 4. 从 GitHub Releases 下载对应的 Docker 版本
# ==========================================
echo -e "${BLUE}=> [4/6] 正在从 itradeicu/itrade.icu 获取最新 Release...${NC}"
REPO="itradeicu/itrade.icu"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

# 设置超时和重试
MAX_RETRIES=3
RETRY_COUNT=0
DOWNLOAD_URL=""

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "   - 尝试获取 Release 信息 (第 $RETRY_COUNT 次)..."
    
    # 尝试匹配当前平台的专属 docker 压缩包
    DOWNLOAD_URL=$(curl -s --max-time 10 "$API_URL" | grep "browser_download_url" | grep -i "docker" | grep -i "$PLATFORM" | cut -d '"' -f 4 | head -n 1)
    
    # 回退 1: 查找通用的 docker 包
    if [ -z "$DOWNLOAD_URL" ]; then
        DOWNLOAD_URL=$(curl -s --max-time 10 "$API_URL" | grep "browser_download_url" | grep -i "docker" | cut -d '"' -f 4 | head -n 1)
    fi
    
    # 回退 2: 直接下载源码包 (tarball)
    if [ -z "$DOWNLOAD_URL" ]; then
        echo -e "   ${YELLOW}- 未找到专属的 Docker 资产包，正在使用默认源码包...${NC}"
        DOWNLOAD_URL=$(curl -s --max-time 10 "$API_URL" | grep "tarball_url" | cut -d '"' -f 4 | head -n 1)
    fi
    
    if [ -n "$DOWNLOAD_URL" ]; then
        break
    fi
    
    echo -e "   ${YELLOW}- 第 $RETRY_COUNT 次尝试失败，等待 2 秒后重试...${NC}"
    sleep 2
done

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "   ${RED}[错误] 无法从 GitHub 获取下载链接，请检查网络连接。${NC}"
    exit 1
fi

echo -e "   ${GREEN}- 下载地址: $DOWNLOAD_URL${NC}"

# 创建工作目录
WORK_DIR="itrade_docker_deploy"
mkdir -p "$WORK_DIR"

# 下载文件
echo -e "   ${YELLOW}- 正在下载...${NC}"
curl -L --progress-bar -o "$WORK_DIR/release.tar.gz" "$DOWNLOAD_URL"

echo -e "   ${YELLOW}- 正在解压...${NC}"
# 尝试 tar 解压，如果失败则尝试 unzip
if tar -xzf "$WORK_DIR/release.tar.gz" -C "$WORK_DIR" --strip-components=1 2>/dev/null; then
    echo -e "   ${GREEN}- 解压成功 (tar)${NC}"
elif unzip -o "$WORK_DIR/release.tar.gz" -d "$WORK_DIR" 2>/dev/null; then
    echo -e "   ${GREEN}- 解压成功 (zip)${NC}"
else
    echo -e "   ${RED}[错误] 解压失败，请检查下载的文件是否完整。${NC}"
    exit 1
fi

cd "$WORK_DIR"
echo ""

# ==========================================
# 5. 使用 uv 同步依赖
# ==========================================
echo -e "${BLUE}=> [5/6] 正在同步项目依赖...${NC}"
if [ -f "pyproject.toml" ]; then
    echo -e "   ${YELLOW}- 发现 pyproject.toml，正在执行 uv sync...${NC}"
    uv sync
    echo -e "   ${GREEN}- 依赖同步完成${NC}"
else
    echo -e "   ${YELLOW}- 未发现 pyproject.toml，跳过 uv 依赖同步。${NC}"
fi
echo ""

# ==========================================
# 6. 启动 Docker
# ==========================================
echo -e "${BLUE}=> [6/6] 正在启动 Docker 容器...${NC}"
if ! command -v docker &>/dev/null; then
    echo -e "   ${RED}[错误] 未检测到 Docker，请先安装 Docker Desktop 或 Docker Engine。${NC}"
    echo -e "   ${YELLOW}提示: 可以访问 https://www.docker.com/products/docker-desktop/ 下载安装${NC}"
    exit 1
fi

# 检查 Docker 是否正在运行
if ! docker info &>/dev/null; then
    echo -e "   ${RED}[错误] Docker 未运行，请先启动 Docker 服务。${NC}"
    exit 1
fi

echo -e "   ${GREEN}- Docker 已就绪${NC}"

if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    echo -e "   ${YELLOW}- 使用 Docker Compose 启动...${NC}"
    if docker compose version &>/dev/null; then
        docker compose up -d
    elif command -v docker-compose &>/dev/null; then
        docker-compose up -d
    else
        echo -e "   ${RED}[错误] 找不到 docker compose 命令，请检查 Docker 安装是否完整。${NC}"
        exit 1
    fi
    echo -e "   ${GREEN}- Docker Compose 启动成功${NC}"
else
    echo -e "   ${YELLOW}- 未找到 docker-compose 文件，尝试通过 Dockerfile 直接构建...${NC}"
    if [ -f "Dockerfile" ]; then
        docker build -t itrade-icu .
        docker run -d --name itrade-icu -p 8080:8080 itrade-icu
        echo -e "   ${GREEN}- Docker 容器启动成功${NC}"
    else
        echo -e "   ${RED}[错误] 未找到 Dockerfile 或 docker-compose.yml，无法启动容器。${NC}"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  ✅ 部署完成！${NC}"
echo -e "${GREEN}  iTrade.icu 的 Docker 服务已在后台启动。${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
echo -e "${BLUE}提示:${NC}"
echo -e "  - 查看日志: ${YELLOW}docker logs -f itrade-icu${NC}"
echo -e "  - 停止服务: ${YELLOW}docker compose down${NC} 或 ${YELLOW}docker stop itrade-icu${NC}"
echo -e "  - 重启服务: ${YELLOW}docker compose restart${NC} 或 ${YELLOW}docker restart itrade-icu${NC}"
echo ""
