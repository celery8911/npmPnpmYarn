# 包管理器要点速记

## NPM / Yarn / PNPM 概览
- NPM：默认最兼容、生态最大；速度与磁盘占用最逊。
- Yarn：体验好、并行安装快、Workspaces 成熟；Classic/Berry 版本割裂。
- PNPM：缓存安装最快、最省空间（全局存储+硬链）；严格禁止幽灵依赖，Monorepo 体验最佳。

## 性能与空间
- 首次安装：pnpm ≈ yarn > npm；热缓存安装 pnpm 领先（硬链接几乎秒装）。
- 单项目 node_modules 体积相近，但多项目时 pnpm 共享全局 store，可省约 60-70% 磁盘。
- CI 缓存：pnpm 命中率和恢复速度最佳，结合 `~/.pnpm-store` 缓存。

## PNPM 机制（示例：project/node_modules/.pnpm/lodash@4.17.21/node_modules/lodash）
- 全局 store 真实包（默认 macOS 路径 `~/Library/pnpm/store/v3`，可用 `pnpm store path` 查看）。
- `.pnpm/*/node_modules/<pkg>` 内的文件多为硬链接指向全局 store。
- 顶层 `node_modules/<pkg>` 通常是指向 `.pnpm/.../node_modules/<pkg>` 的符号链接；目录结构用软链，文件本体用硬链复用 store。
- 若文件系统不支持硬链/软链，pnpm 会回退为符号链接。

## Linux 硬链接 vs 符号链接（软链接）

### 硬链接 (Hard Link)

**概念**：多个文件名指向同一个 inode（文件的实际数据块）

**创建命令**：
```bash
ln source_file hard_link
```

**特点**：
- ✅ 指向同一个 inode，共享文件内容
- ✅ 删除原文件，硬链接仍然有效（只要还有一个链接存在，数据就不会丢失）
- ✅ 占用空间：几乎为 0（只增加一个目录项）
- ✅ 修改任一链接，所有链接都会同步更新（它们是同一个文件）
- ❌ 不能跨文件系统/分区
- ❌ 不能链接目录（防止循环引用）
- ❌ 必须是同一文件系统

**查看硬链接数**：
```bash
ls -li  # i 显示 inode 号，l 显示详细信息
# 第二列数字就是硬链接计数
```

**示例**：
```bash
# 创建原文件
echo "Hello" > original.txt

# 创建硬链接
ln original.txt hardlink.txt

# 查看 inode（两个文件 inode 号相同）
ls -li
# 12345678 -rw-r--r-- 2 user group 6 Dec  3 10:00 original.txt
# 12345678 -rw-r--r-- 2 user group 6 Dec  3 10:00 hardlink.txt
#    ↑ 相同的 inode 号

# 删除原文件
rm original.txt

# hardlink.txt 仍然存在且内容完整
cat hardlink.txt  # 输出: Hello

# 磁盘空间：只占用一份
du -sh original.txt hardlink.txt  # 总共只有一份数据
```

### 符号链接 (Symbolic Link / Soft Link)

**概念**：创建一个特殊文件，内容是指向目标文件的路径

**创建命令**：
```bash
ln -s source_file symlink
```

**特点**：
- ✅ 可以跨文件系统/分区
- ✅ 可以链接目录
- ✅ 可以链接不存在的文件（悬空链接）
- ✅ 更灵活，类似 Windows 的快捷方式
- ❌ 删除原文件，符号链接失效（变成悬空链接）
- ❌ 占用一点空间（存储路径字符串）
- ❌ 访问时需要额外的路径解析（性能略差）

**示例**：
```bash
# 创建原文件
echo "Hello" > original.txt

# 创建符号链接
ln -s original.txt symlink.txt

# 查看（注意箭头指向）
ls -l
# lrwxr-xr-x 1 user group 12 Dec  3 10:00 symlink.txt -> original.txt
#  ↑ l 表示是符号链接

# 删除原文件
rm original.txt

# symlink.txt 变成悬空链接（红色闪烁）
cat symlink.txt  # 报错: No such file or directory

# 查看符号链接本身（不跟随链接）
ls -l symlink.txt
# lrwxr-xr-x 1 user group 12 Dec  3 10:00 symlink.txt -> original.txt (红色)
```

