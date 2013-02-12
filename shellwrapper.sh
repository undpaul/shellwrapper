#!/bin/sh
################################################################################
# Shell wrapper to execute subshells and exportshells of a specified directory.
#
# Subshells are scripts with the extension ".sh" and will be called via the
# command "sh -e".
# Sub shells do not share variables with each other. To do that you have to
# implement a source shell.
#
# Export shells are scripts with the extension ".exportsh" and will be called
# with the source command. So they are handled as the would be called from the
# original script and so can register variables for the whole script by using
# the "export" command.
# So source shells can be used to set up some basic variables for the subshells.
#
# Arguments:
# 1: directory to load the source - the path must be absolute or relative to
#    this file's location
# 2: tag - a string that will be used to determine some scripts that only should
#    be called when that tag is given.
#    Files that end on .TAG.sh or .TAG.exportsh will be called in that case.
#    Otherwise those would not be called.
#    Multiple tags can be separated by comma "," (e.g. stage,search)
#
################################################################################

# We need to set a host domain, due to domain.module.
SHELL_FILES_DIR=${1}

# Exit if we did not get a first argument
if [[ "$SHELL_FILES_DIR" == "" ]]
then
  echo "The first argumented is mandatory, as it is the directory to call the shell files from!!"
  # @TODO: how to invoke an error?
  exit
fi

# Retrieving tag(s).
# -implement multiple tags
TAGS=$(echo "${2}" | tr "," "\n")


# We store directory values, so we can restore them later.
CURRENT_PWD=$(pwd)
# This is the location of this exact file.
SCRIPT_FILE="$CURRENT_PWD"/${0}
SCRIPT_DIR=$(dirname "$SCRIPT_FILE")
# We navigate first to the script directory, so we can change to the parts dir
# either relative or absolute.
cd "$SCRIPT_DIR"
cd "$SHELL_FILES_DIR"

# We add set -e, so the given scripts are all stopped whenever an error occured
# within a single execution
set -e

# Logging starting time
echo "Starting on $(date "+%Y-%m-%d %H:%M:%S")"

# We run through each file in the given PARTS_DIR and execute those that
# match the given tag or have no tag at all.
# Only some file types are executed:
# - *.sh: are implemented as subshell via calling sh -e
# - *.export: are implemented as source shells, that can set export variables
#   within the given call, that may be used within other parts
#
# As we use a wildcard, the for will return filenames in alphabetical order, as
# stated in man bash (topic "Pathname Expansion").
# We locate the parts dir as ., as we changed the dir, before this loop.
for FILE in ./*
do
  FILENAME=$(basename "$FILE")

  TAG_FOUND=0
  # We check first on the tag.
  for TAG in $TAGS
  do
    if [[ "$FILENAME" == *."$TAG".sh ]] || [[ "$FILENAME" == *."$TAG".exportsh ]]
    then
      TAG_FOUND=1
      break
    fi
  done

  # Execute sub shells (either with the specific tag or without any tag).
  if [[ "$FILENAME" == *.sh ]] && ( [[ $TAG_FOUND == 1 ]] || [[ "$FILENAME" != *.*.sh ]] )
  then
    echo "===================================================================="
    echo "SUBSHELL: $FILENAME"
    echo "TIME: $(date "+%Y-%m-%d %H:%M:%S")"
    echo "===================================================================="
    sh -e "$FILE";
  fi

  # Execute export shells (ending on .exportsh). Those scripts may provide
  # additional variables to the subshell calls by using the "export" command.
  if [[ "$FILENAME" == *.exportsh ]] && ( [[ $TAG_FOUND == 1 ]] || [[ "$FILENAME" != *.*.exportsh ]] )
  then
    echo "===================================================================="
    echo "EXPORTSHELL: $FILENAME"
    echo "TIME: $(date "+%Y-%m-%d %H:%M:%S")"
    echo "===================================================================="
    source "$FILE"
  fi

done

# Logging time of the completion.
echo "===================================================================="
echo "Ending on $(date "+%Y-%m-%d %H:%M:%S")"

# change directory back to original location
cd "$CURRENT_PWD"
