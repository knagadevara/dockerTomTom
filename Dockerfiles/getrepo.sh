#!/usr/bin/env bash

buildPATH="/share/jenkins/jbuilder"
scriptPATH="/share/jenkins/jscripts"
repoName="${1}"
repoDirPATH="${2}"
pullRepoName="${3}"
verNo="${4:=2}"
#DocFile=${Dockerfile:-$5}
DocFile="${5:=Dockerfile}"
ConText="${6:="."}"

if [[ ! -d ${buildPATH} ]]
then
	echo "Build path doesnot exist..creating"
	echo "created ${buildPATH}"
	mkdir -p "${buildPATH}"
fi

echo "executing $0 in $(basename $PWD)"
echo "pulling ${pullRepoName}"

function PullSourceSparce() {

	cd ${buildPATH};
	mkdir -p ${repoName} && cd ${repoName} ; 
	git init
	git remote add origin ${pullRepoName}
	git checkout -b "${repoName}"
	git config core.sparsecheckout true
	echo ${repoDirPATH} >> .git/info/sparse-checkout
	git pull origin master

			}

function BuildImage() {
	
	WorkDIR=${1}
	cd $WorkDIR
	docker build --file "${DocFile}" --tag "${repoName}:${verNo}" ${ConText}
	}


main () {
	PullSourceSparce && StatCode=0 || StatCode=1 ;

	if [[ ${StatCode} -ne 0 ]]
	then
		exit 1
	else
		WorkDIR="${buildPATH}/${repoName}/${repoDirPATH}"
		BuildImage ${WorkDIR}
	fi

	}

main