### 对比表格

| 特性 | 硬链接 | 符号链接 |
|-----|--------|---------|
| **命令** | `ln file link` | `ln -s file link` |
| **本质** | 指向同一 inode | 指向文件路径 |
| **跨文件系统** | ❌ 不支持 | ✅ 支持 |
| **链接目录** | ❌ 不支持 | ✅ 支持 |
| **原文件删除** | ✅ 仍有效 | ❌ 失效（悬空） |
| **磁盘空间** | 0（共享数据） | 几 bytes（路径） |
| **inode** | 相同 | 不同 |
| **性能** | ✅ 直接访问 | ❌ 需路径解析 |
| **灵活性** | ❌ 受限多 | ✅ 更灵活 |

### PNPM 为什么同时使用两者？

**硬链接用于文件**（节省空间）：
```bash
# store 中的文件
~/.pnpm-store/v3/files/ab/cd1234.../package.json (原始数据)

# 项目中的硬链接
project/node_modules/.pnpm/lodash@4.17.21/node_modules/lodash/package.json
→ 硬链接到 store，指向同一个 inode

# 优势：完全共享数据，零额外空间
```

**符号链接用于目录**（组织结构）：
```bash
# 顶层访问
project/node_modules/lodash
→ 符号链接指向
  project/node_modules/.pnpm/lodash@4.17.21/node_modules/lodash

# 优势：可以链接目录，灵活组织结构
```

### 实际测试链接

```bash
# 测试硬链接
echo "test" > original.txt
ln original.txt hard.txt
stat original.txt hard.txt  # 查看 inode
# Inode: 12345678 (相同)

# 测试符号链接
ln -s original.txt soft.txt
stat soft.txt
# Inode: 87654321 (不同)

# 查看磁盘占用
du -sh original.txt hard.txt soft.txt
# 5B  original.txt
# 0B  hard.txt       ← 硬链接不占额外空间
# 12B soft.txt       ← 符号链接占一点空间（存路径）

# 删除原文件看效果
rm original.txt
cat hard.txt  # ✅ 成功，输出: test
cat soft.txt  # ❌ 失败，悬空链接
```

### PNPM 空间节省原理

```
假设 lodash 包大小 500KB

NPM/Yarn (3个项目):
  project1/node_modules/lodash  500KB (复制)
  project2/node_modules/lodash  500KB (复制)
  project3/node_modules/lodash  500KB (复制)
  总计: 1.5MB

PNPM (3个项目):
  ~/.pnpm-store/lodash@4.17.21  500KB (原始数据)
  project1/node_modules/.../lodash  0KB (硬链接)
  project2/node_modules/.../lodash  0KB (硬链接)
  project3/node_modules/.../lodash  0KB (硬链接)
  总计: 500KB ✅ 节省 66%
```

## 选择建议
- 新项目、Monorepo、多项目开发、CI 性能/空间敏感：首选 PNPM。
- 兼容性或团队习惯优先的老项目：保持 NPM/Yarn。
- 避免混用多个包管理器；锁文件必须提交（package-lock.json / yarn.lock / pnpm-lock.yaml）。

---

## 为什么小项目中 Yarn 可能比 PNPM 更快？

### 实测案例
在只有 6 个依赖的小 demo 项目中测试缓存安装：
- **Yarn**: 0.66s ✅
- **PNPM**: 1.2s

Yarn 更快！这与"PNPM 最快"的说法矛盾吗？

### 原因分析

#### 1. 项目规模太小
当前测试只有 6 个依赖包（lodash、express、axios、moment、react、react-dom）。

