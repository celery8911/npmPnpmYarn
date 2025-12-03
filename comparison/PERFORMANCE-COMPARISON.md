# 三大包管理器性能对比

## 测试环境

- 操作系统：macOS
- Node.js 版本：建议 v16+
- 测试项目：中等规模（约 100 个依赖）
- 网络环境：相同网络条件

## 对比维度

### 1. 安装速度对比

#### 首次安装（冷缓存）

```bash
# 清空所有缓存
npm cache clean --force
yarn cache clean
pnpm store prune

# 在三个 demo 目录分别测试
cd npm-demo
time npm install lodash express axios react react-dom

cd ../yarn-demo
time yarn add lodash express axios react react-dom

cd ../pnpm-demo
time pnpm add lodash express axios react react-dom
```

**预期结果**（仅供参考）：

| 包管理器 | 首次安装时间 | 相对速度 |
|---------|------------|---------|
| NPM     | ~35-45s    | 基准 1x |
| Yarn    | ~25-30s    | 1.3-1.5x |
| PNPM    | ~22-28s    | 1.5-1.8x |

#### 二次安装（热缓存）

```bash
# 删除 node_modules 但保留缓存
rm -rf node_modules

# 重新安装
time npm install   # npm-demo
time yarn install  # yarn-demo
time pnpm install  # pnpm-demo
```

**预期结果**：

| 包管理器 | 二次安装时间 | 相对速度 |
|---------|------------|---------|
| NPM     | ~20-25s    | 基准 1x |
| Yarn    | ~10-12s    | 2x |
| PNPM    | ~3-5s      | 🏆 5-7x |

**结论**：
- 首次安装：pnpm ≈ yarn > npm
- 二次安装：**pnpm 遥遥领先**（使用硬链接，几乎瞬间完成）

---

### 2. 磁盘空间占用对比

#### 单个项目

```bash
# 在每个 demo 目录安装相同依赖
# lodash, express, axios, react, react-dom, moment, chalk, uuid, dotenv, cors

# 查看 node_modules 大小
cd npm-demo
du -sh node_modules

cd ../yarn-demo
du -sh node_modules

cd ../pnpm-demo
du -sh node_modules
```

**预期结果**：

| 包管理器 | node_modules 大小 | 相对大小 |
|---------|------------------|---------|
| NPM     | ~180-200MB       | 基准 1x |
| Yarn    | ~180-200MB       | ≈1x |
| PNPM    | ~180-200MB       | ≈1x |

看起来差不多？继续看多项目场景...

#### 多项目对比（10个项目）

这才是 pnpm 的真正优势！

```bash
# 模拟 10 个项目
for i in {1..10}; do
  mkdir -p /tmp/npm-test-$i
  cd /tmp/npm-test-$i
  npm init -y
  npm install lodash express axios react react-dom
done

# 计算总大小
du -sh /tmp/npm-test-*
```

**预期结果**：

| 包管理器 | 10个项目总大小 | 相对大小 | 节省空间 |
|---------|---------------|---------|---------|
| NPM     | ~2.0GB        | 基准 1x | 0% |
| Yarn    | ~2.0GB        | ≈1x     | ~0% |
| PNPM    | ~500-800MB    | 🏆 0.3x | **60-70%** |

**为什么？**

- NPM/Yarn：每个项目独立存储所有依赖
  ```
  项目A/node_modules/lodash (5MB)
  项目B/node_modules/lodash (5MB)
  ...
  项目J/node_modules/lodash (5MB)
  总计：50MB
  ```

- PNPM：全局存储，项目中只有硬链接
  ```
  ~/.pnpm-store/lodash@4.17.21 (5MB)
  项目A/node_modules/lodash -> 硬链接
  项目B/node_modules/lodash -> 硬链接
  ...
  总计：5MB + 链接（几乎0成本）
  ```

---

### 3. 依赖解析对比

#### 幽灵依赖测试

创建测试文件：

```javascript
// test-ghost-dependency.js
// 尝试引用未声明的依赖

try {
  const chalk = require('chalk');
  console.log(chalk.green('Success: Can use undeclared dependency!'));
} catch (e) {
  console.log('Error: Cannot use undeclared dependency');
  console.log('This is the correct behavior!');
}
```

**测试步骤**：

1. 安装 `express`（express 依赖 chalk）
2. 运行 `node test-ghost-dependency.js`

**结果**：

| 包管理器 | 能否使用未声明的 chalk | 是否安全 |
|---------|----------------------|---------|
| NPM     | ✅ 可以（被提升了）    | ❌ 不安全 |
| Yarn    | ✅ 可以（被提升了）    | ❌ 不安全 |
| PNPM    | ❌ 不可以            | 🏆 ✅ 安全 |

**PNPM 的优势**：强制开发者显式声明依赖，避免隐藏问题。

---

### 4. Monorepo 性能对比

创建简单的 monorepo 结构：

```
monorepo/
├── packages/
│   ├── pkg-a/
│   └── pkg-b/
└── pnpm-workspace.yaml  # 或 package.json (workspaces)
```

#### NPM Workspaces

```json
// package.json
{
  "workspaces": [
    "packages/*"
  ]
}
```

