#!/usr/bin/env bash
echo "build java wrapper"

# cd to script's directory
pushd `dirname $0` > /dev/null

#settings according to os
dl="so"
dis_omp=0
platform="linux"

if [ $(uname) == "Darwin" ]; then
  export JAVA_HOME=$(/usr/libexec/java_home)
  dl="dylib"
  #change this to 0 if your compiler support openmp
  dis_omp=1
  platform="osx"
fi

cd ..
make jvm no_omp=${dis_omp}
cd jvm-packages
echo "move native lib"

libPath="xgboost4j-native-"${platform}"/src/main/resources/lib"
if [ ! -d "$libPath" ]; then
  mkdir -p "$libPath"
fi

rm -f ${libPath}/libxgboost4j.${dl}
mv lib/libxgboost4j.so ${libPath}/libxgboost4j.${dl}
# copy python to native resources
cp ../dmlc-core/tracker/dmlc_tracker/tracker.py xgboost4j/src/main/resources/tracker.py
# copy test data files
mkdir -p xgboost4j-spark/src/test/resources/
cd ../demo/regression
python mapfeat.py
python mknfold.py machine.txt 1
cd -
cp ../demo/regression/machine.txt.t* xgboost4j-spark/src/test/resources/
cp ../demo/data/agaricus.* xgboost4j-spark/src/test/resources/
popd > /dev/null
echo "complete"
