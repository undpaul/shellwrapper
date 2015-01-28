<?php

$script = new stdClass();
$script->arguments = $argv;

$script->SUBSHELL_COMMAND = 'bash -e';
$script->EXPORTSHELL_COMMAND = 'source';
$script->SUBSHELL_EXT = 'sh';
$script->EXPORTSHELL_EXT = 'exportsh';

// Exit if no first argument is given.
if (empty($argv[1])) {
  echo "The first argument is mandatory, as it is the directory to call the shell files from!!";
  exit(1);
}
// The first argument is the subfolder to work with.
$script->SHELL_FILES_DIR = $argv[1];

// Retrieving tags from second argument.
$script->TAGS = array();
if (isset($argv[2])) {
  $script->TAGS = explode(',', $argv[2]);
}
array_walk($script->TAGS, 'trim');

// We store directory values, so we can restore them later.
$script->CURRENT_PWD = getcwd();
// This is the location of this exact file.
$script->SCRIPT_FILE = __FILE__;
$script->SCRIPT_DIR = __DIR__;

// We navigate first to the script directory, so we can change to the parts dir
// either relative or absolute.
chdir($script->SCRIPT_DIR);
chdir($script->SHELL_FILES_DIR);

$script->SHELL_FILES_DIR_ABSOLUTE = getcwd();

// Logging starting time
echo 'Starting on ' . date('Y-m-d h:i:s') . "\n";


// We run through each file in the given PARTS_DIR and execute those that
// match the given tag or have no tag at all.
// Only some file types are executed:
// - *.sh: are implemented as subshell via calling sh -e
// - *.export: are implemented as source shells, that can set export variables
//   within the given call, that may be used within other parts
//
// As we use a wildcard, the for will return filenames in alphabetical order, as
// stated in man bash (topic "Pathname Expansion").
// We locate the parts dir as ., as we changed the dir, before this loop.

$it = new \RecursiveDirectoryIterator($script->SHELL_FILES_DIR_ABSOLUTE);
$files = new \RecursiveIteratorIterator($it, \RecursiveIteratorIterator::SELF_FIRST);
foreach ($files as $file) {
  echo "[ ] $file \n";

  $filename = basename($file);
  $pattern = '/^([\w]+)\.(([\w]+)\.)?(' . preg_quote($script->SUBSHELL_EXT) . '|' . preg_quote($script->EXPORTSHELL_EXT). ')$/';
  $matches = array();
  if (!preg_match($pattern, $filename, $matches)) {
    continue;
  }

  list( , $file_base, , $file_tag, $file_ext) = $matches;

  // Skip the file if the given tag does not match.
  if (!empty($file_tag) && !in_array($file_tag, $script->TAGS)) {
    continue;
  }

  if ($file_ext == $script->SUBSHELL_EXT) {
    echo "====================================================================\n";
    echo "SUBSHELL: $filename\n";
    echo "TIME: " . date('Y-m-d h:i:s') . "\n";
    echo "====================================================================\n";
    passthru("{$script->SUBSHELL_COMMAND} $file\n");
  }
  elseif ($file_ext == $script->EXPORTSHELL_EXT) {
    echo "====================================================================\n";
    echo "EXPORTSHELL: $filename\n";
    echo "TIME: " . date('Y-m-d h:i:s') . "\n";
    echo "====================================================================\n";
    passthru("{$script->EXPORTSHELL_COMMAND} $file\n");

    # As exportshells may navigate through the directories and also will change
    # that for the wrapper, we make sure we land back in our shell files
    # directory after calling the script.
    chdir($script->SHELL_FILES_DIR_ABSOLUTE);
  }
}

// Logging time of the completion.
echo "====================================================================\n";
echo 'Ending on ' . date('Y-m-d h:i:s') . "\n";

// change directory back to original location
chdir($script->CURRENT_PWD);