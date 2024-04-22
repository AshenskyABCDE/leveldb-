### leveldb源码阅读的学习笔记
本人打算通过用日记笔记的形式来完成学习记录，并通过阅读leveldb源码学习C++知识以及存储相关的知识。错误难免，如果你想和我一起学习，欢迎来加我好友，一起学习。
2024/4/9 学习了leveldb内存分配相关的原理，具体在util文件里的arena.cc和 arena.h 区别于常规的内存分配频繁调用影响性能，先分配一个4KB的内存，然后根据当前大小进行进一步分配，但似乎这样也会浪费一些内存？对于释放内存，不支持单独释放某个块，而是只能销毁整个arena

2024/4/10 学习了atomic里的内存序，尤其知道了relax因为重排和没有内存屏障 所以性能会好一点。
先推荐一些atomic的博客
https://zhuanlan.zhihu.com/p/663652267

https://www.cnblogs.com/kekec/p/14470150.html

这里说一下我的理解，为了让内存顺序和代码顺序一样，设置了内存屏障，一般出现这个问题是由于CPU和编译器优化导致的。因此我们究竟想用什么顺序来访问，便有了六种内存序。其中release-acquire可以实现自旋锁这一操作。总而言之，C++ 并发编程中这些操作很常见，leveldb源码阅读的过程正好有见识到的机会。

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
  //    state_[0..3] == length of message <br>
  //    state_[4]    == code <br>
  //    state_[5..]  == message <br>

2024/4/11 阅读了coding编码部分，leveldb的编码对于整数类型可以分为定长编码和变长编码，可分为7位，如果沾满了 最高位填1
比如说 0000111 1000100 1000000 可变成 (1)1000000 (1)1000100 (0)0000111 <br> <br>
这样可以节省空间使用 <br>
对于字符串就会先记录一个长度编码，后面跟编码，比如说hello，长度为5，所以长度的编码是0x05 <br>
最终编码就是 05 48 45 4C 4C 4F <br>
这样我们可以预先知道字符串的长度，存储大多数字符串都只要1字节 <br>

2024/4/21 经历期中考试，暂时又可以回来研究源码了
Slice.h里面有一个
```cpp
  Slice(const Slice&) = default;
  Slice& operator=(const Slice&) = default;
```
这里这个构造函数后面写default是什么意思呢？
```cpp
class Obj {
public:
  Obj(int x) : val(x) {} // 一旦定义了带参构造函数，就会不在产生默认构造函数

private:
  int val;
};
```
这个时候 Obj A;就会报错 <br>
随意default就是让这个默认构造函数存在 <br>
正如下 <br>
```cpp
class Obj {
public:
  Obj(int x) : val(x) {} // 一旦定义了带参构造函数，就会不在产生默认构造函数
  Obj() = default;

private:
  int val;
};
```
末尾加delete自然也就是禁用的意思，一般防止拷贝构造函数和移动构造函数

还有末尾加const这是什么意思？
```cpp
class Obj {
public:
    Obj (int x) : val(x) {}
    int print() const { // 可以试试把const取消再运行
        return val;
    }

    Obj() = default;
    //Obj(const Obj&) = delete;
    //Obj& operator=(const Obj&) = delete;
    //Obj& operator= delete;
private:
    int val;
};

int main()
{
    const Obj A(2);// 如果没有指定的const成员变量，就会编译报错，比如上面的print()函数后面没有 const
    cout<<A.print()<<endl;
    Obj B = A;
    cout<<B.print()<<endl;
    Obj C;
    Obj D(A);
    cout<<D.print()<<endl;
}
```
对象实例化、拷贝构造
```cpp
class Obj {
public:
    int print() const {
        return val;
    }
    Obj(int x) : val(x) {
        cout<<"A(int x)"<<endl;
    }
    Obj(const Obj  &A){// 拷贝构造函数
        // 如果不是引用 这里传参相当于Obj tmp = A; 也就是Obj tmp(A)继续调用下去
        // 上述例子也正好说明了为什么Obj X(A)也会调用构造函数，原因是里面会有一个Obj tmp = A;
        cout<<"A(const Obj& A)"<<endl;
        val = A.val;
    }
    Obj& operator=(const Obj &tmp) {
        cout<<"Obj &operator=(const Obj &tmp)"<<endl;
        val = tmp.val;
        return *this;
    }
    //禁止实例化
    //virtual void func1() = 0; 纯虚函数则可进制对类实例化
    //也可将所有构造函数都放进private里，或者所有构造函数后面加delete()
    void fun(Obj tmp){

    }
    Obj() = default;

private:
    int val;
};

int main()
{

    // 实例化三个过程：分配空间、初始化、赋值。
    // 分配完内存，先进行基类的构造过程，然后分配虚函数指针，实例化列表，执行构造函数的函数体这一过程
    const Obj A(2);//A(int x)
    cout<<A.print()<<endl;
    Obj B = A;//A(const Obj& A)
    Obj B1(A);//A(const Obj& A)
    cout<<B.print()<<endl;
    Obj C;
    C = A;//Obj &operator=(const Obj &tmp)
    Obj C1 = A;//A(const Obj& A)
    //上述不一样是以为C已经实例，不需要构造直接赋值即可，而C1没实例需要先构造
    Obj D(A);//A(const Obj& A)
    cout<<D.print()<<endl;
}
```
如果要在const里面修改成员变量，需用mutable变量


