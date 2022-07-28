# TRTC Flutter API-Example 
## 第三方美颜接入
为了保证美颜实现的性能及通用性，我们设计实现了美颜数据预处理插件，视频帧数据会抛到这个插件里面，用户只需要实现ITXCustomBeautyProcesser方法，在onProcessVideoFrame里面处理美颜数据即可。

pub地址: tencent_trtc_cloud: ^2.3.1

Demo可参考'进阶功能-美颜预处理'

## Android集成方式
### 美颜预处理
实现第三方美颜关键就是要实现2个接口：ITXCustomBeautyProcesserFactory 和 ITXCustomBeautyProcesser。第三方美颜处理的具体操作在ITXCustomBeautyProcesser的onProcessVideoFrame方法实现。
代码详情可参考 MainActivity.java的代码

![](https://dscache.tencent-cloud.cn/upload/uploader/beauty-android1-min2-d490132a69a899a3edfea720db23a6d4b266a41b.png)

### 注册第三方美颜对象
根据自己的业务需求在需要的地方调用TRTCCloudPlugin的register(ITXCustomBeautyProcesserFactory beautyProcesserFactory)方法来注册美颜实例

![](https://dscache.tencent-cloud.cn/upload/uploader/beauty-android2-d3ccab47c778640d66e8794705b00c90403d0f52.png)

### 开启美颜
在Flutter层，调用Future `enableCustomVideoProcess(bool enable)`接口进行开启或关闭自定义美颜接口，安卓这边开启美颜后会有一个灰色的效果。

## iOS集成方式
### 美颜预处理
实现第三方美颜关键就是要实现2个接口：ITXCustomBeautyProcesserFactory 和 ITXCustomBeautyProcesser。第三方美颜处理的具体操作在ITXCustomBeautyProcesser的onProcessVideoFrame方法实现。
代码详情可参考 AppDelegate.swift的代码

![](https://dscache.tencent-cloud.cn/upload/uploader/beauty-ios1-c4e4afe6ab70fb2ddd86d3ca0f027752f5b50a3d.png)

### 注册第三方美颜对象
根据自己的业务需求在需要的地方调用TencentTRTCCloud的register(ITXCustomBeautyProcesserFactory beautyProcesserFactory)方法来注册美颜实例

![](https://dscache.tencent-cloud.cn/upload/uploader/beauty-ios2-61f93a02e5e247788ca7ae947e35c2401da9f633.png)

### 开启美颜
在Flutter层，调用Future `enableCustomVideoProcess(bool enable)`接口进行开启或关闭自定义美颜接口，iOS这边开启美颜后会有一个亮色的效果。

