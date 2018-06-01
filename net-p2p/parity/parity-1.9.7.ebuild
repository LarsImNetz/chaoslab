# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CRATES="
adler32-1.0.2
advapi32-sys-0.2.0
aho-corasick-0.6.3
ansi_term-0.10.2
ansi_term-0.9.0
arrayvec-0.4.4
aster-0.41.0
atty-0.2.2
backtrace-0.3.3
backtrace-sys-0.1.14
base-x-0.2.2
base32-0.3.1
base64-0.6.0
base64-0.9.0
bigint-4.2.0
bincode-0.8.0
bit-set-0.2.0
bit-set-0.4.0
bit-vec-0.4.4
bitflags-0.7.0
bitflags-0.8.2
bitflags-0.9.1
bitflags-1.0.1
byteorder-1.2.1
bytes-0.4.5
cc-1.0.0
cfg-if-0.1.2
cid-0.2.2
clap-2.29.1
coco-0.1.1
conv-0.3.3
cookie-0.3.1
core-foundation-0.2.3
core-foundation-sys-0.2.3
crossbeam-0.3.2
crunchy-0.1.6
crypt32-sys-0.2.0
custom_derive-0.1.7
daemonize-0.2.3
dbghelp-sys-0.2.0
difference-1.0.0
docopt-0.8.1
dtoa-0.4.2
edit-distance-2.0.0
either-1.1.0
elastic-array-0.9.0
env_logger-0.4.3
error-chain-0.11.0
ethabi-4.0.1
ethbloom-0.2.5
ethcore-bigint-0.2.1
fdlimit-0.1.1
flate2-0.2.20
fnv-1.0.5
foreign-types-0.3.2
foreign-types-shared-0.1.1
fs2-0.4.2
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.18
futures-cpupool-0.1.6
gcc-0.3.54
getopts-0.2.15
glob-0.2.11
globset-0.2.1
hamming-0.1.3
heapsize-0.4.1
heck-0.2.1
hex-0.2.0
httparse-1.2.3
hyper-0.10.13
hyper-0.11.24
hyper-tls-0.1.2
idna-0.1.4
igd-0.6.0
integer-encoding-1.0.3
interleaved-ordered-0.1.1
iovec-0.1.2
ipnetwork-0.12.7
isatty-0.1.3
itertools-0.5.10
itoa-0.3.4
kernel32-sys-0.2.2
language-tags-0.2.2
lazy_static-0.2.8
lazy_static-1.0.0
lazycell-0.6.0
libc-0.2.31
libflate-0.1.11
linked-hash-map-0.4.2
linked-hash-map-0.5.0
local-encoding-0.2.0
log-0.3.8
log-0.4.1
lru-cache-0.1.1
magenta-0.1.1
magenta-sys-0.1.1
matches-0.1.6
memchr-1.0.1
memchr-2.0.1
memmap-0.5.2
memory_units-0.3.0
mime-0.2.6
mime-0.3.4
mime_guess-2.0.0-alpha.2
miniz-sys-0.1.10
mio-0.6.14
mio-uds-0.6.4
miow-0.2.1
msdos_time-0.1.5
multibase-0.6.0
multihash-0.6.0
native-tls-0.1.4
net2-0.2.31
nodrop-0.1.9
ntp-0.3.1
num-0.1.40
num-bigint-0.1.40
num-complex-0.1.40
num-integer-0.1.35
num-iter-0.1.34
num-rational-0.1.39
num-traits-0.1.40
num_cpus-1.7.0
number_prefix-0.2.7
odds-0.2.25
ole32-sys-0.2.0
openssl-0.9.23
openssl-sys-0.9.23
order-stat-0.1.3
ordered-float-0.5.0
owning_ref-0.3.3
parity-dapps-glue-1.9.1
parity-wasm-0.27.5
parity-wordlist-1.2.0
parking_lot-0.4.8
parking_lot-0.5.3
parking_lot_core-0.2.6
percent-encoding-1.0.0
phf-0.7.21
phf_codegen-0.7.21
phf_generator-0.7.21
phf_shared-0.7.21
pkg-config-0.3.9
plain_hasher-0.1.0
podio-0.1.5
pretty_assertions-0.1.2
primal-0.2.3
primal-bit-0.2.4
primal-check-0.2.2
primal-estimate-0.2.1
primal-sieve-0.2.7
protobuf-1.4.1
pulldown-cmark-0.0.3
pwasm-utils-0.1.3
quasi-0.32.0
quasi_codegen-0.32.0
quasi_macros-0.32.0
quick-error-1.2.1
quote-0.3.15
rand-0.3.16
rand-0.4.2
rayon-0.7.1
rayon-0.8.2
rayon-core-1.2.1
redox_syscall-0.1.31
regex-0.2.2
regex-syntax-0.4.1
relay-0.1.1
reqwest-0.7.3
ring-0.9.7
rpassword-1.0.2
rprompt-1.0.3
rust-crypto-0.2.36
rustc-demangle-0.1.5
rustc-hex-1.0.0
rustc-serialize-0.3.24
rustc_version-0.1.7
rustc_version-0.2.1
safemem-0.2.0
schannel-0.1.8
scoped-tls-0.1.0
scopeguard-0.3.2
secur32-sys-0.2.0
security-framework-0.1.16
security-framework-sys-0.1.16
semver-0.1.20
semver-0.6.0
semver-parser-0.7.0
serde-1.0.15
serde_derive-1.0.15
serde_derive_internals-0.16.0
serde_ignored-0.0.4
serde_json-1.0.3
serde_urlencoded-0.5.1
sha1-0.2.0
shell32-sys-0.1.1
siphasher-0.1.3
siphasher-0.2.2
skeptic-0.4.0
slab-0.2.0
slab-0.3.0
slab-0.4.0
smallvec-0.2.1
smallvec-0.4.3
spmc-0.2.2
stable_deref_trait-1.0.0
strsim-0.6.0
subtle-0.5.1
syn-0.11.11
synom-0.11.3
syntex-0.58.1
syntex_errors-0.58.1
syntex_pos-0.58.1
syntex_syntax-0.58.1
take-0.1.0
target_info-0.1.0
tempdir-0.3.5
term-0.4.6
term_size-0.3.0
textwrap-0.9.0
thread_local-0.3.4
threadpool-1.7.1
time-0.1.38
tiny-keccak-1.4.1
tokio-core-0.1.12
tokio-io-0.1.3
tokio-proto-0.1.1
tokio-service-0.1.0
tokio-timer-0.1.2
tokio-tls-0.1.3
tokio-uds-0.1.5
toml-0.4.5
traitobject-0.1.0
transient-hashmap-0.4.0
typeable-0.1.2
unicase-1.4.2
unicase-2.0.0
unicode-bidi-0.3.4
unicode-normalization-0.1.5
unicode-segmentation-1.2.0
unicode-width-0.1.4
unicode-xid-0.0.4
unreachable-0.1.1
unreachable-1.0.0
untrusted-0.5.1
url-1.5.1
utf8-ranges-1.0.0
vcpkg-0.2.2
vec_map-0.8.0
vecio-0.1.0
vergen-0.1.1
version_check-0.1.3
void-1.0.2
wasmi-0.1.3
winapi-0.2.8
winapi-0.3.4
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
ws2_32-sys-0.2.1
xdg-2.1.0
xml-rs-0.3.6
xmltree-0.3.2
zip-0.1.19
"

