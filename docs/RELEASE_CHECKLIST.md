# WishEarn — 发布检查清单

**版本：** 0.15.0  
**最后更新：** 2026-11-10
**当前结论：** **NO-GO** for App Store / TestFlight

详细证据见 [Issue #22 RC QA Report](qa/ISSUE_22_RC_REPORT.md)。

## 1. 代码与构建

- [x] Debug 构建通过
- [x] Release 构建通过（Simulator）
- [x] Release Archive 构建通过（`build/Issue22.xcarchive`）
- [x] Development IPA 导出通过（`build/Issue22Export/WishEarn.ipa`）
- [x] 单元 / 集成测试通过（**274 项**）+ 1 项关键旅程 UI 测试，iPhone 18 Pro / iOS 27.2
- [x] 自动化测试未发现 P0 / P1 缺陷
- [ ] 无编译警告（仍有非致命方向声明警告）
- [x] 版本号与构建号正确（0.15.0 / 1）
- [x] 隐私清单 `PrivacyInfo.xcprivacy` 已打包
- [x] 最新 main 的 CI 为绿色（run 42840733123；274 单元/集成 + 1 UI 测试）

## 2. 核心功能

- [x] 创建 / 编辑 / 删除心愿
- [x] 图片选择、压缩、存储与清理（自动化层）
- [x] 六种条件类型
- [x] 六种行动记录
- [x] 今日行动与历史记录
- [x] 进度计算与连续打卡
- [x] 自动解锁与解锁事件
- [x] 解锁庆祝与兑现奖励
- [x] 成就页统计
- [x] 数据 JSON 导出

## 3. 数据与隐私

- [x] Local-first，无网络依赖
- [x] 无账号 / 无追踪 / 无第三方分析
- [x] 删除心愿级联清理条件、记录、事件、暂停区间与图片
- [x] 解锁事件只追加、不静默删除
- [x] 磁盘容器重建后数据完整（自动化测试）
- [ ] 当前 Playful 构建在真机重启后的数据保持（未执行）

## 4. 真机与视觉

- [x] 七个核心页面 Light / Dark Simulator 截图（Issue #21）
- [x] 深色模式截图验证（Simulator）
- [x] 当前 Playful 构建在 iPhone 17 安装、启动（2026-11-10，Release / `devicectl`）
- [ ] PhotosPicker 选择 / 取消 / 替换 / 移除 — **NOT TESTED**
- [ ] 键盘弹出、滚动、焦点和保存按钮可见性 — **NOT TESTED**
- [ ] 长标题 / 长备注 / Dynamic Type — **NOT TESTED**
- [ ] Today / Detail / Editor / Unlock 导航与返回 — **NOT TESTED**
- [ ] 长列表滚动和图片加载 — **NOT TESTED**
- [ ] App 重启后本地数据保持（真机） — **NOT TESTED**
- [ ] App Icon 已替换为 Playful 方案（提案预览，未获品牌确认）

## 5. 上架

- [x] App Store 文案、关键词、隐私说明草稿（`docs/APP_STORE.md`）
- [ ] 正式 App 名称 / Bundle ID
- [ ] 截图与预览视频
- [ ] 支持 URL / 隐私政策 URL / 营销 URL
- [ ] App Store Connect 创建 App 记录
- [ ] TestFlight 上传与测试
- [ ] App Store 提交审核

## 阻塞项

- 真机交互验收（图片选择、键盘、滚动、导航、重启）仍未完成。
- App Store Connect / TestFlight 账号与凭据缺失。
- 正式名称、Bundle ID、截图、支持 URL、隐私政策 URL 未确认。
- App Icon 仍为上一个 Petrol 版本，Playful 提案待品牌批准。
- UI 自动化覆盖 1 条关键旅程；其他页面与真实设备交互未自动化。

## 证据

- [RC QA Report](qa/ISSUE_22_RC_REPORT.md)
- [Issue #21 screenshots](design/screenshots/issue-21/)
- [App Store materials](APP_STORE.md)
- [main CI run 42840733123](https://github.com/liangmingchao/WishEarn/actions/runs/42840733123)
