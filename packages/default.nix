# Reads the package lists in this folder for one system. The `pkg` command
# edits the lists.
{ lib, platform }:

let
  # One package per line, optionally followed by `linux` or `darwin` to
  # install it on that system only. `#` starts a comment.
  read =
    file:
    lib.pipe (builtins.readFile file) [
      (lib.splitString "\n")
      (map (line: builtins.head (lib.splitString "#" line)))
      (map (line: builtins.filter (word: builtins.isString word && word != "") (builtins.split "[[:space:]]+" line)))
      (builtins.filter (words: words != [ ]))
    ];

  forThisSystem =
    words:
    let
      only = builtins.elemAt words 1;
    in
    builtins.length words == 1
    || (only == "linux" && platform.isLinux)
    || (only == "darwin" && platform.isDarwin)
    || (
      only != "linux"
      && only != "darwin"
      && throw "packages: `${builtins.head words}` is followed by `${only}`, not `linux` or `darwin`"
    );

  names = file: map builtins.head (builtins.filter forThisSystem (read file));
in
{
  nix = names ./nix.txt;
  brews = names ./brews.txt;
  casks = names ./casks.txt;
}