#### Yarn Workspaces

```json
// package.json
{
  "private": true,
  "workspaces": [
    "packages/*"
  ]
}
```

#### PNPM Workspaces

```yaml
# pnpm-workspace.yaml
packages:
  - 'packages/*'
```

**性能对比**：

| 操作 | NPM | Yarn | PNPM |
|-----|-----|------|------|
| 安装所有依赖 | 慢 | 中等 | 🏆 快 |
| 过滤执行命令 | 有限 | 好 | 🏆 最好 |
| 磁盘占用 | 大 | 大 | 🏆 小 |
| 依赖提升控制 | 一般 | 好 | 🏆 最严格 |

**PNPM 的 filter 功能**：

```bash
# 只在特定包中运行命令
pnpm --filter pkg-a build
pnpm --filter "./packages/**" test
pnpm --filter "...pkg-a" build  # pkg-a 及其依赖
```

---

### 5. CI/CD 环境对比

#### 缓存策略

**NPM**：
```yaml
# GitHub Actions
- uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
```

**Yarn**：
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.yarn/cache
    key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
```

**PNPM**：
```yaml
- uses: pnpm/action-setup@v2
  with:
    version: 8
- uses: actions/cache@v3
  with:
    path: ~/.pnpm-store
    key: ${{ runner.os }}-pnpm-${{ hashFiles('**/pnpm-lock.yaml') }}
```

**CI 性能对比**：

| 场景 | NPM | Yarn | PNPM |
|-----|-----|------|------|
| 有缓存 | ~20s | ~10s | 🏆 ~5s |
| 无缓存 | ~40s | ~30s | ~25s |
| 缓存命中率 | 中等 | 好 | 🏆 最好 |

---

### 6. 实际基准测试脚本

创建自动化测试脚本：

```bash
#!/bin/bash
# benchmark.sh - 性能基准测试

echo "=== Package Manager Benchmark ==="
echo ""

PACKAGES="lodash express axios react react-dom moment chalk uuid"

# 测试 NPM
echo "Testing NPM..."
mkdir -p /tmp/npm-bench && cd /tmp/npm-bench
npm init -y > /dev/null 2>&1
npm cache clean --force > /dev/null 2>&1
time npm install $PACKAGES > /dev/null 2>&1
NPM_SIZE=$(du -sh node_modules | cut -f1)
echo "NPM node_modules size: $NPM_SIZE"
cd - > /dev/null

# 测试 Yarn
echo ""
echo "Testing Yarn..."
mkdir -p /tmp/yarn-bench && cd /tmp/yarn-bench
yarn init -y > /dev/null 2>&1
yarn cache clean > /dev/null 2>&1
time yarn add $PACKAGES > /dev/null 2>&1
YARN_SIZE=$(du -sh node_modules | cut -f1)
echo "Yarn node_modules size: $YARN_SIZE"
cd - > /dev/null

# 测试 PNPM
echo ""
echo "Testing PNPM..."
mkdir -p /tmp/pnpm-bench && cd /tmp/pnpm-bench
pnpm init > /dev/null 2>&1
pnpm store prune > /dev/null 2>&1
time pnpm add $PACKAGES > /dev/null 2>&1
PNPM_SIZE=$(du -sh node_modules | cut -f1)
echo "PNPM node_modules size: $PNPM_SIZE"
cd - > /dev/null

echo ""
echo "=== Summary ==="
echo "NPM:  $NPM_SIZE"
echo "Yarn: $YARN_SIZE"
echo "PNPM: $PNPM_SIZE"

# 清理
rm -rf /tmp/npm-bench /tmp/yarn-bench /tmp/pnpm-bench
```

---

## 综合评分

| 维度 | NPM | Yarn | PNPM |
|-----|-----|------|------|
| 首次安装速度 | ⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ |
| 缓存安装速度 | ⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️ |
| 磁盘空间占用 | ⭐️⭐️ | ⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️ |
| 依赖安全性 | ⭐️⭐️⭐️ | ⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️ |
| Monorepo 支持 | ⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️ |
| 生态成熟度 | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ |
| 学习成本 | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ |
| **综合评分** | **21/35** | **26/35** | **32/35** 🏆 |

---

## 结论

### 性能王者：PNPM 🏆

- **最快的缓存安装**：使用硬链接，几乎瞬间完成
- **最省磁盘空间**：多项目场景节省 60-70%
- **最严格的依赖管理**：彻底解决幽灵依赖
- **最佳 Monorepo 体验**：原生支持，性能卓越

### 何时选择各工具？

| 场景 | 推荐工具 | 理由 |
|-----|---------|------|
| 新项目 | **PNPM** | 最佳性能和规范性 |
| 多项目开发 | **PNPM** | 显著节省磁盘空间 |
| Monorepo | **PNPM** | 原生支持最好 |
| 老项目维护 | **NPM/Yarn** | 避免迁移风险 |
| 团队不熟悉新工具 | **NPM** | 学习成本最低 |
| CI/CD 环境 | **PNPM** | 缓存效率最高 |

**总体建议**：如果没有特殊限制，强烈推荐使用 **PNPM**！
