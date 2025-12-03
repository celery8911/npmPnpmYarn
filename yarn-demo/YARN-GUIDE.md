# Yarn 详解

## 简介

Yarn 是由 Facebook、Google、Exponent 和 Tilde 联合推出的新 JavaScript 包管理器。它的出现是为了解决 npm v3-v5 时期的性能和安全性问题。

## 版本说明

- **Yarn Classic (v1.x)**：2016年发布，目前处于维护模式
- **Yarn Berry (v2+)**：2020年发布，引入了 Plug'n'Play (PnP) 等创新特性

本文主要介绍 Yarn Classic，因为它使用最广泛。

## 核心特点

### 1. yarn.lock 文件

类似 package-lock.json，但格式更易读：

```yaml
lodash@^4.17.21:
  version "4.17.21"
  resolved "https://registry.npmjs.org/lodash/-/lodash-4.17.21.tgz"
  integrity sha512-...
```

### 2. 并行安装

Yarn 采用并行安装策略，充分利用网络资源，显著提升安装速度。

### 3. 离线模式

首次安装后，包会缓存到本地。之后即使断网也能安装：

```bash
yarn install --offline
```

### 4. 确定性安装

无论安装顺序如何，生成的 node_modules 结构完全一致。

## 常用命令

```bash
# 初始化项目
yarn init
yarn init -y

# 安装依赖
yarn                          # 安装所有依赖
yarn install                  # 同上
yarn add <package>            # 添加到 dependencies
yarn add <package> --dev      # 添加到 devDependencies
yarn global add <package>     # 全局安装

# 更新依赖
yarn upgrade                  # 更新所有依赖
yarn upgrade <package>        # 更新指定包
yarn upgrade-interactive      # 交互式更新

# 卸载依赖
yarn remove <package>

# 查看依赖
yarn list
yarn list --depth=0

# 运行脚本
yarn run <script>
yarn <script>                 # 可以省略 run
yarn start / yarn test

# 清理缓存
yarn cache clean

# 检查依赖
yarn check                    # 验证 package.json 和 yarn.lock 一致性
yarn why <package>            # 查看为什么安装了某个包
```

## 优势

### ✅ 1. 速度快
- 并行下载和安装
- 高效的缓存机制
- 比 npm (v5之前) 快 2-3 倍

### ✅ 2. 离线模式
```bash
yarn install --offline
```
利用缓存，无网络也能安装依赖

### ✅ 3. 确定性和可靠性
- yarn.lock 确保版本一致
- 安装顺序不影响结果
- 减少"在我机器上能运行"的问题

### ✅ 4. 更好的安全性
```bash
yarn audit         # 检查安全漏洞
yarn audit fix     # 自动修复
```

### ✅ 5. Workspaces 原生支持
对 Monorepo 有很好的支持：

```json
{
  "private": true,
  "workspaces": [
    "packages/*"
  ]
}
```

### ✅ 6. 更友好的输出
- 清晰的进度条
- 彩色输出
- 更易读的错误信息

### ✅ 7. 自动重试
网络请求失败会自动重试，提高稳定性

## 劣势

### ❌ 1. 需要额外安装
不像 npm 是 Node.js 自带的

### ❌ 2. 两个版本导致混乱
- Yarn Classic (v1) vs Yarn Berry (v2+)
- 两者差异较大，社区分裂

### ❌ 3. Yarn Berry (v2+) 的 PnP 模式兼容性问题
- 很多工具不支持 PnP
- 需要额外配置

### ❌ 4. 磁盘占用问题依然存在
- 虽然有缓存，但每个项目仍有独立 node_modules
- 不如 pnpm 节省空间

### ❌ 5. 某些边缘场景下的兼容性
少数包可能在 yarn 上有问题

## Yarn vs NPM 命令对照

| NPM | Yarn | 说明 |
|-----|------|------|
| npm install | yarn / yarn install | 安装依赖 |
| npm install [package] | yarn add [package] | 添加依赖 |
| npm install [package] --save-dev | yarn add [package] --dev | 添加开发依赖 |
| npm uninstall [package] | yarn remove [package] | 卸载依赖 |
| npm update | yarn upgrade | 更新依赖 |
| npm run [script] | yarn [script] | 运行脚本 |
| npm cache clean | yarn cache clean | 清理缓存 |
| npm init | yarn init | 初始化项目 |

## 适用场景

1. **中大型项目**：需要稳定性和性能
2. **团队协作**：确定性安装很重要
3. **Monorepo 项目**：workspaces 支持好
4. **性能敏感场景**：CI/CD 流程
5. **Facebook 技术栈**：React、React Native 等项目官方推荐

## Yarn Berry (v2+) 新特性

### Plug'n'Play (PnP)

不生成 node_modules，而是使用 .pnp.cjs 文件：

```bash
yarn set version berry
```

优势：
- 安装更快（无需复制文件）
- 占用空间更小
- 依赖解析更严格

劣势：
- 兼容性问题
- 很多工具需要额外配置

## 实际演示

在本目录执行：

```bash
# 1. 安装 yarn（如果还没有）
npm install -g yarn

# 2. 查看版本
yarn --version

# 3. 安装依赖
yarn add lodash express moment

# 4. 安装开发依赖
yarn add --dev jest eslint

# 5. 查看为什么安装了某个包
yarn why lodash

# 6. 测试离线模式
yarn install --offline

# 7. 测试安装速度
time yarn install
```

## 性能优化技巧

1. **网络优化**：
   ```bash
   yarn config set registry https://registry.npmmirror.com
   ```

2. **并发控制**：
   ```bash
   yarn config set network-concurrency 8
   ```

3. **使用缓存**：
   ```bash
   yarn config set cache-folder /path/to/cache
   ```

4. **Frozen Lockfile**（CI 环境）：
   ```bash
   yarn install --frozen-lockfile
   ```

## 总结

Yarn 在 npm v5 之前有明显优势（速度、稳定性），但随着 npm 的改进，差距在缩小。选择 Yarn 的主要理由：

1. 更快的安装速度（仍然比 npm 快）
2. 更好的 Monorepo 支持
3. 更友好的用户体验
4. 团队已经在使用 Yarn

如果追求极致性能和磁盘空间优化，建议考虑 pnpm。