inherit cargo systemd user

DESCRIPTION="Fast, light, and robust Ethereum client"
HOMEPAGE="https://parity.io"
SRC_URI="https://github.com/paritytech/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+daemon libressl"

RDEPEND="!libressl? ( dev-libs/openssl:0= )
	libressl? ( dev-libs/libressl:0= )"
DEPEND="${RDEPEND}
	>=virtual/rust-1.23.0"

DOCS=( {CHANGELOG,README,SECURITY}.md )

pkg_setup() {
	# Unfortunately 'network-sandbox' needs to
	# disabled because Cargo fetches a few dependencies.
	has network-sandbox $FEATURES && \
		die "net-p2p/parity requires 'network-sandbox' to be disabled in FEATURES"

	if use daemon; then
		enewgroup parity
		enewuser parity -1 -1 /var/lib/parity parity
	fi
}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"

	cargo build -v $(usex debug '' --release) \
		--features final || die
	cargo build -v $(usex debug '' --release) \
		-p evmbin || die
	cargo build -v $(usex debug '' --release) \
		-p ethstore-cli || die
	cargo build -v $(usex debug '' --release) \
		-p ethkey-cli || die
}

src_install() {
	dobin target/release/{ethkey,ethstore,parity{,-evm}}
	einstalldocs

	if use daemon; then
		newinitd "${FILESDIR}"/${PN}.initd ${PN}
		systemd_dounit scripts/${PN}.service
	fi
}
