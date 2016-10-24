### Usage

runner.sh should self configure as master or slave and do approximately:

```
git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
cd linux-stable && make defconfig

export DISTCC_HOSTS=$(getent hosts distcc | awk '{ printf "%s,cpp,lzo ", $1 }')
#distcc --show-hosts
eval $(distcc-pump --startup)
export PATH=/usr/lib/distcc:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

fakeroot make-kpkg --initrd --append-to-version=testbuild --revision=0.1 kernel_image
```
