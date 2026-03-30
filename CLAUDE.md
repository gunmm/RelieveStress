# RelieveStress — 项目描述文件

> 本文件面向 AI 工具（如 Claude、Cursor、Copilot 等）提供项目全景信息，帮助快速理解代码库结构与核心逻辑。

---

## 项目概述

**RelieveStress** 是一款 iOS 原生 App，用 Swift + UIKit 构建，面向中国用户群体。
核心定位：**虚拟情绪发泄工具**——通过点击屏幕"攻击"用户设定的发泄对象（文字或照片），配合粒子特效、震动反馈和音效，帮助用户释放压力。

- **平台**：iOS（最低版本以 Xcode 项目配置为准）
- **语言**：Swift 5
- **架构**：MVC（UIKit 原生，无 SwiftUI，无第三方框架）
- **数据持久化**：UserDefaults（JSON 编码）
- **内购**：StoreKit（打赏功能）
- **权限**：Photos（PhotosUI 选取照片）

---

## 目录结构

```
RelieveStress/
├── CLAUDE.md                          ← 本文件
├── RelieveStress.xcodeproj/
└── RelieveStress/
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    ├── Info.plist
    ├── Controllers/
    │   ├── ArenaViewController.swift       ← 主战斗页（核心）
    │   ├── TargetSetupViewController.swift ← 发泄对象设置页
    │   ├── EnergyPopupViewController.swift ← 胜利能量弹窗
    │   ├── LevelUpAlertViewController.swift← 阶段升级提示弹窗
    │   ├── RecordsViewController.swift     ← 历史记录页
    │   └── TipViewController.swift         ← 打赏页（StoreKit）
    ├── Models/
    │   ├── TargetModel.swift               ← 发泄对象模型 + TargetType 枚举
    │   ├── WeaponModel.swift               ← 武器模型（4 种武器）
    │   ├── VentingSession.swift            ← 单局游戏状态管理
    │   └── VentingRecord.swift             ← 持久化记录结构体
    ├── Views/
    │   ├── WeaponToolbar.swift             ← 底部武器切换工具栏
    │   └── DamageOverlayView.swift         ← 命中裂纹特效覆盖层
    ├── Services/
    │   └── RecordManager.swift             ← UserDefaults 数据读写单例
    └── Utils/
        └── ShatterAnimator.swift           ← 碎裂动画工具
```

---

## 核心流程（用户视角）

```
启动 App
  └─→ ArenaViewController（主页）
        └─→ 若无 session，弹出 TargetSetupViewController
              ├─→ 用户选择"照片"（PHPicker）或"文字"（输入/预设标签）
              └─→ 生成 TargetModel，回调 didSetupTarget(_:)
                    └─→ 创建 VentingSession，开始点击发泄
                          ├─→ 每次点击：applyHit(weapon:) 累积"怒气值"
                          ├─→ 显示武器动画、裂纹叠加、分数弹出、震动
                          ├─→ 达到阶段阈值 → LevelUpAlertViewController
                          │     ├─→ 继续（levelUp，阈值提高）
                          │     └─→ 毁灭（triggerUltimateDestruction）
                          │           ├─→ 保存 VentingRecord
                          │           ├─→ 爆炸特效 + 音效 + 震动
                          │           └─→ EnergyPopupViewController（领取能量）
                          │                 └─→ 太阳飞入"记录"按钮动画
                          │                       └─→ 重新弹出 TargetSetupViewController
                          └─→ 历史记录（RecordsViewController）
```

---

## 关键模型说明

### TargetModel / TargetType
```swift
enum TargetType {
    case text(String)   // 文字目标
    case image(UIImage) // 照片目标
}
struct TargetModel {
    let id: UUID
    let type: TargetType
    let maxHealth: Int  // 固定 100，当前版本未实际消耗 HP
}
```
内置预设标签分 3 组：「职场/老板PUA」、「AI时代焦虑」、「生活与压力」。

### WeaponModel（4 种武器）
| id | 名称 | damage | emoji | 强度 |
|---|---|---|---|---|
| fist_small | 小拳头 | 2 | 🤜 | light |
| fist_large | 大拳头 | 5 | 👊 | heavy |
| stick_small | 小棍子 | 4 | 🏏 | light |
| hammer_large | 大铁锤 | 10 | 🔨 | heavy |

