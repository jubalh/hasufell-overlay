# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/PEAR-XML_RSS/PEAR-XML_RSS-1.0.1.ebuild,v 1.1 2011/03/19 16:33:28 olemarkus Exp $

EAPI=3

inherit eutils php-pear-r1

DESCRIPTION="WebDAV stream wrapper class"
LICENSE="PHP-2.02 PHP-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="vanilla"
RDEPEND="dev-php/PEAR-HTTP_Request"

src_prepare() {
	if ! use vanilla ; then
		epatch "${FILESDIR}"/${P}-pydio.patch
	fi
}