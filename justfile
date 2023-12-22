build:
    zig build -Doptimize=ReleaseFast \
        -Dbuild_date=`date +"%Y-%m-%dT%H:%M:%S%z"` \
        -Dgit_commit=`git rev-parse --short HEAD` \
        --summary all