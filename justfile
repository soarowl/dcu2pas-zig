debug:
    zig build \
        -Dbuild_date=`date +"%Y-%m-%dT%H:%M:%S%z"` \
        -Dgit_commit=`git rev-parse --short HEAD` \
        --summary all

safe:
    zig build -Doptimize=ReleaseSafe \
        -Dbuild_date=`date +"%Y-%m-%dT%H:%M:%S%z"` \
        -Dgit_commit=`git rev-parse --short HEAD` \
        --summary all

fast:
    zig build -Doptimize=ReleaseFast \
        -Dbuild_date=`date +"%Y-%m-%dT%H:%M:%S%z"` \
        -Dgit_commit=`git rev-parse --short HEAD` \
        --summary all
