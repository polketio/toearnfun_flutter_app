# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in D:\development\AppData\sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# 代码混淆压缩比，在0~7之间
-optimizationpasses 5

# 指定不使用大小写混用的类名，默认情况下混淆后的类名可能同时包含大写小字母。这在某些对大小写不敏感的系统（如windowns）上解压时，可能存在文件被相互覆盖的情况。
-dontusemixedcaseclassnames

# 指定不去忽略非公共库的类
-dontskipnonpubliclibraryclasses

# 指定不去忽略非公共的库的类的成员
-dontskipnonpubliclibraryclassmembers

# 指定不对class进行预校验，默认情况下，在编译版本为micro或者1.6或更高版本时是开启的。但编译成Android版本时，预校验是不必须的，配置这个选项可以节省一点编译时间。
-dontpreverify

# 有了verbose这句话，混淆后就会生成映射文件
# 包含有类名->混淆后类名的映射关系
# 然后使用printmapping指定映射文件的名称
-verbose
-printmapping priguardMapping.txt

# 混淆时所采用的算法
-optimizations !code/simplification/artithmetic,!field/*,!class/merging/*

# 避免混淆注解
-keepattributes *Annotation*

# 避免混淆泛型
# 这在JSON实体映射时非常重要，比如fastJson
-keepattributes Signature

# 抛出异常时保留代码行号
-keepattributes SourceFile,LineNumberTable

# 保持方法不被混淆
#-keep class ** { *; }
-keep class com.Ls.skipBle.ReceiveDataCallback{*; }
-keep class com.Ls.skipBle.SkipBleReceivePack{*; }
-keep class com.Ls.skipBle.SkipBleSendPack{*; }
-keep class com.Ls.skipBle.SkipBleUUIDs{*; }
-keep class com.Ls.skipBle.SkipParamDef{*; }
-keep class com.Ls.skipBle.SkipDisplayData{
    public int get*();
    public int get*();
}
-keep class com.Ls.skipBle.SkipResultData{
    public int get*();
    public int get*(int);
}
