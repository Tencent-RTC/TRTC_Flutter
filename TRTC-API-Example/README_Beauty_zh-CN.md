# TRTC Flutter API-Example 
## 第三方美颜接入
为了保证美颜实现的性能及通用性，我们设计实现了美颜数据预处理插件，视频帧数据会抛到这个插件里面，用户只需要实现ITXCustomBeautyProcesser方法，在onProcessVideoFrame里面处理美颜数据即可。
![](https://upload-dianshi-1255598498.file.myqcloud.com/beauty-d54f6ba86fc1437e37dd50975782e912828f751b.png)

Demo可参考'进阶功能-美颜预处理'

## Android集成方式
### 美颜预处理
实现第三方美颜关键就是要实现2个接口：ITXCustomBeautyProcesserFactory 和 ITXCustomBeautyProcesser。第三方美颜处理的具体操作在ITXCustomBeautyProcesser的onProcessVideoFrame方法实现。
代码详情可参考 MainActivity.java的代码

![](https://upload-dianshi-1255598498.file.myqcloud.com/beauty-android1-873332eb0272583a8b04c33802905d7bdee5a0b2.png)

### 注册第三方美颜对象
根据自己的业务需求在需要的地方调用TRTCCloudPlugin的register(ITXCustomBeautyProcesserFactory beautyProcesserFactory)方法来注册美颜实例

![](https://upload-dianshi-1255598498.file.myqcloud.com/beauty-android2-bc6ccbade4073953d24c1383762609a25a7e1b6e.png)

### 开启美颜
在Flutter层，调用Future `enableCustomVideoProcess(bool enable)`接口进行开启或关闭自定义美颜接口，安卓这边开启美颜后会有一个灰色的效果。

## iOS集成方式
### 美颜预处理
实现第三方美颜关键就是要实现2个接口：ITXCustomBeautyProcesserFactory 和 ITXCustomBeautyProcesser。第三方美颜处理的具体操作在ITXCustomBeautyProcesser的onProcessVideoFrame方法实现。
代码详情可参考 AppDelegate.swift的代码

![](https://upload-dianshi-1255598498.file.myqcloud.com/beauty-ios1-00c083f6d1b6ae13b2e5bb76b3b3987bee271fd8.png)

### 注册第三方美颜对象
根据自己的业务需求在需要的地方调用TencentTRTCCloud的register(ITXCustomBeautyProcesserFactory beautyProcesserFactory)方法来注册美颜实例

![](https://upload-dianshi-1255598498.file.myqcloud.com/beauty-ios2-e96a395282c46deafd2d9a831f0e75c6e9503aac.png)

### 开启美颜
在Flutter层，调用Future `enableCustomVideoProcess(bool enable)`接口进行开启或关闭自定义美颜接口，iOS这边开启美颜后会有一个亮色的效果。