### VentingSession（局内状态）
- `accumulatedVentingValue`：累积怒气值（随等级乘数增加）
- `currentLevel`：当前阶段（初始 1，毁灭前可多次升级）
- `nextThreshold`：下一阶段触发阈值（1000 / 3000 / 5000 / 8000 / …）
- `energyValue`：怒气值 ÷ 100（最少 1），完成后显示给用户
- 伤害公式：`totalDamage = weapon.damageValue × (currentLevel × 1.5)`

### VentingRecord（持久化）
```swift
struct VentingRecord: Codable {
    let id, sessionId: UUID
    let date: Date
    let targetName: String
    let totalVentingScore: Int  // 最终怒气值
    let energyValue: Int        // 转换后能量值
    let weaponUsedTimes: Int    // 击打次数
}
```
存储于 `UserDefaults` key：`com.relievestress.venting.records`，按日期降序。

---

## 特效系统（ArenaViewController）

| 方法 | 触发时机 | 描述 |
|---|---|---|
| `showDamagePopup` | 每次点击 | 黄色伤害数字弹出并上移消失 |
| `showWeaponHitAnimation` | 每次点击 | 武器 emoji 从右上角砸向点击位置 |
| `triggerFullScreenImpact` | 每次点击 | 红色闪光 + CAKeyframeAnimation 横向晃屏 |
| `showWeChatBombExplosion` | 最终毁灭 | 冲击波圆环 + 橙色粒子爆炸 + 火焰闪光 |
| `showFireballExplosion` | 最终毁灭 | ☄️ 粒子发射 + 火球膨胀吞噬目标，完成后回调 |

震屏强度在 `level > 2` 后上限为 level=2 的强度（防止过于眩晕）。

---

## UI 布局（ArenaViewController 主屏）

```
[ 打赏❤️ ]  [ 更换发泄对象 ]  [ 记录📊 ]   ← 顶部导航栏
[ 🔥 已释放怒气值 ]
[ 大数字怒气值计数 ]
┌─────────────────────────────┐
│       发泄对象（文字/图片）   │  ← targetContainerView（点击区域）
└─────────────────────────────┘
[ 🤜 👊 🏏 🔨 ]              ← WeaponToolbar（底部武器选择）
```

---

## 弹窗层级

1. **TargetSetupViewController** — `sheetPresentationController`，`.medium()/.large()` detent
2. **LevelUpAlertViewController** — `overFullScreen` + `crossDissolve`，有"继续发泄"和"彻底毁灭"两个按钮
3. **EnergyPopupViewController** — `overFullScreen` + `crossDissolve`，显示能量值，点击后太阳飞入动画
4. **RecordsViewController** — `pageSheet` + `UINavigationController` 包装
5. **TipViewController** — StoreKit 打赏页，三档消耗型内购

---

## 代理协议

```swift
// TargetSetupViewController → ArenaViewController
protocol TargetSetupDelegate: AnyObject {
    func didSetupTarget(_ target: TargetModel)
}

// WeaponToolbar → ArenaViewController
protocol WeaponToolbarDelegate: AnyObject {
    func didSelectWeapon(_ weapon: WeaponModel)
}
```

---

## 开发注意事项

1. **无 Storyboard**：所有 UI 纯代码（`translatesAutoresizingMaskIntoConstraints = false`），入口在 `SceneDelegate`。
2. **无第三方依赖**：无 CocoaPods / SPM 依赖，直接编译即可。
3. **音效**：使用 `AudioToolbox` 系统音（ID: 1322, 1053）+ `kSystemSoundID_Vibrate`，无自定义音频文件。
4. **图片资源**：所有粒子纹理均通过 `UIGraphicsImageRenderer` 运行时生成，无需外部图片。
5. **数据持久化**：仅用 `UserDefaults`，无 CoreData / CloudKit（打赏历史记录除外，TipViewController 内部管理）。
6. **语言**：UI 全部中文，无国际化（无 Localizable.strings）。
7. **扩展点**：`TargetType.categorizedPresets` 可直接追加新分组/标签；`WeaponModel.availableWeapons` 静态数组可追加新武器。
