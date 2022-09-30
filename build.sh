#!/bin/bash
# this is a test case
buildStaticA(){
    cd funcA
    echo "Build Static A"
    gcc -c funcA.c -shared -fPIC -o funcA.o
    ar -crv libstaticA.a funcA.o
    echo "=======nm libstaticA.a======"
    nm libstaticA.a
    cd ..
}

buildStaticB(){
    cd funcB
    echo "Build Static B"
    path=""
    lib=""
    case "$1" in
        1)
        path=funcA
        lib=staticA
        ;;
        2)
        path=funcA
        lib=sharedA
        ;;
        *)
        ;;
    esac
    gcc -c -I${PWD}/../${path}/ funcB.c -L${PWD}/../${path}/ -l${lib}
    ar -crv libstaticB.a funcB.o
    echo "=======nm libstaticB.a======"
    nm libstaticB.a
    cd ..
}

buildSharedA(){
    echo "Build Shared A"
    cd funcA
    gcc -c funcA.c
    gcc -shared -fPIC -o libsharedA.so funcA.o
    echo "=======nm libsharedA.so======"
    nm libsharedA.so | grep "func*"
    cd ..
}

buildSharedB(){
    echo "Build Shared B"
    cd funcB
    path=""
    lib=""
    case "$1" in
        1)
        path=funcA
        lib=staticA
        ;;
        2)
        path=funcA
        lib=sharedA
        ;;
        *)
        ;;
    esac
    echo ${lib}
    #gcc -c -I${PWD}/../${path}/ funcB.c -L${PWD}/../${path}/ -l${lib}
    gcc -o funcB.o -c funcB.c -I${PWD}/../${path}/
    gcc -o libsharedB.so funcB.o -shared -fPIC -L${PWD}/../${path}/ -l${lib}
    #gcc -shared -fPIC -o libsharedB.so funcB.c -I${PWD}/../${path}/ -L${PWD}/../${path}/ -l${lib}
    echo "=======nm libsharedB.so======"
    nm libsharedB.so | grep "func*"
    cd ..
}

buildMain(){
    echo "Build Main"
    rm a.out *.a -rf

    case "$1" in
        1)
        # ./build.sh 1 1 1  a b 都是静态库，一起使用A和B
        gcc -I${PWD}/funcB/ -I${PWD}/funcA/ main.c -L${PWD}/funcB/ -lstaticB -L${PWD}/funcA/ -lstaticA
        echo "=======nm a.out======"
        nm a.out | grep "func*"
        echo "=======run a.out======"
        ./a.out
        ;;
        2)
        # ./build.sh 1 1 2  a b 都是静态库，独立使用B，结论是不可以
        gcc -I${PWD}/funcB/  main.c -L${PWD}/funcB/ -lstaticB
        ;;
        3)
        # ./build.sh 1 1 3  a b 都是静态库，打包使用A和B
        ar -crT libstaticAB.a ${PWD}/funcA/libstaticA.a ${PWD}/funcB/libstaticB.a
        echo "=======nm libstaticAB.a======"
        nm libstaticAB.a
        gcc -I${PWD}/funcB/ main.c -L${PWD} -lstaticAB
        echo "=======nm a.out======"
        nm a.out | grep "func*"
        echo "=======run a.out======"
        ./a.out
        ;;
        4)
        # ./build.sh 2 1 4   a是动态，b是静态，一起使用a和b
        gcc -I${PWD}/funcB/ -I${PWD}/funcA/ main.c -L${PWD}/funcB/ -lstaticB -L${PWD}/funcA/ -lsharedA
        echo "=======nm a.out======"
        nm a.out | grep "func*"
        echo "=======run a.out======"
        export LD_LIBRARY_PATH=${PWD}/funcA;./a.out
        ;;
        5)
        # ./build.sh 2 1 5   a是动态，b是静态，独立使用b不可以
        gcc -I${PWD}/funcB/  main.c -L${PWD}/funcB/ -lstaticB
        ;;
        6)
        # ./build.sh 1 2 6  a是静态，b是动态，独立使用b就可以了
        gcc -I${PWD}/funcB/ main.c -L${PWD}/funcB/ -lsharedB
        echo "=======nm a.out======"
        nm a.out | grep "func*"
        echo "=======run a.out======"
        export LD_LIBRARY_PATH=${PWD}/funcB;./a.out
        ;;
        7)
        # ./build.sh 2 2 7   a 是动态，b是动态，一起使用a和b
        gcc -I${PWD}/funcB/ -I${PWD}/funcA/ main.c -L${PWD}/funcB/ -lsharedB -L${PWD}/funcA/ -lsharedA
        echo "=======nm a.out======"
        nm a.out | grep "func*"
        echo "=======run a.out======"
        export LD_LIBRARY_PATH=${PWD}/funcB:${PWD}/funcA;./a.out
        ;;
        8)
        # ./build.sh 2 2 8   a是动态，b是动态，独立使用b不可以
        gcc -I${PWD}/funcB/  main.c -L${PWD}/funcB/ -lsharedB
        echo "=======nm a.out======"
        nm a.out | grep "func*"
        echo "=======run a.out======"
        export LD_LIBRARY_PATH=${PWD}/funcB:${PWD}/funcA;./a.out
        ;;
        *)
        echo "do nothing"
        ;;
    esac
}

clear() {
find . -name "*.o" | xargs rm
find . -name "*.a" | xargs rm
find . -name "*.so" | xargs rm
rm a.out
}

clear

case "$1" in
    1)
    buildStaticA
    ;;
    2)
    buildSharedA
    ;;
    *)
    echo "do nothing"
    ;;
esac

case "$2" in
    1)
    buildStaticB $1
    ;;
    2)
    buildSharedB $1
    ;;
    *)
    echo "do nothing"
    ;;
esac

buildMain $3
