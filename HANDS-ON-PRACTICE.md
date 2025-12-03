# 实践练习指南

通过以下实际操作来深入理解三种包管理器的差异。

## 准备工作

确保你已经安装了 Node.js 和三个包管理器：

```bash
# 检查 Node.js 和 NPM（自带）
node --version
npm --version

# 安装 Yarn
npm install -g yarn
yarn --version

# 安装 PNPM
npm install -g pnpm
pnpm --version
```

---

## 练习 1：基础命令对比

### 目标
熟悉三个工具的基本命令和操作流程。

### 步骤

**1.1 NPM 练习**

```bash
cd npm-demo

# 安装依赖
npm install lodash

# 查看安装的包
npm list lodash

# 查看包信息
npm info lodash

# 更新包
npm update lodash

# 卸载包
npm uninstall lodash

# 重新安装
npm install lodash express axios
```

**1.2 Yarn 练习**

```bash
cd ../yarn-demo

# 安装依赖
yarn add lodash

# 查看安装的包
yarn list --pattern lodash

# 查看包信息
yarn info lodash

# 查看为什么安装了这个包
yarn why lodash

# 更新包
yarn upgrade lodash

# 卸载包
yarn remove lodash

# 重新安装
yarn add lodash express axios
```

**1.3 PNPM 练习**

```bash
cd ../pnpm-demo

# 安装依赖
pnpm add lodash

# 查看安装的包
pnpm list lodash

# 查看包信息
pnpm info lodash

# 查看为什么安装了这个包
pnpm why lodash

# 更新包
pnpm update lodash

# 卸载包
pnpm remove lodash

# 重新安装
pnpm add lodash express axios
```

### 观察要点

1. 命令的差异（如 `npm install` vs `yarn add` vs `pnpm add`）
2. 输出信息的友好程度
3. 安装速度的差异

---

## 练习 2：性能对比实测

### 目标
亲自测试三个工具的安装速度。

### 步骤

**2.1 运行自动化基准测试**

```bash
cd comparison
./benchmark.sh
```

这会自动测试三个工具的：
- 冷缓存安装速度
- 热缓存安装速度
- 磁盘占用大小

**2.2 手动测试（更详细）**

```bash
# 测试 NPM
cd npm-demo
rm -rf node_modules package-lock.json
npm cache clean --force
time npm install lodash express axios react react-dom moment
du -sh node_modules

# 测试 Yarn
cd ../yarn-demo
rm -rf node_modules yarn.lock
yarn cache clean
time yarn add lodash express axios react react-dom moment
du -sh node_modules

# 测试 PNPM
cd ../pnpm-demo
rm -rf node_modules pnpm-lock.yaml
pnpm store prune
time pnpm add lodash express axios react react-dom moment
du -sh node_modules
```

**2.3 测试缓存安装**

```bash
# NPM
cd npm-demo
rm -rf node_modules
time npm install

# Yarn
cd ../yarn-demo
rm -rf node_modules
time yarn install

# PNPM (这里会看到显著优势!)
cd ../pnpm-demo
rm -rf node_modules
time pnpm install
```

### 观察要点

1. 哪个工具首次安装最快？
2. 哪个工具缓存安装最快？
3. PNPM 的速度优势在哪里体现？

---

## 练习 3：幽灵依赖测试

### 目标
理解什么是幽灵依赖，以及 PNPM 如何解决这个问题。

### 步骤

**3.1 创建测试文件**

在每个 demo 目录中创建 `test-ghost.js`：

```javascript
// test-ghost.js
// Express 依赖 cookie，但我们没有在 package.json 中声明 cookie

console.log('Testing ghost dependency...\n');

try {
  const cookie = require('cookie');
  console.log('✅ 成功：可以使用未声明的依赖 cookie');
  console.log('❌ 问题：这是幽灵依赖！代码依赖了未声明的包');
} catch (e) {
  console.log('❌ 失败：无法使用未声明的依赖');
  console.log('✅ 正确：PNPM 严格控制依赖访问');
}
```

**3.2 先安装 express（express 依赖 cookie）**

```bash
# 在各个 demo 目录中
npm install express   # npm-demo
yarn add express      # yarn-demo
pnpm add express      # pnpm-demo
```

**3.3 运行测试**

