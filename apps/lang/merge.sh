for lang in $(find . -name '??*' -type d -print | sed -e 's/\.\///')
do
	msgmerge -N -U $lang/tqslapp.po ../tqslapp.pot
done
