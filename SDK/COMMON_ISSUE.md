# 常见问题

## 错误码

[错误码信息查看](http://doc.qcloudtrtc.com/md_introduction_trtc_ErrorCodes.html)

## IOS

### 打包运行crash

排查是否IOS14以上的debug模式问题，[官方说明](https://flutter.cn/docs/development/ios-14#launching-debug-flutter-without-a-host-computer)

### Run报错，Invalid Podfile file: no implicit conversion of nil into String

![图示](https://flutter-im-trtc-1256635546.cos.ap-guangzhou.myqcloud.com/1.png)
解决方案：和flutter版本有关系，缺少编译产物，可以尝试切换不同版试试，已知Flutter 1.24.0-4.0和Flutter 1.24.0-2.0没有问题

### 真机调试报错，因为没有签名，如图

![图片](https://flutter-im-trtc-1256635546.cos.ap-guangzhou.myqcloud.com/9.png)
![图片](https://flutter-im-trtc-1256635546.cos.ap-guangzhou.myqcloud.com/2.png)
解决方案：购买苹果证书，配置，签名，就可以在真机上调试，已购买证书，在target > signing & capabilities配置

### 对插件内的swift文件做了增删，可能存在build时查找不到对应文件

解决方案：在主工程目录的ios文件路径下`pod install`即可

### Run报错，Info.plit, error: No value at that key path or invalid key path: NSBonjourServices

解决方案：`flutter clean`再重新运行

### Pod install报错

![img](https://flutter-im-trtc-1256635546.cos.ap-guangzhou.myqcloud.com/3.png)
分析：报错信息里面提示`pod install`的时候没有`generated.xconfig`文件，这个是flutter编译后的产物。新项目，或者执行了`flutter clean`后，都不存在这个产物，所以运行报错，根据提示需要执行`flutter pub get`
解决方案：执行`flutter pub get`可以解决

### Run的时候ios版本依赖报错

![img](https://flutter-im-trtc-1256635546.cos.ap-guangzhou.myqcloud.com/8.png)
分析：如果pods的target版本，无法满足所依赖的插件，会报错，原因可能是修改了pods的target导致
解决方案：修改报错的target到对应的版本

### iOS无法显示视频（Android是好的）

请确认 io.flutter.embedded_views_preview为YES在你的info.plist中

### 更新sdk版本后，iOS CocoaPods 运行报错

* 删除ios目录下Podfile.lock文件
* 执行`pod repo update`
* 执行`pod install`
* 重新运行

## Android

### Android Manifest merge failed编译失败

![img](https://main.qcloudimg.com/raw/7a37917112831488423c1744f370c883.png)

请打开/example/android/app/src/main/AndroidManifest.xml文件。

1.将xmlns:tools="http://schemas.android.com/tools" 加入到manifest中

2.将tools:replace="android:label"加入到application中。

## Web
### flutter run -d chrom无法运行
![img](https://imgcache.qq.com/operation/dianshi/other/web.a1a4d03228c512b75db7a5367243f28e0bb82fc4.png)
* 执行flutter clean
* 重新运行
### 部分接口不支持
```
 <TRTC Wrapper> web sdk not supper xxxx
```
出现上面类似的日子表示TRTC Web SDK 暂时不支持该接口