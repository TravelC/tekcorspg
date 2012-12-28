target=_/DEBIAN/postinst
cp postinst $target
chmod 0555 $target
target2=_/DEBIAN/postrm
cp postrm $target2
chmod 0555 $target2