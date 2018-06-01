# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/${PN}/${PN}-ce"
EGO_VENDOR=( "github.com/cpuguy83/go-md2man 20f5889" )
GIT_COMMIT="f150324" # Change this when you update the ebuild

inherit bash-completion-r1 golang-vcs-snapshot linux-info systemd udev user

DESCRIPTION="The core functions you need to create Docker images and run Docker containers"
HOMEPAGE="https://dockerproject.org"
SRC_URI="https://${EGO_PN}/archive/v${PV}-ce.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm"
IUSE="apparmor aufs bash-completion btrfs +container-init
	+device-mapper +overlay pkcs11 seccomp systemd zsh-completion"

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#build-dependencies
CDEPEND=">=dev-db/sqlite-3.7.9:3
	device-mapper? ( >=sys-fs/lvm2-2.02.89[thin] )
	apparmor? ( sys-libs/libapparmor )
	seccomp? ( >=sys-libs/libseccomp-2.2.1 )"
DEPEND="${CDEPEND}
	btrfs? ( >=sys-fs/btrfs-progs-3.16.1 )"
# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#optional-dependencies
RDEPEND="${CDEPEND}
	>=app-arch/xz-utils-4.9
	~app-emulation/containerd-1.0.3
	~app-emulation/docker-proxy-0.8.0_p20180411
	~app-emulation/runc-1.0.0_rc5[apparmor?,seccomp?]
	dev-libs/libltdl
	>=dev-vcs/git-1.7
	>=net-firewall/iptables-1.4
	sys-process/procps
	container-init? ( >=sys-process/tini-0.16.1[static] )"

PATCHES=( "${FILESDIR}"/bsc1073877-docker-apparmor-add-signal.patch )

QA_PRESTRIPPED="usr/bin/dockerd
	usr/bin/docker"

RESTRICT="installsources"

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
		ewarn ""
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
	export BUILD_TIME CGO_CFLAGS CGO_LDFLAGS
	BUILD_TIME=$(date -u -d "@$(date +%s)" --rfc-3339 ns 2> /dev/null | sed -e 's/ /T/')
	sed -i \
		-e "/GitCommit/s|=.*|= \"${GIT_COMMIT}\"|" \
		-e "/Version/s|=.*|= \"$(cat VERSION)\"|" \
		-e "/BuildTime/s|=.*|= \"${BUILD_TIME}\"|" \
		-e "/IAmStatic/s|=.*|= \"false\"|" \
		./components/engine/hack/make/.go-autogen || die

	default
}

src_compile() {
	export GOPATH="${G}"

	# setup CFLAGS and LDFLAGS for separate build target
	# see https://github.com/tianon/docker-overlay/pull/10
	CGO_CFLAGS="-I${ROOT}/usr/include"
	CGO_LDFLAGS="-L${ROOT}/usr/$(get_libdir)"

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

	use systemd && \
		DOCKER_BUILDTAGS+=" journald journald_compat"

	use btrfs || \
		DOCKER_BUILDTAGS+=" btrfs_noversion"

	# build daemon
	pushd ../docker || die
	chmod +x hack/make/.go-autogen || die
	hack/make/.go-autogen || die
	local mygoargs=(
		-v -work -x
		"-buildmode=pie"
		-asmflags "-trimpath=${G}/src/${EGO_PN/-ce}"
		-gcflags "-trimpath=${G}/src/${EGO_PN/-ce}"
		-ldflags "-s -w"
		-tags "autogen ${DOCKER_BUILDTAGS}"
	)
	go build "${mygoargs[@]}" ./cmd/dockerd || die
	popd || die

	# build cli
	pushd ../cli || die
	local EGO_PNCLI="${EGO_PN/docker-ce/cli}"
	local mygoargs2=(
		-v -work -x
		-asmflags "-trimpath=${G}/src/${EGO_PNCLI}"
		-gcflags "-trimpath=${G}/src/${EGO_PNCLI}"
		-ldflags "-s -w
			-X ${EGO_PNCLI}/cli.GitCommit=${GIT_COMMIT}
			-X '${EGO_PNCLI}/cli.BuildTime=${BUILD_TIME}'
			-X ${EGO_PNCLI}/cli.Version=$(cat VERSION)"
		-tags pkcs11
	)
	go build "${mygoargs2[@]}" ./cmd/docker || die

	# build man pages
	# see "components/cli/scripts/docs/generate-man.sh"
	local PATH="${G}/bin:$PATH"
	pushd "${S}"/vendor/github.com/cpuguy83/go-md2man || die
	go install || die
	popd || die

	mkdir -p ./man/man1 || die
	go build -o gen-manpages github.com/docker/cli/man || die
	./gen-manpages --root . --target ./man/man1 || die
	./man/md2man-all.sh -q || die
	popd || die
}

src_install() {
	dosym containerd /usr/bin/docker-containerd
	dosym containerd-shim /usr/bin/docker-containerd-shim
	dosym runc /usr/bin/docker-runc
	use container-init && dosym tini /usr/bin/docker-init

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"

	pushd components/engine || die
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
	cp -R contrib/* "${ED%/}/usr/share/${PN}/contrib"
	popd || die

	pushd components/cli || die
	dobin docker

	doman man/man1/*

	if use bash-completion; then
		dobashcomp contrib/completion/bash/docker
	fi

	if use zsh-completion; then
		insinto /usr/share/zsh/site-functions
		doins contrib/completion/zsh/_docker
	fi
	popd || die
}

pkg_postinst() {
	udev_reload

	elog
	elog "To use Docker, the Docker daemon must be running as root. To automatically"
	elog "start the Docker daemon at boot, add Docker to the default runlevel:"
	elog "  rc-update add docker default"
	elog "Similarly for systemd:"
	elog "  systemctl enable docker.service"
	elog
	elog "To use Docker as a non-root user, add yourself to the 'docker' group:"
	elog "  usermod -aG docker youruser"
	elog
}