```bash
# NPM
cd npm-demo
node test-ghost.js
# 结果：可能成功（cookie 被提升了）

# Yarn
cd ../yarn-demo
node test-ghost.js
# 结果：可能成功（cookie 被提升了）

# PNPM
cd ../pnpm-demo
node test-ghost.js
# 结果：失败！PNPM 不允许访问未声明的依赖
```

**3.4 查看 node_modules 结构**

```bash
# NPM/Yarn: 扁平化结构，cookie 在顶层
ls npm-demo/node_modules | grep cookie

# PNPM: 严格结构，cookie 隐藏在 .pnpm 中
ls pnpm-demo/node_modules | grep cookie  # 看不到
ls pnpm-demo/node_modules/.pnpm | grep cookie  # 在这里
```

### 观察要点

1. NPM/Yarn 允许访问未声明的依赖（幽灵依赖）
2. PNPM 严格控制，只能访问声明的依赖
3. 这为什么重要？（可靠性、可维护性）

---

## 练习 4：磁盘空间对比

### 目标
直观感受 PNPM 的空间节省优势。

### 步骤

**4.1 创建多个测试项目**

```bash
cd /tmp

# 创建 5 个 NPM 项目
for i in 1 2 3 4 5; do
  mkdir -p npm-multi-$i
  cd npm-multi-$i
  npm init -y
  npm install lodash express axios
  cd ..
done

# 查看总大小
du -sh npm-multi-*
du -sch npm-multi-* | tail -1

# 创建 5 个 PNPM 项目
for i in 1 2 3 4 5; do
  mkdir -p pnpm-multi-$i
  cd pnpm-multi-$i
  pnpm init
  pnpm add lodash express axios
  cd ..
done

# 查看总大小
du -sh pnpm-multi-*
du -sch pnpm-multi-* | tail -1
```

**4.2 对比结果**

```bash
# NPM 总大小
NPM_SIZE=$(du -sc npm-multi-* | tail -1 | awk '{print $1}')

# PNPM 总大小
PNPM_SIZE=$(du -sc pnpm-multi-* | tail -1 | awk '{print $1}')

echo "NPM 5个项目总大小: $NPM_SIZE"
echo "PNPM 5个项目总大小: $PNPM_SIZE"
```

**4.3 查看 PNPM store**

```bash
# 查看 store 位置
pnpm store path

# 查看 store 状态
pnpm store status

# 查看 store 大小
du -sh $(pnpm store path)
```

### 观察要点

1. PNPM 多项目场景下的空间节省
2. 理解硬链接的概念
3. 为什么 PNPM 能节省空间？

---

## 练习 5：Monorepo 实践

### 目标
体验三个工具的 Monorepo 支持。

### 步骤

**5.1 创建 PNPM Monorepo**

```bash
mkdir pnpm-monorepo
cd pnpm-monorepo

# 创建 workspace 配置
cat > pnpm-workspace.yaml << EOF
packages:
  - 'packages/*'
EOF

# 创建包
mkdir -p packages/utils packages/app

# utils 包
cd packages/utils
pnpm init
cat > package.json << EOF
{
  "name": "@myapp/utils",
  "version": "1.0.0",
  "main": "index.js"
}
EOF

cat > index.js << EOF
module.exports = {
  hello: () => 'Hello from utils!'
};
EOF

# app 包
cd ../app
pnpm init
cat > package.json << EOF
{
  "name": "@myapp/app",
  "version": "1.0.0",
  "dependencies": {
    "@myapp/utils": "workspace:*"
  }
}
EOF

cat > index.js << EOF
const utils = require('@myapp/utils');
console.log(utils.hello());
EOF

# 回到根目录，安装依赖
cd ../..
pnpm install

# 运行 app
node packages/app/index.js
```

**5.2 使用 PNPM 过滤器**

```bash
# 只在 utils 包中运行命令
pnpm --filter @myapp/utils add lodash

# 只在 app 包中运行命令
pnpm --filter @myapp/app add axios

# 在所有包中运行命令
pnpm -r add chalk

# 运行所有包的 script
pnpm -r run test
```

### 观察要点

1. PNPM workspace 配置简单
2. 包之间的依赖管理
3. 过滤器的强大功能

---

## 练习 6：迁移实践

