# CMake generated Testfile for 
# Source directory: /root/code/leveldbStudy/leveldb
# Build directory: /root/code/leveldbStudy/leveldb/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(leveldb_tests "/root/code/leveldbStudy/leveldb/build/leveldb_tests")
set_tests_properties(leveldb_tests PROPERTIES  _BACKTRACE_TRIPLES "/root/code/leveldbStudy/leveldb/CMakeLists.txt;365;add_test;/root/code/leveldbStudy/leveldb/CMakeLists.txt;0;")
add_test(c_test "/root/code/leveldbStudy/leveldb/build/c_test")
set_tests_properties(c_test PROPERTIES  _BACKTRACE_TRIPLES "/root/code/leveldbStudy/leveldb/CMakeLists.txt;391;add_test;/root/code/leveldbStudy/leveldb/CMakeLists.txt;394;leveldb_test;/root/code/leveldbStudy/leveldb/CMakeLists.txt;0;")
add_test(env_posix_test "/root/code/leveldbStudy/leveldb/build/env_posix_test")
set_tests_properties(env_posix_test PROPERTIES  _BACKTRACE_TRIPLES "/root/code/leveldbStudy/leveldb/CMakeLists.txt;391;add_test;/root/code/leveldbStudy/leveldb/CMakeLists.txt;402;leveldb_test;/root/code/leveldbStudy/leveldb/CMakeLists.txt;0;")
subdirs("third_party/googletest")
subdirs("third_party/benchmark")
