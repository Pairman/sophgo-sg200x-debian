#!/bin/sh -e
d=git-archive
[ ! -e ../$d ] || d=../$d
[ -e $d ] || mkdir $d
r=$d/releases/

scriptdir=$(dirname $0) ; pushd $scriptdir >/dev/null ; scriptdir=$(pwd) ; popd >/dev/null

get_pip()
{
  repo=$1
  tag=$2

   if release=$(curl -fqs https://pypi.org/pypi/${repo}/json | jq -r '.releases."'${tag}'"')
    then
      #tag="$(echo "$release" | jq -r '.tag_name')"
      rel_set=$(echo ${repo} | tr / -)-releases-${tag}
      gen_sha256="${r}/pythonhosted"/${repo}-${tag}.sha256
      rel_sha256=${scriptdir}/../addons/python3-${repo}/${repo}-${tag}.sha256
      rel_files="$(echo "$release" | jq -r '.[] | select(.filename | match(".tar.gz$|none-any.whl$")) | .url')"
      echo "Parsing repo $repo at $tag"
      rm -f $gen_sha256
      for rel_file in $rel_files ; do
      if [ -n "$rel_file" ]
      then
        rel_hash=$(echo "$release" | jq -r '.[] | select(.url | match("^'$rel_file'$")) | .digests.sha256')
        rel_name=$(echo "$release" | jq -r '.[] | select(.url | match("^'$rel_file'$")) | .filename')
        echo "Getting ${rel_file}"
        mkdir -p "${r}/pythonhosted"
        echo "$rel_hash  $rel_name" >> $gen_sha256
        pushd "${r}/pythonhosted" >/dev/null
        wget -q -N "${rel_file}"
        popd >/dev/null
      fi
      done
      pushd "${r}/pythonhosted" >/dev/null
      [ -e $rel_sha256 ] || echo "WARNING: $rel_sha256 not found, using hashes from json."
      [ -e $rel_sha256 ] || rel_sha256=${repo}-${tag}.sha256
      sha256sum -c $rel_sha256
      popd >/dev/null
   fi
}

get_rel()
{
  repo=$1
  tag=$2

   if release=$(curl -fqs https://api.github.com/repos/${repo}/releases | jq -r '.[] | select(.tag_name | match("^'${tag}'$"))')
    then
      tag="$(echo "$release" | jq -r '.tag_name')"
      rel_set=$(echo ${repo} | tr / -)-releases-${tag}
      rel_sha256=${scriptdir}/${rel_set}.sha256
      rel_files="$(echo "$release" | jq -r '.assets[] | .name')"
      echo "Parsing repo $repo at $tag"
      for rel_file in $rel_files ; do
      if [ -n "$rel_file" ]
      then
        echo "Getting ${rel_file}"
        mkdir -p "${r}/${repo}/releases/download/${tag}"
        pushd "${r}/${repo}/releases/download/${tag}" >/dev/null
        wget -q -N "https://github.com/${repo}/releases/download/${tag}/${rel_file}"
        popd >/dev/null
      fi
      done
      pushd "${r}/${repo}/releases/download/${tag}" >/dev/null
      sha256sum -c $rel_sha256
      popd >/dev/null
   fi
}

get_tag()
{
  repo=$1
  tag=$2

   if true
    then
      rel_set=$(echo ${repo} | tr / -)-releases-${tag}
      rel_sha256=${scriptdir}/${rel_set}.sha256
      rel_files="${tag}.tar.gz ${tag}.zip"
      echo "Parsing repo $repo at $tag"
      for rel_file in $rel_files ; do
      if [ -n "$rel_file" ]
      then
        echo "Getting ${rel_file}"
        mkdir -p "${r}/${repo}/archive"
        pushd "${r}/${repo}/archive" >/dev/null
        wget -q -N "https://github.com/${repo}/archive/${rel_file}"
        popd >/dev/null
      fi
      done
      pushd "${r}/${repo}/archive" >/dev/null
      sha256sum -c $rel_sha256
      popd >/dev/null
   fi
}

for f in scripts/addons/python3-*/addon.mk ; do
  d=`dirname $f`
  a=`basename $d`
  b=`echo $a | cut -d '-' -f 2-`
  v=`echo $a | tr a-z- A-Z_`_VERSION
  t=$(grep '^'$v $f | cut -d '=' -f 2- | tr -d '\t ')
  [ "X$t" = "X" ] || get_pip $b $t
done

get_tag scpcom/ade v0.1.1f-gcc-13
get_tag opencv/ade v0.1.1f
get_tag opencv/ade v0.1.2a
get_tag opencv/ade v0.1.2b
get_tag opencv/ade v0.1.2c
get_tag opencv/ade v0.1.2d
get_tag opencv/ade v0.1.2e
get_tag opencv/opencv 4.5.0
get_tag opencv/opencv 4.6.0
get_tag opencv/opencv 4.7.0
get_tag opencv/opencv 4.8.0
get_tag opencv/opencv 4.9.0
get_tag opencv/opencv 4.10.0
get_tag opencv/opencv 4.11.0

get_rel sipeed/MaixCDK v0.0.0

echo OK