### 目标
练习从一个工具迁移到另一个工具。

### 步骤

**6.1 从 NPM 迁移到 PNPM**

```bash
# 假设你有一个 NPM 项目
cd npm-demo

# 1. 备份
cp package.json package.json.backup

# 2. 删除 NPM 产物
rm -rf node_modules package-lock.json

# 3. 导入到 PNPM（可选）
pnpm import

# 4. 安装依赖
pnpm install

# 5. 验证
pnpm run test
pnpm run start
```

**6.2 处理兼容性问题（如果遇到）**

```bash
# 如果遇到问题，尝试兼容模式
cat > .npmrc << EOF
shamefully-hoist=true
EOF

# 重新安装
rm -rf node_modules
pnpm install
```

### 观察要点

1. 迁移是否顺利？
2. 遇到了什么问题？
3. 性能提升如何？

---

## 练习 7：配置和优化

### 目标
学习各工具的配置选项。

### 步骤

**7.1 配置镜像源（国内加速）**

```bash
# NPM
npm config set registry https://registry.npmmirror.com

# Yarn
yarn config set registry https://registry.npmmirror.com

# PNPM
pnpm config set registry https://registry.npmmirror.com
```

**7.2 查看和修改配置**

```bash
# NPM
npm config list
npm config get registry
npm config set cache /path/to/cache

# Yarn
yarn config list
yarn config get registry

# PNPM
pnpm config list
pnpm config get registry
pnpm config set store-dir /path/to/store
```

**7.3 项目级配置**

创建 `.npmrc` 文件（三个工具都支持）：

```ini
# .npmrc
registry=https://registry.npmmirror.com
save-exact=true
engine-strict=true
```

PNPM 特有配置：

```ini
# .npmrc
shamefully-hoist=false
strict-peer-dependencies=true
auto-install-peers=false
```

---

## 练习 8：安全审计

### 目标
学习如何检查和修复安全漏洞。

### 步骤

**8.1 安装一个有已知漏洞的旧版本包**

```bash
cd npm-demo
npm install lodash@4.17.11  # 旧版本可能有漏洞
```

**8.2 运行安全审计**

```bash
# NPM
npm audit
npm audit fix
npm audit fix --force  # 强制修复（可能破坏兼容性）

# Yarn
yarn audit
yarn audit fix

# PNPM
pnpm audit
pnpm audit --fix
```

### 观察要点

1. 审计报告的详细程度
2. 自动修复的能力
3. 如何处理无法自动修复的漏洞

---

## 总结问题

完成所有练习后，回答以下问题：

1. **速度**：哪个工具在你的机器上最快？冷启动和热启动各是哪个？
2. **空间**：PNPM 在多项目场景下节省了多少空间？
3. **幽灵依赖**：为什么幽灵依赖是个问题？PNPM 如何解决？
4. **易用性**：哪个工具的命令你觉得最直观？
5. **Monorepo**：PNPM 的 workspace 和 filter 功能如何？
6. **迁移**：从 NPM 迁移到 PNPM 容易吗？遇到了什么问题？
7. **推荐**：基于你的实践，你会在新项目中选择哪个工具？

---

## 深入学习

完成基础练习后，可以进一步学习：

1. **锁文件**：深入理解 package-lock.json、yarn.lock、pnpm-lock.yaml 的格式
2. **发布包**：学习如何发布自己的 npm 包
3. **私有仓库**：搭建企业内部的 npm registry
4. **CI/CD 集成**：在 GitHub Actions 等平台配置包管理器
5. **Monorepo 工具链**：结合 Turborepo、Nx 等工具

---

## 常见问题

**Q: 练习时网络很慢怎么办？**

A: 配置国内镜像源（见练习 7），或使用离线模式（Yarn/PNPM）。

**Q: 某个练习失败了怎么办？**

A: 检查工具版本是否够新，或查看对应工具的文档。有些特性需要较新版本。

**Q: 可以混用不同工具吗？**

A: 不建议。在一个项目中坚持使用一个工具。

**Q: 练习完如何清理？**

A: 删除所有 demo 目录和 /tmp 中的测试项目即可。

---

祝你学习愉快！🎉

通过这些实践练习，你将对三个包管理器有深入的理解，能够在实际项目中做出明智的选择。
