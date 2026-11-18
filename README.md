# 我的川农 iOS

原生 SwiftUI 迁移自本工作区自己的川农 Android。当前覆盖三主页、学校绑定与会话、课表/成绩/考试/校历、学校服务、资料库、校园社区、校外园地、设置、提醒和 WidgetKit。主体代码已移植，正在统一验收与修复，**尚未最终交付**。完整范围、待测项与历史证据见 [迁移与验收记录](docs/IOS_MIGRATION.md)。

## 当前审核修复（2026-11-17）

已读取正式驳回意见：`Guideline 2.1 — Information Needed — New App Submission`，要求实体设备录屏、用途与目标用户、完整账号和功能路径、外部服务、地区差异以及适用的授权证明。`ITMS-90683` 是另一封构建警告，不能代替正式驳回原因。

按用户最新决定，iOS 已移除整项校园地图、地图 SDK 和资源、定位声明，以及平台短信验证码、短信找回和短信验证入口。平台账号使用手机号与密码注册、登录，手机号仅作未核验的登录标识。学校自己的验证码及二次验证保留。未确认授权的跑腿海报已排除出安装包，相册添加权限随之移除；系统照片选择器、可选通知、Keychain 与课表组件保留。此决定取代此前补地图定位用途说明的方案，也停止腾讯云短信资质配置。

当前候选为 `0.1.0 (7)`，已完成归档、Apple Distribution 签名导出和最终 IPA 检查，于北京时间12:05上传成功并处理完成，已关联正式版本草稿。46 项核心测试、3项无短信账号集成测试、10项旧短信流程兼容测试及10项协议收据测试通过；模拟器实看登录、注册页面，不作为实体设备验收。最终包只含自身的1份隐私清单，无地图 SDK、受保护的定位 API、短信接口和未获许可的跑腿海报。主 App 与小组件均已核对 `group.com.mychuannong.app` 共享权限。协议为 `2026-11-17.1` / 第10版；现网保留第6—9版兼容并接受第10版，四份协议网页在主域和 www 域均直接返回200且正文一致。

已建立专用 TestFlight 外部测试组并加入用户指定的测试员；构建7已提交Beta审核，状态为“正在等待审核”，批准后自动通知测试员。远程 iPhone 不在本地 Mac 旁，优先使用 TestFlight 邀请安装；首次外部测试需Beta审核。QQ群入口已在后台启用用户提供的群号及QQ直达链接，客户端点击时读取；实际唤起QQ仍待安装QQ的实体设备验证。正式 App Review 尚未重提，仍须取得最终实体设备视频并补齐独立平台审核账号。详细路径和录制顺序见 [本次审核修复记录](docs/APP_REVIEW_20261117.md)。归档、IPA、日志、协议原稿与私密账号留在本机分类目录，不进入 Git。

## 苹果上架准备历史（2026-11-10）

App 备案已通过，正式备案号已写入本机 Release 配置和 App Store Connect。`0.1.0 (1)` 签名构建已上传、处理完成并关联版本草稿；App Store 状态为「准备提交」，尚未提交审核，发布方式为手动。已为 iPhone 和 iPad 各添加三张无真实账号数据的模拟器截图，补充商店推广文字；TestFlight 的「内部测试」组已关联该构建，目前没有测试员，未发送邀请。最新草稿和待补资料见 [苹果上架资料与待办](../outputs/iOS上架准备-20261110/苹果上架资料与待办.md)。

正式隐私文本、公开隐私政策网址、第三方内容版权确认、审核联系人和审核测试账号仍待补齐；现有官网隐私入口显示「文档尚未发布」。短信服务和地图实体设备验证也应按实际情况完成。以下日期较早的文字仅作为历史记录，不代表当前备案或上传状态。

## Xcode 可视化

打开 `MyChuannong.xcodeproj`，Scheme `MyChuannongDevelopment`。`App/AppVisualPreview.swift` 的 Canvas 使用真实页面组件；可切换首页、服务、我的。固定 Canvas 后可在左侧阅读/修改其他 Swift 文件，右侧继续显示界面。预览不读取真实登录缓存、不上报设备，服务动态明确标注样例。

