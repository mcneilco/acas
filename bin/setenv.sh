# Example:
#export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib:$LD_LIBRARY_PATH
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    LD_LIBRARY_PATH=/usr/lib/jvm/java-1.8.0/jre/lib/amd64:/usr/lib/jvm/java-1.8.0/jre/lib/amd64/server/:/R-4.4.0/lib
elif [ "$ARCH" = "aarch64" ]; then
    LD_LIBRARY_PATH=/usr/lib/jvm/java-1.8.0/jre/lib/aarch64:/usr/lib/jvm/java-1.8.0/jre/lib/aarch64/server/:/R-4.4.0/lib
fi

export LD_LIBRARY_PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
R_LIBS=/home/runner/build/r_libs
JAVA_HOME=/usr/lib/jvm/java-1.8.0
