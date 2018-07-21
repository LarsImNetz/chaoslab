# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CRATES="
adler32-1.0.2
aho-corasick-0.6.4
ansi_term-0.10.2
arrayvec-0.4.7
assert_matches-1.2.0
aster-0.41.0
atty-0.2.8
backtrace-0.3.5
backtrace-sys-0.1.14
base-x-0.2.2
base32-0.3.1
base64-0.6.0
base64-0.9.0
bigint-4.3.0
bincode-0.8.0
bit-set-0.4.0
bit-vec-0.4.4
bitflags-0.7.0
bitflags-0.8.2
bitflags-0.9.1
bitflags-1.0.1
build_const-0.2.1
byteorder-1.2.1
bytes-0.4.6
cc-1.0.10
cfg-if-0.1.2
cid-0.2.3
clap-2.29.1
conv-0.3.3
crc-1.7.0
crossbeam-0.3.2
crossbeam-deque-0.2.0
crossbeam-deque-0.3.0
crossbeam-epoch-0.3.1
crossbeam-epoch-0.4.1
crossbeam-utils-0.2.2
crossbeam-utils-0.3.2
crunchy-0.1.6
ct-logs-0.2.0
custom_derive-0.1.7
difference-1.0.0
docopt-0.8.3
dtoa-0.4.2
edit-distance-2.0.0
either-1.4.0
elastic-array-0.10.0
env_logger-0.4.3
error-chain-0.11.0
ethabi-5.1.1
ethabi-contract-5.1.0
ethabi-derive-5.1.2
ethbloom-0.5.0
ethereum-types-0.3.2
ethereum-types-serialize-0.2.1
fdlimit-0.1.1
fixed-hash-0.2.1
flate2-1.0.1
fnv-1.0.5
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.21
futures-cpupool-0.1.8
futures-timer-0.1.1
gcc-0.3.54
getopts-0.2.15
glob-0.2.11
globset-0.2.1
hamming-0.1.3
heapsize-0.4.2
heck-0.3.0
hex-0.2.0
httparse-1.2.3
hyper-0.11.24
hyper-rustls-0.11.0
idna-0.1.4
igd-0.7.0
integer-encoding-1.0.3
interleaved-ordered-0.1.1
iovec-0.1.2
ipnetwork-0.12.7
itertools-0.5.10
itoa-0.3.4
kernel32-sys-0.2.2
language-tags-0.2.2
lazy_static-0.2.11
lazy_static-1.0.0
lazycell-0.6.0
libc-0.2.36
linked-hash-map-0.4.2
linked-hash-map-0.5.0
local-encoding-0.2.0
log-0.3.9
log-0.4.1
lru-cache-0.1.1
matches-0.1.6
memchr-2.0.1
memmap-0.6.2
memoffset-0.2.1
memory_units-0.3.0
mime-0.3.4
mime_guess-2.0.0-alpha.2
miniz_oxide-0.1.2
miniz_oxide_c_api-0.1.2
mio-0.6.14
mio-uds-0.6.4
miow-0.2.1
miow-0.3.1
msdos_time-0.1.6
multibase-0.6.0
multihash-0.7.0
nan-preserving-float-0.1.0
net2-0.2.31
nodrop-0.1.12
ntp-0.3.1
num-0.1.42
num-bigint-0.1.43
num-integer-0.1.36
num-iter-0.1.35
num-traits-0.1.43
num-traits-0.2.2
num_cpus-1.8.0
number_prefix-0.2.7
ole32-sys-0.2.0
order-stat-0.1.3
ordered-float-0.5.0
owning_ref-0.3.3
parity-dapps-glue-1.9.1
parity-wasm-0.27.5
parity-wordlist-1.2.0
parking_lot-0.5.4
parking_lot_core-0.2.6
percent-encoding-1.0.0
phf-0.7.21
phf_codegen-0.7.21
phf_generator-0.7.21
phf_shared-0.7.21
podio-0.1.5
pretty_assertions-0.1.2
primal-0.2.3
primal-bit-0.2.4
primal-check-0.2.3
primal-estimate-0.2.1
primal-sieve-0.2.8
proc-macro2-0.3.1
protobuf-1.5.1
pulldown-cmark-0.0.3
pwasm-utils-0.1.5
quasi-0.32.0
quasi_codegen-0.32.0
quote-0.5.1
rand-0.3.20
rand-0.4.2
rayon-1.0.1
rayon-core-1.4.0
redox_syscall-0.1.40
redox_termios-0.1.1
regex-0.2.5
regex-syntax-0.4.1
relay-0.1.1
rpassword-1.0.2
rprompt-1.0.3
rust-crypto-0.2.36
rustc-demangle-0.1.5
rustc-hex-1.0.0
rustc-serialize-0.3.24
rustc_version-0.2.2
rustls-0.11.0
safemem-0.2.0
scoped-tls-0.1.0
scopeguard-0.3.2
sct-0.2.0
semver-0.9.0
semver-parser-0.7.0
serde-1.0.37
serde_derive-1.0.37
serde_derive_internals-0.23.0
serde_ignored-0.0.4
serde_json-1.0.9
sha1-0.2.0
shell32-sys-0.1.2
siphasher-0.1.3
siphasher-0.2.2
skeptic-0.4.0
slab-0.2.0
slab-0.3.0
slab-0.4.0
smallvec-0.2.1
smallvec-0.4.3
socket2-0.3.6
stable_deref_trait-1.0.0
strsim-0.6.0
subtle-0.5.1
syn-0.13.1
syntex-0.58.1
syntex_errors-0.58.1
syntex_pos-0.58.1
syntex_syntax-0.58.1
take-0.1.0
target_info-0.1.0
tempdir-0.3.5
tempfile-2.2.0
term-0.4.6
term_size-0.3.1
termion-1.5.1
textwrap-0.9.0
thread_local-0.3.4
threadpool-1.7.1
time-0.1.38
tiny-keccak-1.4.2
tokio-0.1.5
tokio-core-0.1.17
tokio-executor-0.1.2
tokio-io-0.1.6
tokio-proto-0.1.1
tokio-reactor-0.1.1
tokio-retry-0.1.1
tokio-rustls-0.4.0
tokio-service-0.1.0
tokio-tcp-0.1.0
tokio-threadpool-0.1.2
tokio-timer-0.1.2
tokio-timer-0.2.1
tokio-udp-0.1.0
tokio-uds-0.1.5
toml-0.4.5
transient-hashmap-0.4.0
uint-0.2.1
unicase-1.4.2
unicase-2.1.0
unicode-bidi-0.3.4
unicode-normalization-0.1.5
unicode-segmentation-1.2.0
unicode-width-0.1.4
unicode-xid-0.0.4
unicode-xid-0.1.0
unreachable-0.1.1
unreachable-1.0.0
untrusted-0.5.1
url-1.5.1
utf8-ranges-1.0.0
vec_map-0.8.0
vergen-0.1.1
version_check-0.1.3
void-1.0.2
wasmi-0.2.0
webpki-0.17.0
webpki-roots-0.13.0
winapi-0.2.8
winapi-0.3.4
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
ws2_32-sys-0.2.1
xdg-2.1.0
xml-rs-0.7.0
xmltree-0.7.0
zip-0.3.1
"

