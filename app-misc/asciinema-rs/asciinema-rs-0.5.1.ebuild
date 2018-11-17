# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Generated with:
# curl -s https://raw.githubusercontent.com/LegNeato/asciinema-rs/v0.5.1/Cargo.lock | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
adler32-1.0.3
aho-corasick-0.6.9
ansi_term-0.11.0
arrayvec-0.4.7
asciicast-0.2.2
atty-0.2.11
backtrace-0.3.9
backtrace-sys-0.1.24
base64-0.9.3
bitflags-0.4.0
bitflags-1.0.4
build_const-0.2.1
byteorder-1.2.7
bytes-0.3.0
bytes-0.4.10
cc-1.0.25
cfg-if-0.1.6
chrono-0.4.6
clap-2.32.0
cloudabi-0.0.3
config-0.8.0
core-foundation-0.5.1
core-foundation-sys-0.5.1
crc-1.8.1
crossbeam-deque-0.6.1
crossbeam-epoch-0.5.2
crossbeam-utils-0.5.0
derive_builder-0.5.1
derive_builder_core-0.2.0
dtoa-0.4.3
encoding_rs-0.8.10
errno-0.1.8
failure-0.1.3
failure_derive-0.1.3
fnv-1.0.6
foreign-types-0.3.2
foreign-types-shared-0.1.1
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.25
futures-cpupool-0.1.8
gcc-0.3.55
h2-0.1.13
heck-0.3.0
http-0.1.13
httparse-1.3.3
hyper-0.12.13
hyper-tls-0.3.1
idna-0.1.5
indexmap-1.0.2
iovec-0.1.2
itoa-0.4.3
kernel32-sys-0.2.2
lazy_static-0.2.11
lazy_static-1.2.0
lazycell-1.2.0
libc-0.2.43
libflate-0.1.18
linked-hash-map-0.3.0
linked-hash-map-0.5.1
lock_api-0.1.4
log-0.3.9
log-0.4.6
matches-0.1.8
memchr-1.0.2
memchr-2.1.1
memoffset-0.2.1
mime-0.3.12
mime_guess-2.0.0-alpha.6
mio-0.5.1
mio-0.6.16
mio-uds-0.6.7
miow-0.1.5
miow-0.2.1
native-tls-0.2.2
net2-0.2.33
nix-0.10.0
nix-0.5.1
nodrop-0.1.12
nom-3.2.1
num-integer-0.1.39
num-traits-0.1.43
num-traits-0.2.6
num_cpus-1.8.0
openssl-0.10.15
openssl-probe-0.1.2
openssl-sys-0.9.39
os_type-2.2.0
owning_ref-0.3.3
parking_lot-0.6.4
parking_lot_core-0.3.1
percent-encoding-1.0.1
phf-0.7.23
phf_codegen-0.7.23
phf_generator-0.7.23
phf_shared-0.7.23
pkg-config-0.3.14
proc-macro2-0.4.20
pty-0.2.2
quote-0.3.15
quote-0.6.9
rand-0.4.3
rand-0.5.5
rand_core-0.2.2
rand_core-0.3.0
redox_syscall-0.1.40
redox_termios-0.1.1
regex-1.0.6
regex-syntax-0.6.2
remove_dir_all-0.5.1
reqwest-0.9.4
rustc-demangle-0.1.9
rustc_version-0.2.3
ryu-0.2.6
safemem-0.3.0
schannel-0.1.14
scopeguard-0.3.3
security-framework-0.2.1
security-framework-sys-0.2.1
semver-0.9.0
semver-parser-0.7.0
serde-0.8.23
serde-1.0.80
serde-hjson-0.8.2
serde_derive-1.0.80
serde_json-1.0.32
serde_test-0.8.23
serde_urlencoded-0.5.3
siphasher-0.2.3
slab-0.1.3
slab-0.4.1
smallvec-0.6.5
stable_deref_trait-1.1.1
string-0.1.1
strsim-0.7.0
structopt-0.2.13
structopt-derive-0.2.13
syn-0.11.11
syn-0.15.18
synom-0.11.3
synstructure-0.10.1
tempfile-3.0.4
termcolor-0.3.6
termion-1.5.1
termios-0.3.1
textwrap-0.10.0
thread_local-0.3.6
time-0.1.40
tokio-0.1.11
tokio-codec-0.1.1
tokio-current-thread-0.1.3
tokio-executor-0.1.5
tokio-fs-0.1.4
tokio-io-0.1.10
tokio-reactor-0.1.6
tokio-tcp-0.1.2
tokio-threadpool-0.1.8
tokio-timer-0.2.7
tokio-udp-0.1.2
tokio-uds-0.2.3
toml-0.4.8
try-lock-0.2.2
ucd-util-0.1.2
unicase-1.4.2
unicase-2.2.0
unicode-bidi-0.3.4
unicode-normalization-0.1.7
unicode-segmentation-1.2.1
unicode-width-0.1.5
unicode-xid-0.0.4
unicode-xid-0.1.0
unreachable-1.0.0
url-1.7.2
url_serde-0.2.0
utf8-ranges-1.0.2
uuid-0.6.5
uuid-0.7.1
vcpkg-0.2.6
vec_map-0.8.1
version_check-0.1.5
void-1.0.2
want-0.0.6
winapi-0.2.8
winapi-0.3.6
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-0.1.6
ws2_32-sys-0.2.1
yaml-rust-0.4.2
"

inherit cargo

DESCRIPTION="Terminal recording and playback client for asciinema.org, written in Rust"
HOMEPAGE="https://github.com/LegNeato/asciinema-rs"
# shellcheck disable=SC2086
SRC_URI="https://github.com/LegNeato/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="|| ( Apache-2.0 MIT )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libressl"

DEPEND="
	!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )
"
RDEPEND="${DEPEND}
	!app-misc/asciinema
"

DOCS=( README.md )

src_install() {
	dobin target/release/asciinema
	einstalldocs
}
