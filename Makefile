#构造
# Configuration
#
# CC
#指定gcc程序
#gcc是GNU C程序编译器，对于UNIX类的脚本程序而言
CC=gcc
#指定静态链接库的路径
LDFLAG_STATIC=-Wl,-Bstatic=/usr/include
# Libraries
ADDLIB=
# Linker flags
# wl选项告诉编译器将后面的参数传给连接器
# -Wl,-Bstatic和-Wl,-Bdynamic。这两个选项是gcc的特殊选项，它会将选项的参数传递给链接器，作为链接器的选项。
# -wl,Bstatic告诉链接器使用-Bstatic选项，该选项是告诉链接器，对接下来的-l选项使用静态链接库
# -wl,-Bdynamic就是告诉链接器对接下来的-l选项使用动态链接
LDFLAG_STATIC=-Wl,-Bstatic
LDFLAG_DYNAMIC=-Wl,-Bdynamic
# 指定加载库
LDFLAG_CAP=-lcap
# $(1),$(2)call函数里规定的参数形式,比如说（1）=20的话   echo $(1)的话就会打印出20
LDFLAG_GNUTLS=-lgnutls-opensslFUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))
LDFLAG_CRYPTO=-lcrypto
LDFLAG_IDN=-lidn
LDFLAG_RESOLV=-lresolv
LDFLAG_SYSFS=-lsysfs

#
# Options
#所有选项
# 变量定义，设置开关

# Capability support (with libcap) [yes|static|no]
# 使用libcap网络数据包捕获函数包对性能进行支持，状态为，是，静态，没有
USE_CAP=yes
# sysfs support (with libsysfs - deprecated) [no|yes|static]
# sysfs是指虚拟文件系统的支持
# libsysfs 访问系统里的设备信息的一个标准库
# 这句话是指是指不使用libsysfs标准库对sysfs进行支持
E_SYSFS=no
# IDN support (experimental) [no|yes|static]
# 对国际域名的支持，状态为，是，静态，没有
USE_IDN=no

# Do not use getifaddrs [no|yes|static]
# 不使用getifaddrs函数获取本机IP地址
WITHOUT_IFADDRS=no
# arping default device (e.g. eth0) []
# 使用arp命令检测默认的设备驱动，网络设备号为eth0
ARPING_DEFAULT_DEVICE=

# GNU TLS library for ping6 [yes|no|static]
# 使用GNU TLS库ping6的状态为是，从而实现加密协议
USE_GNUTLS=yes
# Crypto library for ping6 [shared|static]
# 分享密码类库
USE_CRYPTO=shared
# Resolv library for ping6 [yes|static]
# 使用Resolv类库
USE_RESOLV=yes
# ping6 source routing (deprecated by RFC5095) [no|yes|RFC3542]
# ping6源路由不显示路由的详细的信息
ENABLE_PING6_RTHDR=no

# rdisc server (-r option) support [no|yes]
# rdisc（路由发现守护程序）服务器不支持-r
ENABLE_RDISC_SERVER=no

# -------------------------------------
# What a pity, all new gccs are buggy and -Werror does not work. Sigh.
# CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
#-Wstrict-prototypes: 如果函数的声明或定义没有指出参数类型，编译器就发出警告
#-Wall 打印所有的警告信息
#-g 加入调试信息
#-O3对代码使用3级优化
#-D_GNU_SOURCE这个参数表示你编写符合 GNU 规范的代码
CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -g
CCOPTOPT=-O3
GLIBCFIX=-D_GNU_SOURCE
DEFINES=
LDLIB=

#判断如果过滤掉了参数1中除了静态函数外的其他函数，就将$(1)),$(LDFLAG_STATIC) $(2)这几个变量所代表的库赋给FUNC_LIB
#否则，就将参数2赋给FUNC_LIB
FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))

# USE_GNUTLS: DEF_GNUTLS, LIB_GNUTLS
#对GUNTLS库的使用：DEF_GNUTLS, LIB_GNUTLS
# USE_CRYPTO: LIB_CRYPTO
#对密码库的使用：LIB_CRYPTO
#ifeq是个判别是否相等的关键字，ifneq($(USE_GNUTLS),no)的意思是取出USE_GNUTLS的值看与no是否相等，相等执行下面两条不相等执行else
ifneq ($(USE_GNUTLS),no)
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
	DEF_CRYPTO = -DUSE_GNUTLS
else
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
endif

# USE_RESOLV: LIB_RESOLV
#对RESOLV的使用
#判断RESOLV函数库中函数是否重复
LIB_RESOLV = $(call FUNC_LIB,$(USE_RESOLV),$(LDFLAG_RESOLV))