开发 Bundle ID：`com.mychuannong.app.development`；Widget：`com.mychuannong.app.development.widgets`。本机模拟器已安装的版本可能落后于正在编辑的代码，编译成功并不等于已经安装或通过业务测试。

2026-10-23 增加独立 `MyChuannongRelease` Scheme，运行使用 `Release` 优化构建，显示名为「我的川农」，Bundle ID 为 `com.mychuannong.app`，Widget 为 `com.mychuannong.app.widgets`，App Group 为 `group.com.mychuannong.app`。Debug 仍使用开发标识与 Canvas；Release 不包含调试预览入口。用户要求重新体验首次安装时，已重置原 iPhone 17 Pro 测试模拟器并安装此 Release 包，首次协议未代为同意。

Release 本机预览命令：

```sh
xcodebuild -project my-chuannong-ios/MyChuannong.xcodeproj \
  -scheme MyChuannongRelease -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .work/ios-release-build CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- build
```

正式签名团队、App Group 与备案信息使用 `Config/Release.local.xcconfig.example` 对应的忽略文件单独配置。Release 不读取开发版 Local.xcconfig。模拟器 Release 包不等于可上传 App Store 的签名归档。

App Store 云端分发签名：若先用 `CODE_SIGNING_ALLOWED=NO` 生成中间归档，导出前须运行 `python3 Scripts/prepare-app-store-archive.py /完整路径/我的川农.xcarchive`。该步骤为主 App 和课表小组件写入临时 ad-hoc 签名，保留 `group.com.mychuannong.app` 共享权限，随后再用 Xcode 的 `app-store-connect`、`signingStyle=automatic` 导出或上传。中间归档不能直接安装或提交；最终 IPA 必须同时核对两个可执行包的 Apple Distribution 签名、共享权限、相同版本号及权限用途说明。仅检查描述文件包含 App Group 不足以证明最终签名保留了该权限。

2026-11-08：已生成并校验 Apple Distribution 签名的候选 IPA，签名证书与当前 App 备案信息核对一致；候选包尚未上传或提交。当前协议及其第 8 版收据是等待法务最终文本的技术草稿，现网仍需部署匹配的收据兼容和手机号验证码接口，不能将此候选包当作可发布版本。短信服务已开通，但资质、签名、模板和运营商报备均未完成。地图仍需实体 iPhone 验证并核对高德隐私披露。备案通过后，在本机 Release 配置中填写实际 **App 备案号** `APP_FILING_NUMBER` 并重新归档；设置为空时“关于”页面不会显示虚构编号。

同日稍后用户确认白底“川”字绿叶作为统一图标；旧叶子候选包仅作历史记录。新图标候选包仍受上述协议、后台、备案和真机验收条件限制。当前备案订单里提交的是旧图标，正式上架前需按审核结果核对是否需要更新备案信息。

## 构建与依赖

从总工作区根目录执行：

```sh
python3 my-chuannong-ios/Scripts/update-project.py
xcodebuild -project my-chuannong-ios/MyChuannong.xcodeproj \
  -scheme MyChuannongDevelopment -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .work/ios-build CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- build
```

从 iOS 目录执行 `swift Scripts/generate-original-brand-icon.swift`，将用户确认的白底“川”字绿叶母版复制到应用内品牌资源，再执行 `swift Scripts/generate-assets.swift` 生成标准 AppIcon。母版和矢量源文件保存在 `DesignReferences/MyChuannongBrand/`；不得重新使用旧的单片绿叶图案。iOS 不再安装或链接高德 SDK。

复制 `Config/Local.xcconfig.example` 为 `Config/Local.xcconfig` 填本机签名与 App Group，不要将私密配置加入 Git。离线协议资源从本机 `MYCHUANNONG_LEGAL_DIR` 读取，不把包含公司联系方式的原始文档或私密账号纳入仓库。

核心规则验收命令：`swift test --package-path my-chuannong-ios/Core`。本轮 34 项核心测试已通过；模拟器与 unsigned 真机目标构建通过。真实学校绑定、课表主动刷新、App 重开与模拟器完整重启后的免重输密码刷新、真实教务超时响应后的自动恢复已通过，2026-10-23 已完成本轮自有服务内容、预约回传、关注通知等测试，完整范围与限制见迁移记录。模拟器必须启用本机 ad-hoc 签名以生成 Keychain/App Group 权限；`CODE_SIGNING_ALLOWED=NO` 只用于编译检查，不能用于安装后登录测试。真实账号与验证码不放在命令行、源码或日志中。

