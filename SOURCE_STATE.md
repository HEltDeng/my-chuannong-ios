# 源码接手说明 · 2026-11-01

本仓库同步截至本次整理的本机现有源码。源码同步不等于重新发布生产服务、App Store 或 APK。

## 获取完整源码

```sh
git clone --recurse-submodules https://github.com/HEltDeng/my-chuannong-ios.git
cd my-chuannong-ios
git submodule update --init --recursive
```

Xcode；先 python3 Scripts/install-amap.py --download，再 python3 Scripts/update-project.py。执行 swift test --package-path Core；xcodebuild -project MyChuannong.xcodeproj -scheme MyChuannongRelease -configuration Release -destination "generic/platform=iOS Simulator" CODE_SIGNING_ALLOWED=NO build 可进行编译验证。安装后登录验收需按 README 使用 ad-hoc 签名。

## 保留与排除

保留源码、构建脚本、工程配置、依赖锁定文件、必要应用资源和合成测试。运行数据库、用户上传文件、登录会话、密钥、签名私钥、个人资料、缓存与可重新生成的输出不随仓库分发。

正式签名、地图/短信/外部服务密钥必须在本机配置。源码、依赖和资源可恢复，生产数据和签名身份需用用户自己的独立备份恢复；不能把缺少真实账号或服务配置当成代码缺失。二进制字节还会受工具链、签名和构建时间影响。
