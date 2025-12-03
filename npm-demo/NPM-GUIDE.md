# NPM (Node Package Manager) 详解

## 简介

NPM 是 Node.js 的默认包管理器，随 Node.js 一起安装。它是最早、使用最广泛的 JavaScript 包管理工具。

## 核心特点

### 1. 依赖管理机制

NPM 使用 **嵌套的 node_modules** 结构（npm v3 之前）和 **扁平化 node_modules** 结构（npm v3+）。

```
node_modules/
├── package-a/
│   └── node_modules/
│       └── package-c/  # package-a 依赖的特定版本
├── package-b/
└── package-c/          # 顶层共享的版本
```

### 2. package-lock.json

- **作用**：锁定依赖树的确切版本
- **好处**：确保团队成员安装相同版本的依赖
- **生成时机**：首次 `npm install` 时自动生成

### 3. 常用命令

```bash
# 初始化项目
npm init
npm init -y  # 使用默认配置

# 安装依赖
npm install                    # 安装 package.json 中的所有依赖
npm install <package>          # 安装并添加到 dependencies
npm install <package> --save-dev  # 安装并添加到 devDependencies
npm install -g <package>       # 全局安装

# 更新依赖
npm update                     # 更新所有依赖
npm update <package>           # 更新指定包

# 卸载依赖
npm uninstall <package>

# 查看依赖
npm list                       # 查看依赖树
npm list --depth=0            # 只查看顶层依赖

# 运行脚本
npm run <script>
npm start / npm test          # 特殊脚本可以省略 run

# 清理缓存
npm cache clean --force
```

## 优势

### ✅ 1. 生态系统最成熟
- 拥有最大的包注册表（npmjs.com）
- 所有包都首先发布到 npm
- 文档和社区支持最完善

### ✅ 2. 默认工具，无需额外安装
- 安装 Node.js 即自动包含
- 兼容性好，几乎所有项目都支持

### ✅ 3. 简单易用
- 命令简洁直观
- 学习曲线平缓

### ✅ 4. 工具链成熟
- 与各种构建工具、CI/CD 深度集成
- npm scripts 功能强大

## 劣势

### ❌ 1. 安装速度较慢
- 相比 yarn 和 pnpm，安装依赖速度最慢
- 没有并行安装优化（早期版本）

### ❌ 2. 磁盘空间占用大
- 每个项目都有独立的 node_modules
- 相同的包在不同项目中重复存储

### ❌ 3. 依赖提升问题（幽灵依赖）
```javascript
// 即使没有在 package.json 中声明
// 也可以使用某些被提升到顶层的包
const express = require('express'); // 可能是其他包的依赖
```

### ❌ 4. node_modules 结构不确定
- 安装顺序可能影响依赖树结构
- 可能导致不同机器上行为不一致

### ❌ 5. Monorepo 支持较弱
- 需要借助 lerna 等第三方工具
- 原生 workspaces 功能较晚才支持（npm v7+）

## 适用场景

1. **小型项目**：依赖少，对性能要求不高
2. **传统项目**：已有项目使用 npm，迁移成本高
3. **CI/CD 环境**：默认工具，配置简单
4. **学习阶段**：最基础的工具，适合入门

## 实际演示

在本目录执行以下命令：

```bash
# 1. 安装一些常用依赖
npm install lodash express moment

# 2. 安装开发依赖
npm install --save-dev jest eslint

# 3. 查看 node_modules 大小
du -sh node_modules

# 4. 查看依赖树
npm list --depth=0

# 5. 测试安装速度
time npm install
```

## 版本历史关键节点

- **npm v3 (2015)**：引入扁平化依赖树
- **npm v5 (2017)**：引入 package-lock.json
- **npm v7 (2020)**：支持 workspaces，peer dependencies 自动安装
- **npm v8 (2021)**：性能优化，严格 peer dependencies

## 性能优化技巧

1. **使用 npm ci**：在 CI 环境中使用，速度更快
   ```bash
   npm ci  # 基于 package-lock.json 安装，删除现有 node_modules
   ```

2. **配置镜像源**：
   ```bash
   npm config set registry https://registry.npmmirror.com
   ```

3. **缓存优化**：
   ```bash
   npm config set cache /path/to/cache
   ```
