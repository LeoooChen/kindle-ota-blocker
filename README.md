# Kindle OTA Blocker

一个面向 Kindle KUAL 的 OTA 更新阻断扩展，目标是比 `renameotabin` 更可逆、更省电、更好恢复。

## 目录

- `kindle-ota-blocker/`
  - `config.xml`
  - `menu.json`
  - `bin/`
    - `ota-blocker.sh`
    - `lib.sh`
    - `check.sh`
    - `block.sh`
    - `restore.sh`
    - `rescue.sh`

## 安装

把 `kindle-ota-blocker/` 整个目录复制到 Kindle 的：

```text
/mnt/us/extensions/kindle-ota-blocker/
```

然后在 KUAL 里打开。

## 设计目标

- 不改写系统 OTA 二进制
- 阻断与恢复解耦
- 省电优先
- 状态可见

## 当前实现

- `Check`：显示状态、固件分支、策略和省电复查状态
- `Recheck`：仅在需要时做快速复查
- `Block`：创建目录型占位阻断
- `Restore`：移除阻断并关闭自动复查
- `Rescue`：最小回退路径
