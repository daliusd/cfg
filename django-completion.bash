#!/bin/bash

########################################################
# @author Vince van Oosten <awesomefireduck@gmail.com> #
########################################################


# ./manage.py, ./manage manage.py manage
managepy="{./,}manage{.py,}"







# checks if value is in array
#   $1: value
#   $2: array
djc_contains_element()
{
	local e
	for e in "${@:2}";
	do
		[[ "$e" == "$1" ]] && return 0;
	done
	return 1;
}

djc_get_app_labels()
{
	# autocomplete app's names
	#   this is now done by checking for a file named __init__.py in the subdirs
	#   this might need to change
	django_apps=""
	for i in $(ls */__init__.py 2>/dev/null);
	do
		django_apps+="$(dirname $i) "
	done
	echo -n "${django_apps}"
}



# only suggests migrations if an app name is already present
djc_get_migration_names()
{
	local app_labels is_app_label migrations

	app_labels="$(djc_get_app_labels)"
	# check if previous COMP_WORD is an app_label. If so only suggest it's migrations
	# else suggest app_labels
	#   might need to be more flexible in the future as in:
	#     ./manage.py migrate polls --database default 0004_auto_20151107_2240
	#   but that depends on how the program handles it
	migrations=""
	if [[ $(djc_contains_element "${COMP_WORDS[COMP_CWORD-1]}" "${app_labels[@]}") -eq 1 ]]
	then
		echo -n "$app_labels"
		return 0;
	fi

	for i in $(ls ${COMP_WORDS[COMP_CWORD-1]}/migrations/*.py 2>/dev/null);
	do
		if [[ "$(basename ${i%.py})" == "__init__" ]];then continue;fi
		migrations+="$(basename ${i%.py}) "
	done
	echo -n "$migrations"
	return 0
}


djc_get_databases()
{
	#TODO: make a better regex/filter for both readability and portability
	# now:
	# - greps the lines between \sDATABASES\s=\s{ ans ^}
	# - greps the lines that go like: \s'name':\s (must be indented at least one space/tab)
	# - sed filters the actual name from the line and outputs it
	databases_list=$(grep -Poz "(?s)^(DATABASES\s=\s\{.*?^})" */settings.py | grep -Poz "\s+'(.*)':\s*{" | sed -rn "s/^\s*'(.*?)':\s*\{/\1/p");
	echo -n "$databases_list"
}

djc_add_help()
{
echo -n "${subcommands}";
return 0;

}
djc_add_createsuperuser()
{
local completions
echo -n "	--database $(djc_get_databases)
		--email ";

}
djc_add_changepassword()
{
local completions
completions="	--database $(djc_get_databases) i
		\$username ";

}
djc_add_check()
{
local completions
completions="	-t --tag
		--list-tags
		$(djc_get_app_labels) ";

}
djc_add_compilemessages()
{
local completions
completions="	--locale -l
		--exclude -x
		--use-fuzzy -f ";

}
djc_add_createcachetable()
{
local completions
completions="	--database $(djc_get_databases)
		\$table_name* ";

}
djc_add_dbshell()
{
local completions
completions=" 	--database $(djc_get_databases) ";

}
djc_add_diffsettings()
{
local completions
completions=" 	--all ";

}
djc_add_dumpdata()
{
local completions
completions="	--format
		--indent
		--database $(djc_get_databases)
		-e --exclude
		-n --natural
		--natural-foreign
		--natural-primary
		-a --all
		--pks
		-o --output
		$(djc_get_app_labels)+[.ModelName]* ";

}


djc_add_flush()
{
local completions
completions="	--database $(djc_get_databases)
		--no-initial-data
		--noinput ";

}


djc_add_inspectdb()
{
local completions
completions="	--database $(djc_get_databases) ";

}


djc_add_loaddata()
{
local completions
completions="	--database $(djc_get_databases)
		--app
		--ignorenonexistent -i
		$(djc_get_fixtures)";

}


