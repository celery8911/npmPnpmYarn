# NPM vs Yarn vs PNPM 对比学习

这个项目通过实际演示和详细文档来深入学习三种主流 JavaScript 包管理工具的特点、优劣势和最佳实践。

## 📚 项目结构

```
npmPnpmYarn/
├── npm-demo/                    # NPM 演示项目
│   ├── NPM-GUIDE.md            # NPM 详细指南
│   ├── package.json
│   └── index.js
├── yarn-demo/                   # Yarn 演示项目
│   ├── YARN-GUIDE.md           # Yarn 详细指南
│   ├── package.json
│   └── index.js
├── pnpm-demo/                   # PNPM 演示项目
│   ├── PNPM-GUIDE.md           # PNPM 详细指南
│   ├── package.json
│   └── index.js
├── comparison/                  # 对比分析
│   ├── PERFORMANCE-COMPARISON.md   # 性能对比详解
│   ├── SUMMARY.md                  # 终极总结
│   └── benchmark.sh                # 自动化性能测试脚本
├── HANDS-ON-PRACTICE.md        # 实践练习指南
└── README.md                    # 本文件
```

## 🎯 学习目标

通过本项目，你将学会：

1. **理解三种包管理器的核心差异**
2. **掌握各工具的常用命令**
3. **了解性能和磁盘占用对比**
4. **理解依赖管理机制（包括幽灵依赖问题）**
5. **学习 Monorepo 支持和最佳实践**
6. **根据项目需求选择合适的工具**

## 🚀 快速开始

### 1. 阅读文档

按以下顺序阅读可以获得最佳学习效果：

```
第一步：基础了解
├─ npm-demo/NPM-GUIDE.md      # 从最基础的 NPM 开始
├─ yarn-demo/YARN-GUIDE.md    # 了解 Yarn 的改进
└─ pnpm-demo/PNPM-GUIDE.md    # 探索 PNPM 的创新

第二步：深入对比
├─ comparison/PERFORMANCE-COMPARISON.md  # 性能实测
└─ comparison/SUMMARY.md                 # 综合总结

第三步：实践练习
└─ HANDS-ON-PRACTICE.md       # 8 个实践练习
```

### 2. 运行性能测试

```bash
# 自动化基准测试（需要安装三个工具）
cd comparison
./benchmark.sh
```

### 3. 实践练习

跟随 [HANDS-ON-PRACTICE.md](HANDS-ON-PRACTICE.md) 进行实践，包括：

- 练习 1: 基础命令对比
- 练习 2: 性能对比实测
- 练习 3: 幽灵依赖测试
- 练习 4: 磁盘空间对比
- 练习 5: Monorepo 实践
- 练习 6: 迁移实践
- 练习 7: 配置和优化
- 练习 8: 安全审计

## 📊 核心对比一览

| 特性 | NPM | Yarn | PNPM |
|-----|-----|------|------|
| **安装速度（缓存）** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **磁盘占用（多项目）** | ⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **依赖安全性** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **生态成熟度** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Monorepo 支持** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **学习成本** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

## 💡 快速推荐

**新项目？** → 使用 PNPM 🏆

**多项目开发？** → 使用 PNPM（节省 60-70% 磁盘空间）

**Monorepo？** → 使用 PNPM（最佳性能）

**老项目维护？** → 保持现状（NPM/Yarn）

**追求兼容性？** → 使用 NPM

详细分析请查看 [comparison/SUMMARY.md](comparison/SUMMARY.md)

## 🔑 关键概念

### NPM
- 默认包管理器，最成熟
- 扁平化 node_modules（v3+）
- package-lock.json 锁定版本

### Yarn
- 更快、更稳定、更安全
- 并行安装、离线模式
- yarn.lock、workspaces 支持

### PNPM
- 最快、最省空间
- 硬链接 + 符号链接
- 严格依赖、无幽灵依赖
- 原生 Monorepo 支持

## 📈 性能数据（参考）

### 安装速度（中等规模项目）

```
首次安装：
NPM:   35-45s
Yarn:  25-30s
PNPM:  22-28s

缓存安装：
NPM:   20-25s
Yarn:  10-12s
PNPM:  3-5s ⚡️
```

### 磁盘占用（10个项目）

```
NPM:   ~2.0GB
Yarn:  ~2.0GB
PNPM:  ~500-800MB  💾 (节省 60-70%)
```

详细测试请查看 [comparison/PERFORMANCE-COMPARISON.md](comparison/PERFORMANCE-COMPARISON.md)

## 🛠️ 工具安装

```bash
# NPM - 随 Node.js 安装，无需额外操作
node --version
npm --version

# Yarn - 全局安装
npm install -g yarn
# 或使用官方脚本
curl -o- -L https://yarnpkg.com/install.sh | bash

# PNPM - 全局安装
npm install -g pnpm
# 或使用官方脚本
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

## 📖 扩展阅读

### 官方文档
- [NPM 官方文档](https://docs.npmjs.com)
- [Yarn 官方文档](https://yarnpkg.com)
- [PNPM 官方文档](https://pnpm.io)

### 知名项目使用情况

**使用 NPM**: 大部分传统项目

**使用 Yarn**:
- React
- React Native
- Jest
- Babel

**使用 PNPM**:
- Vue 3
- Vite
- Nuxt 3
- SvelteKit
- Turborepo
- Prisma

## 🤝 贡献

欢迎提出问题和建议！

## 📝 许可

MIT

---

**开始学习吧！** 🎓

建议先阅读各工具的详细指南，然后运行性能测试，最后通过实践练习巩固理解。
