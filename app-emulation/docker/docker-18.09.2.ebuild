# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="62479626f213818ba5b4565105a05277308587d5"
EGO_PN="github.com/${PN}/${PN}-ce"

inherit bash-completion-r1 golang-vcs-snapshot-r1 linux-info systemd udev user

DESCRIPTION="The core functions you need to create Docker images and run Docker containers"
HOMEPAGE="https://dockerproject.org"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="apparmor aufs debug btrfs +container-init +device-mapper +overlay pkcs11 seccomp systemd"

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#build-dependencies
CDEPEND="
	>=dev-db/sqlite-3.7.9:3
	device-mapper? ( >=sys-fs/lvm2-2.02.89[thin] )
	apparmor? ( sys-libs/libapparmor )
	seccomp? ( >=sys-libs/libseccomp-2.2.1 )
"
DEPEND="${CDEPEND}
	dev-util/go-md2man
	btrfs? ( >=sys-fs/btrfs-progs-3.16.1 )
"
# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#optional-dependencies
RDEPEND="${CDEPEND}
	~app-emulation/containerd-1.2.2
	~app-emulation/docker-proxy-0.8.0_pre20181208
	>=app-emulation/runc-1.0.0_pre20181203-r1[apparmor?,seccomp?]
	dev-libs/libltdl
	>=dev-vcs/git-1.7
	>=net-firewall/iptables-1.4
	sys-process/procps
	container-init? ( >=sys-process/tini-0.18.0[static] )
"

QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

# see "contrib/check-config.sh" from upstream's sources
CONFIG_CHECK="
	~NAMESPACES ~NET_NS ~PID_NS ~IPC_NS ~UTS_NS
	~CGROUPS ~CGROUP_CPUACCT ~CGROUP_DEVICE ~CGROUP_FREEZER ~CGROUP_SCHED ~CPUSETS ~MEMCG
	~KEYS
	~VETH ~BRIDGE ~BRIDGE_NETFILTER
	~NF_NAT_IPV4 ~IP_NF_FILTER ~IP_NF_TARGET_MASQUERADE
	~NETFILTER_XT_MATCH_ADDRTYPE ~NETFILTER_XT_MATCH_CONNTRACK ~NETFILTER_XT_MATCH_IPVS
	~IP_NF_NAT ~NF_NAT ~NF_NAT_NEEDED
	~POSIX_MQUEUE

	~USER_NS
	~SECCOMP
	~CGROUP_PIDS
	~MEMCG_SWAP ~MEMCG_SWAP_ENABLED

	~BLK_CGROUP ~BLK_DEV_THROTTLING ~IOSCHED_CFQ ~CFQ_GROUP_IOSCHED
	~CGROUP_PERF
	~CGROUP_HUGETLB
	~NET_CLS_CGROUP
	~CFS_BANDWIDTH ~FAIR_GROUP_SCHED ~RT_GROUP_SCHED
	~IP_VS ~IP_VS_PROTO_TCP ~IP_VS_PROTO_UDP ~IP_VS_NFCT ~IP_VS_RR

	~VXLAN
	~CRYPTO ~CRYPTO_AEAD ~CRYPTO_GCM ~CRYPTO_SEQIV ~CRYPTO_GHASH ~XFRM_ALGO ~XFRM_USER
	~IPVLAN
	~MACVLAN ~DUMMY
"

ERROR_KEYS="CONFIG_KEYS: is mandatory"
ERROR_MEMCG_SWAP="CONFIG_MEMCG_SWAP: is required if you wish to limit swap usage of containers"
ERROR_RESOURCE_COUNTERS="CONFIG_RESOURCE_COUNTERS: is optional for container statistics gathering"

ERROR_BLK_CGROUP="CONFIG_BLK_CGROUP: is optional for container statistics gathering"
ERROR_IOSCHED_CFQ="CONFIG_IOSCHED_CFQ: is optional for container statistics gathering"
ERROR_CGROUP_PERF="CONFIG_CGROUP_PERF: is optional for container statistics gathering"
ERROR_CFS_BANDWIDTH="CONFIG_CFS_BANDWIDTH: is optional for container statistics gathering"
ERROR_XFRM_ALGO="CONFIG_XFRM_ALGO: is optional for secure networks"
ERROR_XFRM_USER="CONFIG_XFRM_USER: is optional for secure networks"

pkg_setup() {
	if kernel_is lt 3 10; then
		ewarn
		ewarn "Using Docker with kernels older than 3.10 is unstable and unsupported."
		ewarn " - http://docs.docker.com/engine/installation/binaries/#check-kernel-dependencies"
	fi

	if kernel_is le 3 18; then
		CONFIG_CHECK+="
			~RESOURCE_COUNTERS
		"
	fi

	if kernel_is le 3 13; then
		CONFIG_CHECK+="
			~NETPRIO_CGROUP
		"
	else
		CONFIG_CHECK+="
			~CGROUP_NET_PRIO
		"
	fi

	if kernel_is lt 4 5; then
		CONFIG_CHECK+="
			~MEMCG_KMEM
		"
		ERROR_MEMCG_KMEM="CONFIG_MEMCG_KMEM: is optional"
	fi

	if kernel_is lt 4 7; then
		CONFIG_CHECK+="
			~DEVPTS_MULTIPLE_INSTANCES
		"
	fi

	if use aufs; then
		CONFIG_CHECK+="
			~AUFS_FS
			~EXT4_FS_POSIX_ACL ~EXT4_FS_SECURITY
		"
		ERROR_AUFS_FS="CONFIG_AUFS_FS: is required to be set if and only if aufs-sources are used instead of aufs4/aufs3"
	fi

	if use btrfs; then
		CONFIG_CHECK+="
			~BTRFS_FS
			~BTRFS_FS_POSIX_ACL
		"
	fi

	if use device-mapper; then
		CONFIG_CHECK+="
			~BLK_DEV_DM ~DM_THIN_PROVISIONING ~EXT4_FS ~EXT4_FS_POSIX_ACL ~EXT4_FS_SECURITY
		"
	fi

	if use overlay; then
		CONFIG_CHECK+="
			~OVERLAY_FS ~EXT4_FS_SECURITY ~EXT4_FS_POSIX_ACL
		"
	fi

	linux-info_pkg_setup

	# create docker group for the code checking for it in /etc/group
	enewgroup docker
}