djc_add_makemessages()
{
local completions
completions="	--locale -l
		--exclude -x
		--domain -d
		--all -a
		--extensions -e
		--symlinks -s
		--ignore -i
		--no-default-ignore
		--no-wrap
		--no-location
		--no-obsolete
		--keep-pot";

	if [[ "$(djc_contains_element "--exclude"  ${COMP_WORDS[@]})" == -* ]]
	then
		echo ""
	fi
}


djc_add_makemigrations()
{
echo -n "	--dry-run
		--merge
		--empty
		--noinput
		-n --name
		-e --exit
		$(djc_get_app_labels)";
}


djc_add_migrate()
{
echo -n "	--noinput
		--no-initial-data
		--database $(djc_get_databases)
		--fake
		--fake-initial
		--list -l
		$(djc_get_migration_names)";
}


# oh, the vast emptyness...
djc_add_runfcgi()
{
	echo -n ""
}


djc_add_shell()
{
local completions
completions="	--plain
		--no-startup
		-i --interface";

		if ! [[ "${COMP_WORDS[COMP_CWORD-1]}" == "-i" ]];
		then
			completions="ipython bpython"
		fi
	echo -n "$completions"
}

# still displays -p, -l all the time
# TODO: fix this
djc_add_showmigrations()
{
local completions
completions=""
completions="	--database $(djc_get_databases)
		$(djc_get_app_labels)";

	# because you can only use one of:
	#   --print or --list (or -p or -l)
	if  [[ $(djc_contains_element "--list" "${COMP_WORDS[@]}") == 0 ]] \
	&& [[ $(djc_contains_element "-l" "${COMP_WORDS[@]}") == 0 ]]\
	&& [[ $(djc_contains_element "--print" "${COMP_WORDS[@]}") == 0 ]]\
	&& [[ $(djc_contains_element "-p" "${COMP_WORDS[@]}") == 0 ]] ;
	then
		#completions+=" --list -l --print -p"
		completions+=""
	else
		completions+=" --list -l --print -p"
	fi

echo -n "$completions"
}


djc_add_sql()
{
echo -n "	--database $(djc_get_databases)
		$(djc_get_app_labels)";
}
djc_add_sqlall()
{
echo -n "	--database $(djc_get_databases)
		$(djc_get_app_labels)";
}
djc_add_sqlclear()
{
echo -n "	--database $(djc_get_databases)
		$(djc_get_app_labels)";
}
djc_add_sqlcustom()
{
echo -n "	--database $(djc_get_databases)
		$(djc_get_app_labels)";
}
djc_add_sqldropindexes()
{
echo -n "	--database $(djc_get_databases)
		$(djc_get_app_labels)";
}
djc_add_sqlflush()
{
echo -n "	--database $(djc_get_databases)";
}
djc_add_sqlindexes()
{
echo -n "	--database $(djc_get_databases)
		$(djc_get_app_labels)";
}
djc_add_sqlmigrate()
{
echo -n "	--database $(djc_get_databases)
		$(djc_get_app_labels)
		--backwards
		$(djc_get_migration_names)";
}
djc_add_sqlsequencereset()
{
echo -n "	--database $(djc_get_databases)
		$(djc_get_app_labels)";
}
djc_add_squashmigrations()
{
echo -n "	--database $(djc_get_databases)
		$(djc_get_migration_names)
		--no-optimize
		--noinput";
}
djc_add_startapp()
{
local completions
completions="	--template
		--extension -e
		--name -n";

	if [[ "$COMP_CWORD" -gt "2" ]]
	then
		if ! [[ "${COMP_WORDS[COMP_CWORD-1]}" == -* ]]
		then
			completions+="$(/bin/ls -d */ 2>/dev/null) "
		fi
	fi

	echo -n "$completions"
}




# if completing after the 'name'
#   (no option starting with - before it)
#   then suggest existing directories
djc_add_startproject()
{
	local completions
	completions="	--template
		--extension -e
		--name -n";
	if [[ "$COMP_CWORD" -gt "2" ]]
	then
		if ! [[ "${COMP_WORDS[COMP_CWORD-1]}" == -* ]]
		then
			completions+="$(/bin/ls -d */ 2>/dev/null) "
		fi
	fi

	echo -n "$completions"
}