# USE_CAP:  DEF_CAP, LIB_CAP
#对CAP的使用
#ifeq是个判别是否相等的关键字
#DCAPABILTIES前面加-的意思是 不管这里是否出错,继续处理;如果不加的话,一但有错 就会停止处理了.
ifneq ($(USE_CAP),no)
	DEF_CAP = -DCAPABILITIES
	LIB_CAP = $(call FUNC_LIB,$(USE_CAP),$(LDFLAG_CAP))
endif

# USE_SYSFS: DEF_SYSFS, LIB_SYSFS
#对SYSFS文件系统的使用
#取USE_SYSFS的值与no比较看是否相等，看函数是否重复
ifneq ($(USE_SYSFS),no)
	DEF_SYSFS = -DUSE_SYSFS
	LIB_SYSFS = $(call FUNC_LIB,$(USE_SYSFS),$(LDFLAG_SYSFS))
endif

# USE_IDN: DEF_IDN, LIB_IDN
# 对国际化域名的使用：DEF_IDN,LIB_IDN，判断是否重复
ifneq ($(USE_IDN),no)
	DEF_IDN = -DUSE_IDN
	LIB_IDN = $(call FUNC_LIB,$(USE_IDN),$(LDFLAG_IDN))
endif

# WITHOUT_IFADDRS: DEF_WITHOUT_IFADDRS
#判断是否重复，获取本地IP地址
ifneq ($(WITHOUT_IFADDRS),no)
	DEF_WITHOUT_IFADDRS = -DWITHOUT_IFADDRS
endif

# ENABLE_RDISC_SERVER: DEF_ENABLE_RDISC_SERVER
#对RDISC服务器的设置
ifneq ($(ENABLE_RDISC_SERVER),no)
	DEF_ENABLE_RDISC_SERVER = -DRDISC_SERVER
endif

# ENABLE_PING6_RTHDR: DEF_ENABLE_PING6_RTHDR
#对ping6源路由的使用
ifneq ($(ENABLE_PING6_RTHDR),no)
	DEF_ENABLE_PING6_RTHDR = -DPING6_ENABLE_RTHDR
ifeq ($(ENABLE_PING6_RTHDR),RFC3542)
	DEF_ENABLE_PING6_RTHDR += -DPINR6_ENABLE_RTHDR_RFC3542
endif
endif

# -------------------------------------
IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
IPV6_TARGETS=tracepath6 traceroute6 ping6
TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)

CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)
LDLIBS=$(LDLIB) $(ADDLIB)

UNAME_N:=$(shell uname -n)#将变量复制给UNAME
LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')
TODAY=$(shell date +%Y/%m/%d)
DATE=$(shell date --date $(TODAY) +%Y%m%d)
TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)


# -------------------------------------
#将内核产生的所有无用的文件删除
.PHONY: all ninfod clean distclean man html check-kernel modules snapshot

all: $(TARGETS)

%.s: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@
%.o: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@
$(TARGETS): %: %.o
	$(LINK.o) $^ $(LIB_$@) $(LDLIBS) -o $@
## COMPILE.c=$(CC) $(CFLAGS) $(CPPFLAGS) -c
# $< 依赖目标中的第一个目标名字 
# $@ 表示目标
# $^ 所有的依赖目标的集合 
# 在$(patsubst %.o,%,$@ )中，patsubst把目标中的变量符合后缀是.o的全部删除,  DEF_ping
# LINK.o把.o文件链接在一起的命令行,缺省值是$(CC) $(LDFLAGS) $(TARGET_ARCH)
#
#以ping为例，翻译为：
# gcc -O3 -fno-strict-aliasing -Wstrict-prototypes -Wall -g -D_GNU_SOURCE    -c ping.c -DCAPABILITIES   -o ping.o
#gcc   ping.o ping_common.o -lcap    -o ping
# -------------------------------------
# arping
#设置arping,实现通过地址解析协议，使用arping向目的主机发送ARP报文，通过目的主机的IP获得该主机的硬件地址
DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_arping = $(LIB_SYSFS) $(LIB_CAP) $(LIB_IDN)


ifneq ($(ARPING_DEFAULT_DEVICE),)
DEF_arping += -DDEFAULT_DEVICE=\"$(ARPING_DEFAULT_DEVICE)\"
endif

# clockdiff
#设置clockdiff,使用时间戳来测算目的主机和本地主机的系统时间差。
DEF_clockdiff = $(DEF_CAP)
LIB_clockdiff = $(LIB_CAP)

# ping / ping6
# 是指ping命令，测试另一台主机是否可达
DEF_ping_common = $(DEF_CAP) $(DEF_IDN)
DEF_ping  = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_ping  = $(LIB_CAP) $(LIB_IDN)
DEF_ping6 = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS) $(DEF_ENABLE_PING6_RTHDR) $(DEF_CRYPTO)
LIB_ping6 = $(LIB_CAP) $(LIB_IDN) $(LIB_RESOLV) $(LIB_CRYPTO)

