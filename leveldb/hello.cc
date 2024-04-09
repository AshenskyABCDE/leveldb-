#include <assert.h>
#include <string.h>
#include <leveldb/db.h>
#include <iostream>
using namespace leveldb;

int main(){
    leveldb::DB* db;
    leveldb::Options options;
    options.create_if_missing = true;
    // 打开一个数据库，不存在就创建
    leveldb::Status status = leveldb::DB::Open(options, "/tmp/testdb", &db);
    assert(status.ok());

   // 插入一个键值对
    status = db->Put(leveldb::WriteOptions(), "hello", "LevelDB");
    assert(status.ok());

   // 读取键值对
    std::string value;
    status = db->Get(leveldb::ReadOptions(), "hello", &value);

    assert(status.ok());
    std::cout << value << std::endl;

    delete db;
    return 0;
}