djc_add_syncdb()
{
local completions
completions="	--noinput
		--database $(djc_get_databases)
		--no-initial-data";

}
djc_add_test()
{
local completions
completions=""
# top level
if [[ "${COMP_WORDS[COMP_CWORD-1]}" =~ ^--?t(op-level-directory)? ]]
then
	completions="$(djc_get_tags) "
else
completions="	--noinput
		--failfast
		--testrunner
		--liveserver
		-t --top-level-directory
		-p --pattern
		-k --keepdb
		-r --reverse
		-d --debug-sql
		$(djc_get_test_labels)";
fi
echo -n "$completions"
}
djc_add_testserver()
{
local completions
completions="	--noinput
		--addrport
		--ipv6 -6
		$(djc_get_fixtures)";

}
djc_add_validate()
{
local completions


# prev is -t or --tag
if [[ "${COMP_WORDS[COMP_CWORD-1]}" =~ ^--?ta?g? ]]
then
	completions="$(djc_get_tags) "
else
	completions="	--tag -t
			--list-tags
			--deploy
			$(djc_get_app_labels)";
fi

echo -n "$completions"
}
djc_add_clearsessions()
{
echo -n "";

}
djc_add_collectstatic()
{
echo -n "	--noinput
		--no-post-process
		-i --ignore
		-n --dry-run
		-c --clear
		-l --link
		--no-default-ignore";

}
djc_add_findstatic()
{
echo -n "	--first";

}
djc_add_runserver()
{
echo -n "	--ipv6 -6
		--nothreading
		--noreload
		--nostatic
		--insecure
		0.0.0.0";
}

# for a subcommand's flags and arguments
#   ./manage.py migrate poll[TAB] -> polls
#   ./manage.py migrate --no-colo[TAB] -> --no-color
djc_add_completion()
{
# filter on subcommand
#   call the djc_add_migrate / djc_add_check functions etc...
if [[ "$COMP_CWORD" -gt 1 ]];
then
	echo -n "$(djc_add_${COMP_WORDS[1]})";
	return 0;
fi

if [[ $COMP_CWORD -eq 1 ]];
then
	echo -n "${subcommands}"
fi

return 0;
}


# the main completion function
_djc_manage()
{
	local cur prev prevprev subcommands options verbosities completion
# Varibles

	# options that are availiable for all commands
	options="--version -h --help "

	# options that are common in all subcommands
	extra_opts="-v --verbosity --settings --pythonpath --traceback --no-color "

	# allowed values after -v or --verbosity
	verbosities="0 1 2 3"

	# commands that are availiable
	subcommands="createsuperuser changepassword check compilemessages createcachetable dbshell diffsettings dumpdata flush inspectdb loaddata makemessages makemigrations migrate runfcgi shell showmigrations sql sqlall sqlclear sqlcustom sqldropindexes sqlflush sqlindexes sqlmigrate sqlsequencereset squashmigrations startapp startproject syncdb test testserver validate clearsessions collectstatic findstatic runserver "

	# wipe previous completion
	COMPREPLY=()
	completion=""

	# current part (can be empy)
	cur="${COMP_WORDS[COMP_CWORD]}"
	# previous word
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	# previously previous word
	if [[ "$COMP_CWORD" -gt 1 ]];
	then
		prevprev="${COMP_WORDS[COMP_CWORD-2]}"
	else
		prevprev="_noprevprev_"
	fi

	# no './abc help help',
	# just './abc help [someth]'
	if [[ "${COMP_WORDS[1]}" != "help" ]];
	then
		subcommands+="help"
	# no completion after './abc help someth'
	elif [[ "$COMP_CWORD" -gt 2 ]];
	then
		return 0;
	fi

	# add common flags among all subcommands if it's not a subcommand that is being completed
	#   e.g. -h or --verbosity
	if [[ "${prev}" != "${COMP_WORDS[0]}" ]];
	then
		completion="${options} ${extra_opts} "
	fi

	# call the mean big completion function...
	completion+="$(djc_add_completion)"

	# generate the actual completion
	COMPREPLY=( $(compgen -W "${completion}" -- "${cur}"));
	return 0;
}



complete -F _djc_manage ./manage.py