# 列出所有的依赖关系
ping: ping_common.o
ping6: ping_common.o
ping.o ping_common.o: ping_common.h
ping6.o: ping_common.h in6_flowlabel.h

# rarpd
# 通过逆地址解析协议RARP，客户端可以通过硬件地址得到对应的IP地址，rarpd就是处理RARP请求的服务器程序
DEF_rarpd =
LIB_rarpd =

# rdisc
#  rdisc程序根据编译的不同可以程序可以编译成具有或没有服务器功能。
DEF_rdisc = $(DEF_ENABLE_RDISC_SERVER)
LIB_rdisc =

# tracepath
# tracepath可以让我们看到IP数据报从一台主机传到另一台主机所经过的路由。
DEF_tracepath = $(DEF_IDN)
LIB_tracepath = $(LIB_IDN)

# tracepath6
DEF_tracepath6 = $(DEF_IDN)
LIB_tracepath6 =

# traceroute6
DEF_traceroute6 = $(DEF_CAP) $(DEF_IDN)
LIB_traceroute6 = $(LIB_CAP) $(LIB_IDN)

# tftpd
# tftpd程序就是进行tftp服务的服务程序。
DEF_tftpd =
DEF_tftpsubs =
LIB_tftpd =

#列出依赖关系
tftpd依赖与tftpsubs.o文件
tftpd.o和tftpsubs.o文件依赖于tftp.h文件
tftpd: tftpsubs.o
tftpd.o tftpsubs.o: tftp.h

# -------------------------------------
# ninfod
# @表示makefile执行这条命令时不显示出来
# 在"set -e"之后出现的代码，一旦出现了返回值非零，整个脚本就会立即退出
ninfod:
	@set -e; \
		if [ ! -f ninfod/Makefile ]; then \#进行压缩和解压缩
			cd ninfod; \
			./configure; \
			cd ..; \
		fi; \
		$(MAKE) -C ninfod

# -------------------------------------
# modules / check-kernel are only for ancient kernels; obsolete
# 仅对内核版本较低的内核进行检测
check-kernel:
ifeq ($(KERNEL_INCLUDE),)
	@echo "Please, set correct KERNEL_INCLUDE"; false
else
	@set -e; \
	if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \
		echo "Please, set correct KERNEL_INCLUDE"; false; fi
endif

# 内核检测模块
modules: check-kernel
	$(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules

# -------------------------------------
# 生成man文档
# distclean 类似make clean 清除object文件，但同时也将configure生成的文件全部删除掉，包括Makefile。
man:
	$(MAKE) -C doc man#生成man文档

html:
	$(MAKE) -C doc html#生成html网页文档

clean:
	@rm -f *.o $(TARGETS)
	@$(MAKE) -C Modules clean#删除Modules下makefile里写的文件
	@$(MAKE) -C doc clean
	@set -e; \
	#如果存在ninfod目录下makefile文件就进去读取，并删除目标文件
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod clean; \
		fi
#清除ninfod所有object文件，包括Makefile文件
distclean: clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod distclean; \
		fi

# -------------------------------------
snapshot:
	@if [ x"$(UNAME_N)" != x"pleiades" ]; then echo "Not authorized to advance snapshot"; exit 1; fi
        #将TAG内容重定向到RELNOTES>NEW中
	@echo "[$(TAG)]" > RELNOTES.NEW
	@echo >>RELNOTES.NEW
	@git log --no-merges $(LASTTAG).. | git shortlog >> RELNOTES.NEW
	#将git log 和git shortlog的内容重定向到RELNOTES>NEW中
	@echo >> RELNOTES.NEW
	@cat RELNOTES >> RELNOTES.NEW
	@mv RELNOTES.NEW RELNOTES#移动文件RELNOTES
	@sed -e "s/^%define ssdate .*/%define ssdate $(DATE)/" iputils.spec > iputils.spec.tmp
	@mv iputils.spec.tmp iputils.spec
	@echo "static char SNAPSHOT[] = \"$(TAG)\";" > SNAPSHOT.h #将TAG变量的内容输出到SNAPSHOT.h中
	@$(MAKE) -C doc snapshot #生成doc文档
	@$(MAKE) man #执行man命令
	@git commit -a -m "iputils-$(TAG)" #打补丁，提交
	@git tag -s -m "iputils-$(TAG)" $(TAG) #使用私钥
	@git archive --format=tar --prefix=iputils-$(TAG)/ $(TAG) | bzip2 -9 > ../iputils-$(TAG).tar.bz2 #导出