src_prepare() {
	export BUILD_TIME
	BUILD_TIME="$(date -u -d "@$(date +%s)" --iso-8601=ns | sed -e 's/,/./')"
	sed -i \
		-e "/GitCommit/s|=.*|= \"${GIT_COMMIT}\"|" \
		-e "/Version/s|=.*|= \"$(cat VERSION)\"|" \
		-e "/BuildTime/s|=.*|= \"${BUILD_TIME}\"|" \
		-e "/IAmStatic/s|=.*|= \"false\"|" \
		components/engine/hack/make/.go-autogen || die

	default
}

src_compile() {
	export GOPATH="${G}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"

	# fake golang layout
	ln -s docker-ce/components/engine ../docker || die
	ln -s docker-ce/components/cli ../cli || die

	# let's set up some optional features :)
	local gd tag DOCKER_BUILDTAGS
	for gd in aufs btrfs device-mapper overlay; do
		if ! use $gd; then
			DOCKER_BUILDTAGS+=" exclude_graphdriver_${gd//-/}"
		fi
	done

	for tag in apparmor pkcs11 seccomp; do
		if use $tag; then
			DOCKER_BUILDTAGS+=" $tag"
		fi
	done

	use systemd && DOCKER_BUILDTAGS+=" journald journald_compat"
	use btrfs || DOCKER_BUILDTAGS+=" btrfs_noversion"

	# build daemon
	pushd ../docker > /dev/null || die
	chmod +x hack/make/.go-autogen || die
	hack/make/.go-autogen || die
	local mygoargs=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "all=-trimpath=${G}/src/${EGO_PN/-ce}"
		-gcflags "all=-trimpath=${G}/src/${EGO_PN/-ce}"
		-ldflags "$(usex !debug '-s -w' '')"
		-tags "autogen ${DOCKER_BUILDTAGS}"
	)
	go build "${mygoargs[@]}" ./cmd/dockerd || die
	popd > /dev/null || die

	# build cli
	pushd ../cli > /dev/null || die
	local EGO_PNCLI="${EGO_PN/docker-ce/cli}"
	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "${EGO_PNCLI}/cli.GitCommit=${GIT_COMMIT}"
		-X "'${EGO_PNCLI}/cli.BuildTime=${BUILD_TIME}'"
		-X "${EGO_PNCLI}/cli.Version=$(cat VERSION)"
	)
	local mygoargs2=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "all=-trimpath=${G}/src/${EGO_PNCLI}"
		-gcflags "all=-trimpath=${G}/src/${EGO_PNCLI}"
		-ldflags "${myldflags[*]}"
		-tags pkcs11
	)
	go build "${mygoargs2[@]}" ./cmd/docker || die

	# build man pages
	# see "components/cli/scripts/docs/generate-man.sh"
	local PATH="${G}/bin:$PATH"
	mkdir -p ./man/man1 || die
	# Generate man pages from cobra commands
	go build -o "${G}/bin/gen-manpages" github.com/docker/cli/man || die
	gen-manpages --root . --target ./man/man1 > /dev/null || die
	# Generate legacy pages from markdown
	man/md2man-all.sh -q || die
	popd > /dev/null || die
}

src_install() {
	dosym containerd /usr/bin/docker-containerd
	dosym containerd-shim /usr/bin/docker-containerd-shim
	dosym runc /usr/bin/docker-runc
	use container-init && dosym tini /usr/bin/docker-init

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"

	pushd components/engine > /dev/null || die
	dobin dockerd

	systemd_dounit contrib/init/systemd/docker.{service,socket}
	udev_dorules contrib/udev/*.rules

	dodoc AUTHORS CONTRIBUTING.md CHANGELOG.md NOTICE README.md
	dodoc -r docs/*

	insinto /usr/share/vim/vimfiles
	doins -r contrib/syntax/vim/ftdetect
	doins -r contrib/syntax/vim/syntax

	# note: intentionally not using "doins" so that we preserve +x bits
	dodir "/usr/share/${PN}/contrib"
	cp -R contrib/* "${ED}/usr/share/${PN}/contrib"
	popd > /dev/null || die

	pushd components/cli > /dev/null || die
	dobin docker

	use debug && dostrip -x /usr/bin/{docker,dockerd}

	doman man/man*/*

	dobashcomp contrib/completion/bash/docker
	insinto /usr/share/fish/vendor_completions.d
	doins contrib/completion/fish/docker.fish
	insinto /usr/share/zsh/site-functions
	doins contrib/completion/zsh/_docker
	popd > /dev/null || die

	diropts -g docker -m 0750
	keepdir /var/log/docker
}

pkg_postinst() {
	udev_reload

	einfo
	elog "To use Docker, the Docker daemon must be running as root. To automatically"
	elog "start the Docker daemon at boot, add Docker to the default runlevel:"
	elog "  rc-update add docker default"
	elog "Similarly for systemd:"
	elog "  systemctl enable docker.service"
	elog ""
	elog "To use Docker as a non-root user, add yourself to the 'docker' group:"
	elog "  usermod -aG docker youruser"
	elog ""
	elog "Devicemapper storage driver has been deprecated"
	elog "It will be removed in a future release"
	einfo
}
