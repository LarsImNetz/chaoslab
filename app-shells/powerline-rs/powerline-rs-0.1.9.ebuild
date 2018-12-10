# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Generated with:
# curl -s https://gitlab.com/jD91mZM2/powerline-rs/raw/0.1.9/Cargo.lock | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
ansi_term-0.11.0
argon2rs-0.2.5
arrayvec-0.4.7
atty-0.2.11
backtrace-0.3.9
backtrace-sys-0.1.24
bitflags-1.0.4
blake2-rfc-0.2.18
cc-1.0.25
cfg-if-0.1.5
chrono-0.4.6
clap-2.32.0
constant_time_eq-0.1.3
curl-sys-0.4.13
dirs-1.0.4
failure-0.1.2
failure_derive-0.1.2
flame-0.2.2
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
git2-0.7.5
idna-0.1.5
itoa-0.4.3
lazy_static-0.2.11
libc-0.2.43
libgit2-sys-0.7.10
libssh2-sys-0.2.11
libz-sys-1.0.24
log-0.4.5
matches-0.1.8
nodrop-0.1.12
num-integer-0.1.39
num-traits-0.2.6
openssl-probe-0.1.2
openssl-sys-0.9.38
openssl-sys-0.9.39
percent-encoding-1.0.1
pkg-config-0.3.14
proc-macro2-0.4.20
quote-0.6.8
rand-0.4.3
redox_syscall-0.1.40
redox_termios-0.1.1
redox_users-0.2.0
rustc-demangle-0.1.9
ryu-0.2.6
scoped_threadpool-0.1.9
serde-1.0.80
serde_derive-1.0.80
serde_json-1.0.32
strsim-0.7.0
syn-0.14.9
syn-0.15.12
synstructure-0.9.0
termion-1.5.1
textwrap-0.10.0
thread-id-3.3.0
time-0.1.40
unicode-bidi-0.3.4
unicode-normalization-0.1.7
unicode-width-0.1.5
unicode-xid-0.1.0
url-1.7.1
users-0.8.0
vcpkg-0.2.6
vec_map-0.8.1
winapi-0.3.6
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="A powerline-shell rewritten in Rust, inspired by powerline-go"
HOMEPAGE="https://gitlab.com/jD91mZM2/powerline-rs"
ARCHIVE_URI="https://gitlab.com/jD91mZM2/${PN}/-/archive/${PV}/${P}.tar.gz"
# shellcheck disable=SC2086
SRC_URI="${ARCHIVE_URI} $(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+chrono +git libressl +users"

# libgit2-sys depends on OpenSSL/LibreSSL
DEPEND="
	git? (
		!libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= )
	)
"
RDEPEND="${DEPEND}
	git? ( dev-vcs/git )
"

DOCS=( README.md )

src_prepare() {
	has_version '>=dev-libs/libressl-2.8.0' && \
		eapply "${FILESDIR}/${P}-libressl-2.8.patch"

	default
}

src_compile() {
	# shellcheck disable=SC2153
	export CARGO_HOME="${ECARGO_HOME}"

	# shellcheck disable=SC2207
	# build up optional flags
	local options=(
		$(usex chrono 'chrono' '')
		$(usex git 'git2' '')
		$(usex users 'users' '')
	)

	cargo build "$(usex debug '' --release)" --no-default-features \
		--features "${options[*]}" || die
}

src_install() {
	dobin target/release/powerline-rs
	einstalldocs
}