inherit cargo systemd user

DESCRIPTION="Fast, light, and robust Ethereum client"
HOMEPAGE="https://parity.io"
# shellcheck disable=SC2086
SRC_URI="https://github.com/paritytech/${PN}-ethereum/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+daemon"

DOCS=( {CHANGELOG,README,SECURITY}.md )

S="${WORKDIR}/parity-ethereum-${PV}"

pkg_setup() {
	# shellcheck disable=SC2086
	if has network-sandbox $FEATURES; then
		ewarn ""
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn ""
		die "[network-sandbox] is enabled in FEATURES"
	fi

	if use daemon; then
		enewgroup parity
		enewuser parity -1 -1 /var/lib/parity parity
	fi
}

# shellcheck disable=SC2046,SC2153
src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"

	cargo build -v $(usex debug '' --release) --features final || die
	cargo build -v $(usex debug '' --release) -p evmbin || die
	cargo build -v $(usex debug '' --release) -p ethstore-cli || die
	cargo build -v $(usex debug '' --release) -p ethkey-cli || die
}

src_install() {
	dobin target/release/{ethkey,ethstore,parity{,-evm}}
	einstalldocs

	if use daemon; then
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
		systemd_dounit "scripts/${PN}.service"
	fi
}

pkg_postinst() {
	if use daemon; then
		if [[ $(stat -c %a "${EROOT%/}/var/lib/parity") != "750" ]]; then
			einfo "Fixing ${EROOT%/}/var/lib/parity permissions"
			chown -R parity:parity "${EROOT%/}/var/lib/parity" || die
			chmod 0750 "${EROOT%/}/var/lib/parity" || die
		fi
	fi
}