最新学校链路回归：川农 e 会话独立于教务绑定，统一认证、一网通办、学工、综测、周点名、节假日去向及缴费共享学校认证；学工先经官方 mobile SSO 入口取得业务会话再回到所选子页。教务已去掉保存勾选，验证成功默认写入本机 Keychain；隐私正文按用户要求暂不修改。认证页聚焦维持设备宽度与缩放比例，键盘遮挡时允许必要滚动。最终构建完整重启模拟器后的课表刷新与学工会话恢复已实测。详细证据与尚未验收的产品功能见 `docs/IOS_MIGRATION.md`。

## 代码入口

- `App/SchoolSession.swift`、`SchoolViews.swift`、`SchoolSSOBroker.swift`：先 VPN 后教务、身份验证、非同步 Keychain 会话及有限恢复。
- `App/HomeView.swift`、`AcademicViews.swift`、`TimetableImportView.swift`：学习数据和课表刷新/核对导入。
- `App/ServicesView.swift`、`PlatformContent.swift`、`CommunityViews.swift`、`MarketplaceView.swift`、`CampusServiceViews.swift`：原服务分类和平台业务。
- `App/ProfileViews.swift`、`AccountSettings.swift`、`LegalDocuments.swift`：我的、账号与隐私设置。
- `App/AcademicDataStore.swift`、`LocalToolsViews.swift`、`CampusMapView.swift`：校历、提醒、本机工具与校园地图。
- `Widget/SchoolWidgets.swift`、`App/Widgets.swift`：最小共享课表数据与桌面小组件。
- `Core/Sources/ChuannongCore/`：接口、解析、URL/身份/会话规则，禁止上传学校学习数据。

公告保留服务头条下方的原“服务动态”，不在首页新增栏目。云岭星球只做局部参考，未导入其源码。后端与业务域名继续复用；新增 iOS 设备和版本策略已部署到现有后台并通过双端上报验收。用户本机文档实际包含同一学号的川农 e 与教务两套凭据；最终交付必须通过这两段真实登录、主动刷新与登录保存/恢复测试，并明确实际观察时长和未通过项，不能宣称已完成两位学生实测。

2026-10-23：独立高德 iOS 开发 Key 已创建并配置；课表周次单行、预约收键盘/机构名/刷新、通知最新一条去重已修复。后端 135 项、iOS 核心 34 项通过。完整验收状态及生产测试清理见 `docs/IOS_MIGRATION.md`。


2026-10-23 学校更新教务登录方式后，iOS 已改为一次川农 e 认证：通过校园 VPN 自动完成教务 SSO 与学号绑定，去掉第二步学号/教务密码输入；成功后清除旧教务密码，仅保留本机学校会话。当前 Release 已通过真实学校认证与课表/成绩/考试同步、持久化恢复，以及 App 冷启动后绑定和完整成绩详情的 UI 回归。37 项核心测试、模拟器 Release 与 unsigned 真机编译通过；长期会话时效仍由学校决定。详细范围见 `docs/IOS_MIGRATION.md` 最新记录。

2026-10-26 学校刷新修复：刷新统一处理 VPN/教务/CAS 过期，先复用学校会话，确需本人验证时直接进入全屏原生学校认证页；验证后继续同一页面刷新，失败保留缓存。新登录在学校确认本人后将川农 e 学号及密码存入不可同步的本机 Keychain；旧安装没有该密码时需补存一次。学校当前密码登录要求本人完成验证码，不能宣称所有过期情况均可无交互登录。协议更新为 `2026-10-26.1` / 第 7 版，重新同意后才恢复上报；生产仅增加新版协议记录兼容，学校凭据不上报。

## 当前源码同步

2026-11-01 的完整克隆、构建与外部配置说明见 [SOURCE_STATE.md](SOURCE_STATE.md)。如本文保留早期冻结版本或交付分支描述，以本次源码接手说明及实际检出的提交为准。
