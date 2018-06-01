# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Partially generated with:
# curl -s https://raw.githubusercontent.com/shadowsocks/shadowsocks-rust/v1.6.12/Cargo.lock | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
adler32-1.0.2
aesni-0.2.1
aho-corasick-0.6.4
ansi_term-0.10.2
arrayref-0.3.4
atty-0.2.6
base64-0.9.0
bitflags-0.9.1
bitflags-1.0.1
block-buffer-0.3.3
block-cipher-trait-0.5.0
build_const-0.2.0
byte-tools-0.2.0
byte_string-1.0.0
byteorder-1.2.1
bytes-0.4.6
bzip2-0.3.2
bzip2-sys-0.1.6
cc-1.0.4
cfg-if-0.1.2
checked_int_cast-1.0.0
chrono-0.4.0
clap-2.29.1
clear_on_drop-0.2.3
cmac-0.1.0
coco-0.1.1
constant_time_eq-0.1.3
crc-1.7.0
crossbeam-0.2.12
crypto-mac-0.6.0
dbl-0.1.0
digest-0.7.2
dtoa-0.4.2
either-1.4.0
env_logger-0.5.0-rc.2
filetime-0.1.14
flate2-0.2.20
flate2-1.0.1
foreign-types-0.3.2
foreign-types-shared-0.1.1
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.17
futures-cpupool-0.1.8
generic-array-0.9.0
idna-0.1.4
iovec-0.1.1
itoa-0.3.4
kernel32-sys-0.2.2
lazy_static-0.2.11
lazy_static-1.0.0
lazycell-0.6.0
libc-0.2.36
libsodium-ffi-0.1.11
log-0.3.9
log-0.4.1
matches-0.1.6
md-5-0.7.0
memchr-2.0.1
miniz-sys-0.1.10
miniz_oxide-0.1.2
miniz_oxide_c_api-0.1.2
mio-0.6.12
mio-uds-0.6.4
miow-0.2.1
miscreant-0.3.0
msdos_time-0.1.5
net2-0.2.31
num-0.1.41
num-integer-0.1.35
num-iter-0.1.34
num-traits-0.1.41
num_cpus-1.8.0
opaque-debug-0.1.1
openssl-0.9.23
openssl-sys-0.9.24
percent-encoding-1.0.1
pkg-config-0.3.9
pmac-0.1.0
podio-0.1.6
qrcode-0.5.0
rand-0.3.20
rand-0.4.2
rayon-0.9.0
rayon-core-1.3.0
redox_syscall-0.1.37
redox_termios-0.1.1
regex-0.2.5
regex-syntax-0.4.2
ring-0.13.0-alpha
safemem-0.2.0
scoped-tls-0.1.0
scopeguard-0.3.3
serde-1.0.27
serde_json-1.0.9
serde_urlencoded-0.5.1
slab-0.3.0
slab-0.4.0
strsim-0.6.0
subprocess-0.1.12
subtle-0.3.0
tar-0.4.14
termcolor-0.3.3
termion-1.5.1
textwrap-0.9.0
thread_local-0.3.5
time-0.1.39
tokio-core-0.1.12
tokio-io-0.1.4
tokio-signal-0.1.3
typenum-1.9.0
unicode-bidi-0.3.4
unicode-normalization-0.1.5
unicode-width-0.1.4
unreachable-1.0.0
untrusted-0.6.1
unwrap-1.1.0
url-1.6.0
utf8-ranges-1.0.0
vcpkg-0.2.2
vec_map-0.8.0
void-1.0.2
winapi-0.2.8
winapi-0.3.3
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.3.2
winapi-x86_64-pc-windows-gnu-0.3.2
wincolor-0.1.4
ws2_32-sys-0.2.1
xattr-0.1.11
zip-0.2.9
"

inherit cargo user

DESCRIPTION="A Rust port of Shadowsocks"
HOMEPAGE="https://shadowsocks.org"
# shellcheck disable=SC2086
SRC_URI="https://github.com/shadowsocks/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libressl"

RDEPEND="dev-libs/libsodium:0=[-minimal]
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( <dev-libs/libressl-2.7:0= )"
DEPEND="${RDEPEND}"

pkg_setup() {
	enewgroup shadowsocks-rust
	enewuser shadowsocks-rust -1 -1 -1 shadowsocks-rust
}

src_install() {
	dobin target/release/ss{local,server,url}

	newinitd "${FILESDIR}/${PN}-local.initd" "${PN}-local"
	newinitd "${FILESDIR}/${PN}-server.initd" "${PN}-server"

	diropts -o shadowsocks-rust -g shadowsocks-rust -m 0700
	keepdir /{etc,var/log}/shadowsocks-rust

	insinto /etc/shadowsocks-rust
	newins "${FILESDIR}/${PN}-local.conf" local.json.example
	newins "${FILESDIR}/${PN}-server.conf" server.json.example
}
