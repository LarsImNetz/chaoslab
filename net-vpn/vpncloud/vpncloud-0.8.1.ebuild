# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CRATES="
aho-corasick-0.6.3
aligned_alloc-0.1.3
base64-0.5.2
bitflags-0.4.0
bitflags-0.7.0
bitflags-0.8.2
byteorder-1.0.0
cfg-if-0.1.0
daemonize-0.2.3
docopt-0.7.0
fnv-1.0.5
gcc-0.3.45
httparse-1.2.2
hyper-0.10.10
idna-0.1.1
igd-0.6.0
kernel32-sys-0.2.2
language-tags-0.2.2
lazy_static-0.2.8
libc-0.2.22
log-0.3.7
matches-0.1.4
memchr-1.0.1
mime-0.2.3
net2-0.2.29
nix-0.6.0
num_cpus-1.4.0
pkg-config-0.3.9
rand-0.3.15
redox_syscall-0.1.17
regex-0.2.1
regex-syntax-0.4.0
rustc-serialize-0.3.24
rustc_version-0.1.7
semver-0.1.20
signal-0.3.2
siphasher-0.2.2
strsim-0.6.0
thread-id-3.0.0
thread_local-0.3.3
time-0.1.37
traitobject-0.1.0
typeable-0.1.2
unicase-1.4.0
unicode-bidi-0.2.5
unicode-normalization-0.1.4
unreachable-0.1.1
url-1.4.0
utf8-ranges-1.0.0
void-1.0.2
winapi-0.2.8
winapi-build-0.1.1
ws2_32-sys-0.2.1
xml-rs-0.3.6
xmltree-0.3.2
yaml-rust-0.3.5
"

inherit cargo systemd

MY_PN="${PN}.rs"
Na_PV="70170c28c844a4786e75efc626e1aeebc93caebc"
Na_P="libsodium-${Na_PV}"
Na_URI="https://github.com/jedisct1/libsodium/archive/${Na_PV}.tar.gz"

DESCRIPTION="A fully-meshed VPN network in a peer-to-peer manner"
HOMEPAGE="https://github.com/dswd/vpncloud.rs"
SRC_URI="https://github.com/dswd/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	!system-libsodium? ( ${Na_URI} -> ${Na_P}.tar.gz )
	$(cargo_crate_uris ${CRATES})"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="man system-libsodium"

DEPEND="man? ( app-text/ronn )
	system-libsodium? ( >=dev-libs/libsodium-1.0.12[static-libs] )"

RESTRICT="mirror"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	if ! use system-libsodium; then
		rmdir "${S}/libsodium" || die
		mv "${WORKDIR}/${Na_P}" "${S}/libsodium" || die
	fi

	default
}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"

	cargo build -v \
		$(usex debug "" --release) \
		$(usex system-libsodium "--features system-libsodium" "") \
		|| die "cargo build failed"
}

src_install() {
	dobin target/release/${PN}

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service
	systemd_newunit "${FILESDIR}"/${PN}_.service "${PN}@.service"

	insinto /etc/${PN}
	newins "${FILESDIR}"/${PN}.example example.net

	dodoc vpncloud.md

	if use man; then
		ronn -r vpncloud.md || die
		doman vpncloud.1
	fi
}
