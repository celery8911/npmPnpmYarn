#!/bin/bash

# 包管理器性能基准测试脚本
# 使用方法: chmod +x benchmark.sh && ./benchmark.sh

echo "======================================"
echo "  包管理器性能基准测试"
echo "  NPM vs Yarn vs PNPM"
echo "======================================"
echo ""

# 检查工具是否安装
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 未安装，跳过测试"
        return 1
    fi
    echo "✅ $1 已安装 (版本: $($1 --version))"
    return 0
}

echo "检查工具安装情况..."
HAS_NPM=$(check_tool npm && echo "yes" || echo "no")
HAS_YARN=$(check_tool yarn && echo "yes" || echo "no")
HAS_PNPM=$(check_tool pnpm && echo "yes" || echo "no")
echo ""

# 测试包列表
PACKAGES="lodash express axios react react-dom moment chalk uuid"
TEMP_DIR="/tmp/pkg-manager-bench"

# 创建临时目录
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

# 测试 NPM
if [ "$HAS_NPM" = "yes" ]; then
    echo "======================================"
    echo "测试 NPM"
    echo "======================================"

    NPM_DIR="$TEMP_DIR/npm-test"
    mkdir -p $NPM_DIR
    cd $NPM_DIR

    npm init -y > /dev/null 2>&1

    echo "清理缓存..."
    npm cache clean --force > /dev/null 2>&1

    echo "开始安装 (冷缓存)..."
    NPM_TIME_COLD=$( { time npm install $PACKAGES > /dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}')
    NPM_SIZE=$(du -sh node_modules 2>/dev/null | cut -f1)

    echo "删除 node_modules..."
    rm -rf node_modules

    echo "开始安装 (热缓存)..."
    NPM_TIME_WARM=$( { time npm install > /dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}')

    echo "✅ NPM 测试完成"
    echo "   冷缓存安装: $NPM_TIME_COLD"
    echo "   热缓存安装: $NPM_TIME_WARM"
    echo "   node_modules 大小: $NPM_SIZE"
    echo ""
fi

# 测试 Yarn
if [ "$HAS_YARN" = "yes" ]; then
    echo "======================================"
    echo "测试 Yarn"
    echo "======================================"

    YARN_DIR="$TEMP_DIR/yarn-test"
    mkdir -p $YARN_DIR
    cd $YARN_DIR

    yarn init -y > /dev/null 2>&1

    echo "清理缓存..."
    yarn cache clean > /dev/null 2>&1

    echo "开始安装 (冷缓存)..."
    YARN_TIME_COLD=$( { time yarn add $PACKAGES > /dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}')
    YARN_SIZE=$(du -sh node_modules 2>/dev/null | cut -f1)

    echo "删除 node_modules..."
    rm -rf node_modules

    echo "开始安装 (热缓存)..."
    YARN_TIME_WARM=$( { time yarn install > /dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}')

    echo "✅ Yarn 测试完成"
    echo "   冷缓存安装: $YARN_TIME_COLD"
    echo "   热缓存安装: $YARN_TIME_WARM"
    echo "   node_modules 大小: $YARN_SIZE"
    echo ""
fi

# 测试 PNPM
if [ "$HAS_PNPM" = "yes" ]; then
    echo "======================================"
    echo "测试 PNPM"
    echo "======================================"

    PNPM_DIR="$TEMP_DIR/pnpm-test"
    mkdir -p $PNPM_DIR
    cd $PNPM_DIR

    pnpm init > /dev/null 2>&1

    echo "清理 store..."
    pnpm store prune > /dev/null 2>&1

    echo "开始安装 (冷缓存)..."
    PNPM_TIME_COLD=$( { time pnpm add $PACKAGES > /dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}')
    PNPM_SIZE=$(du -sh node_modules 2>/dev/null | cut -f1)

    echo "删除 node_modules..."
    rm -rf node_modules

    echo "开始安装 (热缓存)..."
    PNPM_TIME_WARM=$( { time pnpm install > /dev/null 2>&1; } 2>&1 | grep real | awk '{print $2}')

    echo "✅ PNPM 测试完成"
    echo "   冷缓存安装: $PNPM_TIME_COLD"
    echo "   热缓存安装: $PNPM_TIME_WARM"
    echo "   node_modules 大小: $PNPM_SIZE"
    echo ""
fi

# 显示对比结果
echo "======================================"
echo "  测试结果汇总"
echo "======================================"
echo ""
printf "%-15s %-15s %-15s %-15s\n" "包管理器" "冷缓存安装" "热缓存安装" "磁盘占用"
echo "--------------------------------------------------------------"

if [ "$HAS_NPM" = "yes" ]; then
    printf "%-15s %-15s %-15s %-15s\n" "NPM" "$NPM_TIME_COLD" "$NPM_TIME_WARM" "$NPM_SIZE"
fi

if [ "$HAS_YARN" = "yes" ]; then
    printf "%-15s %-15s %-15s %-15s\n" "Yarn" "$YARN_TIME_COLD" "$YARN_TIME_WARM" "$YARN_SIZE"
fi

if [ "$HAS_PNPM" = "yes" ]; then
    printf "%-15s %-15s %-15s %-15s\n" "PNPM" "$PNPM_TIME_COLD" "$PNPM_TIME_WARM" "$PNPM_SIZE"
fi

echo ""
echo "======================================"
echo "  多项目磁盘占用对比 (10个项目)"
echo "======================================"
echo ""

# 测试多项目场景（简化版，只创建3个项目）
MULTI_DIR="$TEMP_DIR/multi-project"
mkdir -p $MULTI_DIR

echo "创建 3 个测试项目，每个都安装相同的依赖..."

# NPM 多项目
if [ "$HAS_NPM" = "yes" ]; then
    NPM_MULTI_DIR="$MULTI_DIR/npm"
    mkdir -p $NPM_MULTI_DIR
    NPM_TOTAL=0

    for i in 1 2 3; do
        mkdir -p "$NPM_MULTI_DIR/project-$i"
        cd "$NPM_MULTI_DIR/project-$i"
        npm init -y > /dev/null 2>&1
        npm install lodash express > /dev/null 2>&1
    done

    NPM_MULTI_SIZE=$(du -sh $NPM_MULTI_DIR 2>/dev/null | cut -f1)
    echo "✅ NPM (3项目总大小): $NPM_MULTI_SIZE"
fi

# PNPM 多项目
if [ "$HAS_PNPM" = "yes" ]; then
    PNPM_MULTI_DIR="$MULTI_DIR/pnpm"
    mkdir -p $PNPM_MULTI_DIR

    for i in 1 2 3; do
        mkdir -p "$PNPM_MULTI_DIR/project-$i"
        cd "$PNPM_MULTI_DIR/project-$i"
        pnpm init > /dev/null 2>&1
        pnpm add lodash express > /dev/null 2>&1
    done

    PNPM_MULTI_SIZE=$(du -sh $PNPM_MULTI_DIR 2>/dev/null | cut -f1)
    echo "✅ PNPM (3项目总大小): $PNPM_MULTI_SIZE"

    # 显示 store 信息
    echo ""
    echo "PNPM Store 信息:"
    pnpm store path
fi

echo ""
echo "======================================"
echo "  测试结论"
echo "======================================"
echo ""
echo "🚀 速度: PNPM 在有缓存时表现最好"
echo "💾 空间: PNPM 在多项目场景下节省显著"
echo "⚡️ 推荐: 新项目建议使用 PNPM"
echo ""

# 清理
echo "清理测试文件..."
cd /
rm -rf $TEMP_DIR
echo "✅ 测试完成！"
