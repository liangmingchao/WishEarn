# WishEarn — 发布检查清单

**版本：** 0.15.0  
**最后更新：** 2026-11-08

## 1. 代码与构建

- [x] Debug 构建通过
- [x] Release Archive 构建通过（`build/WishEarn.xcarchive`）
- [x] IPA 导出通过（`build/export/WishEarn.ipa`）
- [x] 单元 / 集成测试通过（207 项）
- [x] 无已知 P0 缺陷
- [ ] 无新增编译警告（仅有 AppIntents 元数据提示）
- [x] 版本号与构建号正确（0.15.0 / 1）
- [x] 隐私清单 `PrivacyInfo.xcprivacy` 已打包

## 2. 核心功能

- [x] 创建 / 编辑 / 删除心愿
- [x] 图片选择、压缩、存储与清理
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
- [x] 磁盘容器重建后数据完整

## 4. 真机与视觉

- [x] iPhone 17 Debug 安装、启动
- [x] iPhone 17 Release 0.15.0 安装、启动
- [x] 解锁庆祝即时性已确认（条件达成后立即出现）
- [ ] 真机图片选择 / 键盘 / 滚动手动确认
- [x] 深色模式截图验证
- [x] App 图标已替换为正式占位设计

## 5. 上架

- [x] App Store 文案、关键词、隐私说明草稿（`docs/APP_STORE.md`）
- [ ] 正式 App 名称 / Bundle ID
- [ ] 截图与预览视频
- [ ] 支持 URL / 隐私政策 URL
- [ ] App Store Connect 创建 App 记录
- [ ] TestFlight 上传与测试
- [ ] App Store 提交审核

## 阻塞项

- App Store Connect 账号与 TestFlight 上传需要用户提供凭据或手动操作。
- 真机手动交互项需用户在设备上确认。