**PNPM 的优势在中大型项目才显著**。小项目中：
- 创建符号链接的开销相对明显
- Yarn 的并行复制策略更直接
- 依赖少，链接机制的优势不明显

#### 2. PNPM 需要做更多工作

**PNPM 安装过程**：
```
1. 检查全局 store (~/.pnpm-store)
2. 创建 .pnpm 目录结构
3. 从 store 创建硬链接
4. 创建符号链接到顶层 node_modules
5. 验证链接完整性
```

**Yarn 安装过程**：
```
1. 从缓存直接复制文件
2. 解析依赖关系
3. 扁平化处理（简单快速）
```

对于小项目：**PNPM 的链接开销 > 节省的时间**

#### 3. Yarn 的缓存策略
Yarn 缓存命中时非常激进：
- 直接从 `~/.yarn/cache` 复制，无需额外检查
- 扁平化结构复制更简单直接
- 并行优化对小项目效果好

#### 4. 文件系统影响
不同文件系统对符号链接性能不同：
- **APFS (macOS)**: 符号链接性能较好，但仍有开销
- **ext4 (Linux)**: 符号链接性能更好
- **NTFS (Windows)**: 符号链接可能需要管理员权限

### PNPM 优势何时体现？

#### 场景 1：中大型项目（20+ 依赖）
典型 React 项目（含 TypeScript、Webpack、ESLint、Jest 等）

**预期结果**（缓存安装）：
- Yarn: ~8-12s
- PNPM: ~2-4s ⚡️

#### 场景 2：多项目场景（磁盘空间）
假设 5 个类似项目：

```
Yarn (5个项目):
  各 ~150MB node_modules
  总计: ~750MB

PNPM (5个项目):
  ~/.pnpm-store: ~200MB (全局，共享)
  各项目符号链接: ~10MB
  总计: ~250MB
```

**节省空间：60-70%** 💾

#### 场景 3：Monorepo 项目
PNPM 的 workspace + filter 功能强大：
```bash
pnpm --filter @myapp/utils add lodash
pnpm -r run test
pnpm --filter "...@myapp/web" build
```

### 性能对比总结表

| 场景 | Yarn | PNPM | 谁更快 |
|-----|------|------|--------|
| 小项目缓存安装 (< 10 依赖) | **0.6s** | 1.2s | ✅ Yarn |
| 中型项目缓存安装 (~30 依赖) | 8s | **3s** | ✅ PNPM |
| 大型项目缓存安装 (100+ 依赖) | 15s | **4s** | ✅ PNPM |
| 多项目磁盘占用 | 750MB | **250MB** | ✅ PNPM |

### 核心结论

1. **小项目中 Yarn 更快是正常的**
   - 符号链接有开销
   - 依赖少，优势不明显
   - 差异通常 < 1 秒，影响不大

2. **PNPM 的优势在规模化**
   - 依赖越多，速度越快
   - 项目越多，空间越省
   - Monorepo 支持最佳

3. **选择工具看实际需求**
   - 小 demo (< 10 依赖)：Yarn/NPM 都可以
   - 中型项目 (10-50 依赖)：PNPM 开始显示优势
   - 大型项目 (> 50 依赖)：PNPM 强烈推荐
   - 多项目开发：PNPM（空间优势巨大）
   - Monorepo：PNPM（最佳支持）

4. **PNPM 的核心价值不只是速度**
   - ✅ 严格依赖管理（无幽灵依赖）
   - ✅ 节省磁盘空间（60-70%）
   - ✅ Monorepo 原生支持
   - ✅ 速度优势（中大项目）

### 最终理解

**新项目推荐 PNPM，不是因为它在所有情况下都最快，而是因为：**
1. 长期来看更快（随着项目增长）
2. 多项目开发省空间（显著）
3. 依赖管理更严格（避免隐藏问题）
4. 代表未来方向（Vue 3、Vite、Nuxt 3 等都在用）

**对于 6 个依赖的 demo，Yarn 快 0.5 秒是完全正常的！** 这反而帮助理解了工具的底层原理。🎓
