PHP container to debug with GDB.

## How to use

```
docker run --security-opt seccomp=unconfined hanhan1978/php-debug:latest bash
gdb php
(gdb) run ***.php
```