### leveldb源码阅读的学习笔记
2024/4/9 学习了leveldb内存分配相关的原理，具体在util文件里的arena.cc和 arena.h 区别于常规的内存分配频繁调用影响性能，先分配一个4KB的内存，然后根据当前大小进行进一步分配，但似乎这样也会浪费一些内存？对于释放内存，不支持单独释放某个块，而是只能销毁整个arena

2024/4/10 学习了atomic里的内存序，尤其知道了relax因为重排和没有内存屏障 所以性能会好一点。
也学习了一写atomic的用法
https://leetcode.cn/problems/print-in-order/
https://leetcode.cn/problems/print-foobar-alternately/description/
这两个可以练习一下对atmoic的掌握

阅读源码自然离不开四种类型转换，查阅资料之后发现转为枚举，还有两个类之间的转换是static_cast，dynamic_cast可以实现派生类转换为基类，也可以将多态下的基类指针转换为派生类，但是如果没有虚函数进行多态 基类转派生类会报错
，const_cast是将一个const类型转化成非const类型，reinterpret_cast常用于指针之间的转换。
```cpp
  Code code() const {
    return (state_ == nullptr) ? kOk : static_cast<Code>(state_[4]);
  }
```
关于leveldb字符串的处理是Slice.cpp 错误状态码相关是status.cpp
错误码相关的结构是这样的
  //    state_[0..3] == length of message
  //    state_[4]    == code
  //    state_[5..]  == message
